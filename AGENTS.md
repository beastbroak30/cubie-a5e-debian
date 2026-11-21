# AGENTS.md — Radxa Cubie A5E minimal Debian Bookworm (arm64) firmware

Canonical location: `/home/akar/cubie-a5e-fw/AGENTS.md` (native WSL2 ext4).
A read-only mirror lives at `D:\misc_prj\radxa_firmware\AGENTS.md` for the Windows side.
If the two differ, the WSL2 copy wins. Update both together.

This file is the rulebook and the shared state document. Every agent reads it before
acting and appends to the build-state checklist when a phase changes.

---

## 1. Target hardware profile

| Item | Value |
|---|---|
| Board | Radxa Cubie A5E |
| SoC | Allwinner A527 (arm64, Cortex-A55 cluster) |
| RAM | 1 GiB LPDDR |
| Storage | microSD only, 128 GB card, **no eMMC on board** |
| Networking | 2x Gigabit Ethernet (dual GbE), onboard Wi-Fi, onboard BLE |
| USB | USB-C OTG (gadget capable), USB host ports |
| Debug | GPIO UART header (3.3 V TTL) |
| Console LED / buttons | per Radxa docs; do not invent GPIO numbers |

Board must boot with the microSD alone: boot0 → U-Boot (TOC1/Allwinner boot package) →
`extlinux`/`boot.scr` → kernel `Image` + `.dtb` → rootfs on partition 2 (or 1).

## 2. Driver & BSP sourcing rule (hard rule)

We build the **OS image** from scratch. We do **not** write kernel drivers, do not
mainline patches, and do not invent device trees.

Allowed and required sources, in priority order:

1. `github.com/radxa` — kernel tree, U-Boot tree, `linux-radxa-*`, DT sources, board dts.
2. `github.com/radxa-pkg` — packaged kernel/U-Boot/firmware/bsp `.deb` artifacts.
3. `github.com/RadxaOS-SDK` — build scripts (`radxa-build` / `rsdk`) used as reference.
4. `apt.radxa.com` — official binary packages: kernel, U-Boot, `rsetup`, overlays,
   `firmware-misc-nonfree`, wireless/BLE blobs.
5. Allwinner official BSP / `linux-sunxi` community — only when Radxa does not publish
   the needed blob, and never for driver development.

Every artifact we ship must be traceable to a URL plus branch/tag/version. Record those
URLs in section 8 (`Source registry`). If a URL is unverified, mark it `UNVERIFIED` and
do not build on it.

Never guess:
- A527 `boot0` / U-Boot raw sector offsets,
- `u-boot` defconfig or board dts filename,
- Wi-Fi/BLE chip part number or firmware blob name.

Verify each from Radxa docs/repos before use.

## 3. WSL2 host constraints (mandatory)

- **No build artifacts under `/mnt/c/` or `/mnt/d/`.** Those are 9p/v9fs. Everything
  (sources, chroot, rootfs, images) stays under `/home/akar/cubie-a5e-fw` or `/tmp`
  on `/dev/sdd` (ext4).
- Allowed Windows interaction: small text/script handoff files under
  `C:\Users\akant\AppData\Local\Temp\opencode\`, and the final `.img` copy out.
- Host has **7.5 GiB RAM, 2 GiB swap, 14 cores, 928 GB free**. Treat 4 GiB as the
  practical compile ceiling: use `make -j8` maximum for kernel builds, never `-j14`
  with a full rootfs chroot in memory.
- Loop devices: always `losetup -fP --show`, record the path, and detach in the same
  script. Every build script that uses a loop device must use `trap` to detach on exit.
- `qemu-user-static` + binfmt must be registered before any `arm64` chroot command.
  Unregister nothing; a stale binfmt entry is fine, a missing one breaks the build.
- Never `rm -rf` a path built from an unset variable. Scripts use `set -euo pipefail`.
- SD card is `/dev/sdX` inside WSL only after `usbipd attach`. Flashing requires explicit
  user approval and a printed `lsblk` confirmation first.

## 4. Architecture and firmware goals

- Pure from-scratch **Debian Bookworm arm64**, CLI only, headless, no X/Wayland.
- `debootstrap` rootfs, Debian archive + Radxa apt repo for board packages.
- Working `sudo apt update && sudo apt install` on the board (needs correct
  `/etc/apt/sources.list` for bookworm arm64 + Radxa keyring).
- ZRAM swap at **50% of RAM** (zram-tools or systemd-zram-generator), no disk swap.
- `/tmp` on `tmpfs`.
- USB OTG gadget: `g_ether` (RNDIS/NCM) with static `10.55.0.1/24`, plus serial gadget
  `ttyGS0`, plus hardware UART `ttyS0` console.
- Wi-Fi via `NetworkManager`; BLE via `bluez`; Ethernet via systemd-networkd/DHCP.
- SSH server enabled, key or password per user answer.
- First boot: auto-expand the rootfs partition to fill the 128 GB card
  (`resize2fs` + `parted`/`growpart`), then self-disable.
- Boot chain and offsets must mirror Radxa's official image layout for this board.

## 5. Build layout

```
/home/akar/cubie-a5e-fw/
├── AGENTS.md              this file (rules + state)
├── src/                   cloned official repositories (kernel, u-boot, SDK refs)
├── cache/                 downloaded .deb, firmware blobs, tarballs
├── rootfs/                debootstrapped arm64 Bookworm rootfs
├── boot/                  staged kernel Image, dtb, extlinux files, boot0/ATF blobs
├── scripts/               build scripts (numbered, idempotent, trap-cleaned)
├── output/                final cubie-a5e-lite-arm64.img + sha256
└── logs/                  one log per build step
```

## 6. Sub-agent coordination

| Agent | Write scope | Never touches |
|---|---|---|
| Orchestrator (main) | `AGENTS.md`, `scripts/`, `output/`, final assemble | — |
| BSP/Driver Scout | `AGENTS.md` §8, `cache/urls/` | rootfs, kernel build dirs |
| Host Tools + Bootloader/Kernel | `src/`, `boot/`, `scripts/1x-*` | `rootfs/` |
| RootFS Builder | `rootfs/`, `scripts/2x-*` | `boot/`, `src/` |

Rules:
- One agent writes a given path at a time. Announce before writing an existing file.
- Long commands write to `logs/<step>.log`; report only the tail plus exit status.
- Facts discovered online go into §8 with URL + branch, before any build uses them.
- If two agents disagree on an offset, filename, or package name: stop, verify from the
  official source, and record the verified value. Never pick the plausible one.
- Irreversible actions (flashing a block device, `mkfs`, `dd` to `/dev/sdX`) require
  explicit user approval. Never flash from an automated sub-agent.

## 7. Build state checklist

Mark `[x]` only after the artifact exists and was verified.

- [x] Phase 0 — Host environment surveyed (WSL2 Ubuntu 24.04, ext4, 14 cores, 7.5 GiB RAM, 928 GB free)
- [x] Phase 1 — `AGENTS.md` created
- [x] Phase 2 — Clarifying answers received from user
- [x] Phase 3 — Official sources resolved and recorded in §8 (U-Boot, kernel, dtb, blobs, offsets)
- [x] Phase 4 — Host build packages installed (debootstrap 1.0.134, gcc-aarch64 13.3.0, dtc 1.7.0, mkimage 2025.10, debuild, qemu-aarch64 binfmt present)
- [x] Phase 5 — U-Boot + boot0/ATF artifacts staged in `boot/`
- [x] Phase 6 — Kernel `Image`, `.dtb`, modules staged in `boot/` and `rootfs/lib/modules`
- [x] Phase 7 — arm64 Bookworm rootfs debootstrapped
- [x] Phase 8 — Users, hostname, apt, SSH, ZRAM, tmpfs, networking, OTG gadget configured
- [x] Phase 9 — First-boot partition expand service installed
- [x] Phase 10 — Image assembled at verified offsets, `sha256` written
- [x] Phase 11 — Loop devices detached, image checked (mount + chroot smoke test)
- [x] Phase 12a — SD card flashed with user approval (balenaEtcher 2.1.9, image sha256
  `0759fa97bd9aa145a7c4ab7713bae41226025abb66a0a3bad84e42802ed77a44`); Etcher validate passed,
  three GPT partitions at 16777216 / 33554432 / 348127232, boot0 + TOC1 verified on card
- [x] Phase 12b — Board booted on the card. Verified 2026-11-21: login on `ttyGS0` (COM5),
  SSH over `usb0`, `/tmp` tmpfs, zram swap active, Wi-Fi joined `akar`, clock via NTP,
  rootfs expanded to 118 GB, BLE `hci0` up (`A8:B5:8E:0D:73:B8`, HCI over UART `ttyAS1`).
  Still **unverified**: `eth0`/`eth1` (no cable attached — both `NO-CARRIER`, MACs
  `08:ef:6c:a9:84:88` / `:89` present).
  Rootfs auto-expand needed `cloud-guest-utils` (`growpart`) — that package is now in the image
  and the service deletes itself only after `resize2fs`.

## 8. Source registry (fill with verified URLs only)

Platform codename for this SoC family is **aw2501** (A527/T527). Radxa's kernel and
U-Boot are published as Debian packaging repos, built with `make deb`.

| Artifact | Source URL | Branch/Tag | Verified |
|---|---|---|---|
| Board overview | https://docs.radxa.com/en/cubie/a5e | — | yes (fetched) |
| Low-level dev docs | https://docs.radxa.com/en/cubie/a5e/low-level-dev/build-system | — | yes (fetched) |
| Env setup doc | https://docs.radxa.com/en/cubie/a5e/low-level-dev/build-system/install-env | — | yes (fetched) |
| U-Boot doc | https://docs.radxa.com/en/cubie/a5e/low-level-dev/build-system/u-boot | — | yes (fetched) |
| Kernel doc | https://docs.radxa.com/en/cubie/a5e/low-level-dev/build-system/kernel | — | yes (fetched) |
| Radxa OS doc | https://docs.radxa.com/en/cubie/a5e/low-level-dev/build-system/radxa-os | — | yes (fetched) |
| U-Boot packaging repo | https://github.com/radxa-pkg/u-boot-aw2501.git | `main` | yes (API 200, Debian pkg, `make deb`) |
| Kernel packaging repo | https://github.com/radxa-pkg/linux-aw2501.git | `main` | yes (API 200, Debian pkg, `make deb`) |
| RadxaOS SDK | https://github.com/RadxaOS-SDK/rsdk.git | `main` | documented by Radxa |
| Reference image | https://github.com/radxa-build/radxa-cubie-a5e/releases/download/rsdk-r7/radxa-cubie-a5e_bullseye_cli_r7.output_512.img.xz | `rsdk-r7` | URL from Radxa docs (`_512` = 512 B sector layout) |
| Radxa apt repo (bullseye) | http://apt.radxa.com/bullseye-stable/ | — | NOT yet verified |
| Radxa apt repo (bookworm) | https://apt.radxa.com/bookworm-stable/dists/bookworm/main/binary-arm64/Packages.gz | — | **404 — does not exist** |
| Kernel config patch | `debian/patches/linux/0001-feat-Radxa-common-kernel-config.patch` | in linux-aw2501 | documented |
| boot0 / ATF blobs | Sector 256 (eGON.BT0) / Sector 24576 (TOC1 sunxi-package) | `ref.img` binary hexdump + `u-boot_setup-allwinner.sh` | yes (extracted) |
| board `.dts` name | `sun55i-a527-cubie-a5e.dtb` | `ref.img` `/usr/lib/linux-image-*/allwinner/` | yes (extracted) |
| Wi-Fi/BLE chip | **AIC8800D80 (SDIO)** — `SDIO_ID=C8A1:0082`, driver `aic8800_bsp` + `aic8800_fdrv` (BSP tree), `CONFIG_AIC8800_SDIO=y`, `CONFIG_AIC_FW_PATH="/lib/firmware/aic8800d80"` | board `/sys/bus/sdio` + `dmesg` (`aicwf_sdio_chipmatch USE AIC8800D80`) | yes (verified on board) |
| Wi-Fi/BLE firmware blobs | **AIC8800D80** — 15 files (`fmacfw_8800d80_u02.bin`, `fw_patch_8800d80_u02.bin`, `fw_patch_table_8800d80_u02.bin`, `lmacfw_rf_8800d80_u02.bin`, `fmacfwbt_8800d80_u02.bin`, …) | `ref.img` `/lib/firmware/aic8800_fw/SDIO/aic8800D80/` → installed to `/lib/firmware/aic8800d80/` | yes (installed, Wi-Fi associated) |
| Wi-Fi/BLE firmware (superseded) | RTL8852BS / RTL8852BU (`rtw8852b_fw.bin`, `rtl8852bs_fw.bin`) | `ref.img` `/lib/firmware/rtw89/` | **not the fitted chip** — ref image ships both; board SDIO ID proves AIC8800D80 |
| SD sector offsets | GPT; boot0@256, TOC1@24576, P1 FAT16 `config` @32768, P2 FAT16 `efi` @65536, P3 ext4 `rootfs` @679936 | `ref.img` `sfdisk -d` | yes (extracted) |
| extlinux vs boot.scr | `extlinux/extlinux.conf` | `ref.img` `/boot/extlinux/extlinux.conf` | yes (extracted) |

Authoritative hardware facts from docs (not guessed):

- Debug UART0 is on 40-pin header pins 8/10 (per Radxa/CNX board description).
  Verified direction from Radxa 40-pin GPIO table (`hardware-use/pin-gpio`): pin 8 = PB9
  `UART0-TX`, pin 10 = PB10 `UART0-RX`, GND = pin 6/9. Adapter RX → pin 8, adapter TX → pin 10,
  115200 8N1, no flow control, adapter at 3.3 V logic, VCC not connected.
- Board has onboard SPI flash for the bootloader, so microSD boot also needs a valid
  boot0 + U-Boot on the card unless SPI flash is already programmed.
- Boot priority: microSD > NVMe > onboard eMMC.
- Wi-Fi 6 + Bluetooth 5.4 radio with external antenna connector; **chip verified: AIC8800D80**
  (SDIO `C8A1:0082`, MAC `a8:b5:8e:0d:73:b7`). `CONFIG_RTL8852BS` is not set — do not chase
  Realtek firmware. `nmcli` reports `WIFI-HW` from the vendor driver only after
  `aic8800_bsp` + `aic8800_fdrv` both load, which needs `/lib/firmware/aic8800d80/` populated.
- USB-C is USB 2.0 OTG + 5 V power input; only one USB 3.0 Type-A host port.
- Build tooling Radxa uses: Docker + Dev Container, `make deb` for kernel/U-Boot,
  `rsdk` TUI for full OS images.

## 9. User decisions (record answers here when received)

- Wi-Fi credentials pre-baked: **Yes, changed 2026-11-21.** User asked the board to join SSID
  `akar` (WPA2-PSK). Profile stored at
  `/etc/NetworkManager/system-connections/akar.nmconnection`, mode 600.
- Debug console: **Both.** USB-C OTG gadget console (`ttyGS0` → Windows COM5, verified working)
  **and** GPIO UART0 (`ttyAS0`, pins 8/10, 115200 8N1). UART needs a CP2102-class adapter;
  the user has none, so `ttyGS0` is the practical console.
- USB gadget protocol: **CDC-NCM + CDC-ACM** via configfs (`/usr/local/sbin/usb-gadget-init.sh`,
  `usb-gadget.service` in `sysinit.target.wants`). RNDIS was abandoned: Windows 11 24H2
  (build 26100) gives `Code 28` for the legacy `g_ether`/ECM descriptors. NCM binds to the
  in-box `UsbNcm.sys` and works with no driver install.
- Board-side network on `usb0`: `10.55.0.1/24`, `Gateway=10.55.0.2`, `DNS=1.1.1.1`,
  `DHCPServer=yes` (systemd-networkd, `20-usb0.network`). NetworkManager keeps `usb0`
  unmanaged (`/etc/NetworkManager/conf.d/10-usb-gadget.conf`). Never add
  `/etc/network/interfaces.d/usb0` — ifupdown fights networkd (`File exists`).
- Extra CLI tools: **git, build-essential, python3, python3-pip, python3-venv, python3-dev.**
- Identity: username `radxa`, password `radxa`, hostname `cubie-a5e`.
- Kernel delivery route: **Build from source.** Bookworm rootfs; kernel and U-Boot built
  from `radxa-pkg/linux-aw2501` and `radxa-pkg/u-boot-aw2501` on the host. The official
  Bullseye R7 image is used only as a layout/offset reference.
- Distribution: **Debian 12 Bookworm confirmed by user.** Bullseye rejected because it
  is past end of LTS security support (2026-08-31) and the bookworm apt repo 404s.

## 10. Verification gates

1. `.dtb` must be present for the Cubie A5E board name and must describe dual GbE.
2. `Image` must boot under QEMU `virt` only as a smoke test; real validation on board.
3. Rootfs chroot must succeed with `qemu-aarch64-static` before image assembly.
4. Image offsets: `boot0` at its documented sector, U-Boot package at its documented
   sector, first partition start matching Radxa layout. Compare with a Radxa reference
   image's `sfdisk -d` / `fdisk -l` output when one is downloadable.
5. `losetup -a` must be empty after every build phase.

## 11. Verified on-board access (2026-11-21)

Board identity: `radxa@cubie-a5e`, password `radxa`, kernel `5.15.147+ #1 SMP PREEMPT`.

| Path | How |
|---|---|
| Serial console | Windows `COM5`, 115200 8N1, DTR+RTS asserted. Login prompt `cubie-a5e login:` |
| SSH (recommended) | `ssh -i C:\Users\akant\.ssh\cubie_a5e radxa@10.55.0.1` — key already in `/home/radxa/.ssh/authorized_keys` |
| Wi-Fi | `wlan0` joined `akar`, DHCP lease `10.131.147.34/24`, route via `10.131.147.171` |
| USB link | `usb0` `10.55.0.1/24` on board, `10.55.0.2/24` static on Windows adapter `Ethernet 5` |

Windows host side (needs elevation, run once per boot-setup change):

```
Set-NetIPInterface -InterfaceAlias 'Ethernet 5' -Dhcp Disabled
New-NetIPAddress -InterfaceAlias 'Ethernet 5' -IPAddress 10.55.0.2 -PrefixLength 24
Set-NetIPInterface -InterfaceAlias 'Ethernet 5' -Forwarding Enabled
New-NetNat -Name 'CubieUSB' -InternalIPInterfaceAddressPrefix '10.55.0.0/24'
```

`New-NetNat` steals `10.55.0.0/24` from the WSL NAT: after enabling it, WSL can no longer
reach `10.55.0.1`. Use the Windows OpenSSH client for board access, not WSL.

Known state quirks:
- Board clock has no RTC; without NTP it boots months behind and `apt` rejects Release files.
  `systemd-timesyncd` is installed and enabled — keep it.
- `zramswap` sizing: Debian's `/usr/sbin/zramswap` reads **`PERCENT`**, not `PERCENTAGE`.
  With `PERCENTAGE=50` it silently fell back to the `SIZE=256` MiB default. Master image now
  sets `PERCENT=50` → 480 MB swap on 937 MB RAM.
- AIC8800D80 Bluetooth: HCI rides the board UART, not SDIO.
  `/usr/local/sbin/aic8800-bt-up.sh` loads `aic8800_btlpm`, clears the `bluetooth` rfkill
  soft block, then runs `hciattach -s 1500000 /dev/ttyAS1 any 1500000 flow nosleep`
  (`aic8800-bt.service`, `Type=forking`). The rsetup `__aic8800_reset` / `bt_test` step in
  the reference image is **not** required — it hangs and only delays the attach.
  Verified: `hci0` up, BD address `A8:B5:8E:0D:73:B8`, `bluetooth.service` active.
- `eth0`/`eth1` show `NO-CARRIER` until a cable is plugged; driver, MACs and systemd-networkd
  DHCP config are in place, so this is a cable check, not a software check.

## 12. Repository, backups, and the RPi-compatibility track

Repo root (working copy): `D:\misc_prj\radxa_firmware` — git initialized 2026-11-21,
initial commit `32de470`, 368 tracked files, ~1 MB. Build outputs, dumps and installers
are git-ignored; the image ships as a release artifact, not as a commit.

Suggested publishable names, in order:

1. **`cubie-a5e-debian`** — recommended: names the OS work, leaves room for the RPi layer.
2. `cubie-a5e-pihat` — if the repo ever narrows to GPIO/HAT compatibility only.
3. `rpi-compat-cubie-a5e` — discovery-friendly for people searching RPi-compatible SBCs.

Description line for the repo/forum post: "Debian 12 for the Radxa Cubie A5E, built from
Radxa's BSP, plus a Raspberry Pi compatibility layer: verified 40-pin pin map, libgpiod,
gpiozero, RPi.GPIO shim, overlay-driven I2C/SPI/UART/PWM."

Layout (moved out of `%TEMP%\opencode` on 2026-11-21, provenance in `docs/MOVE-LOG.txt`):

```
docs/               pin map JSON, RPi plan, reference image layout, board manifest
scripts/build/      numbered image build steps (67 files)
scripts/board/      board-side scripts (119 files)
scripts/windows/    host-side PowerShell helpers (138 files)
scripts/misc/       probes and analysis output (45 files)
logs/               captured run output (37 files)
tools/              AIC8800D80 firmware (15 blobs), bt_test
backups/            rootfs dumps + image archive
output/             image, checksum, Etcher installer
```

Backups taken 2026-11-21 before any further work:

| Artifact | SHA256 |
|---|---|
| `output/cubie-a5e-lite-arm64.img` (as booted) | `eee1d63ad59bd231df9e5e0f62e8f81de46ab8f3a77872a1672f726cfcfc9942` |
| `backups/cubie-a5e-lite-arm64-2026-11-21.img.gz` (792 MB) | `7385b001d407913f196455eabfc8c7c208ea04c0a84f3d3ac971c7b27697c9f1` |
| `output/cubie-a5e-lite-arm64.img` (after license + attribution patch) | `dc0424cd067fad67aed17e97a4071d3b9397a87472115c3943277c310b90a6df` |

Author of record: **beastbroak30** — kernel and firmware development. Credit is inside the
image (`/usr/share/doc/cubie-a5e-debian/AUTHORS` and `NOTICE`), in `README.md` and in
`LICENSE`. The license audit and third-party obligations are tracked in
`docs/LICENSES.md`; kernel/U-Boot/firmware source offer is in `README.md`.

RPi-compatibility plan lives in `docs/RPI-COMPAT-PLAN.md`. Its binding rule: map by
**physical header pin** only. The A527 has no BCM numbering, and the
`num + 32 * bank` formula in `docs/cubie-a5e-pinmap.json` is verified against the running
kernel (`PIN_3`, `PIN_5`, `PIN_15`, `PIN_22` line names), never inferred.
