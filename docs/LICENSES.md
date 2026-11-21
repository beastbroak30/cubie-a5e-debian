# Licenses of everything shipped

Checked against the actual files in the build tree and the image, not from memory.
Date: 2026-11-21.

## Components

| Component | Where | License | Evidence |
|---|---|---|---|
| This repository's scripts (`scripts/`, `tools/` glue) | repo | MIT | `LICENSE`; no third-party copyright headers found in any `.sh`/`.ps1`/`.py` |
| Documentation (`docs/`, `README.md`) | repo | CC BY 4.0 | derived from Radxa docs, which are CC BY 4.0 |
| Linux kernel 5.15.147 | image `/boot/Image` | **GPL-2.0 WITH Linux-syscall-note** | `src/linux-aw2501/src/COPYING`; files carry `SPDX-License-Identifier: GPL-2.0-only` |
| Kernel packaging | build only | GPL-3+ | `src/linux-aw2501/debian/copyright` — packaging metadata, not the kernel |
| U-Boot | image `boot_package.fex` | **GPL-2.0+** (upstream) | upstream U-Boot; Radxa's packaging repo says GPL-3 in `debian/copyright` |
| ARM Trusted Firmware / ATF | image `boot_package.fex` | BSD-3-Clause | upstream TF-A |
| Allwinner `boot0` (eGON.BT0) | image `boot_package.fex` | **no public license grant** | binary blob; shipped by Radxa inside their official image |
| AIC8800 driver (bsp / fdrv / btlpm modules) | image `/lib/modules/5.15.147+` | GPL-2 (Radxa declaration) | `aic8800-firmware` packaging: `src/* GPL-2`; `MODULE_LICENSE("GPL")` in the source |
| AIC8800D80 firmware blobs (15 files) | image `/lib/firmware/aic8800d80` | **GPL-3+** (Radxa declaration) | `aic8800-firmware` `debian/copyright`: `Files: * License: GPL-3+` |
| `bt_test` binary | `tools/bin/bt_test` | **GPL-3+** | `aicrf-test` package `debian/copyright` |
| bluez / `hciattach` | image, installed by apt | GPL-2.0 | `/usr/share/doc/bluez/copyright` |
| Other Debian packages | image | per package | each `/usr/share/doc/<pkg>/copyright` ships in the image; 17 texts in `/usr/share/common-licenses` |
| balenaEtcher installer | `output/` | Apache-2.0 | upstream; redistributed unmodified, not in git |
| Radxa docs (pin map source) | reference | CC BY 4.0 | https://docs.radxa.com/en/cubie/a5e/hardware-use/pin-gpio |

## Obligations that follow

1. **Kernel + modules (GPL-2)**: shipping the binary requires source availability. Satisfied
   by building from `github.com/radxa-pkg/linux-aw2501` with `scripts/build/`, plus a
   written offer in the README. Must keep doing this for every published image.
2. **AIC8800 firmware (GPL-3+ per Radxa)**: the image ships 15 blobs but **no license text
   or attribution**. Gap — fix by installing `/usr/share/doc/aic8800-firmware/copyright`
   (copied from Radxa's package) next to the blobs.
3. **`bt_test` (GPL-3+)**: redistributed inside this repo with no GPL-3 text. Gap — add
   `LICENSES/GPL-3.0-or-later.txt` and a `tools/bin/NOTICE`, or drop the binary (the
   working BT unit does not use it; plain `hciattach` is enough).
4. **`boot0` + ATF**: no license grant for the Allwinner part. It is redistributed inside
   Radxa's official media, but a public release that contains it may exceed what Radxa
   granted. Safer: publish the image only on request, or point users at Radxa's release and
   document that the boot area comes from them unchanged.
5. **Radxa docs (CC BY 4.0)**: attribution must name the author. `docs/cubie-a5e-pinmap.json`
   cites the URL; add "Radxa Computer (Shenzhen) Co., Ltd" to the JSON and to
   `docs/RPI-COMPAT-PLAN.md`.
6. **Debian packages**: nothing to do — `/usr/share/doc/*/copyright` travels with the image.

## Note on Radxa's own declarations

Two of Radxa's repos label everything `GPL-3+` (`linux-aw2501`, `u-boot-aw2501`), while the
code they contain is GPL-2.0 (kernel) and GPL-2.0+ (U-Boot). The stricter, factual license of
the code itself is used in this table. Anyone redistributing should quote the upstream
license, and may also satisfy the GPL-3 terms to be safe.

The AIC8800 BSP driver has 113 `.c` files and only 6 carry a license header; the rest rely on
`MODULE_LICENSE("GPL")`. That is Radxa's/AICSemi's file, not something this project can
correct, but it means the driver's GPL-2 status is by declaration rather than per-file text.
