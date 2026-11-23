# Firmware OTA and rollback

`cubie-ota` updates **firmware only**: kernel `Image`, board device tree and
`/lib/modules`. The bootloader chain (`boot0`, TOC1 U-Boot package) is Radxa's
and is never rewritten by an update.

## Flow

1. `sudo apt update` runs the apt hook `/etc/apt/apt.conf.d/99cubie-ota`, which
   calls `cubie-ota check --apt`. It only prints; it never changes the system.
   The hook ends in `|| true`, so a failed check cannot fail `apt update`.
2. `sudo cubie-ota apply` reads `/releases/latest`, downloads `cubie-ota.json`
   then the bundle, and verifies the bundle's sha256 against the manifest. It
   unpacks into `/boot/ota/<version>/`, runs `tar --zstd -xf modules.tar.zst -C /`
   to install `lib/modules/<kver>`, then atomically rewrites
   `/boot/extlinux/extlinux.conf` with `timeout 0` and
   `root=PARTUUID=<rootfs>` (from `findmnt` + `blkid`, never `root=UUID=`).
   The previous slot stays on disk.
3. Reboot. `cubie-ota-boot.service` (pulled by `sysinit.target`) runs
   `cubie-ota boot-guard`, which increments the attempt counter for the
   pending slot.
4. After 90 s of uptime, `cubie-ota-confirm.timer` runs `cubie-ota confirm`;
   the new version is marked good, `/etc/cubie-a5e-release` is rewritten,
   the counter resets and slots beyond `keep_slots` (2) are pruned. The
   current and previous versions are protected from pruning.
5. If the counter exceeds `max_attempts` (3) without a confirm, `boot-guard`
   restores the previous slot and reboots into it.

Rollback is **userspace-only**. This board has no persistent U-Boot
environment, so there is no bootloader bootcount. A kernel that panics before
`init` cannot roll itself back.

## Commands

```
cubie-ota status        # installed version, slot, pending, attempts
cubie-ota check         # ask GitHub for the newest release (no change)
cubie-ota apply         # stage newest release, boot it on next reboot
cubie-ota apply --force # restage even when already on that version
cubie-ota confirm       # mark the booted slot good (also run by the timer)
cubie-ota rollback      # go back to the previous slot on next reboot
cubie-ota boot-guard    # internal: count attempts, roll back after max_attempts
```

Config: `/etc/cubie-ota.conf`. State: `/var/lib/cubie-ota/state.json`.
Installed version: `/etc/cubie-a5e-release`. Slots: `/boot/ota/<version>`.
Boot entry: `/boot/extlinux/extlinux.conf`.

### What `sudo apt update` shows

After the normal apt output, the hook prints one line:

```
cubie-ota: 1.2.0 available (installed 1.1.0)
cubie-ota: run 'sudo cubie-ota apply' to stage it, or reboot after apply
```

Other cases: `cubie-ota: up to date (1.1.0)`;
`cubie-ota: release <tag> has no cubie-ota.json`;
`cubie-ota: update check failed: <error>`. All are informational and
never change exit status of `apt update`.

## Release assets

Each `vX.Y.Z` release must carry:

| Asset | Contents |
|---|---|
| `cubie-a5e-firmware.tar.zst` | `./Image`, `./sun55i-a527-cubie-a5e.dtb`, `./modules.tar.zst` at top level; `modules.tar.zst` holds `lib/modules/<kver>` only |
| `cubie-ota.json` | manifest, fields below |

Manifest example (field names exactly as the CLI reads them):

```json
{
  "version": "1.1.0",
  "dtb": "sun55i-a527-cubie-a5e.dtb",
  "asset": "cubie-a5e-firmware.tar.zst",
  "sha256": "32ffd1bff48df073cdcbf0be35ca5cf9e14fdc342524a1514311f28202fd97ca"
}
```

`version` is the number without the `v`; `asset` is the bundle filename;
`sha256` is the sha256 of the bundle file itself. Checksum verification is
skipped if `sha256` is absent. Build both files on the WSL2 host with:

```
scripts/build/make-ota-bundle.sh <version> <rootfs-dir> <out-dir>
```

Arguments are absolute paths; `out-dir` is per-version, e.g.
`/home/akar/cubie-a5e-fw/output/v1.1.0`. The script refuses to overwrite an
existing bundle or manifest unless `--force` is passed, and prints the exact
`gh release upload` line to run.

## Publishing a release

1. Build the bundle on the WSL2 host (`make-ota-bundle.sh`). No build artefacts
   under `/mnt/c` or `/mnt/d`.
2. Tag and push. CI (`.github/workflows/release-build.yml`) runs checks on
   every push and, on a `v*.*.*` tag, creates the release and verifies
   `output/v<version>/cubie-ota.json`.

   ```sh
   git tag -a v1.1.0 -m "v1.1.0 (release)"
   git push origin v1.1.0
   ```

3. Upload binaries from the host, after CI has opened the release:

   ```sh
   gh release upload v1.1.0 --clobber \
     /home/akar/cubie-a5e-fw/output/cubie-a5e-lite-arm64.img.gz \
     /home/akar/cubie-a5e-fw/output/cubie-a5e-lite-arm64.img.gz.sha256 \
     /home/akar/cubie-a5e-fw/output/v1.1.0/cubie-a5e-firmware.tar.zst \
     /home/akar/cubie-a5e-fw/output/v1.1.0/cubie-ota.json
   ```

   Paths are the defaults; substitute the real `out-dir` if you staged the
   bundle elsewhere. GitHub caps one release asset at **2 GB**, so the 4 GiB
   `.img` is never attached — only the compressed `.img.gz` (about 933 MB),
   its `.sha256`, the bundle and the manifest. CI cannot carry the binaries:
   they are built on the host and are too large for git.

`cubie-ota check` reads `/releases/latest`, so the release that carries
`cubie-ota.json` must be the newest non-draft, non-prerelease release.

## Failure modes

| Situation | CLI behaviour |
|---|---|
| No network | `check --apt` prints `cubie-ota: update check failed: <error>` and exits 0; `apt update` continues. `apply` aborts on the unhandled network exception before changing state. |
| Manifest missing | `check` prints `cubie-ota: release <tag> has no cubie-ota.json`. `apply` prints `cubie-ota: release <tag> missing cubie-a5e-firmware.tar.zst or cubie-ota.json` and exits 1. No change. |
| Checksum mismatch | `apply` prints `cubie-ota: checksum mismatch` with expected/actual sha256 and exits 1 before staging. Downloads live in a temporary directory and are removed. No change. |
| Slot full | No explicit capacity check. `apply` extracts into `/boot/ota/<version>`; an out-of-space `/boot` makes extraction fail and state is not saved. A partial slot may remain — verify on board. Old slots are pruned only on confirm. |
| Previous slot missing | `rollback` prints `cubie-ota: no previous slot to roll back to` and exits 1. `boot-guard` falls back to the installed version slot; if that slot is also gone, the written boot entry may have no files — verify on board. |

## Limits

- Only firmware is versioned. Userspace packages update through `apt` as usual.
- Slots live on the microSD root filesystem; there is no eMMC or NVMe slot.
- `extlinux.conf` is always written with `timeout 0` and `root=PARTUUID=<rootfs>`.
  `root=UUID=` would need an initrd the default label does not load.
- Confirmation is one-shot per boot (`OnBootSec=90`, `Persistent=false`); the
  board has no RTC, so the timer is monotonic and never catches up after boot.
