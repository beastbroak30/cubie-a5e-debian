# Flashing the Radxa Cubie A5E image

## Files

| File | Purpose |
|---|---|
| `cubie-a5e-lite-arm64.img` | 4 GiB image to flash (4,294,967,296 bytes) |
| `cubie-a5e-lite-arm64.img.sha256` | checksum |
| `balenaEtcher-2.1.9.Setup.exe` | installer for balenaEtcher 2.1.9 |

Current image SHA256:

```
0759fa97bd9aa145a7c4ab7713bae41226025abb66a0a3bad84e42802ed77a44  cubie-a5e-lite-arm64.img
```

Etcher installer SHA256 (matches upstream `SHA256SUMS.Windows.x64.txt`):

```
3FA63EA453E75C0338F8F1444B511F38DECDD002E17922A910AEC5E29B85B751  balenaEtcher-2.1.9.Setup.exe
```

## Step 1 — install balenaEtcher

Run `balenaEtcher-2.1.9.Setup.exe`. Accept the UAC prompt. Finish the installer.

## Step 2 — flash

1. Open balenaEtcher.
2. **Flash from file** → select `D:\misc_prj\radxa_firmware\cubie-a5e-lite-arm64.img`.
3. **Select target** → the 128 GB card reader (`Generic- xD/SD/M.S.`, ~119 GB, was drive `E:`).
   Check the size. Two internal disks exist (512 GB KIOXIA, 1 TB WD Blue) — do not pick them.
4. **Flash!** and confirm the overwrite warning.
5. Wait for "Flash Complete".
6. Windows will offer to format the unallocated space. **Click Cancel.** The card must stay as
   the 3 Linux partitions.

## Step 3 — verify (optional)

```powershell
Get-Partition -DiskNumber 2 | Format-Table PartitionNumber,Offset,Size,Type
```

Expect exactly three partitions:

| # | Offset (bytes) | Size (bytes) | Label |
|---|---|---|---|
| 1 | 16777216 | 16777216 | `config` (FAT16) |
| 2 | 33554432 | 314572800 | `efi` (FAT16) |
| 3 | 348127232 | 3946823168 | `rootfs` (ext4) |

The card holds only 4 GiB of used data. `rootfs` expands to the full 128 GB on first boot via
`expand-rootfs.service`.

## Step 4 — boot the board

1. Insert the card into the Cubie A5E microSD slot.
2. Console: CP2102 USB-TTL on 40-pin header **pins 8 (TX) / 10 (RX) / 6 (GND)**, 115200 8N1,
   or USB-C OTG with the `g_ether`/`ttyGS0` gadget.
3. Power on. Expect U-Boot, then extlinux, then kernel, then a login prompt on `ttyAS0`.
4. Login: user `radxa`, password `radxa` (hostname `cubie-a5e`).

## Post-boot checks

```sh
ip -br a                 # eth0/eth1 DHCP, usb0 10.55.0.1/24
zramctl                  # zram0 ≈ 50% RAM
findmnt /tmp             # tmpfs
systemctl is-active ssh NetworkManager bluetooth
sudo apt update          # confirms apt sources work
lsblk                    # rootfs grown to ~119G after first boot
```
