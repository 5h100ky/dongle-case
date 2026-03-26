# dongle-case

3D-printable enclosure for the [Snake Dongle](https://github.com/joaopedropio/snake-dongle)
with **automatic display-brightness control** via a light sensor (LDR) — **no buzzer required**.

Inspired by [felixJR123/Snake-Dongle-Case](https://github.com/felixJR123/Snake-Dongle-Case).

---

## Features

| Feature | Details |
|---------|---------|
| 3D-printable shell | Two-part snap-fit case (top + bottom), designed in OpenSCAD |
| Display window | 28 mm × 28 mm cut-out for the 1.54" ST7789 TFT |
| Light sensor slot | Replaces the buzzer — LDR module reads ambient light to auto-dim/brighten the display |
| Button openings | 2× 6 mm holes for the tactile action / menu buttons |
| USB access | Cut-out for the onboard USB-C connector |
| Fasteners | M2 heat-set brass inserts + M2 screws |

---

## Bill of Materials

### Electronics

| Qty | Part | Link |
|-----|------|------|
| 1× | Pro Micro nRF52840 / Nice Nano v2 | [AliExpress](https://pt.aliexpress.com/item/1005009890354737.html) |
| 1× | 1.54" TFT 240×240 ST7789 display | [AliExpress](https://pt.aliexpress.com/item/1005008723433125.html) |
| 2× | 6×6×8 mm tactile push button | [AliExpress](https://pt.aliexpress.com/item/1005007623070623.html) |
| 1× | **LDR light-sensor module** (replaces buzzer) | [AliExpress](https://de.aliexpress.com/item/1005008608771773.html) |
| — | 1.27 mm flat ribbon cable (or any thin wire) | [AliExpress](https://pt.aliexpress.com/item/1005007868158870.html) |

> **Note:** The LDR module listed above includes both a digital (DO) and analog (AO)
> output. Use the **AO** pin for smooth brightness control.

### Hardware / fasteners

| Qty | Part | Link |
|-----|------|------|
| 4× | M2 heat-set brass insert (OD ≈ 3.2 mm, L ≈ 3 mm) | [AliExpress](https://www.aliexpress.us/item/3256807466816961.html) |
| 4× | M2 × 8 mm screw | [AliExpress](https://www.aliexpress.us/item/3256805692722422.html) |

---

## 3D Printing

### Files

```
case/
├── parameters.scad     ← shared dimensions (edit here to re-size everything)
├── top_shell.scad      ← top half: display window, buttons, light-sensor slot
├── bottom_shell.scad   ← bottom half: USB cut-out, alignment rim
└── dongle_case.scad    ← assembly preview (both halves together)
```

### Export for printing

Open each file in [OpenSCAD](https://openscad.org/) and export to STL:

```
File → Export → Export as STL
```

| File | STL to print | Orientation |
|------|--------------|-------------|
| `top_shell.scad` | `top_shell.stl` | face down (display window on build plate) |
| `bottom_shell.scad` | `bottom_shell.stl` | face down |

### Recommended slicer settings

| Setting | Value |
|---------|-------|
| Layer height | 0.15–0.20 mm |
| Infill | 20–30 % |
| Wall count | 3 |
| Supports | Not needed |
| Filament | PLA or PETG |

---

## Wiring

```
nRF52840 pin  │  Component
──────────────┼──────────────────────────────────────────────────────────
3.3 V         │  Display VCC, LDR module VCC
GND           │  Display GND, LDR module GND, buttons (one leg)
SCK (P0.17)   │  Display SCK
MOSI (P0.20)  │  Display SDA/MOSI
CS   (P0.06)  │  Display CS
DC   (P0.15)  │  Display DC
RST  (P0.14)  │  Display RST
BL   (P0.22)  │  Display BL  (for backlight PWM)

P0.30 (D9)   │  Action button (other leg → GND)
P0.28 (D8)   │  Menu / reset button (other leg → GND)

P0.02 (A0)   │  LDR module AO (analog output)
```

> **Buzzer:** no connections needed — the buzzer is omitted in this build.

---

## Firmware Setup

### 1. Add the ZMK module to your `config/west.yml`

```yaml
manifest:
  remotes:
    - name: zmkfirmware
      url-base: https://github.com/zmkfirmware
    - name: joaopedropio
      url-base: https://github.com/joaopedropio
  projects:
    - name: zmk
      remote: zmkfirmware
      revision: v0.2
      import: app/west.yml
    - name: snake-module
      remote: joaopedropio
      revision: master
  self:
    path: config
```

### 2. Update your `config/build.yaml`

```yaml
---
include:
  - board: nice_nano_v2
    shield: MY_KEYBOARD_dongle snake_adapter   # replace MY_KEYBOARD with your shield name
    artifact-name: snake_dongle
```

### 3. Copy the configuration files

Copy the files from `firmware/config/` into your ZMK `config/` folder:

```
firmware/config/dongle.conf    → config/MY_KEYBOARD_dongle.conf
firmware/config/dongle.overlay → config/MY_KEYBOARD_dongle.overlay
```

### 4. Add the light-sensor module

Copy `firmware/src/light_sensor_backlight.c` into your ZMK module or add it as
a Zephyr module source file. The file registers itself via `SYS_INIT` so no
further integration code is required.

### 5. Key configuration options (`dongle.conf`)

| Variable | Default | Description |
|----------|---------|-------------|
| `CONFIG_SNAKE_LIGHT_SENSOR_POLL_MS` | `500` | How often to sample the LDR (ms) |
| `CONFIG_SNAKE_LIGHT_SENSOR_DIM_THRESHOLD` | `800` | ADC value (0–4095) below which backlight dims |
| `CONFIG_SNAKE_LIGHT_SENSOR_BRIGHT_THRESHOLD` | `2500` | ADC value above which backlight is at full brightness |
| `CONFIG_ZMK_BACKLIGHT_BRT_START` | `80` | Startup brightness (%) |
| `CONFIG_USE_BUZZER` | `n` | Buzzer disabled |

---

## Assembly

1. Solder wires to the display and buttons as shown in the wiring table.
2. Connect the LDR module AO pin to **A0** on the controller.
3. Press M2 heat-set inserts into the top shell using a soldering iron.
4. Place the display PCB into the top-shell recess (face toward the window).
5. Seat the controller on the bottom shell; route the USB-C port toward the cut-out.
6. Clip the two halves together and secure with 4× M2 screws.

---

## Credits

- [joaopedropio/snake-dongle](https://github.com/joaopedropio/snake-dongle) — original Snake Dongle firmware
- [felixJR123/Snake-Dongle-Case](https://github.com/felixJR123/Snake-Dongle-Case) — case design inspiration
