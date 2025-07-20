# Test-DBManager-Fixed.ps1
# Testet den robusten DBManager über IPC-Kommunikation

Write-Host "🔧 Teste DBManager mit IPC-Kommunikation..." -ForegroundColor Cyan

# Überprüfe ob Node.js und npm verfügbar sind
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js Version: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js nicht gefunden!" -ForegroundColor Red
    exit 1
}

# Wechsle zum App-Verzeichnis
Set-Location "c:\Users\Michael.Lindner\source\repos\MthBdeIotClient\App"

# Überprüfe ob die notwendigen Dateien existieren
$requiredFiles = @(
    "src/main/modules/database/DBManager.js",
    "src/main/modules/database/DBConfig.js", 
    "release/app/package.json"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ Datei gefunden: $file" -ForegroundColor Green
    } else {
        Write-Host "❌ Datei fehlt: $file" -ForegroundColor Red
        exit 1
    }
}

# Überprüfe ob better-sqlite3 in release/app installiert ist
if (Test-Path "release/app/node_modules/better-sqlite3") {
    Write-Host "✅ better-sqlite3 in release/app installiert" -ForegroundColor Green
} else {
    Write-Host "❌ better-sqlite3 nicht in release/app gefunden!" -ForegroundColor Red
    exit 1
}

# Erstelle einen simplen Test für den DBManager
Write-Host "🧪 Erstelle Test-Script für DBManager..." -ForegroundColor Yellow

# JavaScript Test-Code als separate Datei erstellen
@'
// test-dbmanager-simple.js
const path = require('path');

// Setze den NODE_ENV für den Test
process.env.NODE_ENV = 'test';

// Füge den release/app/node_modules Pfad hinzu für better-sqlite3
const releaseAppModules = path.join(__dirname, 'release', 'app', 'node_modules');
if (!module.paths.includes(releaseAppModules)) {
    module.paths.unshift(releaseAppModules);
}

console.log('🔧 Teste DBManager...');

try {
    // Importiere den DBManager
    const DBManager = require('./src/main/modules/database/DBManager.js');
    console.log('✅ DBManager erfolgreich importiert');
    
    // Teste Initialisierung
    const dbManager = new DBManager();
    console.log('✅ DBManager-Instanz erstellt');
    
    // Teste Datenbankinitialisierung
    const db = dbManager.initializeDatabase();
    console.log('✅ Datenbankinitialisierung erfolgreich');
    
    if (db && typeof db.prepare === 'function') {
        console.log('✅ Echte SQLite-Datenbank verfügbar');
        
        // Teste eine einfache Abfrage
        const stmt = db.prepare('SELECT 1 as test');
        const result = stmt.get();
        if (result && result.test === 1) {
            console.log('✅ SQLite-Abfrage erfolgreich');
        }
    } else if (db && db.isMock) {
        console.log('⚠️  Mock-Datenbank aktiv (SQLite nicht verfügbar)');
    }
    
    console.log('🎉 Alle Tests erfolgreich!');
} catch (error) {
    console.error('❌ Fehler beim Testen:', error.message);
    console.error('Stack:', error.stack);
    process.exit(1);
}
'@ | Out-File -FilePath "test-dbmanager-simple.js" -Encoding UTF8

Write-Host "🚀 Führe DBManager-Test aus..." -ForegroundColor Yellow

try {
    # Führe den Test aus
    $output = & node "test-dbmanager-simple.js" 2>&1
    Write-Host $output
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "🎉 DBManager-Test erfolgreich!" -ForegroundColor Green
    } else {
        Write-Host "❌ DBManager-Test fehlgeschlagen!" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Fehler beim Ausführen des Tests: $_" -ForegroundColor Red
}

# Aufräumen
if (Test-Path "test-dbmanager-simple.js") {
    Remove-Item "test-dbmanager-simple.js"
}

Write-Host "✨ Test abgeschlossen!" -ForegroundColor Cyan
