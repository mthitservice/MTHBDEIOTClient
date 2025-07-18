# MTH BDE IoT Client

[![Build Status](https://dev.azure.com/mth-it-service/MTHUABDEDS/_apis/build/status%2FMthBdeIotClient-CI?branchName=master)](https://dev.azure.com/mth-it-service/MTHUABDEDS/_build/latest?definitionId=YourPipelineId&branchName=master)
[![GitHub Release](https://img.shields.io/github/v/release/mthitservice/MTHBDEIOTClient)](https://github.com/mthitservice/MTHBDEIOTClient/releases/latest)

Ein Electron-basierter IoT Client für Raspberry Pi, entwickelt für MTH IT-Service. Diese Anwendung bietet eine moderne Desktop-Umgebung für IoT-Geräte mit React und TypeScript.

## 📋 Features

- **Cross-Platform**: Läuft auf Windows, macOS und Linux
- **Raspberry Pi Support**: Speziell optimiert für ARM64 und ARMv7l
- **Modern UI**: React-basierte Benutzeroberfläche mit TypeScript
- **Electron Framework**: Native Desktop-Integration
- **Automatische Updates**: Integrierte Update-Mechanismen
- **SQLite Database**: Lokale Datenspeicherung mit SQLite
- **CI/CD Pipeline**: Automatisierte Builds und Releases

## 🚀 Installation

### Raspberry Pi Installation

Für Raspberry Pi gibt es vorgefertigte `.deb` Pakete:

#### Neueste Version herunterladen:
```bash
# ARM64 (Raspberry Pi 4, Pi 400, Pi 5)
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/latest/download/mthbdeiotclient_latest_arm64.deb

# ARMv7l (Raspberry Pi 3, Pi Zero 2 W)
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/latest/download/mthbdeiotclient_latest_armv7l.deb
```

#### Spezifische Version herunterladen:
```bash
# Beispiel für Version 1.0.82 - ARM64
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/download/v1.0.82/mthbdeiotclient_1.0.82_arm64.deb

# Beispiel für Version 1.0.82 - ARMv7l
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/download/v1.0.82/mthbdeiotclient_1.0.82_armv7l.deb
```

#### Installation:
```bash
# Paket installieren
sudo dpkg -i mthbdeiotclient_*.deb

# Abhängigkeiten reparieren (falls nötig)
sudo apt-get install -f
```

### Entwicklungsumgebung Setup

```bash
# Repository klonen
git clone https://github.com/mthitservice/MTHBDEIOTClient.git
cd MTHBDEIOTClient/App

# Abhängigkeiten installieren
npm install

# Entwicklungsserver starten
npm start
```

## 🛠 Entwicklung

### Verfügbare Scripts

```bash
# Entwicklungsserver starten
npm start

# Für Produktion kompilieren
npm run build

# Tests ausführen
npm test

# Pakete für lokale Plattform erstellen
npm run package

# Release erstellen (für Maintainer)
npm run release:patch    # Patch Version (1.0.0 -> 1.0.1)
npm run release:minor    # Minor Version (1.0.0 -> 1.1.0)
npm run release:major    # Major Version (1.0.0 -> 2.0.0)
```

### Projektstruktur

```
App/
├── src/
│   ├── main/           # Electron Main Process
│   ├── renderer/       # React Frontend
│   └── __tests__/      # Test Dateien
├── public/
│   └── database/       # SQLite Datenbank
├── assets/             # App Icons und Assets
├── release/            # Build Ausgabe
└── scripts/            # Build Scripts
```

## 📦 Build und Deployment

### Automatische Releases

Das Projekt nutzt Azure DevOps Pipelines für automatische Builds und GitHub Releases:

1. **Release erstellen**: `npm run release:patch`
2. **Pipeline**: Wird automatisch durch Git Tags ausgelöst
3. **Build**: Erstellt .deb Pakete für ARM64 und ARMv7l
4. **Release**: Automatisches GitHub Release mit Paketen

### Raspberry Pi Deployment

Das Deployment-Script für Raspberry Pi:

```bash
# In das App-Verzeichnis wechseln
cd App

# Deployment ausführen
./deploy.ps1
```

## 🔧 Konfiguration

### Datenbank

Die Anwendung nutzt SQLite für lokale Datenspeicherung:
- **Speicherort**: `public/database/bde.sqlite`
- **Konfiguration**: `public/database/DBConfig.js`
- **Manager**: `public/database/DBManager.js`

### Environment Variables

```bash
VERSION=1.0.82          # App Version
APP_VERSION=1.0.82      # Display Version
```

## 🔗 Links

- [GitHub Repository](https://github.com/mthitservice/MTHBDEIOTClient)
- [Releases](https://github.com/mthitservice/MTHBDEIOTClient/releases)
- [Azure DevOps](https://dev.azure.com/mth-it-service/MTHUABDEDS)
- [MTH IT-Service](https://mth-it-service.de)

## 📄 Lizenz

Dieses Projekt ist lizenziert unter der MIT License - siehe [LICENSE](LICENSE) Datei für Details.

## 👥 Entwickelt von

**MTH IT-Service**
- Website: [mth-it-service.de](https://mth-it-service.de)
- Repository: [MTHBDEIOTClient](https://github.com/mthitservice/MTHBDEIOTClient)

## 🤝 Beitragen

1. Fork das Repository
2. Erstelle einen Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Committe deine Änderungen (`git commit -m 'Add some AmazingFeature'`)
4. Push zum Branch (`git push origin feature/AmazingFeature`)
5. Öffne einen Pull Request

## 📞 Support

Bei Fragen oder Problemen:
- Öffne ein [GitHub Issue](https://github.com/mthitservice/MTHBDEIOTClient/issues)
- Kontaktiere MTH IT-Service
