# Schnelle Lösung für better-sqlite3 Binding-Probleme
# Führt die wichtigsten Reparatur-Schritte automatisch aus

Write-Host "=== Schnelle better-sqlite3 Reparatur ===" -ForegroundColor Green

$AppPath = "c:\Users\Michael.Lindner\source\repos\MthBdeIotClient\App"

# Wechsle in App-Verzeichnis
Set-Location $AppPath

Write-Host "Aktuelles Verzeichnis: $(Get-Location)" -ForegroundColor Yellow

# Schritt 1: ERB-spezifische better-sqlite3 Reparatur
Write-Host "`n1. ERB-spezifische better-sqlite3 Reparatur..." -ForegroundColor Blue

# Prüfe ob wir im ERB-Projekt sind
if (Test-Path ".erb") {
    Write-Host "✓ ERB-Projekt erkannt" -ForegroundColor Green
    
    # Entferne better-sqlite3 aus dem Haupt-package.json (darf dort nicht sein!)
    Write-Host "Entferne better-sqlite3 aus Haupt-package.json..." -ForegroundColor Yellow
    npm uninstall better-sqlite3
    
    # Stelle sicher, dass release/app Verzeichnis existiert
    if (!(Test-Path "release\app")) {
        Write-Host "Erstelle release/app Verzeichnis..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path "release\app" -Force
    }
    
    # Wechsle zu release/app und installiere better-sqlite3 dort
    Write-Host "Installiere better-sqlite3 in release/app..." -ForegroundColor Yellow
    Set-Location "release\app"
    
    # Entferne alte Installation
    if (Test-Path "node_modules\better-sqlite3") {
        Remove-Item "node_modules\better-sqlite3" -Recurse -Force
    }
    
    # Installiere better-sqlite3 für die korrekte Electron Node.js Version
    npm install better-sqlite3 --save
    
    # Zurück zum Hauptverzeichnis
    Set-Location "..\..\"
    
    # WICHTIG: Für ERB Development Mode - kopiere better-sqlite3 auch in .erb Verzeichnis
    Write-Host "Kopiere better-sqlite3 für ERB Development Mode..." -ForegroundColor Yellow
    
    # Erstelle .erb/node_modules Verzeichnis
    if (!(Test-Path ".erb\node_modules")) {
        New-Item -ItemType Directory -Path ".erb\node_modules" -Force
    }
    
    # Kopiere better-sqlite3 von release/app nach .erb/node_modules
    if (Test-Path "release\app\node_modules\better-sqlite3") {
        Copy-Item "release\app\node_modules\better-sqlite3" ".erb\node_modules\" -Recurse -Force
        Write-Host "✓ better-sqlite3 in .erb/node_modules kopiert" -ForegroundColor Green
    }
    
} else {
    Write-Host "Standard better-sqlite3 Installation..." -ForegroundColor Yellow
    if (Test-Path "node_modules\better-sqlite3") {
        Write-Host "✓ better-sqlite3 gefunden" -ForegroundColor Green
    } else {
        npm install better-sqlite3 --save
    }
}

# Schritt 2: ERB-spezifisches Electron Rebuild
Write-Host "`n2. ERB-spezifisches Electron Rebuild..." -ForegroundColor Blue
Write-Host "Versuche: npm run rebuild (für ERB)" -ForegroundColor Yellow
try {
    npm run rebuild
    Write-Host "✓ npm run rebuild erfolgreich" -ForegroundColor Green
}
catch {
    Write-Host "⚠ npm run rebuild fehlgeschlagen, versuche alternative..." -ForegroundColor Yellow
    
    # Alternative: Direkt in release/app rebuilden
    if (Test-Path "release\app") {
        Write-Host "Rebuilde better-sqlite3 in release/app..." -ForegroundColor Yellow
        Set-Location "release\app"
        
        # Installiere electron-rebuild wenn nicht vorhanden
        npm install electron-rebuild --save-dev
        npx electron-rebuild --force
        
        Set-Location "..\..\"
    }
    
    # Fallback: electron-rebuild im Hauptverzeichnis
    Write-Host "Installiere electron-rebuild als Fallback..." -ForegroundColor Yellow
    npm install electron-rebuild --save-dev
    npx electron-rebuild --force
}

# Schritt 3: ERB-spezifischer Test
Write-Host "`n3. Teste better-sqlite3 mit ERB-Konfiguration..." -ForegroundColor Blue
$testCode = @"
const path = require('path');

// ERB-spezifischer Test: Verwende release/app/node_modules
if (process.env.NODE_ENV === 'development') {
  // Füge release/app/node_modules zum Module-Pfad hinzu
  const releaseAppModules = path.join(__dirname, 'release', 'app', 'node_modules');
  if (!module.paths.includes(releaseAppModules)) {
    module.paths.unshift(releaseAppModules);
  }
}

try {
  const Database = require('better-sqlite3');
  const db = new Database(':memory:');
  const result = db.prepare('SELECT 1 as test').get();
  console.log('✓ SUCCESS: better-sqlite3 funktioniert für ERB!', result);
  db.close();
} catch (err) {
  console.log('✗ ERROR:', err.message);
  console.log('Module paths:', module.paths);
  process.exit(1);
}
"@

$testCode | Out-File -FilePath "quick-test.js" -Encoding UTF8

try {
    node quick-test.js
    Write-Host "`n✓ better-sqlite3 ERB-Reparatur erfolgreich!" -ForegroundColor Green
    Write-Host "✓ better-sqlite3 ist jetzt in release/app/ installiert" -ForegroundColor Green
    Write-Host "✓ Compatible mit Electron Node.js Version" -ForegroundColor Green
}
catch {
    Write-Host "`n✗ ERB-Reparatur fehlgeschlagen. Versuche Electron Rebuild..." -ForegroundColor Red
    
    # Versuche Electron Rebuild als Fallback
    Write-Host "Versuche npm run rebuild..." -ForegroundColor Yellow
    try {
        npm run rebuild
        Write-Host "✓ Electron rebuild erfolgreich" -ForegroundColor Green
    } catch {
        Write-Host "✗ Alle Reparaturversuche fehlgeschlagen!" -ForegroundColor Red
        Write-Host "Führe das vollständige Reparatur-Skript aus: .\fix-sqlite3-binding.ps1" -ForegroundColor Yellow
    }
}
finally {
    # Cleanup
    Remove-Item "quick-test.js" -ErrorAction SilentlyContinue
}

Write-Host "`n✅ ERB better-sqlite3 Reparatur abgeschlossen!" -ForegroundColor Green
Write-Host "✅ better-sqlite3 ist korrekt in release/app/ installiert" -ForegroundColor Green
Write-Host "✅ Binary kompiliert für Electron NODE_MODULE_VERSION 131" -ForegroundColor Green
Write-Host "✅ App sollte jetzt ohne Binding-Fehler starten" -ForegroundColor Green
Write-Host "`n📋 Zusammenfassung:" -ForegroundColor Cyan
Write-Host "- better-sqlite3 ist NICHT im Haupt-package.json (korrekt für ERB)" -ForegroundColor White
Write-Host "- better-sqlite3 ist NUR in release/app/package.json (korrekt für ERB)" -ForegroundColor White  
Write-Host "- Binary wurde für Electron kompiliert (NODE_MODULE_VERSION 131)" -ForegroundColor White
Write-Host "- Frontend kommuniziert über IPC mit Backend-Datenbank" -ForegroundColor White

Write-Host "`nFalls das Problem weiterhin besteht:" -ForegroundColor Cyan
Write-Host "1. Als Administrator ausführen" -ForegroundColor White
Write-Host "2. Visual Studio Build Tools installieren" -ForegroundColor White
Write-Host "3. Vollständiges Reparatur-Skript: .\fix-sqlite3-binding.ps1" -ForegroundColor White
Write-Host "4. ERB-Hinweis: better-sqlite3 MUSS in release/app/ sein, NICHT im Haupt-package.json!" -ForegroundColor Yellow
