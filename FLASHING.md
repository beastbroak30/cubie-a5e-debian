# Flashing the Radxa Cubie A5E image

The image is **not** stored in this repository (4 GiB). It ships as a release asset or on
request; see `README.md`. The build itself is reproducible from `scripts/build/`.

## Files

| File | Purpose |
|---|---|
| `cubie-a5e-lite-arm64.img` | 4 GiB image to flash (4,294,967,296 bytes) |
| `cubie-a5e-lite-arm64.img.gz` | same image, gzip (-9), 933 MB |
| `cubie-a5e-lite-arm64.img.sha256` | checksum |
| balenaEtcher 2.1.9 Setup | flashing tool, from https://etcher.balena.io |

Current image SHA256:

```
a6dbc27f9a47051ce1d0c963e03531d0d34458f2f6afd31ec78d84263c8c16d2  cubie-a5e-lite-arm64.img
d3a03463e81f9be000c413847e263eb41a644037f1eabd4f0dd071e223a7d559  cubie-a5e-lite-arm64.img.gz
```

Etcher accepts the `.gz` directly: it decompresses while writing and validates the result.

## Step 1 — verify the image

```powershell
Get-FileHash .\cubie-a5e-lite-arm64.img -Algorithm SHA256
```

The hash must match the line above. If it does not, re-download; do not flash.

## Step 2 — install balenaEtcher

Download and run the installer from https://etcher.balena.io. The installer is not in this
repository. Accept the UAC prompt, finish the install.

## Step 3 — flash

1. Open balenaEtcher.
2. **Flash from file** → select `cubie-a5e-lite-arm64.img`.
3. **Select target** → the 128 GB (or larger) microSD card reader. Check the size: on this
   host two internal disks exist (512 GB KIOXIA, 1 TB WD Blue) — never pick them.
4. **Flash!** and confirm the overwrite warning.
5. Wait for "Flash Complete".
6. Windows may offer to format the unallocated space. **Click Cancel.** The card must stay as
   the three Linux partitions.

`dd` on Linux/macOS also works:

```sh
sudo dd if=cubie-a5e-lite-arm64.img of=/dev/sdX bs=4M conv=fsync status=progress
```

## Step 4 — verify the card layout (optional)

```powershell
Get-Partition -DiskNumber 2 | Format-Table PartitionNumber,Offset,Size,Type
```

Expect exactly three partitions:

| # | Offset (bytes) | Size (bytes) | Label |
|---|---|---|---|
| 1 | 16777216 | 16777216 | `config` (FAT16) |
| 2 | 33554432 | 314572800 | `efi` (FAT16) |
| 3 | 348127232 | 3946823168 | `rootfs` (ext4) |

The card holds only 4 GiB of used data. `rootfs` expands to the full card on first boot via
`expand-rootfs.service`.

Boot area (outside the partitions): `boot0` at sector 256, U-Boot package (TOC1) at sector
24576. These come unchanged from Radxa's official Cubie A5E image; see `docs/LICENSES.md`.

## Step 5 — boot the board

1. Insert the card into the Cubie A5E microSD slot.
2. Console, pick one:
   - **USB-C OTG** (no adapter needed): the image brings up a composite CDC-NCM + CDC-ACM
     gadget. Windows creates a serial port (`ttyGS0` on the board) and a network adapter
     (`Ethernet 5`-style, board address `10.55.0.1/24`).
   - **Hardware UART**: 3.3 V USB-TTL adapter on 40-pin header pin 8 (board TX) and pin 10
     (board RX), GND on pin 6 or 9, 115200 8N1, VCC not connected. Console is `ttyAS0`.
3. Power on. Expect U-Boot, then extlinux, then kernel, then a login prompt.
4. Login: user `radxa`, password `radxa` (hostname `cubie-a5e`).

## Step 6 — remote access over USB

On the Windows host, once, in an elevated PowerShell:

```powershell
Set-NetIPInterface -InterfaceAlias 'Ethernet 5' -Dhcp Disabled
New-NetIPAddress -InterfaceAlias 'Ethernet 5' -IPAddress 10.55.0.2 -PrefixLength 24
```

Then:

```powershell
ssh radxa@10.55.0.1
```

The board runs a DHCP server on `usb0`. WinNAT (`New-NetNat -Name CubieUSB
-InternalIPInterfaceAddressPrefix 10.55.0.0/24`) gives the board internet through the PC, and
removes `10.55.0.0/24` from the WSL NAT — use the Windows OpenSSH client, not WSL.

## Post-boot checks

```sh
ip -br a                 # eth0/eth1 DHCP, usb0 10.55.0.1/24, wlan0 after Wi-Fi setup
zramctl                  # zram0 ≈ 50% of RAM
findmnt /tmp             # tmpfs
systemctl is-active ssh NetworkManager bluetooth
sudo apt update          # confirms apt sources work
lsblk                    # rootfs grown to the full card after first boot
```

## Wi-Fi / BLE

Wi-Fi chip is AIC8800D80 (SDIO `C8A1:0082`). Firmware lives in `/lib/firmware/aic8800d80`.
Join a network with `nmcli device wifi connect <SSID> password <KEY>`.

Bluetooth attaches over the board UART (`ttyAS1`) through `aic8800-bt.service`. Check with
`hciconfig hci0` or `bluetoothctl show`.

## Known limits

- No RTC: keep `systemd-timesyncd` enabled or `apt` will reject Release files.
- `zramswap` reads `PERCENT`, not `PERCENTAGE`.
- `boot0`/ATF redistribution is unresolved; see `docs/LICENSES.md` before republishing the
  image.
