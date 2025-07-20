# Raspberry Pi Database Fix Script
# Führt automatische Reparaturen für Datenbankprobleme auf Raspberry Pi durch

param(
    [switch]$CreateDirs,
    [switch]$SetPermissions,
    [switch]$SetEnvVar,
    [switch]$All
)

Write-Host "=== Raspberry Pi Database Fix Script ===" -ForegroundColor Green

if ($All) {
    $CreateDirs = $true
    $SetPermissions = $true
    $SetEnvVar = $true
}

# 1. Erstelle Datenbankverzeichnisse
if ($CreateDirs -or $All) {
    Write-Host "`n1. Erstelle Datenbankverzeichnisse:" -ForegroundColor Yellow

    $databasePaths = @(
        "$HOME/.mthbdeiotclient/database",
        "$HOME/mthbdeiotclient-data/database"
    )

    foreach ($dbPath in $databasePaths) {
        try {
            if (!(Test-Path $dbPath)) {
                New-Item -Path $dbPath -ItemType Directory -Force | Out-Null
                Write-Host "✅ Erstellt: $dbPath" -ForegroundColor Green
            }
            else {
                Write-Host "ℹ️  Existiert bereits: $dbPath" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "❌ Fehler beim Erstellen von $dbPath`: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# 2. Setze Berechtigungen (Linux/macOS)
if ($SetPermissions -or $All) {
    Write-Host "`n2. Setze Berechtigungen:" -ForegroundColor Yellow

    if ($IsLinux -or $IsMacOS) {
        $commands = @(
            "chmod 755 ~/.mthbdeiotclient/database",
            "chmod 755 ~/mthbdeiotclient-data/database"
        )

        foreach ($cmd in $commands) {
            try {
                Invoke-Expression $cmd
                Write-Host "✅ Ausgeführt: $cmd" -ForegroundColor Green
            }
            catch {
                Write-Host "❌ Fehler: $cmd - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host "ℹ️  Berechtigungen nur auf Linux/macOS relevant" -ForegroundColor Yellow
    }
}

# 3. Setze Umgebungsvariable
if ($SetEnvVar -or $All) {
    Write-Host "`n3. Setze Umgebungsvariable:" -ForegroundColor Yellow

    try {
        $env:RASPBERRY_PI = "true"
        Write-Host "✅ RASPBERRY_PI=true gesetzt (aktuelle Session)" -ForegroundColor Green

        # Für dauerhafte Einstellung (Linux)
        if ($IsLinux) {
            $bashrcPath = "$HOME/.bashrc"
            $exportLine = "export RASPBERRY_PI=true"

            if (Test-Path $bashrcPath) {
                $bashrcContent = Get-Content $bashrcPath
                if ($bashrcContent -notcontains $exportLine) {
                    Add-Content -Path $bashrcPath -Value $exportLine
                    Write-Host "✅ Zu .bashrc hinzugefügt: $exportLine" -ForegroundColor Green
                }
                else {
                    Write-Host "ℹ️  Bereits in .bashrc vorhanden" -ForegroundColor Yellow
                }
            }
        }
    }
    catch {
        Write-Host "❌ Fehler beim Setzen der Umgebungsvariable: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 4. Test Datenbankzugriff
Write-Host "`n4. Teste Datenbankzugriff:" -ForegroundColor Yellow

$testPaths = @(
    "$HOME/.mthbdeiotclient/database",
    "$HOME/mthbdeiotclient-data/database",
    "/tmp"
)

foreach ($testPath in $testPaths) {
    if (Test-Path $testPath) {
        try {
            $testFile = Join-Path $testPath "test.sqlite"
            "test" | Out-File -FilePath $testFile -Encoding UTF8
            Remove-Item $testFile -Force
            Write-Host "✅ Schreibtest erfolgreich: $testPath" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Schreibtest fehlgeschlagen: $testPath - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "⚠️  Pfad nicht gefunden: $testPath" -ForegroundColor Yellow
    }
}

# 5. Zeige Empfehlungen
Write-Host "`n5. Empfehlungen:" -ForegroundColor Yellow
Write-Host "🔧 Für beste Ergebnisse auf Raspberry Pi:" -ForegroundColor Magenta
Write-Host "  1. Führe dieses Script mit -All Parameter aus" -ForegroundColor White
Write-Host "  2. Starte die Anwendung neu" -ForegroundColor White
Write-Host "  3. Überprüfe Logs auf Datenbankfehler" -ForegroundColor White
Write-Host "  4. Bei anhaltenden Problemen: troubleshoot-raspberry-db.sh ausführen" -ForegroundColor White

Write-Host "`n=== Reparatur abgeschlossen ===" -ForegroundColor Green
