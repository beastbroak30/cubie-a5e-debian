# Raspberry Pi compatibility plan — Radxa Cubie A5E

Goal: a user who follows a Raspberry Pi tutorial for GPIO, I2C, SPI, UART or PWM should
get working hardware on the Cubie A5E with the smallest possible edit. Same 40-pin
workflow, same Python libraries, same "enable the bus then reboot" habit.

Rules this plan follows: no custom drivers, no invented device trees, no pin numbers from
memory. Every mapping comes from the Radxa pinout page and is verified against the running
kernel.

## 1. Hardware truth (verified 2026-11-21)

Source: https://docs.radxa.com/en/cubie/a5e/hardware-use/pin-gpio
Data file: `docs/cubie-a5e-pinmap.json`

Two GPIO chips, both usable through the libgpiod character device:

| Chip | Kernel parent | Lines | Banks | Numbering |
|---|---|---|---|---|
| `gpiochip1` | `2000000.pinctrl` | 352 | PA..PK | `num + 32 * bank` (A=0 … K=10) |
| `gpiochip0` | — | 64 | PL, PM | `num + 32 * bank` (L=0, M=1) |

Verified against the running board, not the doc alone:

| Physical pin | Signal | Formula | Observed in kernel |
|---|---|---|---|
| 3 | PB5 | `5 + 32*1 = 37` | `gpiochip1` line 37 name `PIN_3` |
| 5 | PB4 | `4 + 32*1 = 36` | `gpiochip1` line 36 name `PIN_5` |
| 15 | PL12 | `12 + 32*0 = 12` | `gpiochip0` line 12 name `PIN_15` |
| 22 | PL13 | `13 + 32*0 = 13` | `gpiochip0` line 13 name `PIN_22` |

The A5E device tree already labels header pins `PIN_<n>`, which confirms the formula
without any table of our own.

Important difference from a Raspberry Pi: **there is no BCM numbering.** Any tutorial that
does `GPIO.setmode(GPIO.BCM); GPIO.setup(17, ...)` cannot work as written. The pin map is
*physical*. A shim maps physical pin → `(gpiochip, line)` and refuses BCM numbers with a
message that lists the physical equivalent.

## 2. Gap list

| Raspberry Pi feature | Cubie A5E today | Plan |
|---|---|---|
| `/dev/gpiomem` mmap of SoC registers | absent | libgpiod char device instead; no mmap path, never will be |
| `RPi.GPIO` Python API | absent | build a libgpiod-backed shim (phase 3) |
| `gpiozero` | installable, needs a pin factory | use the libgpiod/native factory (phase 4) |
| `pigpio` (DMA, BCM only) | impossible | document as unsupported |
| `raspi-config` | `rsetup` (different menu) | thin wrapper + docs (phase 5) |
| `/boot/firmware/config.txt` + `dtparam=` | `extlinux.conf` + `rsetup` overlays | config.txt translator (phase 5) |
| HAT EEPROM auto-detect (i2c-0 @ 0x50) | no EEPROM bus on the header | unsupported, document |
| RPi camera (CSI + libcamera) | MIPI CSI connector, different pinout | unsupported for RPi cameras |
| 1-Wire, I2S, PWM | available via overlays | enable through rsetup overlays |
| ADC | only `GPADC2` on pin 37 | document the single channel |
| Default serial console on 8/10 | UART0 is the console (`ttyAS0`) | matches RPi's GPIO14/15 behaviour |

## 3. Phases

Each phase ends with a verification gate. A phase is not done until the gate passes on the
real board, not in a chroot.

### Phase 1 — bus tooling baseline

Install and verify the generic tools, so nothing later depends on closed code:

```
gpiod  i2c-tools  device-tree-compiler  python3-libgpiod  python3-periphery
python3-smbus  python3-spidev  gpiozero
```

Enable the header buses with the Radxa overlay mechanism (`rsetup` → Overlay):
`Enable TWI1`, `Enable spidev on SPI1`, `Enable UART3`, `Enable PWM0-7`.

Gate: `gpioinfo` lists both chips; `i2cdetect -y 1` reports the bus; SPI loopback on pins
19/21 passes; `ls /dev/spidev*` shows the device.

### Phase 2 — pin map package

Ship `docs/cubie-a5e-pinmap.json` with a tiny Python module and a CLI:

- `cubie_pinmap.pin(40) -> {"chip": 1, "line": 260, "name": "PI4"}`
- `cubie-pinout` prints an ASCII header diagram with `gpiochip:line` per pin, plus which
  alternate functions that pin has.

Gate: `cubie-pinout` output matches `gpioinfo` line names for the pins the DT already
labels (3, 5, 15, 22).

### Phase 3 — `RPi.GPIO` shim

A pure-Python package named `RPi.GPIO`, backed by libgpiod:

- `setmode(BOARD)` works. `setmode(BCM)` raises `ValueError` with the physical pin table —
  silently wrong behaviour would be worse than an error.
- `setup(pin, IN|OUT, pull_up_down=...)`, `input`, `output`, `cleanup`.
- `PWM(pin, freq)` on pins that have a PWM alternate function, using `/sys/class/pwm`.
- `add_event_detect` / `wait_for_edge` over libgpiod edge events.

Gate: blink an LED on pin 40 (PI4 = chip1:260), read a button on pin 38 (PI5 = chip1:261),
and a PWM fade on pin 33 (PI6 = chip1:262) after the `PWM0-7` overlay.

### Phase 4 — `gpiozero`

Install `gpiozero`, select the libgpiod pin factory, and prove `LED`, `Button`,
`PWMLED`, plus one I2C device (`MCP23017` expander or an SSD1306 OLED on TWI1, pins 3/5).

Gate: `LED(40).blink()` runs for 10 s with no warnings; `Button(38)` reports presses.

### Phase 5 — familiarity layer

- `cubie-config`: a small menu that maps the six things people actually use from
  `raspi-config` (interfaces, hostname, password, locale, SSH, expand filesystem) onto
  `rsetup` and the existing units.
- `config.txt` translator: read `/boot/firmware/config.txt` if present, convert
  `dtparam=i2c_arm=on`, `dtparam=spi=on`, `enable_uart=1`, `dtoverlay=...` into the
  equivalent `rsetup` overlay calls, and warn about the ones with no equivalent.

Gate: a `config.txt` copied from a Pi tutorial enables I2C on the next boot with no manual
edit.

### Phase 6 — HAT reality matrix

Document, per HAT class, what happens when it is plugged in:

| HAT class | Expectation |
|---|---|
| I2C sensor / OLED HATs | work after enabling TWI1 |
| SPI display HATs | work after enabling spidev on SPI1 (pin 24 is CE0) |
| UART HATs (GPS, LoRa) | work after enabling UART3/UART5, but the console is on UART0 |
| Plain GPIO LED/button HATs | work, physical pins only |
| HATs with ID EEPROM | EEPROM ignored, HAT still functions if it does not require autodetect |
| PoE HAT | not supported: no PoE header |
| Camera HATs / RPi camera | not supported: different CSI connector and pinout |
| 3.3 V high-current HATs | check the board's regulator budget; the header is not a Pi's 3.3 V rail |

Gate: matrix published with at least one HAT tested per row that is marked working.

### Phase 7 — publish

Image release with sha256, this document, the tested matrix, and an issue template that
asks for `cubie-pinout` + `gpioinfo` output. Post to the Radxa forum and the Cubie A5E
docs thread for field testing.

## 4. Test matrix to fill

| Test | Pins | Expected |
|---|---|---|
| LED blink | 40 (PI4) | `chip1:260` toggles |
| Button read | 38 (PI5) | `chip1:261` reads 0/1 |
| PWM fade | 33 (PI6) | `PWM0-7` overlay, brightness ramps |
| I2C scan | 3/5 (PB5/PB4) | `i2cdetect -y 1` shows the device |
| SPI loopback | 19/21 (PB13/PB14) | bytes echo, `spidev1.0` |
| UART loopback | 16/31 (PI11/PI12) | bytes echo on UART3 |
| 1-Wire DS18B20 | 7 (PI7) | temperature reads after the 1-Wire overlay |
| ADC | 37 (GPADC2) | raw value changes with input |

## 5. Known limits to state in public docs

- No BCM numbering, ever. Physical pins only.
- 1 GB RAM, microSD storage, no eMMC or NVMe.
- `pigpio` and anything that mmaps SoC registers will not work.
- HAT ID EEPROM and Raspberry Pi cameras are unsupported.
- Overlays exist only for what `radxa-overlays` ships; check before promising a function.
- Kernel is the Radxa BSP 5.15, not mainline.
