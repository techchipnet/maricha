# MARICHA
**Powered by: TechChip**

[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](https://github.com)
[![Hardware](https://img.shields.io/badge/Target-ESP32--C5-orange.svg)](https://www.espressif.com)
[![Firmware](https://img.shields.io/badge/Release-Pre--built%20Binaries-brightgreen.svg)](firmware/)
[![Architecture](https://img.shields.io/badge/Arch-RISC--V%2032--bit-red.svg)](https://github.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Community](https://img.shields.io/badge/Community-TechChip-blueviolet.svg)](https://www.youtube.com/@TechChipNet)

---

## Overview

**MARICHA** is an advanced wireless BLE emulation and HID injection firmware developed for the **ESP32-C5** platform. Inspired by the mythological master of disguise and illusions, MARICHA enables your micro-controller to broadcast multi-device BLE identities—including Android TV, Apple TV, Wireless Keyboards, Mice, Gamepads, AirTags, JioTags, and Heart Rate Sensors—while simultaneously hosting a standalone Wi-Fi access point with an onboard web dashboard.

When paired over Bluetooth, MARICHA functions as a legitimate BLE Human Interface Device (HID) capable of executing programmable keystroke payloads.

---

## Key Features

- **Multi-Device BLE Disguise:** Emulate 10+ preset Bluetooth identities with matching appearances:
  - Android TV & Apple TV (Media Player / Display)
  - Wireless Keyboard, Mouse, Gamepad & Joystick
  - Digital Pen / Digitizer
  - AirTag & JioTag (Tracker Beacon)
  - Heart Rate Sensor
  - Custom Identity (Custom Name up to 25 characters & appearance hex codes)
- **Dynamic BLE Icons:** Modern web interface dynamically switches SVG icons based on the currently selected device appearance.
- **Microsoft Swift Pair:** Broadcasts Windows Swift Pair beacons to trigger instant pairing popups on Windows 10/11 machines.
- **Normal Beacon Mode:** Standard connectable BLE advertising without vendor-specific tags.
- **Zero-Install Web Dashboard:** Built-in Wi-Fi SoftAP (`192.168.4.1`) serves a clean, responsive mobile/desktop management interface.
- **Built-in Keystroke Payloads:**
  - **Notepad + Hello:** Opens Notepad on Windows (`Win + R`) and automatically writes `Hello From MARICHA`.
  - **Custom PowerShell:** Type any custom PowerShell or commands in the web textbox; MARICHA opens windows terminal and run it automatically.
  - **Custom Script Runner:** Supports up to 512 bytes of ASCII keystroke instructions (DuckyScript style: `STRING`, `DELAY`, `ENTER`, `CTRL`, `ALT`, `GUI`, `LEFT`, `RIGHT`, `UP`, `DOWN`).
- **Wi-Fi Credential Management:** Modify SoftAP SSID and Password on the fly directly from the web settings or serial console (stored in NVS flash).
- **Serial Console Control (CLI):** MARICHA can be fully controlled without a browser via any serial terminal at 115200 baud. Simply type `help` or `menu` to view the complete interactive command list.
- **Dual Console Support:** Pre-compiled binaries available for both standard UART bridges (CH340/CP2102) and native ESP32 USB-Serial-JTAG ports.

---

## Supported Hardware & Compatibility

| Hardware | Compatibility Status | Notes |
|---|---|---|
| **ESP32-C5** (Beta/DevKit) | **Fully Supported (Current Release)** | Requires at least 4MB Flash. Dual-band 2.4/5 GHz RISC-V core. |
| **ESP32-S3** | Architecture Compatible | Different binary build required (Xtensa dual-core target). |
| **ESP32-WROOM-32 / 32U** | BLE 4.2 / Legacy Compatible | Classic ESP32 core; requires separate compile target for Bluedroid/NimBLE. |

> [!NOTE]
> The binaries provided in this repository (`firmware/uart/` and `firmware/usb/`) are strictly built for the **ESP32-C5** chip with 4MB+ flash. Do not flash these specific binaries directly onto standard ESP32 or ESP32-S3 boards.

---

## Repository Structure

```text
├── firmware/
│   ├── uart/                    # For boards using CH340 / CP2102 USB-to-UART bridge
│   │   ├── app.bin              # Main application firmware (offset: 0x10000)
│   │   ├── bootloader.bin       # ESP32-C5 bootloader (offset: 0x2000)
│   │   ├── partition-table.bin  # Partition table (offset: 0x8000)
│   │   └── sdkconfig.txt        # Build configuration parameters
│   └── usb/                     # For boards connected via native USB-Serial-JTAG port
│       ├── app.bin
│       ├── bootloader.bin
│       ├── partition-table.bin
│       └── sdkconfig.txt
├── payloads/                    # Reference payload scripts (.txt)
│   ├── custom-ps.txt
│   ├── custom-text-demo.txt
│   └── notepad-hello.txt
├── SHA256SUMS.txt               # Verification checksums for release binaries
└── README.md
```

---

## Flashing Pre-Built Binaries

### Step 1: Install Flashing Tool
Make sure you have Python 3 installed, then install `esptool`:

```bash
pip install --upgrade esptool
```

### Step 2: Identify Your COM Port
1. Connect your ESP32-C5 board to your computer using a reliable USB data cable.
2. Check your port:
   - **Windows:** Open **Device Manager** > expand **Ports (COM & LPT)** (e.g. `COM5`).
   - **Linux / macOS:** Run `ls /dev/ttyUSB*` or `ls /dev/ttyACM*`.

### Step 3: Choose the Correct Firmware Variant
- Use **`firmware/uart/`** if your board uses an onboard USB-to-UART chip (such as CH340, CP2102, FTDI).
- Use **`firmware/usb/`** if your board connects directly through the native USB-Serial-JTAG pins (labeled `USB` on most dev boards).

---

### Step 4: Flash the Board

Replace `COM5` below with your board's actual serial port.

#### Option A: Flashing UART Variant (CH340 / CP2102)
```bash
python -m esptool --chip esp32c5 -p COM5 -b 460800 --before default_reset --after hard_reset --no-stub write_flash --flash_mode dio --flash_size 4MB --flash_freq 80m 0x2000 firmware/uart/bootloader.bin 0x8000 firmware/uart/partition-table.bin 0x10000 firmware/uart/app.bin
```

#### Option B: Flashing Native USB Variant (USB-Serial-JTAG)
```bash
python -m esptool --chip esp32c5 -p COM5 -b 460800 --before default_reset --after hard_reset --no-stub write_flash --flash_mode dio --flash_size 4MB --flash_freq 80m 0x2000 firmware/usb/bootloader.bin 0x8000 firmware/usb/partition-table.bin 0x10000 firmware/usb/app.bin
```

> [!TIP]
> If `esptool` fails to connect with `A fatal error occurred: Failed to connect to ESP32-C5: No serial data received`, hold down the **BOOT** (IO0) button on your board, press and release the **RESET / EN** button, and then release the **BOOT** button. Run the flash command again.

---

## Getting Started & Usage

1. **Power On:** Once flashed, reboot or power-cycle your board.
2. **Connect to Wi-Fi:**
   - Scan for Wi-Fi networks on your smartphone or PC.
   - Connect to the access point named **`Maricha-XXXX`** (where `XXXX` corresponds to your board's unique MAC address).
   - Enter your default password (or the random key shown in serial monitor).
3. **Open the Web UI:**
   - Open any browser and navigate to:
     ```text
     http://192.168.4.1
     ```
4. **Broadcast Discovery:**
   - In the **Connect** tab, tap **Start discovery** to begin advertising over Bluetooth.
   - On Windows, a Swift Pair notification will appear in the Action Center.
   - Pair the device. Once paired, the status will show **HID ready**.
5. **Trigger Keystroke Payloads:**
   - Open the **Payloads** tab.
   - Choose between **Notepad + Hello**, **Custom PS**, or **Custom payload**.
   - Tap **Run** to execute the sequence.

---

## Serial Console Commands (115200 Baud)

You can also control MARICHA directly via any serial terminal (e.g. PuTTY, Arduino Serial Monitor, Screen) set to **115200 baud**. Type `help` or `menu` at any time to display the full command list:

```text
 help / menu         Display this interactive command menu
 1 / start           Start BLE discovery broadcast
 0 / stop            Stop advertising / disconnect active session
 2 / status          Display real-time connection status
 3 / profiles        List available BLE appearance profiles
 name <text>         Set custom BLE name (up to 25 characters)
 name tv             Reset identity to Android TV
 appearance <hex>    Set raw appearance (e.g. appearance 0x03C1)
 duration <sec>      Set discovery timeout (5 - 60 seconds)
 mode swift          Enable Microsoft Swift Pair beacon mode
 mode beacon         Enable standard BLE beacon mode
 wifi                Display current Wi-Fi SSID & Password
 wifi set <s <p>     Update SoftAP SSID and Password (min 8 chars)
 4 / hid             List HID payload menu
 5 / hello           Execute Notepad + Hello preset
 payload begin       Enter interactive custom script mode (finish with END)
 payload run         Execute the stored custom payload
 abort               Immediately cancel active payload and release held keys
 forget              Clear stored Bluetooth pairing bonds
```

---

## Payload Script Syntax

Custom payloads support standard DuckyScript-style commands (up to 512 bytes / 64 lines):

```text
STRING Hello World           # Types literal text (US English layout)
DELAY 500                    # Pause in milliseconds (0 - 5000)
ENTER                        # Press and release Enter
TAB / ESC / BACKSPACE        # Standard utility keys
LEFT / RIGHT / UP / DOWN     # Arrow keys
GUI r                        # Windows Key + R (Run prompt)
CTRL SHIFT ESC               # Multi-key combination
REM This is a comment        # Ignored by compiler
```

---

## Disclaimer & Educational Use

> [!WARNING]
> **FOR EDUCATIONAL, RESEARCH, AND AUTHORIZED SECURITY TESTING PURPOSES ONLY.**
> 
> MARICHA is created to demonstrate wireless protocol behavior, Bluetooth Low Energy discovery mechanisms (including Swift Pair and beacon profiles), and standard Human Interface Device (HID) communication.
> 
> Do not use this tool on any system or device without explicit, written permission from the owner. The author and contributors assume no liability and are not responsible for any misuse, damage, or legal consequences resulting from the use of this software. Always test responsibly in an isolated, controlled lab environment.

---

**Developed & Maintained by [TechChip](https://www.youtube.com/@TechChipNet)**
