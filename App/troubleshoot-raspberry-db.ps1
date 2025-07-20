# Raspberry Pi Database Troubleshooting Script
# Dieses Script hilft bei der Diagnose von Datenbankproblemen auf Raspberry Pi

Write-Host "=== Raspberry Pi Database Troubleshooting ===" -ForegroundColor Green

# 1. System-Information
Write-Host "`n1. System-Information:" -ForegroundColor Yellow
Write-Host "Architektur: $(uname -m)" -ForegroundColor White
Write-Host "Betriebssystem: $(lsb_release -d)" -ForegroundColor White
Write-Host "Benutzer: $(whoami)" -ForegroundColor White
Write-Host "Home-Verzeichnis: $HOME" -ForegroundColor White

# 2. Überprüfe mögliche Datenbankpfade
Write-Host "`n2. Überprüfe Datenbankpfade:" -ForegroundColor Yellow

$databasePaths = @(
    "$HOME/.mthbdeiotclient/database",
    "/var/lib/mthbdeiotclient/database",
    "/tmp/mthbdeiotclient/database",
    "$HOME/mthbdeiotclient-data/database"
)

foreach ($dbPath in $databasePaths) {
    Write-Host "`n📁 Pfad: $dbPath" -ForegroundColor Cyan

    if (Test-Path $dbPath) {
        Write-Host "  ✅ Verzeichnis existiert" -ForegroundColor Green

        # Überprüfe Berechtigungen
        try {
            $testFile = Join-Path $dbPath ".write-test"
            "test" | Out-File -FilePath $testFile -Encoding UTF8
            Remove-Item $testFile -Force
            Write-Host "  ✅ Schreibberechtigung vorhanden" -ForegroundColor Green
        }
        catch {
            Write-Host "  ❌ Keine Schreibberechtigung: $($_.Exception.Message)" -ForegroundColor Red
        }

        # Suche nach SQLite-Dateien
        $sqliteFiles = Get-ChildItem -Path $dbPath -Filter "*.sqlite" -ErrorAction SilentlyContinue
        if ($sqliteFiles) {
            Write-Host "  📄 SQLite-Dateien gefunden:" -ForegroundColor White
            foreach ($file in $sqliteFiles) {
                $size = [math]::Round($file.Length / 1KB, 2)
                Write-Host "    - $($file.Name) (${size} KB)" -ForegroundColor Gray
            }
        }
        else {
            Write-Host "  ℹ️  Keine SQLite-Dateien gefunden" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "  ❌ Verzeichnis existiert nicht" -ForegroundColor Red

        # Versuche Verzeichnis zu erstellen
        try {
            New-Item -Path $dbPath -ItemType Directory -Force | Out-Null
            Write-Host "  ✅ Verzeichnis erfolgreich erstellt" -ForegroundColor Green
        }
        catch {
            Write-Host "  ❌ Verzeichnis konnte nicht erstellt werden: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# 3. Überprüfe Electron-Logs
Write-Host "`n3. Electron-Logs überprüfen:" -ForegroundColor Yellow

$logPaths = @(
    "$HOME/.config/mthbdeiotclient/logs",
    "$HOME/.local/share/mthbdeiotclient/logs",
    "/tmp/electron-logs"
)

foreach ($logPath in $logPaths) {
    if (Test-Path $logPath) {
        Write-Host "✅ Log-Verzeichnis gefunden: $logPath" -ForegroundColor Green

        $logFiles = Get-ChildItem -Path $logPath -Filter "*.log" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 3

        if ($logFiles) {
            foreach ($logFile in $logFiles) {
                Write-Host "`n📄 Log-Datei: $($logFile.Name) ($(Get-Date $logFile.LastWriteTime -Format 'dd.MM.yyyy HH:mm:ss'))" -ForegroundColor Cyan

                # Suche nach Datenbankfehlern
                $dbErrors = Select-String -Path $logFile.FullName -Pattern "database|sqlite|permission|denied" -SimpleMatch -CaseSensitive:$false | Select-Object -Last 5

                if ($dbErrors) {
                    Write-Host "  🔍 Relevante Log-Einträge:" -ForegroundColor White
                    foreach ($logEntry in $dbErrors) {
                        Write-Host "    $($logEntry.Line)" -ForegroundColor Gray
                    }
                }
            }
        }
    }
    else {
        Write-Host "ℹ️  Log-Verzeichnis nicht gefunden: $logPath" -ForegroundColor Yellow
    }
}

# 4. Systemd Service Status (falls vorhanden)
Write-Host "`n4. Systemd Service Status:" -ForegroundColor Yellow
try {
    $serviceStatus = systemctl status mthbdeiotclient --no-pager 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Service gefunden:" -ForegroundColor Green
        Write-Host $serviceStatus -ForegroundColor White
    }
    else {
        Write-Host "ℹ️  Kein systemd Service gefunden" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "ℹ️  Systemctl nicht verfügbar oder Service nicht gefunden" -ForegroundColor Yellow
}

# 5. Empfohlene Lösungen
Write-Host "`n5. Empfohlene Lösungen:" -ForegroundColor Yellow
Write-Host "🔧 Lösungsvorschläge für Raspberry Pi:" -ForegroundColor Magenta
Write-Host "  1. Erstelle manuell Datenbankverzeichnis:" -ForegroundColor White
Write-Host "     mkdir -p ~/.mthbdeiotclient/database" -ForegroundColor Gray
Write-Host "     chmod 755 ~/.mthbdeiotclient/database" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Setze Umgebungsvariable:" -ForegroundColor White
Write-Host "     export RASPBERRY_PI=true" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Überprüfe Speicherplatz:" -ForegroundColor White
Write-Host "     df -h" -ForegroundColor Gray
Write-Host ""
Write-Host "  4. Überprüfe Dateisystem-Berechtigungen:" -ForegroundColor White
Write-Host "     ls -la ~/.mthbdeiotclient/" -ForegroundColor Gray

Write-Host "`n=== Troubleshooting abgeschlossen ===" -ForegroundColor Green
