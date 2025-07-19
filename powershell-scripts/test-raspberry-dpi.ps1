# Raspberry Pi DPI Testing Tool
# Test verschiedene Zoom-Level für optimale Darstellung

param(
    [Parameter(Position = 0)]
    [ValidateSet('1.0', '1.1', '1.2', '1.3', '1.4', '1.5', 'auto', 'reset')]
    [string]$ZoomLevel = 'auto'
)

function Show-Header {
    Write-Host ""
    Write-Host "🍓 Raspberry Pi DPI Testing Tool" -ForegroundColor Green
    Write-Host "=================================" -ForegroundColor Green
    Write-Host ""
}

function Test-ZoomLevel {
    param([string]$Level)
    
    Write-Host "🔍 Testing zoom level: $Level" -ForegroundColor Cyan
    
    # Setze Umgebungsvariable für den Test
    $env:RASPBERRY_DPI_ZOOM = $Level
    $env:RASPBERRY_PI = "true"
    
    Write-Host "   Starting app with zoom level $Level..." -ForegroundColor Yellow
    Write-Host "   Press Ctrl+C to stop and try next level" -ForegroundColor Yellow
    Write-Host ""
    
    # Starte App im Test-Modus
    try {
        & npm start
    }
    catch {
        Write-Host "   App was stopped." -ForegroundColor Yellow
    }
}

function Show-Help {
    Write-Host "Verfügbare Zoom-Level:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1.0   - Standard (100%)" -ForegroundColor White
    Write-Host "1.1   - Leicht vergrößert (110%)" -ForegroundColor White
    Write-Host "1.2   - Empfohlen für Raspberry Pi (120%)" -ForegroundColor Green
    Write-Host "1.3   - Groß (130%)" -ForegroundColor White
    Write-Host "1.4   - Sehr groß (140%)" -ForegroundColor White
    Write-Host "1.5   - Maximum (150%)" -ForegroundColor White
    Write-Host "auto  - Automatische Erkennung" -ForegroundColor Cyan
    Write-Host "reset - Alle Einstellungen zurücksetzen" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verwendung:" -ForegroundColor Yellow
    Write-Host "  .\test-raspberry-dpi.ps1 1.2" -ForegroundColor White
    Write-Host "  .\test-raspberry-dpi.ps1 auto" -ForegroundColor White
    Write-Host ""
}

function Reset-Settings {
    Write-Host "🔄 Zurücksetzen der DPI-Einstellungen..." -ForegroundColor Yellow
    
    Remove-Item Env:RASPBERRY_DPI_ZOOM -ErrorAction SilentlyContinue
    Remove-Item Env:RASPBERRY_PI -ErrorAction SilentlyContinue
    
    Write-Host "✅ Einstellungen zurückgesetzt" -ForegroundColor Green
}

function Auto-Detect {
    Write-Host "🔍 Automatische DPI-Erkennung..." -ForegroundColor Cyan
    Write-Host ""
    
    # Prüfe Bildschirmauflösung (nur auf Windows möglich)
    try {
        $resolution = Get-WmiObject -Class Win32_VideoController | Select-Object CurrentHorizontalResolution, CurrentVerticalResolution
        if ($resolution.CurrentHorizontalResolution -eq 1920 -and $resolution.CurrentVerticalResolution -eq 1080) {
            Write-Host "📺 1920x1080 erkannt - empfohlener Zoom: 1.2" -ForegroundColor Green
            return
        }
    }
    catch {
        Write-Host "⚠️  Auflösung konnte nicht automatisch erkannt werden" -ForegroundColor Yellow
    }
    
    Write-Host "🍓 Raspberry Pi Modus - verwende Standard-Zoom: 1.2" -ForegroundColor Green
}

function Interactive-Test {
    Write-Host "🧪 Interaktiver DPI-Test" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Dieser Test führt Sie durch verschiedene Zoom-Level." -ForegroundColor Yellow
    Write-Host "Drücken Sie Ctrl+C um zum nächsten Level zu wechseln." -ForegroundColor Yellow
    Write-Host ""
    
    $testLevels = @("1.0", "1.1", "1.2", "1.3", "1.4", "1.5")
    
    foreach ($level in $testLevels) {
        Write-Host "Teste Zoom-Level: $level" -ForegroundColor Cyan
        Read-Host "Drücken Sie Enter um fortzufahren oder Ctrl+C zum Abbrechen"
        Test-ZoomLevel $level
        Write-Host ""
    }
    
    Write-Host "🎯 Test abgeschlossen!" -ForegroundColor Green
    Write-Host "Welches Zoom-Level war am besten lesbar?" -ForegroundColor Yellow
    $preferred = Read-Host "Eingabe (1.0-1.5)"
    
    if ($preferred -match '^1\.[0-5]$') {
        Write-Host "💾 Empfohlenes Zoom-Level: $preferred" -ForegroundColor Green
        Write-Host "Setzen Sie RASPBERRY_DPI_ZOOM=$preferred in der .env Datei" -ForegroundColor Cyan
    }
}

# Hauptlogik
Show-Header

# Prüfe ob wir im App-Verzeichnis sind
if (-not (Test-Path "package.json")) {
    Write-Host "❌ Fehler: package.json nicht gefunden!" -ForegroundColor Red
    Write-Host "   Bitte führen Sie dieses Skript im App-Verzeichnis aus." -ForegroundColor Red
    exit 1
}

switch ($ZoomLevel) {
    'reset' { 
        Reset-Settings
    }
    'auto' { 
        Auto-Detect
        # Verwende 1.2 als Standard für Raspberry Pi
        Test-ZoomLevel "1.2"
    }
    'interactive' {
        Interactive-Test
    }
    default { 
        if ($ZoomLevel -match '^1\.[0-5]$') {
            Test-ZoomLevel $ZoomLevel
        }
        else {
            Write-Host "❌ Ungültiges Zoom-Level: $ZoomLevel" -ForegroundColor Red
            Show-Help
        }
    }
}

Write-Host ""
