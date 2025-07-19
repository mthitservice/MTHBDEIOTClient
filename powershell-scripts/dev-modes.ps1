Write-Host "🖥️  MTH BDE IoT Client - Entwicklungsmodi" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Wählen Sie einen Entwicklungsmodus:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1️⃣  Standard (jetzt 1920x1080!)" -ForegroundColor Green
Write-Host "2️⃣  Klassisch (1024x728)" -ForegroundColor White
Write-Host "3️⃣  1920x1080 Fullscreen" -ForegroundColor White
Write-Host "4️⃣  Kiosk-Modus (1920x1080)" -ForegroundColor White
Write-Host "5️⃣  Raspberry Pi Test-Modus" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Ihre Wahl (1-5)"

switch ($choice) {
    "1" {
        Write-Host "🚀 Starte Standard-Modus (1920x1080)..." -ForegroundColor Green
        npm start
    }
    "2" {
        Write-Host "🚀 Starte klassischen Modus (1024x728)..." -ForegroundColor Green
        npm run start:standard
    }
    "3" {
        Write-Host "🚀 Starte 1920x1080 Fullscreen-Modus..." -ForegroundColor Green
        npm run start:fullscreen
    }
    "4" {
        Write-Host "🚀 Starte Kiosk-Modus (1920x1080)..." -ForegroundColor Green
        npm run start:kiosk
    }
    "5" {
        Write-Host "🚀 Starte Raspberry Pi Test-Modus..." -ForegroundColor Green
        $env:RASPBERRY_PI = "true"
        $env:DEV_1080 = "true"
        npm start
    }
    default {
        Write-Host "❌ Ungültige Auswahl" -ForegroundColor Red
        exit 1
    }
}
