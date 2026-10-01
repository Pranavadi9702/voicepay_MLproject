# VoicePay Backend Starter Script
# Run this from the thackur project root.
# It sets up adb reverse port forwarding and starts the Flask server.

Write-Host "=== VoicePay Backend Startup ===" -ForegroundColor Cyan

# ── 1. ADB reverse: forward phone's 127.0.0.1:5002 to PC's 5002 ──
Write-Host "`n[1] Setting up ADB port forwarding..." -ForegroundColor Yellow
$adbResult = adb reverse tcp:5002 tcp:5002 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "    adb reverse tcp:5002 tcp:5002 ... OK" -ForegroundColor Green
} else {
    Write-Host "    WARNING: adb reverse failed. Phone may not be connected." -ForegroundColor DarkYellow
    Write-Host "    Output: $adbResult" -ForegroundColor DarkYellow
    Write-Host "    Continuing anyway (WiFi fallback may work)..." -ForegroundColor DarkYellow
}

# Also forward port 5001 in case any legacy calls still target it
adb reverse tcp:5001 tcp:5001 2>&1 | Out-Null

# ── 2. Start Flask app from the python/ directory ──
Write-Host "`n[2] Starting Flask backend on port 5002..." -ForegroundColor Yellow
$pyDir = Join-Path $PSScriptRoot "python"
Set-Location $pyDir
Write-Host "    Working directory: $pyDir" -ForegroundColor DarkGray
Write-Host "    Server will be available at http://127.0.0.1:5002" -ForegroundColor Green
Write-Host "    Press Ctrl+C to stop.`n" -ForegroundColor DarkGray

python app.py
