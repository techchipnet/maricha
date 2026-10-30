param(
    [Parameter(Mandatory=$true, HelpMessage="Serial port of your board (e.g. COM5)")]
    [ValidatePattern('^COM[1-9][0-9]*$')]
    [string]$Port,

    [ValidateSet('esp32-c5', 'esp32-s3', 'esp32-wroom-32u', 'c5', 's3', 'wroom', 'esp32')]
    [string]$Chip = 'esp32-c5',

    [ValidateSet('uart', 'usb')]
    [string]$Console = 'uart',

    [ValidateSet(115200, 230400, 460800, 921600)]
    [int]$Baud = 460800,

    [switch]$EraseFlash
)

$ErrorActionPreference = 'Stop'

# Normalize chip and configure flash parameters
switch ($Chip) {
    { $_ -in 'esp32-c5', 'c5' } {
        $chipFolder       = 'esp32-c5'
        $esptoolChip      = 'esp32c5'
        $bootloaderOffset = '0x2000'
        $flashFreq        = '80m'
        $useNoStub        = $true
    }
    { $_ -in 'esp32-s3', 's3' } {
        $chipFolder       = 'esp32-s3'
        $esptoolChip      = 'esp32s3'
        $bootloaderOffset = '0x0'
        $flashFreq        = '80m'
        $useNoStub        = $false
    }
    { $_ -in 'esp32-wroom-32u', 'wroom', 'esp32' } {
        $chipFolder       = 'esp32-wroom-32u'
        $esptoolChip      = 'esp32'
        $bootloaderOffset = '0x1000'
        $flashFreq        = '40m'
        $useNoStub        = $false

        if ($Console -eq 'usb') {
            Write-Host "Error: ESP32-WROOM-32U uses an external USB-to-UART bridge. Native USB console is not supported on this chip." -ForegroundColor Red
            Write-Host "Please use: -Console uart" -ForegroundColor Yellow
            exit 1
        }
    }
}

# Locate Python
$pyCmd = 'python'
if (Get-Command py -ErrorAction SilentlyContinue) {
    $pyCmd = 'py'
} elseif (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Warning: Python executable not found in PATH. Defaulting to 'python'." -ForegroundColor Yellow
}

# Validate firmware directory and files
$firmwareDir   = Join-Path $PSScriptRoot "firmware\$chipFolder\$Console"
$bootloaderBin = Join-Path $firmwareDir 'bootloader.bin'
$partitionBin  = Join-Path $firmwareDir 'partition-table.bin'
$appBin        = Join-Path $firmwareDir 'app.bin'

if (!(Test-Path $bootloaderBin) -or !(Test-Path $partitionBin) -or !(Test-Path $appBin)) {
    Write-Host "Error: Firmware binaries not found in: $firmwareDir" -ForegroundColor Red
    Write-Host "Ensure the folder contains bootloader.bin, partition-table.bin, and app.bin." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  Maricha Firmware Flasher - powered by: TechChip" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Target Chip   : $chipFolder ($esptoolChip)"
Write-Host "Console Type  : $Console"
Write-Host "Serial Port   : $Port"
Write-Host "Baud Rate     : $Baud"
Write-Host "Bootloader    : 0x$($bootloaderOffset.Substring(2)) -> $bootloaderBin"
Write-Host "Partition     : 0x8000 -> $partitionBin"
Write-Host "Application   : 0x10000 -> $appBin"
Write-Host "----------------------------------------------------------"

if ($EraseFlash) {
    Write-Host "Erasing entire flash memory (clearing old NVS/data)..." -ForegroundColor Magenta
    $eraseArgs = @('-m', 'esptool', '--chip', $esptoolChip, '--port', $Port, '--baud', $Baud, 'erase_flash')
    if ($pyCmd -eq 'py') {
        & py -3 $eraseArgs
    } else {
        & python $eraseArgs
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Erase failed! Please put board in download mode and retry." -ForegroundColor Red
        exit 1
    }
    Write-Host "Erase completed successfully." -ForegroundColor Green
}

Write-Host "Connecting and flashing device..." -ForegroundColor Green
Write-Host ""

# Construct esptool arguments
$flashArgs = @(
    '-m', 'esptool',
    '--chip', $esptoolChip,
    '--port', $Port,
    '--baud', $Baud,
    '--before', 'default_reset',
    '--after', 'hard_reset'
)

if ($useNoStub) {
    $flashArgs += '--no-stub'
}

$flashArgs += @(
    'write_flash',
    '--flash_mode', 'dio',
    '--flash_size', '4MB',
    '--flash_freq', $flashFreq,
    $bootloaderOffset, $bootloaderBin,
    '0x8000', $partitionBin,
    '0x10000', $appBin
)

if ($pyCmd -eq 'py') {
    & py -3 $flashArgs
} else {
    & python $flashArgs
}

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "----------------------------------------------------------" -ForegroundColor Red
    Write-Host "Flashing failed! (Exit code: $LASTEXITCODE)" -ForegroundColor Red
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host " 1. If connection timed out, hold the board's BOOT (IO0) button, press and release RESET/EN once, then release BOOT."
    Write-Host " 2. Try lower baud rate by adding: -Baud 115200"
    Write-Host " 3. Verify that your port ($Port) is not open in another serial monitor or software."
    Write-Host "----------------------------------------------------------" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  Flash Complete! Firmware successfully written." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Next Steps:"
Write-Host " 1. Power-cycle or press RESET/EN on your board."
Write-Host " 2. Connect to Wi-Fi SSID: Maricha-XXXX"
Write-Host " 3. Open Web Dashboard: http://192.168.4.1"
Write-Host " 4. Or open Serial Monitor at 115200 baud (type 'wifi' or 'help')."
Write-Host ""
