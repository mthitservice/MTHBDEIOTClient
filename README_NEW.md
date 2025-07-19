# MTH BDE IoT Client

## 🚀 Überblick

Eine moderne Electron-basierte Anwendung für die Verwaltung von MTH BDE IoT-Geräten mit fokussierter Raspberry Pi-Unterstützung.

## 🎯 Features

- ✅ **Native Electron Desktop App** für Windows, macOS und Linux
- ✅ **Raspberry Pi optimiert** (ARM64 & ARMv7l Architektur)
- ✅ **AutoUpdater** mit GitHub-Integration
- ✅ **SQLite-Datenbank** für lokale Datenverwaltung
- ✅ **Cross-Platform** Build-System
- ✅ **Azure DevOps CI/CD** Pipeline

## 📦 Schnellstart

### Installation (Raspberry Pi)

```bash
curl -fsSL https://raw.githubusercontent.com/mthitservice/MTHBDEIOTClient/master/shell-scripts/install-latest.sh | bash
```

### Entwicklung

```bash
git clone https://github.com/mthitservice/MTHBDEIOTClient.git
cd MTHBDEIOTClient/App
npm install
npm run dev
```

## 📚 Dokumentation

Für die vollständige Dokumentation siehe: **[MAIN_DOCUMENTATION.md](./MAIN_DOCUMENTATION.md)**

Diese enthält:

- 🛠️ Detaillierte Installation & Setup
- 🚀 Deployment & Pipeline Konfiguration
- 🔧 Troubleshooting & Debug-Guides
- 📁 Projektstruktur
- 🤝 Contributing Guidelines

## 🔗 Quick Links

- **Assets**: Direkte Links zu [Icons & Images](./MAIN_DOCUMENTATION.md#asset-zugriff)
- **Shell-Skripte**: Alle Skripte in [`./shell-scripts/`](./shell-scripts/)
- **Pipeline Config**: [`./azure-pipelines.yml`](./azure-pipelines.yml)
- **App Code**: [`./App/`](./App/)

## 📞 Support

Bei Problemen oder Fragen:

1. [MAIN_DOCUMENTATION.md](./MAIN_DOCUMENTATION.md) prüfen
2. GitHub Issues erstellen
3. Debug-Modi verwenden: `./shell-scripts/dev-modes.sh --debug`

---

**Quick Commands:**

```bash
# Service Status
systemctl status mthbdeiotclient

# Logs anzeigen
journalctl -u mthbdeiotclient -f

# Neustart
sudo systemctl restart mthbdeiotclient
```
