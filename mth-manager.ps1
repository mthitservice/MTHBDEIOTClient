# MTH BDE IoT Client - PowerShell Verwaltungstool
# Zentrales Skript für alle wichtigen Operationen

param(
    [Parameter(Position = 0)]
    [ValidateSet('help', 'build', 'dev', 'release', 'debug', 'deploy', 'trigger', 'validate', 'fix', 'rpi-test', 'install-fonts')]
    [string]$Command = 'help',
    
    [Parameter(Position = 1)]
    [string]$Parameter = ""
)

function Show-Header {
    Write-Host ""
    Write-Host "🚀 MTH BDE IoT Client - PowerShell Verwaltung" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host ""
}

function Show-Help {
    Write-Host "Verfügbare Befehle:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📦 build     - App bauen (dev/prod/raspberry)" -ForegroundColor Cyan
    Write-Host "🔧 dev       - Entwicklungsmodus starten" -ForegroundColor Cyan
    Write-Host "🚀 release   - Release erstellen" -ForegroundColor Cyan
    Write-Host "🐛 debug     - Debug-Modi für DEB-Pakete" -ForegroundColor Cyan
    Write-Host "📤 deploy    - Deployment starten" -ForegroundColor Cyan
    Write-Host "⚡ trigger   - Pipeline triggern" -ForegroundColor Cyan
    Write-Host "✅ validate  - DEB-Paket validieren" -ForegroundColor Cyan
    Write-Host "🔧 fix       - Schnelle Fehlerbehebung" -ForegroundColor Cyan
    Write-Host "🍓 rpi-test  - Raspberry Pi Auflösung testen" -ForegroundColor Cyan
    Write-Host "🔤 install-fonts - Segoe UI Fonts für Raspberry Pi installieren" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Beispiele:" -ForegroundColor Yellow
    Write-Host "  .\mth-manager.ps1 dev" -ForegroundColor White
    Write-Host "  .\mth-manager.ps1 build raspberry" -ForegroundColor White
    Write-Host "  .\mth-manager.ps1 release 1.0.50" -ForegroundColor White
    Write-Host "  .\mth-manager.ps1 rpi-test large" -ForegroundColor White
    Write-Host "  .\mth-manager.ps1 install-fonts" -ForegroundColor White
    Write-Host ""
}

function Invoke-DevModes {
    Write-Host "🔧 Starte Entwicklungsmodi..." -ForegroundColor Green
    & ".\powershell-scripts\dev-modes.ps1"
}

function Invoke-Build {
    param([string]$Target = "")
    
    Write-Host "📦 Starte Build-Prozess..." -ForegroundColor Green
    
    if (-not (Test-Path "App\package.json")) {
        Write-Host "❌ Error: App\package.json nicht gefunden!" -ForegroundColor Red
        Write-Host "   Bitte führe dieses Skript im Repository-Root aus." -ForegroundColor Red
        return
    }
    
    Set-Location "App"
    
    switch ($Target.ToLower()) {
        "raspberry" {
            Write-Host "🍓 Raspberry Pi Build..." -ForegroundColor Magenta
            npm run build:raspberry
        }
        "dev" {
            Write-Host "🔧 Development Build..." -ForegroundColor Cyan
            npm run build:dev
        }
        "prod" {
            Write-Host "🚀 Production Build..." -ForegroundColor Green
            npm run build:prod
        }
        default {
            Write-Host "🏗️ Standard Build..." -ForegroundColor Blue
            npm run build
        }
    }
    
    Set-Location ".."
}

function Invoke-Release {
    param([string]$Version = "")
    
    Write-Host "🚀 Starte Release-Prozess..." -ForegroundColor Green
    
    if ($Version -ne "") {
        & ".\powershell-scripts\create-manual-release.ps1" -Version $Version
    }
    else {
        & ".\powershell-scripts\create-manual-release.ps1"
    }
}

function Invoke-Debug {
    Write-Host "🐛 Starte DEB Debug-Tools..." -ForegroundColor Yellow
    & ".\powershell-scripts\debug-deb.ps1"
}

function Invoke-Deploy {
    Write-Host "📤 Starte Deployment..." -ForegroundColor Green
    & ".\App\deploy.ps1"
}

function Invoke-Trigger {
    Write-Host "⚡ Triggere Pipeline..." -ForegroundColor Blue
    & ".\powershell-scripts\trigger-pipeline.ps1"
}

function Invoke-Validate {
    Write-Host "✅ Validiere DEB-Paket..." -ForegroundColor Green
    & ".\powershell-scripts\validate-deb-package.ps1"
}

function Invoke-Fix {
    Write-Host "🔧 Starte schnelle Fehlerbehebung..." -ForegroundColor Yellow
    & ".\powershell-scripts\quick-fix-deb.ps1"
}

function Invoke-RaspberryTest {
    param([string]$Resolution = "large")
    
    Write-Host "🍓 Starte Raspberry Pi Auflösungstest..." -ForegroundColor Magenta
    
    if (-not (Test-Path "powershell-scripts\raspberry-dev-test.ps1")) {
        Write-Host "❌ Raspberry Pi Test-Skript nicht gefunden!" -ForegroundColor Red
        return
    }
    
    & ".\powershell-scripts\raspberry-dev-test.ps1" $Resolution
}

function Invoke-InstallFonts {
    Write-Host "🔤 Installiere Segoe UI Fonts für Raspberry Pi..." -ForegroundColor Blue
    Write-Host ""
    
    $scriptPath = "App\scripts\install-segoe-ui-fonts.sh"
    
    if (-not (Test-Path $scriptPath)) {
        Write-Host "❌ Font-Installations-Skript nicht gefunden: $scriptPath" -ForegroundColor Red
        return
    }
    
    Write-Host "📋 Anweisungen für Raspberry Pi:" -ForegroundColor Yellow
    Write-Host "1. Kopiere das Skript auf den Raspberry Pi:" -ForegroundColor White
    Write-Host "   scp $scriptPath pi@raspberry-ip:~/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Führe das Skript auf dem Raspberry Pi aus:" -ForegroundColor White
    Write-Host "   sudo bash install-segoe-ui-fonts.sh" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Kopiere Segoe UI Fonts von Windows:" -ForegroundColor White
    Write-Host "   Von: C:\Windows\Fonts\" -ForegroundColor Gray
    Write-Host "   Nach: /usr/share/fonts/truetype/segoe-ui/" -ForegroundColor Gray
    Write-Host ""
    Write-Host "✅ Font-Installations-Skript bereit!" -ForegroundColor Green
    Write-Host "   Datei: $scriptPath" -ForegroundColor Gray
}

# Hauptlogik
Show-Header

switch ($Command.ToLower()) {
    'help' { Show-Help }
    'build' { Invoke-Build -Target $Parameter }
    'dev' { Invoke-DevModes }
    'release' { Invoke-Release -Version $Parameter }
    'debug' { Invoke-Debug }
    'deploy' { Invoke-Deploy }
    'trigger' { Invoke-Trigger }
    'validate' { Invoke-Validate }
    'fix' { Invoke-Fix }
    'rpi-test' { Invoke-RaspberryTest -Resolution $Parameter }
    'install-fonts' { Invoke-InstallFonts }
    default { 
        Write-Host "❌ Unbekannter Befehl: $Command" -ForegroundColor Red
        Show-Help 
    }
}

Write-Host ""
