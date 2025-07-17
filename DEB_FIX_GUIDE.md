# Electron Builder DEB Package Fix

## Problem
Das generierte DEB-Paket wird nicht als gültiges Debian-Format erkannt: "not a Debian format archive"

## Lösungsansätze

### 1. Electron Builder Konfiguration verbessern

Die aktuelle Konfiguration in `package.json` sollte erweitert werden:

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
      "packageCategory": "devel",
      "desktop": {
        "Name": "MTH BDE IoT Client",
        "Comment": "IoT Client for Raspberry Pi",
        "Keywords": "IoT;Raspberry;Client",
        "Categories": "Development;Utility"
      },
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

### 2. Build-Umgebung optimieren

Verwende native Linux-Umgebung für DEB-Erstellung:

```bash
# In Ubuntu/Debian-Container
npm run package:raspberry-deb
```

### 3. Validierung und Debugging

```bash
# Nach dem Build
for debfile in $(find . -name "*.deb"); do
  echo "Validating: $debfile"
  
  # Dateigröße
  ls -lh "$debfile"
  
  # Dateityp
  file "$debfile"
  
  # Debian-Paket-Validation
  dpkg-deb --info "$debfile"
  
  # AR-Archiv-Inhalt
  ar t "$debfile"
  
  # Installationstest
  dpkg-deb --extract "$debfile" /tmp/test-extract
done
```

### 4. Alternative: Manuelle DEB-Erstellung

Falls electron-builder versagt:

```bash
# Erstelle DEB-Paket manuell
mkdir -p manual-deb/DEBIAN
mkdir -p manual-deb/opt/MthBdeIotClient
mkdir -p manual-deb/usr/share/applications

# Control-Datei
cat > manual-deb/DEBIAN/control << EOF
Package: mthbdeiotclient
Version: 1.0.0
Section: devel
Priority: optional
Architecture: armhf
Maintainer: MTH IT Service <info@mth-it-service.com>
Description: MTH BDE IoT Client
 IoT Client Application for Raspberry Pi
EOF

# App-Dateien kopieren
cp -r dist/* manual-deb/opt/MthBdeIotClient/

# Desktop-Datei
cat > manual-deb/usr/share/applications/mthbdeiotclient.desktop << EOF
[Desktop Entry]
Name=MTH BDE IoT Client
Comment=IoT Client for Raspberry Pi
Exec=/opt/MthBdeIotClient/mthbdeiotclient
Icon=mthbdeiotclient
Terminal=false
Type=Application
Categories=Development;Utility;
EOF

# DEB-Paket erstellen
dpkg-deb --build manual-deb MthBdeIotClient_1.0.0_armhf.deb
```

### 5. Cross-Platform Building

Für Windows-Entwicklung:

```bash
# WSL verwenden
wsl
cd /mnt/c/path/to/project/App
npm run package:raspberry-deb

# Oder Docker
docker run --rm -v $(pwd):/project electronuserland/builder:wine \
  bash -c "cd /project/App && npm ci && npm run package:raspberry-deb"
```

### 6. Electron Builder Alternativen

```bash
# Electron Forge
npm install --save-dev @electron-forge/cli
npx electron-forge import

# pkg
npm install -g pkg
pkg package.json --targets linux-arm --output mthbdeiotclient-arm
```

## Troubleshooting

### Problem: Datei zu klein
**Lösung**: Prüfe Build-Prozess, stelle sicher dass alle Abhängigkeiten inkludiert sind

### Problem: Falsche Architektur
**Lösung**: Explizit `--armv7l` Flag verwenden

### Problem: Node.js Native Modules
**Lösung**: `electron-rebuild` für ARM-Architektur

### Problem: Berechtigungen
**Lösung**: Korrekte DEBIAN/postinst Skripte

## Implementierung

Die Pipeline wurde erweitert um:
1. Detaillierte DEB-Validierung
2. Mehrfache Archiv-Tests
3. Größen- und Typ-Prüfung
4. dpkg-deb Validierung
5. Fallback-Mechanismen

Diese Änderungen sollten das "not a Debian format archive" Problem beheben.
