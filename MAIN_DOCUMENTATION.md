# MTH BDE IoT Client - Dokumentation

## 🚀 Überblick

Eine moderne Electron-basierte Anwendung für die Verwaltung von MTH BDE IoT-Geräten mit fokussierter Raspberry Pi-Unterstützung.

## 🎯 Features

- ✅ **Native Electron Desktop App** für Windows, macOS und Linux
- ✅ **Raspberry Pi optimiert** (ARM64 & ARMv7l Architektur)
- ✅ **AutoUpdater** mit GitHub-Integration
- ✅ **SQLite-Datenbank** für lokale Datenverwaltung
- ✅ **Cross-Platform** Build-System
- ✅ **Azure DevOps CI/CD** Pipeline

## 📦 Installation

### Schnellinstallation (Raspberry Pi)

```bash
curl -fsSL https://raw.githubusercontent.com/mthitservice/MTHBDEIOTClient/master/shell-scripts/install-latest.sh | bash
```

### Manuelle Installation

1. Download der neuesten Release von GitHub
2. Entpacken des Archives
3. Installation der Abhängigkeiten: `npm install`
4. Start der Anwendung: `npm start`

## 🔧 Entwicklung

### Lokale Entwicklung

```bash
git clone https://github.com/mthitservice/MTHBDEIOTClient.git
cd MTHBDEIOTClient/App
npm install
npm run dev
```

### Build-Prozess

```bash
# Für aktueller Plattform
npm run build

# Für Raspberry Pi
npm run build:raspberry

# Multi-Architektur Build
npm run build:all
```

## 🚀 Deployment

### Azure DevOps Pipeline

Das Projekt verwendet Azure DevOps für automatische Builds und Releases:

- **azure-pipelines.yml**: Haupt-Pipeline für alle Plattformen
- **azure-pipelines-raspberry.yml**: Speziell für Raspberry Pi
- **azure-pipelines-multi-arch.yml**: Multi-Architektur Builds

### GitHub Release Management

Automatische Releases werden durch die Pipeline getriggert:

```bash
# Manuelle Release auslösen
./shell-scripts/trigger-auto-release.sh
```

## 🛠️ Troubleshooting

### Häufige Probleme

#### White Screen Probleme

- Electron Cache löschen: `rm -rf ~/.config/mthbdeiotclient`
- GPU-Beschleunigung deaktivieren: `--disable-gpu` Flag verwenden

#### DEB Package Probleme

- Abhängigkeiten prüfen: `sudo apt-get install -f`
- Package validieren: `./shell-scripts/validate-deb-package.sh`

#### Autostart Probleme (Raspberry Pi)

- Service-Status prüfen: `systemctl status mthbdeiotclient`

## 🔧 Quick Fixes

### Fehlende Icons nach Installation

Wenn nach der Installation das Standard-Electron-Icon angezeigt wird:

```bash
# Icon-Pfade automatisch reparieren
./shell-scripts/fix-icon-paths.sh
```

### Weitere Fixes

- Permissions fixen: `sudo ./shell-scripts/fix-autostart-admin.sh`

#### Performance Optimierung (Raspberry Pi)

- GPU Memory Split: `sudo raspi-config` → Advanced Options → Memory Split → 128
- Swap vergrößern: `sudo dphys-swapfile swapoff && sudo nano /etc/dphys-swapfile`
- Desktop-Environment deaktivieren: `sudo systemctl set-default multi-user.target`

### Debug-Modi

```bash
# Debug mit ausführlichen Logs
./shell-scripts/dev-modes.sh --debug

# Entwicklungsmodus
./shell-scripts/dev-modes.sh --dev

# Verbose Modus
./shell-scripts/dev-modes.sh --verbose
```

### Raspberry Pi Auflösungstests (Windows Development)

Für das Testen verschiedener Raspberry Pi Auflösungen unter Windows 11:

```powershell
# Verschiedene Raspberry Pi Display-Größen testen
.\mth-manager.ps1 rpi-test small      # 1024x768 (kleine Displays)
.\mth-manager.ps1 rpi-test medium     # 1280x720 (mittlere Displays) 
.\mth-manager.ps1 rpi-test large      # 1920x1080 (Standard Pi 4)
.\mth-manager.ps1 rpi-test fullscreen # 1920x1080 Vollbild/Kiosk

# Direkte npm Scripts
npm run start:raspberry              # Standard Raspberry Pi Modus
npm run start:raspberry-small        # Kleinere Auflösung
npm run start:raspberry-fullscreen   # Kiosk-Modus
```

**Features des Raspberry Pi Dev-Modus:**
- Automatisches Öffnen der DevTools
- Responsive Design Vorschau
- CSS Media Query Tests
- Touch-Target Optimierungen
- Display-Anzeige für aktuelle Auflösung

## 📁 Projektstruktur

```text
MTHBDEIOTClient/
├── App/                    # Hauptanwendung
│   ├── src/               # Source Code
│   ├── assets/            # Bilder, Icons, etc.
│   ├── public/            # Öffentliche Dateien
│   └── package.json       # App Dependencies
├── shell-scripts/         # Shell-Skripte (Linux/macOS)
├── powershell-scripts/    # PowerShell-Skripte (Windows)
├── azure-devops/          # Azure DevOps Konfiguration
├── Documentation/         # Zusätzliche Dokumentation
├── mth-manager.ps1        # Haupt-Verwaltungstool (Windows)
└── azure-pipelines*.yml  # CI/CD Pipeline Definitionen
```

## 🔗 Asset-Zugriff

### Direkter Image-Zugriff

```bash
# Logo herunterladen
curl -L https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/images/mthitservicelogo.png -o logo.png
```

### App-Icons (verschiedene Größen)

```bash
# Icons herunterladen
mkdir -p ~/mth-bde-client/icons
cd ~/mth-bde-client/icons

wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/icon.png
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/1024x1024.png
# ... weitere Icon-Größen verfügbar
```

## 📝 Cheat Sheet

### Wichtige Befehle

```bash
# Neueste Version installieren
curl -fsSL https://raw.githubusercontent.com/mthitservice/MTHBDEIOTClient/master/shell-scripts/install-latest.sh | bash

# Service neustarten
sudo systemctl restart mthbdeiotclient

# Logs anzeigen
journalctl -u mthbdeiotclient -f
```

### Windows PowerShell

```powershell
# Master-Verwaltungstool (Windows)
.\mth-manager.ps1 help

# Entwicklungsmodus
.\mth-manager.ps1 dev

# Pipeline triggern
.\mth-manager.ps1 trigger

# Release erstellen
.\mth-manager.ps1 release 1.0.51
```

### Pipeline Management

```bash
# Pipeline manuell triggern (Linux/macOS)
./shell-scripts/trigger-auto-release.sh

# Release erstellen (Linux/macOS)
./shell-scripts/release-version.sh
```

### Entwickler-Shortcuts

```bash
# Schnelle Fehlerbehebung (Linux/macOS)
./shell-scripts/quick-fix-pgrep.sh

# DEB Package debuggen (Linux/macOS)
./shell-scripts/debug-deb.sh

# Version bumpen und releasen (Linux/macOS)
./shell-scripts/release-version.sh
```

```powershell
# Windows PowerShell Shortcuts
.\mth-manager.ps1 fix      # Schnelle Fehlerbehebung
.\mth-manager.ps1 debug    # DEB Package debuggen
.\mth-manager.ps1 build raspberry  # Raspberry Pi Build
```

## 🤝 Contributing

1. Repository forken
2. Feature Branch erstellen: `git checkout -b feature/amazing-feature`
3. Änderungen committen: `git commit -m 'Add amazing feature'`
4. Branch pushen: `git push origin feature/amazing-feature`
5. Pull Request erstellen

## 📄 Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Details in der `LICENSE` Datei.

## 📞 Support

Bei Problemen oder Fragen:

1. GitHub Issues erstellen
2. Dokumentation prüfen
3. Debug-Modi verwenden
4. Community Support nutzen

---

Letzte Aktualisierung: Juli 2025
