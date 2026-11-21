# [Release] Minimal Headless Debian 12 (Bookworm) for Radxa Cubie A5E (1GB RAM) + RPi Compatibility Layer

Hi Radxa Community,

Like many Cubie A5E (Allwinner A527) owners, I ran into the issue where official Radxa OS images ship with heavy desktop environments (KDE) on Debian 11 Bullseye (now EOL), leaving almost no usable RAM on the 1GB LPDDR variant. Existing community Armbian images also frequently fail on the 1GB DRAM variant during U-Boot SPL.

To solve this, I've built a **clean, headless, minimal Debian 12 Bookworm arm64** system from scratch using Radxa's official BSP kernel (`5.15.147+`) and verified boot components.

---

### Key Highlights & Hardware Verification

- **Ultra-lightweight:** Boots in **15.6 seconds**, idling at **~116 MB RAM** (out of 937 MB usable).
- **Tested on 1GB Hardware:** Boot0 and TOC1 package tailored for 1GB LPDDR timings. Boots reliably from microSD.
- **Out-of-the-box Remote Access (Zero Drivers Needed):**
  - Features a composite USB-C OTG gadget (**CDC-NCM Ethernet + CDC-ACM Serial Console**).
  - Works natively on modern Windows 11 (24H2) without RNDIS driver breakage.
  - SSH directly over USB via `10.55.0.1` (board runs DHCP server on `usb0`).
  - Serial console available simultaneously over USB COM port (`ttyGS0`) and hardware header pins 8/10 (`ttyAS0`).
- **Working Wi-Fi 6 & Bluetooth 5.4 (AIC8800D80):**
  - Proprietary vendor SDIO driver + all 15 firmware blobs baked into `/lib/firmware/aic8800d80`.
  - Bluetooth configured via HCI over UART (`ttyAS1` at 1.5M baud) as a systemd service.
- **Smart Resource Management:**
  - ZRAM swap configured at **50% of RAM** (~480 MB) with no disk thrashing.
  - `/tmp` on tmpfs.
  - UTF-8 locale pre-configured (`en_US.UTF-8` + `C.UTF-8`) for terminal utilities like `btop` / `htop`.
- **First-Boot Auto-Expansion:**
  - Auto-grows partition 3 (`rootfs`) from 4GB to the full capacity of your microSD card (e.g., 128GB) on first boot.
- **Raspberry Pi Compatibility Layer:**
  - Full 40-pin header map cataloged and verified against kernel line names (`PIN_3`, `PIN_5`, `PIN_15`, `PIN_22`).
  - Pin map JSON data and planned `RPi.GPIO` / `gpiozero` shims included.

---

### Quick Start / Flashing

1. Flash `cubie-a5e-lite-arm64.img.gz` to your microSD card using balenaEtcher or `dd`:
   ```bash
   gzip -dc cubie-a5e-lite-arm64.img.gz | sudo dd of=/dev/sdX bs=4M conv=fsync status=progress
   ```
2. Insert card into microSD slot.
3. Connect USB-C OTG cable to your PC.
4. SSH to `radxa@10.55.0.1` (Password: `radxa`).

---

### Project Repository & Full Source

- **GitHub Repository:** [https://github.com/beastbroak30/cubie-a5e-debian](https://github.com/beastbroak30/cubie-a5e-debian)
- Includes all build scripts, license audits (GPL compliance), pin mappings, and CI workflows.

Feedback, tests on different HATs/sensors, and contributions are very welcome!
