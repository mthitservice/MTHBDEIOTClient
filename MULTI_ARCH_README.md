# MthBdeIotClient - Multi-Architecture Builds

## 🏗️ Verfügbare Builds

Diese Anwendung wird für mehrere Architekturen kompiliert, um maximale Kompatibilität zu gewährleisten:

### 🍓 Raspberry Pi (ARMv7l)
- **Zielgeräte:** Raspberry Pi 3, 3+, 4, Zero 2 W
- **Format:** .deb (Debian Package)
- **Pipeline:** `azure-pipelines-raspberry.yml`
- **NPM Script:** `npm run package:raspberry-deb`

### 🐧 Linux 32-bit (ia32)
- **Zielgeräte:** Linux x86 32-bit Systeme (ältere PCs, embedded Systems)
- **Format:** .deb (Debian Package)
- **Pipeline:** `azure-pipelines-linux32.yml`
- **NPM Script:** `npm run package:linux32`

### 🪟 Windows 32-bit (ia32)
- **Zielgeräte:** Windows x86 32-bit Systeme (ältere PCs, embedded Systems)
- **Format:** .exe (Windows Installer)
- **Pipeline:** `azure-pipelines-windows32.yml`
- **NPM Script:** `npm run package:windows32`

### 🌟 Multi-Architecture Build
- **Alle Architekturen:** Ein Pipeline-Lauf für alle Targets
- **Pipeline:** `azure-pipelines-multi-arch.yml`
- **Automatische GitHub Releases:** Alle Pakete in einem Release

## 📦 Installation

### Raspberry Pi
```bash
# Abhängigkeiten installieren (inkl. libgbm für Electron)
sudo apt-get update
sudo apt-get install -y libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 libatspi2.0-0 libuuid1 libsecret-1-0 libgbm1 libasound2 libxrandr2 libatk1.0-0 libdrm2 libxcomposite1 libxdamage1 libxfixes3 libgconf-2-4 mesa-utils libgl1-mesa-glx libgl1-mesa-dev

# Download der neuesten Version
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/latest/download/mthbdeiotclient_[VERSION]_armv7l.deb

# Installation
sudo dpkg -i mthbdeiotclient_*_armv7l.deb
sudo apt-get install -f

# Anwendung starten
mthbdeiotclient --fullscreen1233
```

### Linux 32-bit
```bash
# Abhängigkeiten installieren
sudo apt-get update
sudo apt-get install -y libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 libatspi2.0-0 libuuid1 libsecret-1-0 libgbm1

# Download der neuesten Version
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/latest/download/mthbdeiotclient_[VERSION]_ia32.deb

# Installation
sudo dpkg -i mthbdeiotclient_*_ia32.deb
sudo apt-get install -f

# Anwendung starten
mthbdeiotclient --fullscreen
```

### Windows 32-bit
1. [Release-Seite](https://github.com/mthitservice/MTHBDEIOTClient/releases/latest) öffnen
2. `mthbdeiotclient-[VERSION]-ia32.exe` herunterladen
3. Als Administrator ausführen
4. Installationsassistent befolgen
5. Anwendung aus Startmenü starten

## 🖥️ Kiosk-Modus (Linux/Raspberry Pi)

### Autostart einrichten
```bash
# Autostart-Datei bearbeiten
sudo nano /etc/xdg/lxsession/LXDE-pi/autostart

# Diese Zeilen hinzufügen:
@xset s off
@xset -dpms
@xset s noblank
@mthbdeiotclient --fullscreen

# Bildschirmschoner deaktivieren
sudo nano /etc/lightdm/lightdm.conf
# Unter [Seat:*] hinzufügen:
xserver-command=X -s 0 -dpms

# Neustart für Autostart
sudo reboot
```

## 🔧 Entwicklung

### Lokale Builds
```bash
# Alle Abhängigkeiten installieren
cd App
npm install

# Raspberry Pi Build
npm run package:raspberry-deb

# Linux 32-bit Build
npm run package:linux32

# Windows 32-bit Build (auf Windows-System)
npm run package:windows32

# Alle Builds (auf entsprechenden Systemen)
npm run package:all
```

### Pipeline-Konfiguration

#### Einzelne Pipelines
- `azure-pipelines-raspberry.yml` - Nur Raspberry Pi
- `azure-pipelines-linux32.yml` - Nur Linux 32-bit
- `azure-pipelines-windows32.yml` - Nur Windows 32-bit

#### Multi-Architecture Pipeline
- `azure-pipelines-multi-arch.yml` - Alle Architekturen in einem Lauf

### Electron-builder Konfiguration

Die `package.json` ist so konfiguriert, dass sie alle Architekturen unterstützt:

```json
{
  "build": {
    "linux": {
      "target": [
        {
          "target": "deb",
          "arch": ["armv7l", "ia32", "x64"]
        }
      ]
    },
    "win": {
      "target": [
        {
          "target": "nsis",
          "arch": ["x64", "ia32"]
        }
      ]
    }
  }
}
```

## 📋 Systemanforderungen

### Raspberry Pi
- ✅ Raspberry Pi 3, 3+, 4 oder Zero 2 W
- ✅ Raspberry Pi OS (32-bit, ARMv7l)
- ✅ Mindestens 1GB RAM
- ✅ Desktop-Umgebung (X11)

### Linux 32-bit
- ✅ Linux x86 32-bit Distribution
- ✅ Debian-basierte Systeme (Ubuntu, Mint, etc.)
- ✅ Mindestens 1GB RAM
- ✅ Desktop-Umgebung (X11)

### Windows 32-bit
- ✅ Windows 7, 8, 10, 11 (32-bit)
- ✅ Mindestens 1GB RAM
- ✅ .NET Framework 4.5 oder höher

## 🔍 Troubleshooting

### Häufige Probleme

#### libgbm.so.1 fehlt (Linux/Raspberry Pi)
```bash
# Lösung: Electron-Abhängigkeiten installieren
sudo apt-get install -y libgbm1 mesa-utils libgl1-mesa-glx libgl1-mesa-dev

# Alternative: Software-Rendering verwenden
LIBGL_ALWAYS_SOFTWARE=1 mthbdeiotclient --no-sandbox
```

#### Berechtigungsprobleme
```bash
# Ausführungsberechtigungen reparieren
sudo chmod +x /usr/bin/mthbdeiotclient

# Abhängigkeiten reparieren
sudo apt-get install -f
```

#### Windows Installation schlägt fehl
1. Als Administrator ausführen
2. Windows Defender temporär deaktivieren
3. Antivirus-Software ausschalten
4. Neustart und erneut versuchen

## 📊 Build-Status

### Aktuelle Pipelines
- 🍓 Raspberry Pi: [![Build Status](https://dev.azure.com/mthitservice/MTHBDEIOTClient/_apis/build/status/raspberry-pi)](https://dev.azure.com/mthitservice/MTHBDEIOTClient/_build/latest?definitionId=raspberry-pi)
- 🐧 Linux 32-bit: [![Build Status](https://dev.azure.com/mthitservice/MTHBDEIOTClient/_apis/build/status/linux32)](https://dev.azure.com/mthitservice/MTHBDEIOTClient/_build/latest?definitionId=linux32)
- 🪟 Windows 32-bit: [![Build Status](https://dev.azure.com/mthitservice/MTHBDEIOTClient/_apis/build/status/windows32)](https://dev.azure.com/mthitservice/MTHBDEIOTClient/_build/latest?definitionId=windows32)
- 🌟 Multi-Arch: [![Build Status](https://dev.azure.com/mthitservice/MTHBDEIOTClient/_apis/build/status/multi-arch)](https://dev.azure.com/mthitservice/MTHBDEIOTClient/_build/latest?definitionId=multi-arch)

### Automatische Releases
- Alle Builds werden automatisch bei Git-Tags erstellt
- GitHub Releases enthalten alle Architekturen
- Direkte Download-Links verfügbar

## 🔗 Links

- [GitHub Repository](https://github.com/mthitservice/MTHBDEIOTClient)
- [Latest Release](https://github.com/mthitservice/MTHBDEIOTClient/releases/latest)
- [Azure DevOps Pipelines](https://dev.azure.com/mthitservice/MTHBDEIOTClient)
- [MTH IT Service](https://mth-it-service.com)

---

**Erstellt:** $(Get-Date -Format "dd.MM.yyyy")  
**Autor:** Michael Lindner, MTH IT Service  
**Version:** Multi-Architecture Support
