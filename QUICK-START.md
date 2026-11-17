# MARICHA Quick Start Guide

**Powered by: TechChip**

### 1. Flash Firmware
- **Method 1 (Web Flasher):** Double-click `run-web-flasher.bat` or open `web-flasher.html` in Chrome/Edge, select your board (`ESP32-C5`, `ESP32-S3`, or `ESP32-WROOM-32U`), click **Connect & Flash**, verify in popup, and flash!
- **Method 2 (PowerShell):** Run `.\flash-windows.ps1 -Port COM5 -Chip esp32-s3 -Console uart`.

### 2. Connect to Board Wi-Fi
- Power the board via USB.
- On your phone or laptop, connect to the Wi-Fi network:
  - **SSID:** `Maricha-XXXX`
  - **Default Password:** `12345678`
- Open your browser and navigate to: **`http://192.168.4.1`**

### 3. Pair with Windows PC
- On the web dashboard, tap **Start discovery** in the **Connect** tab.
- On a nearby Windows 10/11 PC with Bluetooth enabled, click the **Swift Pair** popup notification to pair.
- Once connected, the dashboard displays **HID ready**.

### 4. Execute Keystroke Payloads
- Switch to the **Payloads** tab.
- Choose **Notepad + Hello**, **Custom PowerShell**, or enter your custom keystroke script.
- Tap **Run** to execute. Tap **Stop payload** to abort anytime.

### 5. Serial Console (Optional)
- Connect any serial terminal (or use the **Serial Monitor** tab in `web-flasher.html`) at **115200 baud**.
- Type `menu`, `status`, or `wifi` to view or manage credentials directly over USB.
