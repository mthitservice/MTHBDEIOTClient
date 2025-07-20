# PowerShell Test-Skript für den robusten DBManager
# Führt verschiedene Tests aus um die Datenbankfunktionalität zu überprüfen

param(
    [string]$AppPath = "c:\Users\Michael.Lindner\source\repos\MthBdeIotClient\App",
    [switch]$CleanStart = $false
)

Write-Host "=== DBManager Test Script ===" -ForegroundColor Green
Write-Host "App-Pfad: $AppPath" -ForegroundColor Yellow

# Absolute Pfade setzen
$AbsoluteAppPath = Resolve-Path $AppPath -ErrorAction SilentlyContinue
if (-not $AbsoluteAppPath) {
    Write-Error "App-Pfad existiert nicht: $AppPath"
    exit 1
}

$DatabaseDir = Join-Path $AbsoluteAppPath "public\database"
$DatabaseFile = Join-Path $DatabaseDir "bde.sqlite"
$NodeModulesDir = Join-Path $AbsoluteAppPath "node_modules"
$PackageJsonFile = Join-Path $AbsoluteAppPath "package.json"

Write-Host "Absolute Pfade:" -ForegroundColor Cyan
Write-Host "  App: $AbsoluteAppPath" -ForegroundColor White
Write-Host "  Database Dir: $DatabaseDir" -ForegroundColor White
Write-Host "  Database File: $DatabaseFile" -ForegroundColor White

# Funktion zum Ausführen von Node.js Commands
function Invoke-NodeCommand {
    param([string]$Command, [string]$WorkingDir)
    
    Push-Location $WorkingDir
    try {
        Write-Host "Führe aus: $Command" -ForegroundColor Yellow
        $result = Invoke-Expression $Command 2>&1
        Write-Host $result
        return $LASTEXITCODE -eq 0
    }
    catch {
        Write-Error "Fehler beim Ausführen: $_"
        return $false
    }
    finally {
        Pop-Location
    }
}

# Test 1: Überprüfe ob package.json existiert
Write-Host "`n--- Test 1: Package.json Überprüfung ---" -ForegroundColor Blue
if (Test-Path $PackageJsonFile) {
    Write-Host "✓ package.json gefunden: $PackageJsonFile" -ForegroundColor Green
    $packageContent = Get-Content $PackageJsonFile | ConvertFrom-Json
    Write-Host "  Projektname: $($packageContent.name)" -ForegroundColor White
}
else {
    Write-Error "✗ package.json nicht gefunden: $PackageJsonFile"
    exit 1
}

# Test 2: Überprüfe Node.js Installation
Write-Host "`n--- Test 2: Node.js Installation ---" -ForegroundColor Blue
try {
    $nodeVersion = node --version 2>$null
    if ($nodeVersion) {
        Write-Host "✓ Node.js gefunden: $nodeVersion" -ForegroundColor Green
    }
    else {
        Write-Error "✗ Node.js nicht gefunden oder nicht im PATH"
        exit 1
    }
}
catch {
    Write-Error "✗ Node.js nicht verfügbar: $_"
    exit 1
}

# Test 3: Überprüfe NPM-Dependencies
Write-Host "`n--- Test 3: NPM Dependencies ---" -ForegroundColor Blue
if (-not (Test-Path $NodeModulesDir)) {
    Write-Host "node_modules nicht gefunden, installiere Dependencies..." -ForegroundColor Yellow
    if (-not (Invoke-NodeCommand "npm install" $AbsoluteAppPath)) {
        Write-Error "✗ NPM install fehlgeschlagen"
        exit 1
    }
}

# Überprüfe wichtige Dependencies
$requiredDeps = @("better-sqlite3", "dotenv")
foreach ($dep in $requiredDeps) {
    $depPath = Join-Path $NodeModulesDir $dep
    if (Test-Path $depPath) {
        Write-Host "✓ Dependency gefunden: $dep" -ForegroundColor Green
    }
    else {
        Write-Warning "⚠ Dependency fehlt: $dep"
    }
}

# Test 4: Clean Start Option
if ($CleanStart) {
    Write-Host "`n--- Test 4: Clean Start (Datenbank löschen) ---" -ForegroundColor Blue
    if (Test-Path $DatabaseFile) {
        Remove-Item $DatabaseFile -Force
        Write-Host "✓ Alte Datenbankdatei gelöscht: $DatabaseFile" -ForegroundColor Green
    }
    if (Test-Path $DatabaseDir) {
        Remove-Item $DatabaseDir -Recurse -Force
        Write-Host "✓ Datenbankverzeichnis gelöscht: $DatabaseDir" -ForegroundColor Green
    }
}

# Test 5: Erstelle .env-Datei für Test
Write-Host "`n--- Test 5: Test-Umgebung vorbereiten ---" -ForegroundColor Blue
$envFile = Join-Path $AbsoluteAppPath ".env"
$envContent = @"
NODE_ENV=development
DB_NAME=bde.sqlite
"@

Set-Content -Path $envFile -Value $envContent -Encoding UTF8
Write-Host "✓ .env-Datei erstellt: $envFile" -ForegroundColor Green

# Test 6: Erstelle Test-Script für DBManager
Write-Host "`n--- Test 6: DBManager Test-Script erstellen ---" -ForegroundColor Blue
$testScript = @"
// Test-Script für DBManager
console.log('=== DBManager Test ===');
console.log('Arbeitsverzeichnis:', process.cwd());
console.log('__dirname:', __dirname);
console.log('NODE_ENV:', process.env.NODE_ENV);

try {
  console.log('Lade DBManager...');
  const { db } = require('./src/main/DBManager.js');
  
  console.log('✓ DBManager erfolgreich geladen');
  
  // Test: Datenbankverbindung
  console.log('Teste Datenbankverbindung...');
  const result = db.prepare('SELECT 1 as test').get();
  console.log('✓ Datenbankverbindung erfolgreich:', result);
  
  // Test: Config-Tabelle
  console.log('Teste Config-Tabelle...');
  const tables = db.prepare("SELECT name FROM sqlite_master WHERE type='table'").all();
  console.log('✓ Verfügbare Tabellen:', tables.map(t => t.name));
  
  // Test: Insert/Select in Config-Tabelle
  console.log('Teste Insert/Select...');
  const insertStmt = db.prepare('INSERT OR REPLACE INTO config (key, value) VALUES (?, ?)');
  insertStmt.run('test_key', 'test_value');
  
  const selectStmt = db.prepare('SELECT value FROM config WHERE key = ?');
  const value = selectStmt.get('test_key');
  console.log('✓ Insert/Select erfolgreich:', value);
  
  // Test: Datenbankinfo
  console.log('Datenbankinfo:');
  const pragma = db.prepare('PRAGMA journal_mode').get();
  console.log('  Journal Mode:', pragma.journal_mode);
  
  const dbSize = db.prepare('SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()').get();
  console.log('  Größe:', dbSize.size, 'Bytes');
  
  console.log('=== Alle Tests erfolgreich! ===');
  
} catch (error) {
  console.error('✗ Fehler beim DBManager Test:', error.message);
  console.error('Stack:', error.stack);
  process.exit(1);
}
"@

$testScriptFile = Join-Path $AbsoluteAppPath "test-dbmanager.js"
Set-Content -Path $testScriptFile -Value $testScript -Encoding UTF8
Write-Host "✓ Test-Script erstellt: $testScriptFile" -ForegroundColor Green

# Test 7: Führe DBManager Test aus
Write-Host "`n--- Test 7: DBManager Test ausführen ---" -ForegroundColor Blue
if (Invoke-NodeCommand "node test-dbmanager.js" $AbsoluteAppPath) {
    Write-Host "✓ DBManager Test erfolgreich!" -ForegroundColor Green
}
else {
    Write-Error "✗ DBManager Test fehlgeschlagen!"
    exit 1
}

# Test 8: Verifikation der erstellten Dateien
Write-Host "`n--- Test 8: Verifikation der erstellten Dateien ---" -ForegroundColor Blue
$filesToCheck = @(
    @{Path = $DatabaseDir; Type = "Directory"; Name = "Datenbankverzeichnis" },
    @{Path = $DatabaseFile; Type = "File"; Name = "Datenbankdatei" }
)

foreach ($item in $filesToCheck) {
    if (Test-Path $item.Path) {
        if ($item.Type -eq "File") {
            $size = (Get-Item $item.Path).Length
            Write-Host "✓ $($item.Name) existiert: $($item.Path) ($size Bytes)" -ForegroundColor Green
        }
        else {
            Write-Host "✓ $($item.Name) existiert: $($item.Path)" -ForegroundColor Green
        }
    }
    else {
        Write-Error "✗ $($item.Name) fehlt: $($item.Path)"
    }
}

# Test 9: Datenbankinhalt prüfen
Write-Host "`n--- Test 9: Datenbankinhalt prüfen ---" -ForegroundColor Blue
$sqliteCommand = Get-Command sqlite3 -ErrorAction SilentlyContinue
if ($sqliteCommand) {
    Write-Host "SQLite3 CLI gefunden, prüfe Datenbankinhalt..." -ForegroundColor Yellow
    $tables = & sqlite3 $DatabaseFile ".tables"
    Write-Host "Tabellen in der Datenbank: $tables" -ForegroundColor White
    
    $configCount = & sqlite3 $DatabaseFile "SELECT COUNT(*) FROM config;"
    Write-Host "Einträge in config-Tabelle: $configCount" -ForegroundColor White
}
else {
    Write-Warning "SQLite3 CLI nicht verfügbar, überspringe Datenbankinhalt-Prüfung"
}

# Cleanup
Write-Host "`n--- Cleanup ---" -ForegroundColor Blue
Remove-Item $testScriptFile -Force -ErrorAction SilentlyContinue
Write-Host "✓ Test-Script entfernt" -ForegroundColor Green

Write-Host "`n=== Alle Tests abgeschlossen! ===" -ForegroundColor Green
Write-Host "Die Datenbank wurde erfolgreich erstellt und getestet." -ForegroundColor Cyan
Write-Host "Datenbankpfad: $DatabaseFile" -ForegroundColor White
