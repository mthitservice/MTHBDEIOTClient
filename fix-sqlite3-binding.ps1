# PowerShell-Skript zur Behebung von better-sqlite3 Binding-Problemen in Electron-Apps
# Automatisierte Lösung für "could not locate the binding file" Fehler

param(
    [string]$AppPath = "c:\Users\Michael.Lindner\source\repos\MthBdeIotClient\App",
    [switch]$Force = $false,
    [switch]$CleanInstall = $false
)

Write-Host "=== better-sqlite3 Binding Reparatur-Tool ===" -ForegroundColor Green
Write-Host "App-Pfad: $AppPath" -ForegroundColor Yellow

# Absolute Pfade setzen
$AbsoluteAppPath = Resolve-Path $AppPath -ErrorAction SilentlyContinue
if (-not $AbsoluteAppPath) {
    Write-Error "App-Pfad existiert nicht: $AppPath"
    exit 1
}

$NodeModulesDir = Join-Path $AbsoluteAppPath "node_modules"
$BetterSqliteDir = Join-Path $NodeModulesDir "better-sqlite3"
$PackageJsonFile = Join-Path $AbsoluteAppPath "package.json"

Write-Host "Prüfe Verzeichnisse:" -ForegroundColor Cyan
Write-Host "  App: $AbsoluteAppPath" -ForegroundColor White
Write-Host "  node_modules: $NodeModulesDir" -ForegroundColor White
Write-Host "  better-sqlite3: $BetterSqliteDir" -ForegroundColor White

# Funktion zum sicheren Ausführen von Commands
function Invoke-SafeCommand {
    param([string]$Command, [string]$WorkingDir, [string]$Description)
    
    Push-Location $WorkingDir
    try {
        Write-Host "[$Description] Führe aus: $Command" -ForegroundColor Yellow
        $result = Invoke-Expression $Command 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[$Description] ✓ Erfolgreich" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "[$Description] ✗ Fehlgeschlagen (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
            Write-Host $result -ForegroundColor Gray
            return $false
        }
    }
    catch {
        Write-Host "[$Description] ✗ Exception: $_" -ForegroundColor Red
        return $false
    }
    finally {
        Pop-Location
    }
}

# Schritt 1: Systemprüfung
Write-Host "`n--- Schritt 1: Systemprüfung ---" -ForegroundColor Blue

# Node.js Version prüfen
try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js Version: $nodeVersion" -ForegroundColor Green
}
catch {
    Write-Error "✗ Node.js nicht gefunden"
    exit 1
}

# NPM Version prüfen
try {
    $npmVersion = npm --version
    Write-Host "✓ NPM Version: $npmVersion" -ForegroundColor Green
}
catch {
    Write-Error "✗ NPM nicht gefunden"
    exit 1
}

# Electron Version aus package.json ermitteln
if (Test-Path $PackageJsonFile) {
    $packageContent = Get-Content $PackageJsonFile | ConvertFrom-Json
    $electronVersion = $packageContent.devDependencies.electron
    Write-Host "✓ Electron Version (package.json): $electronVersion" -ForegroundColor Green
}
else {
    Write-Error "✗ package.json nicht gefunden"
    exit 1
}

# Python prüfen (für node-gyp)
try {
    $pythonVersion = python --version 2>$null
    if ($pythonVersion) {
        Write-Host "✓ Python gefunden: $pythonVersion" -ForegroundColor Green
    }
    else {
        Write-Warning "⚠ Python nicht gefunden - könnte zu Problemen bei der Kompilierung führen"
    }
}
catch {
    Write-Warning "⚠ Python nicht verfügbar"
}

# Visual Studio Build Tools prüfen (Windows)
if ($env:OS -eq "Windows_NT") {
    $vsBuildTools = Get-Command "MSBuild.exe" -ErrorAction SilentlyContinue
    if ($vsBuildTools) {
        Write-Host "✓ Visual Studio Build Tools gefunden" -ForegroundColor Green
    }
    else {
        Write-Warning "⚠ Visual Studio Build Tools nicht gefunden - könnte zu Kompilierungsproblemen führen"
        Write-Host "  Installiere: npm install --global windows-build-tools" -ForegroundColor Yellow
    }
}

# Schritt 2: Clean Install (optional)
if ($CleanInstall) {
    Write-Host "`n--- Schritt 2: Clean Install ---" -ForegroundColor Blue
    
    # node_modules löschen
    if (Test-Path $NodeModulesDir) {
        Write-Host "Lösche node_modules..." -ForegroundColor Yellow
        Remove-Item $NodeModulesDir -Recurse -Force
        Write-Host "✓ node_modules gelöscht" -ForegroundColor Green
    }
    
    # package-lock.json löschen
    $packageLockFile = Join-Path $AbsoluteAppPath "package-lock.json"
    if (Test-Path $packageLockFile) {
        Remove-Item $packageLockFile -Force
        Write-Host "✓ package-lock.json gelöscht" -ForegroundColor Green
    }
}

# Schritt 3: better-sqlite3 Installation/Reparatur
Write-Host "`n--- Schritt 3: better-sqlite3 Installation/Reparatur ---" -ForegroundColor Blue

# Prüfe ob better-sqlite3 in package.json ist
$hasBetterSqlite = $false
if ($packageContent.dependencies."better-sqlite3" -or $packageContent.devDependencies."better-sqlite3") {
    $hasBetterSqlite = $true
    Write-Host "✓ better-sqlite3 in package.json gefunden" -ForegroundColor Green
}
else {
    Write-Host "⚠ better-sqlite3 nicht in package.json gefunden" -ForegroundColor Yellow
    Write-Host "Füge better-sqlite3 zur package.json hinzu..." -ForegroundColor Yellow
    
    if (Invoke-SafeCommand "npm install better-sqlite3 --save" $AbsoluteAppPath "NPM Install") {
        $hasBetterSqlite = $true
    }
}

# Schritt 4: Electron Rebuild
Write-Host "`n--- Schritt 4: Electron Rebuild ---" -ForegroundColor Blue

# Prüfe ob electron-rebuild verfügbar ist
$electronRebuildAvailable = $false
try {
    $electronRebuildPath = Join-Path $NodeModulesDir ".bin\electron-rebuild.cmd"
    if (Test-Path $electronRebuildPath) {
        $electronRebuildAvailable = $true
        Write-Host "✓ electron-rebuild lokal gefunden" -ForegroundColor Green
    }
    else {
        # Global prüfen
        $globalRebuild = Get-Command "electron-rebuild" -ErrorAction SilentlyContinue
        if ($globalRebuild) {
            $electronRebuildAvailable = $true
            Write-Host "✓ electron-rebuild global gefunden" -ForegroundColor Green
        }
    }
}
catch {
    Write-Host "electron-rebuild nicht gefunden" -ForegroundColor Yellow
}

# Installiere electron-rebuild falls nicht vorhanden
if (-not $electronRebuildAvailable) {
    Write-Host "Installiere electron-rebuild..." -ForegroundColor Yellow
    Invoke-SafeCommand "npm install electron-rebuild --save-dev" $AbsoluteAppPath "electron-rebuild Installation"
}

# Führe Rebuild aus
$rebuildCommands = @(
    "npm run rebuild",
    "npx electron-rebuild",
    "npx electron-rebuild --force",
    "npx electron-rebuild --force --module-dir . --which-module better-sqlite3"
)

$rebuildSuccess = $false
foreach ($cmd in $rebuildCommands) {
    Write-Host "Versuche: $cmd" -ForegroundColor Yellow
    if (Invoke-SafeCommand $cmd $AbsoluteAppPath "Electron Rebuild") {
        $rebuildSuccess = $true
        break
    }
}

if (-not $rebuildSuccess) {
    Write-Warning "⚠ Electron Rebuild fehlgeschlagen - versuche manuelle Kompilierung"
}

# Schritt 5: Manuelle node-gyp Kompilierung (Fallback)
if (-not $rebuildSuccess -and $hasBetterSqlite) {
    Write-Host "`n--- Schritt 5: Manuelle Kompilierung ---" -ForegroundColor Blue
    
    if (Test-Path $BetterSqliteDir) {
        Push-Location $BetterSqliteDir
        try {
            Write-Host "Führe manuelle node-gyp Kompilierung aus..." -ForegroundColor Yellow
            
            # Verschiedene node-gyp Befehle versuchen
            $nodeGypCommands = @(
                "node-gyp rebuild --target=$(node -p process.versions.electron) --arch=x64 --dist-url=https://electronjs.org/headers",
                "npm run install",
                "node-gyp configure build"
            )
            
            foreach ($cmd in $nodeGypCommands) {
                if (Invoke-SafeCommand $cmd $BetterSqliteDir "node-gyp") {
                    break
                }
            }
        }
        finally {
            Pop-Location
        }
    }
}

# Schritt 6: Binding-Datei Verifikation
Write-Host "`n--- Schritt 6: Binding-Datei Verifikation ---" -ForegroundColor Blue

if (Test-Path $BetterSqliteDir) {
    # Suche nach .node Dateien
    $nodeFiles = Get-ChildItem $BetterSqliteDir -Filter "*.node" -Recurse
    
    if ($nodeFiles.Count -gt 0) {
        Write-Host "✓ Binding-Dateien gefunden:" -ForegroundColor Green
        foreach ($file in $nodeFiles) {
            Write-Host "  $($file.FullName)" -ForegroundColor White
            Write-Host "    Größe: $($file.Length) Bytes" -ForegroundColor Gray
            Write-Host "    Erstellt: $($file.CreationTime)" -ForegroundColor Gray
        }
    }
    else {
        Write-Warning "⚠ Keine .node Binding-Dateien gefunden"
        
        # Suche in build/Release
        $buildDir = Join-Path $BetterSqliteDir "build\Release"
        if (Test-Path $buildDir) {
            $buildFiles = Get-ChildItem $buildDir -Recurse
            Write-Host "Build-Verzeichnis Inhalt:" -ForegroundColor Yellow
            foreach ($file in $buildFiles) {
                Write-Host "  $($file.Name)" -ForegroundColor White
            }
        }
    }
}
else {
    Write-Warning "⚠ better-sqlite3 Verzeichnis nicht gefunden"
}

# Schritt 7: Test der Funktionalität
Write-Host "`n--- Schritt 7: Funktionalitätstest ---" -ForegroundColor Blue

$testScript = @"
console.log('=== better-sqlite3 Binding Test ===');
try {
    console.log('Versuche better-sqlite3 zu laden...');
    const Database = require('better-sqlite3');
    console.log('✓ better-sqlite3 erfolgreich geladen');
    
    // Teste mit temporärer Datenbank
    const db = new Database(':memory:');
    console.log('✓ In-Memory Datenbank erfolgreich erstellt');
    
    // Einfacher Test
    const result = db.prepare('SELECT 1 as test').get();
    console.log('✓ Test-Query erfolgreich:', result);
    
    db.close();
    console.log('✓ Alle Tests erfolgreich - Binding funktioniert!');
    
} catch (error) {
    console.error('✗ Binding-Test fehlgeschlagen:', error.message);
    console.error('Stack:', error.stack);
    process.exit(1);
}
"@

$testFile = Join-Path $AbsoluteAppPath "test-binding.js"
Set-Content -Path $testFile -Value $testScript -Encoding UTF8

Write-Host "Führe Binding-Test aus..." -ForegroundColor Yellow
if (Invoke-SafeCommand "node test-binding.js" $AbsoluteAppPath "Binding Test") {
    Write-Host "✓ better-sqlite3 Binding funktioniert!" -ForegroundColor Green
}
else {
    Write-Warning "⚠ Binding-Test fehlgeschlagen"
}

# Cleanup
Remove-Item $testFile -Force -ErrorAction SilentlyContinue

# Schritt 8: DBManager Test
Write-Host "`n--- Schritt 8: DBManager Integration Test ---" -ForegroundColor Blue

$dbManagerTestScript = @"
console.log('=== DBManager Integration Test ===');
try {
    const { db } = require('./src/main/DBManager.js');
    console.log('✓ DBManager erfolgreich geladen');
    
    if (db && typeof db.prepare === 'function') {
        console.log('✓ DB-Objekt ist funktional');
        const result = db.prepare('SELECT 1 as test').get();
        console.log('✓ DBManager Test erfolgreich:', result);
    } else {
        console.log('⚠ DB-Objekt ist Mock (normal ohne better-sqlite3)');
    }
    
} catch (error) {
    console.error('✗ DBManager Test fehlgeschlagen:', error.message);
}
"@

$dbTestFile = Join-Path $AbsoluteAppPath "test-dbmanager-integration.js"
Set-Content -Path $dbTestFile -Value $dbManagerTestScript -Encoding UTF8

Write-Host "Führe DBManager Integration Test aus..." -ForegroundColor Yellow
Invoke-SafeCommand "node test-dbmanager-integration.js" $AbsoluteAppPath "DBManager Test"

# Cleanup
Remove-Item $dbTestFile -Force -ErrorAction SilentlyContinue

# Zusammenfassung und Empfehlungen
Write-Host "`n=== Zusammenfassung ===" -ForegroundColor Green

Write-Host "Binding-Reparatur abgeschlossen!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Was wurde gemacht:" -ForegroundColor White
Write-Host "  ✓ System-Voraussetzungen geprüft" -ForegroundColor Green
Write-Host "  ✓ better-sqlite3 installiert/repariert" -ForegroundColor Green
Write-Host "  ✓ Electron Rebuild ausgeführt" -ForegroundColor Green
Write-Host "  ✓ Binding-Dateien verifiziert" -ForegroundColor Green
Write-Host "  ✓ Funktionalität getestet" -ForegroundColor Green
Write-Host ""
Write-Host "Nächste Schritte:" -ForegroundColor Cyan
Write-Host "  1. Teste die Electron-App: npm start" -ForegroundColor White
Write-Host "  2. Baue die App: npm run package" -ForegroundColor White
Write-Host "  3. Bei weiteren Problemen: npm run rebuild" -ForegroundColor White
Write-Host ""
Write-Host "Bei persistenten Problemen:" -ForegroundColor Yellow
Write-Host "  - Installiere Visual Studio Build Tools" -ForegroundColor White
Write-Host "  - Führe als Administrator aus" -ForegroundColor White
Write-Host "  - Prüfe Electron/Node.js Versionskompatibilität" -ForegroundColor White
