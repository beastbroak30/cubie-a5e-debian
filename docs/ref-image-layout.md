# Ground-Truth SD Image Layout: Radxa Cubie A5E

Derived from official reference binary: `radxa-cubie-a5e_bullseye_cli_r7.output_512.img.xz`

| FACT | VALUE | EVIDENCE |
|---|---|---|
| Compressed file size | 500,889,824 bytes (477.7 MiB) | `stat -c %s radxa-cubie-a5e_bullseye_cli_r7.output_512.img.xz` -> `500889824` |
| Uncompressed raw image size | 3,791,561,728 bytes (3.53 GiB / 7,405,394 sectors) | `stat -c %s ref.img` -> `3791561728` |
| Sector size | 512 bytes (logical and physical) | `fdisk -l ref.img`: `Units: sectors of 1 * 512 = 512 bytes` |
| Partition table type | GPT (GUID Partition Table) | `fdisk -l ref.img`: `Disklabel type: gpt` |
| Disk GUID | 5D41453B-15BE-4B6F-959A-155782DA369A | `sfdisk -d ref.img`: `label-id: 5D41453B-15BE-4B6F-959A-155782DA369A` |
| First / Last usable LBA | 34 / 7405360 | `sgdisk -p ref.img`: `First usable sector is 34, last usable sector is 7405360` |
| Sector 0-33 layout | LBA 0: Protective MBR; LBA 1: GPT Header; LBA 2-33: Partition Table Entries | `hexdump -C` on sectors 0..33 |
| Partition 1 start sector / size | Start: 32768 (0x8000), Size: 32768 (16.0 MiB), End: 65535 | `sfdisk -d ref.img`: `start= 32768, size= 32768` |
| Partition 1 type / name / label | Type: Linux filesystem (0FC63DAF-8483-4772-8E79-3D69D8477DE4), Name: "primary", FAT Label: "config", UUID: 9DD7-BC07 | `blkid`: `LABEL="config" UUID="9DD7-BC07" TYPE="vfat"` |
| Partition 1 purpose | rsetup boot configuration (`config.txt`, `before.txt`, `logo.bmp`), mounted at `/config` | `ls -la /config` in p1; `/etc/fstab` entry: `UUID=9DD7-BC07 /config vfat ...` |
| Partition 2 start sector / size | Start: 65536 (0x10000), Size: 614400 (300.0 MiB), End: 679935 | `sfdisk -d ref.img`: `start= 65536, size= 614400` |
| Partition 2 type / name / label | Type: EFI System (C12A7328-F81F-11D2-BA4B-00A0C93EC93B), Name: "primary", FAT Label: "efi", UUID: 9DD8-13A9 | `blkid`: `LABEL="efi" UUID="9DD8-13A9" TYPE="vfat"` |
| Partition 2 flags | `boot`, `legacy_boot`, `esp` (attrs="LegacyBIOSBootable") | `parted unit s print`: `boot, legacy_boot, esp` |
| Partition 2 purpose | Empty EFI System Partition mounted at `/boot/efi` | `/etc/fstab`: `UUID=9DD8-13A9 /boot/efi vfat ...` (no files inside ref image) |
| Partition 3 start sector / size | Start: 679936 (0xA6000), Size: 6725425 (3.2 GiB), End: 7405360 | `sfdisk -d ref.img`: `start= 679936, size= 6725425` |
| Partition 3 type / name / label | Type: Linux filesystem (0FC63DAF-8483-4772-8E79-3D69D8477DE4), Name: "primary", Label: "rootfs", UUID: 7cf9f135-82db-4514-af4e-5817cb922fec | `blkid`: `LABEL="rootfs" UUID="7cf9f135-82db-4514-af4e-5817cb922fec" BLOCK_SIZE="4096" TYPE="ext4"` |
| Partition 3 flags | `legacy_boot` (attrs="LegacyBIOSBootable") | `sfdisk -d ref.img`: `attrs="LegacyBIOSBootable"` |
| Partition 3 filesystem | ext4 (4096-byte blocks) | `blkid`: `TYPE="ext4"` |
| boot0 location (confirmed) | Sector 256 (byte offset 131072 / 0x20000). eGON magic at offset +4: 131076. | `dd if=ref.img bs=512 skip=256 count=1 \| hexdump -C`: `de 04 00 ea 65 47 4f 4e 2e 42 54 30 ...` ("eGON.BT0") |
| boot_package.fex location (confirmed) | Sector 24576 (byte offset 12582912 / 0xC00000). Magic: "sunxi-package" at offset 0. | `dd if=ref.img bs=512 skip=24576 count=1 \| hexdump -C`: `73 75 6e 78 69 2d 70 61 63 6b 61 67 65 ...` ("sunxi-package") containing u-boot, monitor, scp |
| First 128 sectors contents | Sector 0: PMBR; Sectors 1-33: GPT table; Sectors 34-127: All zeros (0x00). | `dd if=ref.img bs=512 count=128 \| hexdump -C` |
| Boot mechanism | U-Boot extlinux (`/boot/extlinux/extlinux.conf` on rootfs p3). No `boot.scr` present. | `ls /boot/extlinux/extlinux.conf` exists; `boot.scr` absent |
| Device tree filename | `sun55i-a527-cubie-a5e.dtb` (size: 161,179 bytes) | `ls -la /tmp/ref_mnt/usr/lib/linux-image-5.15.147-20-aw2501/allwinner/sun55i-a527-cubie-a5e.dtb` |
| Device tree location | `/usr/lib/linux-image-5.15.147-20-aw2501/allwinner/sun55i-a527-cubie-a5e.dtb` (referenced via `fdtdir /usr/lib/linux-image-5.15.147-20-aw2501/`) | In `/boot/extlinux/extlinux.conf`: `fdtdir /usr/lib/linux-image-5.15.147-20-aw2501/` |
| Kernel command line | `root=UUID=7cf9f135-82db-4514-af4e-5817cb922fec console=ttyAS0,115200n8 earlyprintk=sunxi-uart,0x2500000 rootwait clk_ignore_unused mac_addr=${mac} mac1_addr=${mac1} quiet splash loglevel=4 rw earlycon consoleblank=0 console=tty1 coherent_pool=2M irqchip.gicv3_pseudo_nmi=0 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1 kasan=off` | Extracted verbatim from `/boot/extlinux/extlinux.conf` APPEND line |
| Primary serial console | `ttyAS0,115200n8` (Allwinner UART at address 0x2500000) | In kernel cmdline: `console=ttyAS0,115200n8 earlyprintk=sunxi-uart,0x2500000` |
| Wireless / BT firmware chip | Realtek RTL8852BS / RTL8852BU (`rtw89/rtw8852b_fw.bin`, `rtl_bt/rtl8852bs_fw.bin`, `rtl_bt/rtl8852bs_config.bin`) | `ls -la /lib/firmware/rtw89/rtw8852b_fw.bin` (Feb 14 2026), `/lib/firmware/rtl_bt/rtl8852bs*` |
| Official Radxa apt repositories | `https://radxa-repo.github.io/bullseye` and `https://radxa-repo.github.io/a527-bullseye` | In `/etc/apt/sources.list.d/70-radxa.list` and `80-radxa-a527.list` |

---

## Raw `sfdisk -d` Output

```text
label: gpt
label-id: 5D41453B-15BE-4B6F-959A-155782DA369A
device: ref.img
unit: sectors
first-lba: 34
last-lba: 7405360
sector-size: 512

ref.img1 : start=       32768, size=       32768, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=154E5B0C-A4FB-4319-AD08-9E25D38BDF06, name="primary"
ref.img2 : start=       65536, size=      614400, type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B, uuid=7CA915AE-E6B1-4030-917B-E4785B48C60F, name="primary", attrs="LegacyBIOSBootable"
ref.img3 : start=      679936, size=     6725425, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=0715D0EB-DA6D-4794-8E32-1CC2F8A71D77, name="primary", attrs="LegacyBIOSBootable"
```

---

## Verbatim `/boot/extlinux/extlinux.conf` Output

```text
## /boot/extlinux/extlinux.conf
##
## IMPORTANT WARNING
##
## The configuration of this file is generated automatically.
## Do not edit this file manually, use: u-boot-update

default l0
menu title U-Boot menu
prompt 1
timeout 10


label l0
	menu label Debian GNU/Linux 11 (bullseye) 5.15.147-20-aw2501
	linux /boot/vmlinuz-5.15.147-20-aw2501
	initrd /boot/initrd.img-5.15.147-20-aw2501
	fdtdir /usr/lib/linux-image-5.15.147-20-aw2501/
	
	append root=UUID=7cf9f135-82db-4514-af4e-5817cb922fec console=ttyAS0,115200n8 earlyprintk=sunxi-uart,0x2500000 rootwait clk_ignore_unused mac_addr=${mac} mac1_addr=${mac1} quiet splash loglevel=4 rw earlycon consoleblank=0 console=tty1 coherent_pool=2M irqchip.gicv3_pseudo_nmi=0 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1 kasan=off

label l0r
	menu label Debian GNU/Linux 11 (bullseye) 5.15.147-20-aw2501 (rescue target)
	linux /boot/vmlinuz-5.15.147-20-aw2501
	initrd /boot/initrd.img-5.15.147-20-aw2501
	fdtdir /usr/lib/linux-image-5.15.147-20-aw2501/
	append root=UUID=7cf9f135-82db-4514-af4e-5817cb922fec console=ttyAS0,115200n8 earlyprintk=sunxi-uart,0x2500000 rootwait clk_ignore_unused mac_addr=${mac} mac1_addr=${mac1} splash loglevel=4 rw earlycon consoleblank=0 console=tty1 coherent_pool=2M irqchip.gicv3_pseudo_nmi=0 cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1 kasan=off single
```
