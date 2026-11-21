# cubie-a5e-debian

Debian 12 (Bookworm) arm64 for the **Radxa Cubie A5E** (Allwinner A527), built from
scratch, plus a compatibility layer that makes the board behave like a Raspberry Pi
development board: 40-pin GPIO, libgpiod, `gpiozero`, an `RPi.GPIO` shim, and
overlay-driven buses (I2C / SPI / UART / PWM).

Everything is traceable to an official Radxa source. No custom drivers, no invented
device trees, no guessed pin numbers.

## Board

| Item | Value |
|---|---|
| SoC | Allwinner A527, 8x Cortex-A55 |
| RAM | 1 GB LPDDR |
| Storage | microSD only (no eMMC, no NVMe on the board) |
| Network | 2x GbE, Wi-Fi 6 + BLE 5.4 (AIC8800D80), USB-C OTG |
| Kernel | `5.15.147+`, built from `radxa-pkg/linux-aw2501` |
| Boot | boot0 → U-Boot (TOC1) → extlinux → `Image` + `sun55i-a527-cubie-a5e.dtb` |

## Image

`output/cubie-a5e-lite-arm64.img` — 4 GiB, three GPT partitions, expands the rootfs to the
full card on first boot.

| Check | Value |
|---|---|
| Debian | 12 Bookworm arm64 |
| Login | `radxa` / `radxa`, hostname `cubie-a5e` |
| Console | USB-C OTG CDC-ACM on `ttyGS0` (Windows COM port) |
| Console (hardware) | UART0 `ttyAS0`, header pins 8/10, 115200 8N1 |
| USB network | CDC-NCM, board `10.55.0.1/24`, DHCP server for the host |
| Wi-Fi | AIC8800D80, firmware in `/lib/firmware/aic8800d80` |
| BLE | `hci0` over `ttyAS1`, BD `A8:B5:8E:0D:73:B8` |
| Swap | zram, 50 % of RAM (`PERCENT=50` in `/etc/default/zramswap`) |
| Idle | 116 MB RAM used, 1.5 GB disk, load 0.00, 15.6 s boot |

See [FLASHING.md](FLASHING.md) for the flashing procedure and
[docs/](docs) for the pin map, the reference image layout, and the on-board manifest.

## Repository layout

```
AGENTS.md                 build rules, verified source registry, board state
FLASHING.md               how to write the image to an SD card
docs/                     pin map, reference layout, RPi-compat plan, board manifest
scripts/build/            numbered image build steps (debootstrap, kernel, U-Boot, assemble)
scripts/board/            scripts that run on the board itself
scripts/windows/          host-side helpers: flashing, serial console, SSH, NAT
scripts/misc/             one-off probes and analysis
tools/                    AIC8800D80 firmware, bt_test
backups/                  rootfs dumps and image archives
logs/                     captured output of past runs
```

## Status

Working: boot, USB console, USB networking, SSH, Wi-Fi, BLE, Ethernet, zram, NTP,
first-boot rootfs expand.

Not yet validated: the RPi-compatibility layer. It is specified in
[docs/RPI-COMPAT-PLAN.md](docs/RPI-COMPAT-PLAN.md); GPIO pins are mapped and verified,
the `RPi.GPIO` shim and the bus overlays are not built yet.

## Contributing

Test reports are the most useful contribution: which HAT or sensor, which pins, which
image build, what worked. Open an issue with the output of `cubie-pinout` and
`gpioinfo` (once the tooling lands).

## License

MIT for scripts and code, CC BY 4.0 for the documentation, matching the Radxa docs that
the pin map is derived from.
