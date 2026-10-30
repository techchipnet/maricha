# Maricha
**Powered by: TechChip**

<p align="left">
  <a href="https://github.com"><img src="https://img.shields.io/badge/Release-v1.2.0-blue.svg?style=flat-square" alt="Release"></a>
  <a href="https://www.espressif.com"><img src="https://img.shields.io/badge/Platform-ESP32--C5%20%7C%20S3%20%7C%20WROOM--32U-orange.svg?style=flat-square" alt="Supported Chips"></a>
  <a href="firmware/"><img src="https://img.shields.io/badge/Firmware-Pre--compiled%20Binaries-brightgreen.svg?style=flat-square" alt="Firmware"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square" alt="License"></a>
  <a href="https://www.youtube.com/@TechChipNet"><img src="https://img.shields.io/badge/Community-TechChip-blueviolet.svg?style=flat-square" alt="Community"></a>
  <a href="https://github.com"><img src="https://img.shields.io/badge/PRs-Welcome-brightgreen.svg?style=flat-square" alt="PRs Welcome"></a>
</p>

---

## What is Maricha?

**Maricha** is a lightweight wireless security research and device emulation firmware built for Espressif microcontrollers. Named after the legendary shape-shifter from Indian folklore, Maricha lets your ESP32 board broadcast customizable Bluetooth Low Energy (BLE) identities—such as an Android TV, Apple TV, wireless keyboard, mouse, gamepad, or locator beacon—while simultaneously serving an onboard Wi-Fi management dashboard.

Once paired with a target computer over Bluetooth, Maricha acts as a standard BLE Human Interface Device (HID) capable of executing programmable keystroke payloads.

This repository distributes **pre-compiled binary releases** ready to flash directly onto supported boards. No source compilation or local build environment is required.

---

## Key Features

- **Multi-Identity BLE Spoofing:** Broadcast popular device profiles with matching appearances:
  - Android TV & Apple TV (Media Display)
  - Wireless Keyboard, Mouse, Gamepad & Joystick
  - Digital Pen & Stylus
  - Tracker Beacons (AirTag, JioTag emulation)
  - Heart Rate & Fitness Sensors
  - Custom profile with user-defined names (up to 25 characters) and appearance hex values.
- **Microsoft Swift Pair Support:** Broadcasts standard Microsoft-format BLE advertisements to trigger one-click pairing notifications on Windows 10 and 11.
- **Standard BLE Beacon Mode:** Switch to normal connectable BLE advertisements without proprietary vendor tags.
- **Onboard Wi-Fi Web Dashboard:** Spin up a standalone Wi-Fi Access Point (`192.168.4.1`) with a responsive mobile-first interface. No internet connection or mobile app installation needed.
- **Keystroke Injection Engine (HID):**
  - **Notepad + Hello:** Quick test payload that opens Windows Notepad and types greeting text.
  - **Custom PowerShell:** Type any custom PowerShell or commands in the web textbox; MARICHA opens windows terminal and run it automatically.
  - **DuckyScript-style Payloads:** Supports multi-line sequential scripts (`GUI`, `STRING`, `DELAY`, `ENTER`, `CTRL`, `ALT`).
- **Dual Console Control:**
  - Pre-built variants for boards with USB-to-UART bridge chips (CH340/CP2102) and boards using native ESP32 USB-Serial-JTAG ports.
  - Full interactive serial command-line interface (CLI) at 115200 baud.

---

## Supported Devices

| Board / Chip | Architecture | Connectivity | Recommended Console | Bootloader Offset |
|---|---|---|---|---|
| **ESP32-C5** | RISC-V 32-bit | Dual-Band Wi-Fi (2.4/5GHz) + BLE 5.0 | `uart` or `usb` | `0x2000` |
| **ESP32-S3** | Xtensa LX7 Dual-Core | 2.4GHz Wi-Fi + BLE 5.0 | `uart` or `usb` | `0x0` |
| **ESP32-WROOM-32U** / **ESP32** | Xtensa LX6 Dual-Core | 2.4GHz Wi-Fi + BLE 4.2 (External Antenna) | `uart` | `0x1000` |

> [!IMPORTANT]
> Always flash the firmware folder matching your specific chip model. For example, flashing ESP32-C5 binaries onto an ESP32-S3 or ESP32-WROOM board will fail to boot due to different CPU architectures and bootloader flash offsets.

---

## Repository & Firmware Layout

The `firmware/` directory contains pre-compiled binaries organized by chip architecture and console type:

```text
firmware/
├── esp32-c5/
│   ├── uart/                    # For boards with CH340 / CP2102 USB bridge
│   │   ├── bootloader.bin       # Flash offset: 0x2000
│   │   ├── partition-table.bin  # Flash offset: 0x8000
│   │   └── app.bin              # Flash offset: 0x10000
│   └── usb/                     # For boards connected via native USB-Serial-JTAG
│       ├── bootloader.bin
│       ├── partition-table.bin
│       └── app.bin
├── esp32-s3/
│   ├── uart/
│   │   ├── bootloader.bin       # Flash offset: 0x0
│   │   ├── partition-table.bin  # Flash offset: 0x8000
│   │   └── app.bin              # Flash offset: 0x10000
│   └── usb/
│       ├── bootloader.bin
│       ├── partition-table.bin
│       └── app.bin
└── esp32-wroom-32u/
    └── uart/                    # Classic ESP32 uses UART0 bridge
        ├── bootloader.bin       # Flash offset: 0x1000
        ├── partition-table.bin  # Flash offset: 0x8000
        └── app.bin              # Flash offset: 0x10000
```

---

## How to Flash the Firmware

### Step 1: Install `esptool`
`esptool` is Espressif's official flashing utility. You only need Python 3 installed on your machine:

```bash
pip install --upgrade esptool
```

### Step 2: Check Your COM Port
1. Plug your ESP32 board into your computer with a good quality USB data cable.
2. Check your assigned serial port:
   - **Windows PowerShell:**
     ```powershell
     Get-CimInstance Win32_PnPEntity | Where-Object { $_.Caption -match 'COM\d+' } | Select-Object Caption
     ```
   - **Windows GUI:** Open **Device Manager** and expand **Ports (COM & LPT)** (e.g., `COM5`).
   - **Linux / macOS:** Run `ls /dev/ttyUSB*` or `ls /dev/ttyACM*`.

### Step 3: Choose Your Flashing Command

You can use the automated Windows helper script (`flash-windows.ps1`) or run `esptool` directly.

#### Windows Shortcut Script (`flash-windows.ps1`)

Open PowerShell in this folder and run:

```powershell
# ESP32-C5 (UART):
.\flash-windows.ps1 -Port COM5 -Chip esp32-c5 -Console uart

# ESP32-S3 (UART or Native USB):
.\flash-windows.ps1 -Port COM5 -Chip esp32-s3 -Console uart
.\flash-windows.ps1 -Port COM5 -Chip esp32-s3 -Console usb

# ESP32-WROOM-32U (Standard ESP32):
.\flash-windows.ps1 -Port COM5 -Chip esp32-wroom-32u -Console uart
```

---

#### Manual `esptool` Commands (Cross-Platform)

Replace `COM5` below with your board's actual serial port.

---

#### 1. For ESP32-C5

* **UART Variant** (CH340 / CP2102 bridge):
  ```bash
  python -m esptool --chip esp32c5 -p COM5 -b 460800 --before default_reset --after hard_reset --no-stub write_flash --flash_mode dio --flash_size 4MB --flash_freq 80m 0x2000 firmware/esp32-c5/uart/bootloader.bin 0x8000 firmware/esp32-c5/uart/partition-table.bin 0x10000 firmware/esp32-c5/uart/app.bin
  ```

* **Native USB Variant** (Direct USB-Serial-JTAG port):
  ```bash
  python -m esptool --chip esp32c5 -p COM5 -b 460800 --before default_reset --after hard_reset --no-stub write_flash --flash_mode dio --flash_size 4MB --flash_freq 80m 0x2000 firmware/esp32-c5/usb/bootloader.bin 0x8000 firmware/esp32-c5/usb/partition-table.bin 0x10000 firmware/esp32-c5/usb/app.bin
  ```

---

#### 2. For ESP32-S3

* **UART Variant** (CH340 / CP2102 port):
  ```bash
  python -m esptool --chip esp32s3 -p COM5 -b 460800 --before default_reset --after hard_reset write_flash --flash_mode dio --flash_size 4MB --flash_freq 80m 0x0 firmware/esp32-s3/uart/bootloader.bin 0x8000 firmware/esp32-s3/uart/partition-table.bin 0x10000 firmware/esp32-s3/uart/app.bin
  ```

* **Native USB Variant** (Direct USB port):
  ```bash
  python -m esptool --chip esp32s3 -p COM5 -b 460800 --before default_reset --after hard_reset write_flash --flash_mode dio --flash_size 4MB --flash_freq 80m 0x0 firmware/esp32-s3/usb/bootloader.bin 0x8000 firmware/esp32-s3/usb/partition-table.bin 0x10000 firmware/esp32-s3/usb/app.bin
  ```

---

#### 3. For ESP32-WROOM-32U (Standard ESP32)

* **UART Variant**:
  ```bash
  python -m esptool --chip esp32 -p COM5 -b 460800 --before default_reset --after hard_reset write_flash --flash_mode dio --flash_size 4MB --flash_freq 40m 0x1000 firmware/esp32-wroom-32u/uart/bootloader.bin 0x8000 firmware/esp32-wroom-32u/uart/partition-table.bin 0x10000 firmware/esp32-wroom-32u/uart/app.bin
  ```

---

### Alternative: GUI Flashing via Espressif Flash Download Tool

If you prefer a graphical interface:
1. Download the [Espressif Flash Download Tool](https://www.espressif.com/en/support/download/other-tools).
2. Select your chip type (`ESP32-C5`, `ESP32-S3`, or `ESP32`) and set workMode to **Develop**.
3. Add the three bin files with their respective offsets from the table above:
   - `bootloader.bin` ➔ Offset (`0x2000` for C5, `0x0` for S3, `0x1000` for ESP32)
   - `partition-table.bin` ➔ Offset `0x8000`
   - `app.bin` ➔ Offset `0x10000`
4. Set SPI SPEED to **80MHz** (or 40MHz for standard ESP32), SPI MODE to **DIO**.
5. Select your COM port, Baud rate `460800`, and click **START**.

> [!TIP]
> **Board not entering flashing mode?**
> Hold down the board's **BOOT / IO0** button, press and release the **RESET / EN** button once, then release the **BOOT** button. Run the flash command again.

---

## Quick Start & Usage

### 1. Connect to the Web Dashboard
1. Power up the board via USB or an external 5V power supply.
2. On your smartphone or laptop, open Wi-Fi settings and look for the network:
   - **SSID:** `Maricha-XXXX` (where `XXXX` is part of the chip's MAC address)
   - **Default Password:** `12345678` (can be changed in the web Settings tab or serial console)
3. Open any web browser and go to:
   ```text
   http://192.168.4.1
   ```

> [!TIP]
> **ESP32-WROOM-32U Hardware Note:** The WROOM-32U module does not have an onboard PCB trace antenna—it relies entirely on the IPEX/U.FL connector. Please ensure an external 2.4 GHz antenna is firmly connected to the U.FL port, otherwise Wi-Fi signal will be too weak for devices to complete the handshake.

### 2. Pair with Target PC
1. In the **Connect** tab, tap **Start discovery**.
2. On a nearby Windows 10/11 machine with Bluetooth enabled, a **Swift Pair** popup will appear.
3. Click **Connect / Pair**. Once paired and connected, the dashboard status changes to **HID ready**.

### 3. Run Payloads
1. Switch to the **Payloads** tab in the web dashboard.
2. Select **Notepad + Hello**, **Custom PS**, or write your own script.
3. Tap **Run**. The countdown will begin and the keystrokes will be typed into the connected PC.
4. Tap **Stop payload** at any time to immediately cancel typing and release all keys.

---

## Serial Console Commands (115200 Baud)

You can manage the device entirely without Wi-Fi using any serial monitor (PuTTY, Arduino IDE, miniterm) at **115200 baud**:

```text
help / menu       Show command summary
1 / start         Start BLE discovery advertising
0 / stop          Stop advertising / disconnect active session
2 / status        Show connection, security, and payload status
3 / profiles      List all available BLE appearance profiles
name <text>       Change advertised BLE device name
appearance <hex>  Set raw Bluetooth appearance code (e.g., appearance 0x0140)
duration <sec>    Set discovery timeout (5 to 60 seconds)
mode swift        Enable Microsoft Swift Pair broadcast
mode beacon       Enable standard BLE beacon mode
wifi              Display current Wi-Fi SSID and password
wifi set <s <p>   Update Wi-Fi SSID and password
4 / hid           Show HID payload menu
5 / hello         Execute Notepad + Hello test payload
payload begin     Enter interactive script entry mode (finish with END)
payload run       Execute loaded script
abort             Emergency abort: stops payload and releases keys
forget            Clear stored Bluetooth pairing bonds
```

---

## Payload Script Syntax

Custom scripts use clean, intuitive commands:

```text
STRING Hello from Maricha     # Types text
DELAY 500                     # Wait in milliseconds
ENTER                         # Press Enter key
GUI r                         # Windows Key + R (Run dialogue)
TAB / ESC / BACKSPACE         # Common navigation keys
LEFT / RIGHT / UP / DOWN      # Directional arrows
CTRL SHIFT ESC                # Task Manager shortcut
REM This is a comment         # Ignored line
```

---

## Educational & Legal Disclaimer

> [!WARNING]
> **THIS SOFTWARE IS INTENDED FOR EDUCATIONAL, RESEARCH, AND AUTHORIZED SECURITY TESTING PURPOSES ONLY.**
>
> Maricha is developed to help researchers, students, and engineers understand Bluetooth Low Energy protocols, Microsoft Swift Pair discovery behaviors, and USB/BLE Human Interface Device interactions.
>
> Testing this tool on any computer, network, or hardware without explicit prior written authorization from the owner is illegal and unethical. The author and contributors accept no liability and cannot be held responsible for any misuse, damage, or legal consequences caused by the use of this project. Always test responsibly in isolated environments.

---

**Developed & Maintained by [TechChip](https://www.youtube.com/@TechChipNet)**
