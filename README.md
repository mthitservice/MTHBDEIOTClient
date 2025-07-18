# MTH BDE IoT Client

## 🚀 Überblick

Eine moderne Electron-basierte Anwendung für die Verwaltung von MTH BDE IoT-Geräten mit fokussierter Raspberry Pi-Unterstützung.

## 🎯 Features

Eine moderne Electron-basierte Anwendung für die Verwaltung von MTH BDE IoT-Geräten mit fokussierter Raspberry Pi-Unterstützung.

- ✅ **Native Electron Desktop App** für Windows, macOS und Linux
- ✅ **Raspberry Pi optimiert** (ARM64 & ARMv7l Architektur)
- ✅ **AutoUpdater** mit GitHub-Integration
- ✅ **SQLite-Datenbank** für lokale Datenverwaltung
- ✅ **Cross-Platform** Build-System
- ✅ **Azure DevOps CI/CD** Pipeline

### Direkter Image-Zugriff

```bash
# Einzelne Images direkt verwenden
curl -L https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/images/mthitservicelogo.png -o logo.png
```

### App-Icons (verschiedene Größen)

Für die Integration in andere Anwendungen stehen verschiedene Icon-Größen zur Verfügung:

```bash
# App-Icons herunterladen
mkdir -p ~/mth-bde-client/icons
cd ~/mth-bde-client/icons

# Standard Desktop-Icons
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/icon.png
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/icon.ico
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/1024x1024.png
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/512x512.png
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/256x256.png
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/128x128.png
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/64x64.png
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/32x32.png
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/16x16.png

# Mobile/Web-Icons
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/android-chrome-192x192.png
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/apple-touch-icon.png
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/favicon.ico

echo "✅ Alle App-Icons erfolgreich heruntergeladen!"
```

### Schneller Icon-Download (alle Größen)

```bash
# Ein-Kommando für alle wichtigen Icons
wget -P ~/mth-bde-client/icons/ \
  https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/icon.png \
  https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/1024x1024.png \
  https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/512x512.png \
  https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/256x256.png \
  https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/128x128.png \
  https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/64x64.png \
  https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/32x32.png \
  https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/icons/16x16.png
```

##  Installation

### Raspberry Pi (Ein-Kommando-Installation)

```bash
wget -O /tmp/install-latest.sh https://github.com/mthitservice/MTHBDEIOTClient/raw/master/scripts/install-raspberry.sh && chmod +x /tmp/install-latest.sh && /tmp/install-latest.sh
```

### Manuelle Installation (.deb Pakete)

```bash
# Raspberry Pi 64-bit (ARM64) - empfohlen für Pi 4
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/download/v1.0.80/MthBdeIotClient_1.0.80_arm64.deb
sudo dpkg -i MthBdeIotClient_1.0.80_arm64.deb
sudo apt-get install -f

# Raspberry Pi 32-bit (ARMv7l) - für Pi 3/3+
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/download/v1.0.80/MthBdeIotClient_1.0.80_armv7l.deb
sudo dpkg -i MthBdeIotClient_1.0.80_armv7l.deb
sudo apt-get install -f
```

### Neueste Version automatisch herunterladen

```bash
# Automatisch die neueste ARM64-Version herunterladen
LATEST_VERSION=$(curl -s https://api.github.com/repos/mthitservice/MTHBDEIOTClient/releases/latest | grep tag_name | cut -d '"' -f 4)
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/download/${LATEST_VERSION}/MthBdeIotClient_${LATEST_VERSION#v}_arm64.deb

# Automatisch die neueste ARMv7l-Version herunterladen
LATEST_VERSION=$(curl -s https://api.github.com/repos/mthitservice/MTHBDEIOTClient/releases/latest | grep tag_name | cut -d '"' -f 4)
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/download/${LATEST_VERSION}/MthBdeIotClient_${LATEST_VERSION#v}_armv7l.deb
```

Für detaillierte Raspberry Pi-Installationsanweisungen siehe: [RASPBERRY_PI_INSTALLATION.md](App/RASPBERRY_INSTALLATION.md)

### Entwicklungsumgebung

```bash
# Repository klonen
git clone https://github.com/mthitservice/MTHBDEIOTClient.git
cd MTHBDEIOTClient/App

# Abhängigkeiten installieren
npm install

# Entwicklungsserver starten
npm run dev

# Build für aktuelle Plattform
npm run build

# Raspberry Pi Build
npm run build:raspberry
```

## 🏗️ Architektur

```
MTHBDEIOTClient/
├── App/                    # Electron Hauptanwendung
│   ├── src/
│   │   ├── main/          # Electron Main Process
│   │   └── renderer/      # React Frontend
│   ├── public/            # Statische Dateien
│   └── package.json
├── azure-devops/          # Azure DevOps Konfiguration
├── scripts/               # Build & Deployment Scripts
└── Documentation/         # Entwicklerdokumentation
```

## 🚀 Deployment

### Azure DevOps Pipeline

Die Anwendung nutzt eine optimierte Azure DevOps Pipeline:

- **Build-Stage**: Cross-Platform Compilation
- **Test-Stage**: Unit Tests & E2E Tests
- **Deploy-Stage**: GitHub Release & Raspberry Pi Distribution

### GitHub Releases

Automatische Releases werden erstellt mit:
- **DEB-Paketen** für Raspberry Pi (ARMv7l)
- **SHA256-Checksummen** für Verifikation
- **Auto-Installer Script** für Ein-Kommando-Installation

## 📋 Systemanforderungen

### Raspberry Pi
- **Raspberry Pi 3+** oder **Zero 2 W**
- **Raspberry Pi OS (32-bit)** mit ARMv7l
- **Desktop-Umgebung** (X11/Wayland)
- **Mindestens 1GB RAM**

### Entwicklung
- **Node.js** 18+ LTS
- **npm** 8+
- **Git**
- **Visual Studio Code** (empfohlen)

## 🔄 AutoUpdater

Die Anwendung verfügt über einen integrierten AutoUpdater:

```typescript
// GitHub-basierte Update-Prüfung
const updateProvider = new GitHubProvider({
  owner: 'mthitservice',
  repo: 'MTHBDEIOTClient'
});

// Automatische Update-Prüfung
await autoUpdater.checkForUpdates();
```

## 🛠️ Entwicklung

### Verfügbare Scripts

```bash
# Entwicklung
npm run dev              # Entwicklungsserver
npm run build           # Build für aktuelle Plattform
npm run build:raspberry # Raspberry Pi Build
npm run test           # Unit Tests
npm run lint           # Code Linting

# Release
npm run release        # Version Release
npm run package       # Paket erstellen
```

### Debugging

```bash
# Debug-Modus
npm run dev:debug

# Logs anzeigen
npm run logs

# Electron DevTools
npm run devtools
```

## 📁 Wichtige Dateien

- `App/package.json` - Electron Konfiguration
- `App/src/main/main.ts` - Main Process
- `App/src/renderer/App.tsx` - React Frontend
- `azure-pipelines-raspberry.yml` - CI/CD Pipeline
- `install-latest.sh` - Auto-Installer Script
- `RASPBERRY_PI_INSTALLATION.md` - Detaillierte Installationsanleitung

## �️ Assets & Images

### Logo und Branding Images

Für die Verwendung in eigenen Projekten oder zur Offline-Verfügung können die Images direkt heruntergeladen werden:

```bash
# Erstelle Images-Verzeichnis
mkdir -p ~/mth-bde-client/images
cd ~/mth-bde-client/images

# Lade alle verfügbaren Images herunter
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/images/mthitservicelogo.png
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/images/mthitservicelogo2.png
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/images/mthuabdedslogo.png
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/images/mthuabdedsbarcodescanner.png

# Ein-Kommando für alle Images
wget -P ~/mth-bde-client/images/ \
  https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/images/mthitservicelogo.png \
  https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/images/mthitservicelogo2.png \
  https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/images/mthuabdedslogo.png \
  https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/images/mthuabdedsbarcodescanner.png

echo "✅ Alle Images erfolgreich heruntergeladen!"
```

### Verfügbare Images

| Image                          | Beschreibung                 | Größe | Verwendung                   |
| ------------------------------ | ---------------------------- | ----- | ---------------------------- |
| `mthitservicelogo.png`         | MTH IT Service Haupt-Logo    | ~KB   | Branding, About-Dialog       |
| `mthitservicelogo2.png`        | MTH IT Service Logo Variante | ~KB   | Alternative Darstellung      |
| `mthuabdedslogo.png`           | MTH UAE BDE DS Logo          | ~KB   | Anwendungs-Branding          |
| `mthuabdedsbarcodescanner.png` | Barcode Scanner Icon         | ~KB   | UI-Element, Scanner-Funktion |

### Direkter Image-Zugriff

```bash
# Einzelne Images direkt verwenden
curl -L https://github.com/mthitservice/MTHBDEIOTClient/raw/master/App/assets/images/mthitservicelogo.png -o logo.png
```

## �🔗 Links

- **GitHub Repository**: https://github.com/mthitservice/MTHBDEIOTClient
- **Releases**: https://github.com/mthitservice/MTHBDEIOTClient/releases
- **Issues**: https://github.com/mthitservice/MTHBDEIOTClient/issues
- **Wiki**: https://github.com/mthitservice/MTHBDEIOTClient/wiki

## 🤝 Beitragen

1. **Fork** das Repository
2. **Feature Branch** erstellen (`git checkout -b feature/AmazingFeature`)
3. **Commit** die Änderungen (`git commit -m 'Add AmazingFeature'`)
4. **Push** zum Branch (`git push origin feature/AmazingFeature`)
5. **Pull Request** öffnen

## 📄 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe [LICENSE](App/LICENSE) für Details.

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/mthitservice/MTHBDEIOTClient/issues)
- **Discussions**: [GitHub Discussions](https://github.com/mthitservice/MTHBDEIOTClient/discussions)
- **E-Mail**: support@mth-it-service.de

---

**🎉 Vielen Dank für die Nutzung von MTH BDE IoT Client!**

*Entwickelt mit ❤️ für die IoT-Community*