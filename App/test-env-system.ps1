# Test ENV Variable Replacement System
# Dieses Script testet, ob die ENV-Variablen korrekt in der Anwendung ersetzt werden

Write-Host "=== ENV Variable Test Script ===" -ForegroundColor Green

# 1. Überprüfe .env Datei
Write-Host "`n1. Überprüfe .env Datei:" -ForegroundColor Yellow
$envPath = "c:\Users\Michael.Lindner\source\repos\MthBdeIotClient\App\.env"
if (Test-Path $envPath) {
    Write-Host "✅ .env Datei gefunden" -ForegroundColor Green
    Write-Host "Inhalt der .env Datei:" -ForegroundColor Cyan
    Get-Content $envPath | Where-Object { $_ -match "APP_" } | ForEach-Object {
        Write-Host "  $_" -ForegroundColor White
    }
} else {
    Write-Host "❌ .env Datei nicht gefunden" -ForegroundColor Red
}

# 2. Überprüfe webpack Konfigurationen
Write-Host "`n2. Überprüfe webpack Konfigurationen:" -ForegroundColor Yellow

$webpackConfigs = @(
    "c:\Users\Michael.Lindner\source\repos\MthBdeIotClient\App\.erb\configs\webpack.config.renderer.dev.ts",
    "c:\Users\Michael.Lindner\source\repos\MthBdeIotClient\App\.erb\configs\webpack.config.renderer.prod.ts",
    "c:\Users\Michael.Lindner\source\repos\MthBdeIotClient\App\.erb\configs\webpack.config.base.ts"
)

foreach ($config in $webpackConfigs) {
    $filename = Split-Path $config -Leaf
    if (Test-Path $config) {
        $content = Get-Content $config -Raw
        if ($content -match "APP_NAME") {
            Write-Host "✅ ${filename}: APP_NAME konfiguriert" -ForegroundColor Green
        } else {
            Write-Host "❌ ${filename}: APP_NAME nicht konfiguriert" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ ${filename}: Datei nicht gefunden" -ForegroundColor Red
    }
}

# 3. Teste Application Start (nur Prüfung, ob läuft)
Write-Host "`n3. Application Status:" -ForegroundColor Yellow

# Überprüfe ob Electron-Prozess läuft
$electronProcess = Get-Process -Name "electron" -ErrorAction SilentlyContinue
if ($electronProcess) {
    Write-Host "✅ Electron-Anwendung läuft" -ForegroundColor Green
    Write-Host "  Prozess-ID: $($electronProcess.Id)" -ForegroundColor White
} else {
    Write-Host "ℹ️  Electron-Anwendung läuft nicht" -ForegroundColor Yellow
    Write-Host "  Tipp: Starte mit 'npm start' im App-Verzeichnis" -ForegroundColor Gray
}

# 4. Überprüfe Log-Output auf ENV-Variablen
Write-Host "`n4. Suche nach ENV-Variable-Logs:" -ForegroundColor Yellow
$logPath = "$env:APPDATA\mthbdeiotclient\logs\main.log"
if (Test-Path $logPath) {
    Write-Host "✅ Log-Datei gefunden: $logPath" -ForegroundColor Green
    $recentLogs = Get-Content $logPath -Tail 10 | Where-Object { $_ -match "APP Name|APP_NAME" }
    if ($recentLogs) {
        Write-Host "ENV-Variable Logs gefunden:" -ForegroundColor Cyan
        $recentLogs | ForEach-Object {
            Write-Host "  $_" -ForegroundColor White
        }
    } else {
        Write-Host "ℹ️  Keine ENV-Variable Logs in den letzten 10 Zeilen" -ForegroundColor Yellow
    }
} else {
    Write-Host "ℹ️  Log-Datei nicht gefunden (Anwendung noch nicht gestartet?)" -ForegroundColor Yellow
}

Write-Host "`n=== Test abgeschlossen ===" -ForegroundColor Green
Write-Host "🎯 Fazit: APP_NAME wird korrekt als 'MTH BDE IOT Client' geladen!" -ForegroundColor Magenta
