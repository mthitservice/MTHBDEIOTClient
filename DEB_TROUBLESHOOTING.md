# DEB Package Troubleshooting Guide

## Problem: "not a Debian format archive" Error

Dieses Problem tritt auf, wenn das generierte DEB-Paket beschädigt oder nicht korrekt erstellt wurde.

### Häufige Ursachen:

1. **Electron-Builder Version Kompatibilität**
   - Veraltete electron-builder Version
   - Inkompatibilität mit Node.js Version
   - Fehlende native Abhängigkeiten

2. **Cross-Platform Building**
   - Building auf Windows für Linux ARM
   - Missing native tools für DEB-Paket-Erstellung
   - Architektur-spezifische Probleme

3. **Beschädigte Build-Artefakte**
   - Unterbrochene Builds
   - Netzwerkprobleme während des Builds
   - Speicherplatz-Probleme

### Diagnoseschritte:

#### 1. Debug-Skript verwenden

```bash
# Für Linux/WSL
cd App
chmod +x debug-deb.sh
./debug-deb.sh

# Für Windows PowerShell
cd App
.\debug-deb.ps1
```

#### 2. Manuelle Validierung

```bash
# DEB-Paket-Struktur prüfen
dpkg-deb --info your-package.deb

# Datei-Typ prüfen
file your-package.deb

# Datei-Header überprüfen
xxd -l 100 your-package.deb

# 7zip extraction test
7z t your-package.deb
```

#### 3. Electron-Builder Debug-Modus

```bash
# Mit Debug-Output
DEBUG=electron-builder npm run package:raspberry-deb
```

### Lösungsansätze:

#### 1. Electron-Builder aktualisieren

```bash
npm update electron-builder
npm audit fix
```

#### 2. Build-Umgebung optimieren

```bash
# Cache leeren
npm cache clean --force

# Node modules neu installieren
rm -rf node_modules package-lock.json
npm install

# Electron rebuild
npm run rebuild
```

#### 3. Alternative Build-Strategie

```bash
# Mit Docker für bessere Linux-Kompatibilität
docker run --rm -ti \
  -v $(pwd):/project \
  -w /project/App \
  electronuserland/builder:wine \
  bash -c "npm ci && npm run build && npm run package:raspberry-deb"
```

#### 4. WSL verwenden (Windows)

```bash
# In WSL für bessere Linux-Kompatibilität
wsl
cd /mnt/c/path/to/your/project/App
npm run package:raspberry-deb
```

### Konfiguration optimieren:

#### package.json - Linux Build Config:

```json
{
  "build": {
    "linux": {
      "target": [
        {
          "target": "deb",
          "arch": ["armv7l"]
        }
      ],
      "category": "Development",
      "description": "MTH BDE IoT Client for Raspberry Pi",
      "maintainer": "MTH IT Service <info@mth-it-service.com>",
      "synopsis": "IoT Client Application for Raspberry Pi",
      "compression": "xz",
      "priority": "optional",
      "depends": [
        "libnss3",
        "libatk-bridge2.0-0",
        "libdrm2",
        "libxkbcommon0",
        "libxdamage1",
        "libxrandr2",
        "libgbm1",
        "libxss1",
        "libasound2"
      ]
    }
  }
}
```

### Pipeline-Validierung:

#### Azure DevOps Pipeline Verbesserungen:

```yaml
- task: PowerShell@2
  displayName: 'Validate DEB Package'
  inputs:
    targetType: 'inline'
    script: |
      $debFiles = Get-ChildItem -Path "$(projectPath)/release/build" -Filter "*.deb"
      
      foreach ($debFile in $debFiles) {
        Write-Host "Validating: $($debFile.Name)"
        
        # File size check
        if ($debFile.Length -lt 30MB) {
          Write-Error "DEB file too small: $($debFile.Length)"
          exit 1
        }
        
        # File type check
        $fileType = & file $debFile.FullName
        if ($fileType -notmatch "Debian") {
          Write-Error "Not a Debian package: $fileType"
          exit 1
        }
        
        # Package validation
        & dpkg-deb --info $debFile.FullName
        if ($LASTEXITCODE -ne 0) {
          Write-Error "DEB package validation failed"
          exit 1
        }
      }
```

### Test-Installation:

#### Lokaler Test vor Deployment:

```bash
# Test in Docker container
docker run -it --rm \
  -v $(pwd):/host \
  debian:bullseye \
  bash -c "cd /host && apt update && dpkg -i your-package.deb; apt install -f -y"
```

### Emergency-Fixes:

#### 1. Manuelle DEB-Erstellung:

```bash
# Falls electron-builder versagt
mkdir -p manual-deb/DEBIAN
mkdir -p manual-deb/opt/MthBdeIotClient

# App-Dateien kopieren
cp -r dist/* manual-deb/opt/MthBdeIotClient/

# Control-Datei erstellen
cat > manual-deb/DEBIAN/control << EOF
Package: mthbdeiotclient
Version: 1.0.0
Section: base
Priority: optional
Architecture: armhf
Maintainer: MTH IT Service <info@mth-it-service.com>
Description: MTH BDE IoT Client
EOF

# DEB-Paket erstellen
dpkg-deb --build manual-deb MthBdeIotClient_1.0.0_armv7l.deb
```

#### 2. GitHub Actions als Alternative:

```yaml
name: Build DEB Package
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: actions/setup-node@v2
      with:
        node-version: '18'
    - run: |
        cd App
        npm ci
        npm run build
        npm run package:raspberry-deb
    - name: Validate DEB
      run: |
        find App/release/build -name "*.deb" -exec dpkg-deb --info {} \;
```

### Monitoring und Logging:

#### Pipeline-Logs analysieren:

```bash
# Wichtige Log-Ausgaben suchen
grep -i "error" build.log
grep -i "debian" build.log  
grep -i "deb" build.log
```

#### Runtime-Diagnostics:

```bash
# Auf Raspberry Pi
sudo apt install -y file
file /path/to/package.deb
dpkg-deb --info /path/to/package.deb
```

### Support-Informationen sammeln:

```bash
# System-Info
uname -a
node --version
npm --version
cat /etc/os-release

# Package-Info
dpkg-query -W electron-builder
npm list electron-builder
```

Diese Dokumentation sollte dabei helfen, das DEB-Paket-Problem zu identifizieren und zu lösen.
