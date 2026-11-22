# Firmware OTA and rollback

`cubie-ota` updates **firmware only**: kernel `Image`, board device tree and
`/lib/modules`. The bootloader chain (`boot0`, TOC1 U-Boot package) is Radxa's
and is never rewritten by an update.

## Flow

1. `sudo apt update` runs the apt hook `/etc/apt/apt.conf.d/99cubie-ota`, which
   calls `cubie-ota check --apt`. It only prints; it never changes the system.
2. `sudo cubie-ota apply` downloads the release bundle for the newest GitHub
   tag, verifies the sha256 from `cubie-ota.json`, unpacks it to
   `/boot/ota/<version>/`, installs its modules and points
   `/boot/extlinux/extlinux.conf` at that slot.
3. Reboot. `cubie-ota-boot.service` runs `cubie-ota boot-guard` and increments
   the attempt counter.
4. After 90 s of uptime, `cubie-ota-confirm.timer` runs `cubie-ota confirm`;
   the new version is marked good, the counter resets and old slots beyond
   `keep_slots` are pruned.
5. If the counter exceeds `max_attempts` (3) without a confirm, `boot-guard`
   restores the previous slot and reboots into it.

The previous slot is kept until a successful confirm, so a failed boot always
has somewhere to go back to.

## Commands

```
cubie-ota status        # installed version, slot, pending, attempts
cubie-ota check         # ask GitHub for the newest release (no change)
cubie-ota apply         # stage newest release, boot it on next reboot
cubie-ota confirm       # mark the booted slot good (also run by the timer)
cubie-ota rollback      # go back to the previous slot on next reboot
```

Config: `/etc/cubie-ota.conf`. State: `/var/lib/cubie-ota/state.json`.
Installed version: `/etc/cubie-a5e-release`.

## Release assets

Each `vX.Y.Z` release must carry:

| Asset | Contents |
|---|---|
| `cubie-a5e-firmware.tar.zst` | `Image`, `sun55i-a527-cubie-a5e.dtb`, `modules.tar.zst` |
| `cubie-ota.json` | `{version, dtb, asset, sha256}` |

Build them on the host with
`scripts/build/make-ota-bundle.sh <version> <rootfs-dir> <out-dir>` and publish the tag.

## Publishing a release

The CI workflow (`.github/workflows/release-build.yml`) runs the checks on every
push and, on a `v*.*.*` tag, creates the release and verifies
`output/v<version>/cubie-ota.json`. It cannot carry the binaries: they are built
on the WSL2 host and are too large for git (GitHub also caps one release asset
at 2 GB, so the 4 GiB `.img` is never attached, only the `.img.gz`).

```sh
git tag -a v1.1.0 -m "v1.1.0 (release)"
git push origin v1.1.0

gh release upload v1.1.0 --clobber \
  output/cubie-a5e-lite-arm64.img.gz \
  output/cubie-a5e-lite-arm64.img.gz.sha256 \
  output/v1.1.0/cubie-a5e-firmware.tar.zst \
  output/v1.1.0/cubie-ota.json
```

`cubie-ota check` reads `/releases/latest`, so the release that carries
`cubie-ota.json` must be the newest non-draft, non-prerelease release.

## Limits

- Rollback is userspace-driven. A kernel that panics before `init` cannot roll
  itself back: this board exposes no persistent U-Boot environment, so there is
  no bootloader bootcount.
- Only firmware is versioned. Userspace packages update through `apt` as usual.
- Slots live on the microSD root filesystem; there is no eMMC or NVMe slot.
- `extlinux.conf` is always written with `timeout 0` and `root=PARTUUID=<rootfs>`.
  `root=UUID=` would need an initrd the default label does not load.
