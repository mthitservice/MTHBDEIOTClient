# MTH BDE IoT Client - PowerShell Verwaltungstool
# Zentrales Skript für alle wichtigen Operationen

param(
    [Parameter(Position = 0)]
    [ValidateSet('help', 'build', 'dev', 'release', 'debug', 'deploy', 'trigger', 'validate', 'fix', 'dpi-test')]
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
    Write-Host "🍓 dpi-test  - Raspberry Pi DPI Test" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Beispiele:" -ForegroundColor Yellow
    Write-Host "  .\mth-manager.ps1 dev" -ForegroundColor White
    Write-Host "  .\mth-manager.ps1 build raspberry" -ForegroundColor White
    Write-Host "  .\mth-manager.ps1 release 1.0.50" -ForegroundColor White
    Write-Host "  .\mth-manager.ps1 dpi-test 1.2" -ForegroundColor White
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
    & ".\powershell-scripts\deploy.ps1"
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

function Invoke-DpiTest {
    param([string]$ZoomLevel = "auto")
    
    Write-Host "🍓 Starte Raspberry Pi DPI Test..." -ForegroundColor Magenta
    
    if (-not (Test-Path "powershell-scripts\test-raspberry-dpi.ps1")) {
        Write-Host "❌ DPI-Test Skript nicht gefunden!" -ForegroundColor Red
        return
    }
    
    if ($ZoomLevel -ne "") {
        & ".\powershell-scripts\test-raspberry-dpi.ps1" $ZoomLevel
    } else {
        & ".\powershell-scripts\test-raspberry-dpi.ps1" "auto"
    }
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
    'dpi-test' { Invoke-DpiTest -ZoomLevel $Parameter }
    default { 
        Write-Host "❌ Unbekannter Befehl: $Command" -ForegroundColor Red
        Show-Help 
    }
}

Write-Host ""
