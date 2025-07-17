# MTH BDE IoT Client

## 🚀 Überblick

Eine moderne Electron-basierte Anwendung für die Verwaltung von MTH BDE IoT-Geräten mit fokussierter Raspberry Pi-Unterstützung.

## 🎯 Features

- ✅ **Native Electron Desktop App** für Windows, macOS und Linux
- ✅ **Raspberry Pi optimiert** (ARMv7l Architektur)
- ✅ **AutoUpdater** mit GitHub-Integration
- ✅ **SQLite-Datenbank** für lokale Datenverwaltung
- ✅ **Cross-Platform** Build-System
- ✅ **Azure DevOps CI/CD** Pipeline

## 🔧 Installation

### Raspberry Pi (Ein-Kommando-Installation)

```bash
wget -O /tmp/install-latest.sh https://github.com/mthitservice/MTHBDEIOTClient/raw/main/install-latest.sh && chmod +x /tmp/install-latest.sh && /tmp/install-latest.sh
```

Für detaillierte Raspberry Pi-Installationsanweisungen siehe: [RASPBERRY_PI_INSTALLATION.md](RASPBERRY_PI_INSTALLATION.md)

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

## 🔗 Links

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