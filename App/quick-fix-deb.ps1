# PowerShell Quick Fix für DEB Package Problem

Write-Host "🔧 MTH BDE IoT Client - DEB Package Quick Fix" -ForegroundColor Green
Write-Host "=============================================="

# Prüfe Arbeitsverzeichnis
if (!(Test-Path "package.json")) {
    Write-Error "package.json nicht gefunden. Bitte im App-Verzeichnis ausführen."
    exit 1
}

# Prüfe Node.js Version
$nodeVersion = node --version
Write-Host "Node.js Version: $nodeVersion"

# Empfohlene Node.js Version prüfen
if ([version]($nodeVersion.Substring(1)) -lt [version]"18.0.0") {
    Write-Warning "Node.js Version ist zu alt. Empfohlen: v18.0.0 oder höher"
}

# 1. Cache und temporäre Dateien bereinigen
Write-Host "🧹 Bereinige Cache und temporäre Dateien..." -ForegroundColor Yellow
Remove-Item -Path "release/build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "dist" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "node_modules/.cache" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:USERPROFILE\.npm\_cacache" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:TEMP\electron-*" -Recurse -Force -ErrorAction SilentlyContinue

# 2. Electron-Builder aktualisieren
Write-Host "📦 Aktualisiere electron-builder..." -ForegroundColor Yellow
npm update electron-builder

# 3. Native Module neu kompilieren
Write-Host "🔨 Kompiliere native Module neu..." -ForegroundColor Yellow
try {
    npm run rebuild
} catch {
    npm rebuild
}

# 4. Dependencies neu installieren
Write-Host "📥 Installiere Dependencies neu..." -ForegroundColor Yellow
npm ci

# 5. Build mit Debug-Informationen
Write-Host "🔍 Führe Build mit Debug-Informationen aus..." -ForegroundColor Yellow
$env:DEBUG = "electron-builder"
npm run build

# 6. DEB-Paket erstellen
Write-Host "📦 Erstelle DEB-Paket..." -ForegroundColor Yellow
npm run package:raspberry-deb

# 7. Validierung
Write-Host "✅ Validiere generierte DEB-Pakete..." -ForegroundColor Yellow
$debDir = "release/build"

if (!(Test-Path $debDir)) {
    Write-Error "Build-Verzeichnis nicht gefunden: $debDir"
    exit 1
}

$debFiles = Get-ChildItem -Path $debDir -Filter "*.deb" -Recurse

if ($debFiles.Count -eq 0) {
    Write-Error "Keine DEB-Dateien gefunden"
    exit 1
}

foreach ($debFile in $debFiles) {
    Write-Host "📋 Prüfe: $($debFile.Name)" -ForegroundColor Cyan

    # Dateigröße
    $size = $debFile.Length
    $sizeMB = [math]::Round($size / 1MB, 2)
    Write-Host "   Größe: $size Bytes ($sizeMB MB)"

    # Mindestgröße prüfen
    if ($size -lt 30MB) {
        Write-Warning "   Datei ist sehr klein für eine Electron-App"
    }

    # Dateityp prüfen (erste 100 Bytes)
    $header = Get-Content $debFile.FullName -Encoding Byte -TotalCount 100
    $headerHex = ($header | ForEach-Object { "{0:X2}" -f $_ }) -join " "
    Write-Host "   Header: $($headerHex.Substring(0, [Math]::Min($headerHex.Length, 40)))..."

    # Prüfe auf Debian-Signatur
    $headerString = [System.Text.Encoding]::ASCII.GetString($header)
    if ($headerString -match "debian|!<arch>") {
        Write-Host "   ✅ Debian-Signatur gefunden" -ForegroundColor Green
    } else {
        Write-Warning "   ❌ Debian-Signatur NICHT gefunden"
    }

    # 7zip Test falls verfügbar
    if (Get-Command "7z" -ErrorAction SilentlyContinue) {
        Write-Host "   Teste mit 7zip..."
        try {
            $result = & 7z t $debFile.FullName 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "   ✅ Archiv-Struktur ist OK" -ForegroundColor Green
            } else {
                Write-Warning "   ❌ Archiv-Struktur ist beschädigt"
            }
        } catch {
            Write-Warning "   7zip Test fehlgeschlagen: $($_.Exception.Message)"
        }
    }
}

Write-Host ""
Write-Host "🎯 Quick Fix abgeschlossen!" -ForegroundColor Green
Write-Host ""
Write-Host "Nächste Schritte:" -ForegroundColor Yellow
Write-Host "1. Teste DEB-Installation auf Raspberry Pi"
Write-Host "2. Falls Probleme bestehen, verwende das debug-deb.ps1 Skript"
Write-Host "3. Prüfe die DEB_TROUBLESHOOTING.md Dokumentation"
Write-Host ""
Write-Host "Support-Informationen:" -ForegroundColor Yellow
Write-Host "- Node.js: $(node --version)"
Write-Host "- NPM: $(npm --version)"
Write-Host "- Electron-Builder: $(npm list electron-builder --depth=0 2>$null | Select-String 'electron-builder')"
Write-Host "- OS: $([System.Environment]::OSVersion.VersionString)"
Write-Host "- PowerShell: $($PSVersionTable.PSVersion)"

# Zusätzliche Windows-spezifische Hinweise
Write-Host ""
Write-Host "Windows-spezifische Tipps:" -ForegroundColor Cyan
Write-Host "- Für bessere Linux-Kompatibilität: WSL verwenden"
Write-Host "- Docker alternative: electronuserland/builder Image"
Write-Host "- Node.js LTS Version installieren"
Write-Host "- Windows Defender ausschließen für bessere Performance"
