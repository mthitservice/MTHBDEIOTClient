# Manual GitHub Release Creation Script

param(
    [string]$Version = "1.0.0",
    [string]$ReleaseNotes = "Automated release"
)

Write-Host "📦 Manual GitHub Release Creation" -ForegroundColor Green
Write-Host "=================================="
Write-Host ""

# Prüfe ob GitHub CLI verfügbar ist
try {
    $ghVersion = & gh --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ GitHub CLI verfügbar: $ghVersion" -ForegroundColor Green
        $useGHCLI = $true
    } else {
        throw "GitHub CLI nicht verfügbar"
    }
} catch {
    Write-Host "❌ GitHub CLI nicht verfügbar" -ForegroundColor Red
    Write-Host "Installiere GitHub CLI: https://cli.github.com/"
    $useGHCLI = $false
}

# Suche nach DEB-Dateien
$debFiles = Get-ChildItem -Path "App/release/build" -Filter "*.deb" -Recurse -ErrorAction SilentlyContinue

if ($debFiles.Count -eq 0) {
    Write-Host "❌ Keine DEB-Dateien gefunden!" -ForegroundColor Red
    Write-Host "Führe zuerst den Build aus:"
    Write-Host "   cd App"
    Write-Host "   npm run package:raspberry-deb"
    exit 1
}

Write-Host "📋 Gefundene DEB-Dateien:" -ForegroundColor Yellow
foreach ($debFile in $debFiles) {
    Write-Host "   - $($debFile.Name) ($([math]::Round($debFile.Length/1MB, 2)) MB)"
}

# Erstelle Release-Verzeichnis
$releaseDir = "release-manual"
if (Test-Path $releaseDir) {
    Remove-Item -Path $releaseDir -Recurse -Force
}
New-Item -ItemType Directory -Path $releaseDir -Force | Out-Null

# Kopiere Dateien
Write-Host "📁 Kopiere Dateien für Release..." -ForegroundColor Yellow
foreach ($debFile in $debFiles) {
    Copy-Item -Path $debFile.FullName -Destination $releaseDir -Force
}

# Kopiere Install-Skripte
if (Test-Path "scripts/install-raspberry.sh") {
    Copy-Item -Path "scripts/install-raspberry.sh" -Destination $releaseDir -Force
}
if (Test-Path "install-latest.sh") {
    Copy-Item -Path "install-latest.sh" -Destination $releaseDir -Force
}

# Erstelle Release Notes
$releaseNotesContent = @"
## Raspberry Pi Release $Version

### What's New
- Automated build and deployment for Raspberry Pi
- Validated DEB package for ARM architecture
- Updated installation script with proper GitHub URLs

### Installation
```bash
# Download and run the installation script
wget https://github.com/mthitservice/MTHBDEIOTClient/blob/main/scripts/install-raspberry.sh
chmod +x install-raspberry.sh
sudo ./install-raspberry.sh
```

### Files in this release
- `*.deb` - Debian package for Raspberry Pi (ARM)
- `install-raspberry.sh` - Automated installation script

### Requirements
- Raspberry Pi OS (32-bit or 64-bit)
- ARM architecture (ARMv7l)
- Minimum 1GB RAM

$ReleaseNotes

Built manually with PowerShell script
"@

$releaseNotesFile = Join-Path $releaseDir "release-notes.md"
Set-Content -Path $releaseNotesFile -Value $releaseNotesContent

Write-Host "📝 Release Notes erstellt: $releaseNotesFile" -ForegroundColor Green

if ($useGHCLI) {
    Write-Host ""
    Write-Host "🚀 Erstelle GitHub Release mit GitHub CLI..." -ForegroundColor Yellow
    
    # Prüfe ob eingeloggt
    try {
        & gh auth status 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Nicht bei GitHub angemeldet" -ForegroundColor Red
            Write-Host "Führe aus: gh auth login"
            exit 1
        }
    } catch {
        Write-Host "❌ GitHub Auth-Status nicht verfügbar" -ForegroundColor Red
        exit 1
    }
    
    # Erstelle Release
    $tagName = "v$Version"
    $releaseFiles = Get-ChildItem -Path $releaseDir -File | Where-Object { $_.Name -ne "release-notes.md" }
    
    try {
        $fileArgs = $releaseFiles | ForEach-Object { $_.FullName }
        
        Write-Host "Tag: $tagName"
        Write-Host "Files: $($fileArgs -join ', ')"
        
        & gh release create $tagName $fileArgs --repo mthitservice/MTHBDEIOTClient --title "Raspberry Pi Release $Version" --notes-file $releaseNotesFile
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Release erfolgreich erstellt!" -ForegroundColor Green
            Write-Host "🔗 Release URL: https://github.com/mthitservice/MTHBDEIOTClient/releases/tag/$tagName"
        } else {
            throw "GitHub CLI Release fehlgeschlagen"
        }
    } catch {
        Write-Host "❌ Fehler beim Erstellen des Releases: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Versuche manuelle Erstellung..."
        $useGHCLI = $false
    }
}

if (-not $useGHCLI) {
    Write-Host ""
    Write-Host "📋 Manuelle Release-Erstellung:" -ForegroundColor Yellow
    Write-Host "================================"
    Write-Host ""
    Write-Host "1. Gehe zu: https://github.com/mthitservice/MTHBDEIOTClient/releases"
    Write-Host "2. Klicke: 'Create a new release'"
    Write-Host "3. Tag: v$Version"
    Write-Host "4. Title: Raspberry Pi Release $Version"
    Write-Host "5. Lade folgende Dateien hoch:"
    
    $releaseFiles = Get-ChildItem -Path $releaseDir -File | Where-Object { $_.Name -ne "release-notes.md" }
    foreach ($file in $releaseFiles) {
        Write-Host "   - $($file.Name)"
    }
    
    Write-Host ""
    Write-Host "6. Kopiere Release Notes aus: $releaseNotesFile"
    Write-Host "7. Klicke: 'Publish release'"
    Write-Host ""
    Write-Host "📁 Alle Dateien sind bereit in: $releaseDir"
}

Write-Host ""
Write-Host "✅ Manual Release Creation abgeschlossen!" -ForegroundColor Green
Write-Host "Alle benötigten Dateien sind in: $releaseDir"
