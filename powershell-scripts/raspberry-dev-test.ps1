# Raspberry Pi Development Testing Tool
# Emuliert verschiedene Raspberry Pi Auflösungen für Windows 11 Development

param(
    [Parameter(Position = 0)]
    [ValidateSet('small', 'medium', 'large', 'fullscreen', 'help')]
    [string]$Resolution = 'help'
)

function Show-Help {
    Write-Host ""
    Write-Host "🍓 Raspberry Pi Development Testing Tool" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Verwendung:" -ForegroundColor Yellow
    Write-Host "  .\raspberry-dev-test.ps1 [Resolution]" -ForegroundColor White
    Write-Host ""
    Write-Host "Verfügbare Auflösungen:" -ForegroundColor Yellow
    Write-Host "  small      - 1024x768 (Ältere/kleinere Displays)" -ForegroundColor Cyan
    Write-Host "  medium     - 1280x720 (Standard kleinere Displays)" -ForegroundColor Cyan
    Write-Host "  large      - 1920x1080 (Standard Raspberry Pi 4)" -ForegroundColor Cyan
    Write-Host "  fullscreen - 1920x1080 Vollbild (Kiosk-Modus)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Beispiele:" -ForegroundColor Yellow
    Write-Host "  .\raspberry-dev-test.ps1 large" -ForegroundColor White
    Write-Host "  .\raspberry-dev-test.ps1 small" -ForegroundColor White
    Write-Host ""
    Write-Host "Hinweise:" -ForegroundColor Magenta
    Write-Host "• DevTools öffnen sich automatisch im Raspberry Pi Modus" -ForegroundColor Gray
    Write-Host "• Verwenden Sie die DevTools für responsive Design Tests" -ForegroundColor Gray
    Write-Host "• CSS Media Queries werden automatisch getestet" -ForegroundColor Gray
}

function Start-RaspberryTest {
    param([string]$Mode)
    
    Write-Host ""
    Write-Host "🍓 Starte Raspberry Pi Emulation..." -ForegroundColor Green
    Write-Host "Modus: $Mode" -ForegroundColor Cyan
    Write-Host ""
    
    # In das App-Verzeichnis wechseln
    $AppPath = "App"
    if (-not (Test-Path $AppPath)) {
        Write-Host "❌ App-Verzeichnis nicht gefunden!" -ForegroundColor Red
        Write-Host "Stellen Sie sicher, dass Sie das Script aus dem Projektroot ausführen." -ForegroundColor Yellow
        return
    }
    
    Set-Location $AppPath
    
    switch ($Mode) {
        'small' {
            Write-Host "📱 Teste kleine Raspberry Pi Displays (1024x768)" -ForegroundColor Yellow
            $env:RASPBERRY_PI = "true"
            npm run start:raspberry-small
        }
        'medium' {
            Write-Host "📺 Teste mittlere Raspberry Pi Displays (1280x720)" -ForegroundColor Yellow
            $env:RASPBERRY_PI = "true"
            $env:DEV_1080 = "false"
            npm run start:raspberry
        }
        'large' {
            Write-Host "🖥️ Teste große Raspberry Pi Displays (1920x1080)" -ForegroundColor Yellow
            $env:RASPBERRY_PI = "true"
            npm run start:raspberry
        }
        'fullscreen' {
            Write-Host "🖼️ Teste Raspberry Pi Vollbild-Modus (1920x1080)" -ForegroundColor Yellow
            $env:RASPBERRY_PI = "true"
            npm run start:raspberry-fullscreen
        }
    }
    
    # Cleanup
    Remove-Item Env:RASPBERRY_PI -ErrorAction SilentlyContinue
    Remove-Item Env:DEV_1080 -ErrorAction SilentlyContinue
    
    # Zurück zum ursprünglichen Verzeichnis
    Set-Location ..
}

# Hauptlogik
switch ($Resolution.ToLower()) {
    'help' { Show-Help }
    'small' { Start-RaspberryTest -Mode 'small' }
    'medium' { Start-RaspberryTest -Mode 'medium' }
    'large' { Start-RaspberryTest -Mode 'large' }
    'fullscreen' { Start-RaspberryTest -Mode 'fullscreen' }
    default { 
        Write-Host "❌ Unbekannte Auflösung: $Resolution" -ForegroundColor Red
        Show-Help 
    }
}
