# PowerShell-Skripte für MTH BDE IoT Client

Dieses Verzeichnis enthält alle PowerShell-Skripte für die Verwaltung und Automatisierung des MTH BDE IoT Client Projekts.

## 🚀 Schnellstart

### Master-Verwaltungstool

Verwende das zentrale Verwaltungstool für alle Operationen:

```powershell
# Hilfe anzeigen
.\mth-manager.ps1 help

# Entwicklungsmodus starten
.\mth-manager.ps1 dev

# Raspberry Pi Build erstellen
.\mth-manager.ps1 build raspberry

# Release erstellen
.\mth-manager.ps1 release 1.0.50
```

## 📁 Verfügbare Skripte

### 🎯 Hauptskripte

| Skript                      | Beschreibung                       | Verwendung                    |
| --------------------------- | ---------------------------------- | ----------------------------- |
| `create-manual-release.ps1` | Manuelles GitHub Release erstellen | Release Management            |
| `dev-modes.ps1`             | Entwicklungsmodi starten           | Lokale Entwicklung            |
| `deploy.ps1`                | Deployment-Prozess                 | Automatisierte Bereitstellung |
| `trigger-auto-release.ps1`  | Automatischen Release triggern     | CI/CD                         |
| `trigger-pipeline.ps1`      | Azure DevOps Pipeline starten      | CI/CD                         |

### 🔧 Debug & Wartung

| Skript                     | Beschreibung             | Verwendung         |
| -------------------------- | ------------------------ | ------------------ |
| `debug-deb.ps1`            | DEB-Paket Debug-Tools    | Problemdiagnose    |
| `quick-fix-deb.ps1`        | Schnelle DEB-Korrekturen | Fehlerbehebung     |
| `validate-deb-package.ps1` | DEB-Paket Validierung    | Qualitätssicherung |

### ⚙️ Setup & Konfiguration

| Skript                         | Beschreibung                    | Verwendung         |
| ------------------------------ | ------------------------------- | ------------------ |
| `setup-pipeline-variables.ps1` | Azure DevOps Pipeline Variablen | Setup              |
| `release-version.ps1`          | Versionsverwaltung              | Release Management |

## 🛠️ Verwendung

### Entwicklung

```powershell
# Entwicklungsmodus mit Auswahl
.\powershell-scripts\dev-modes.ps1

# Oder über Master-Tool
.\mth-manager.ps1 dev
```

### Builds

```powershell
# Standard Build
.\mth-manager.ps1 build

# Raspberry Pi Build
.\mth-manager.ps1 build raspberry

# Development Build
.\mth-manager.ps1 build dev
```

### Releases

```powershell
# Automatisches Release
.\mth-manager.ps1 release

# Release mit spezifischer Version
.\mth-manager.ps1 release 1.0.51

# Manuelles Release
.\powershell-scripts\create-manual-release.ps1 -Version "1.0.51" -ReleaseNotes "Bug fixes"
```

### Debug & Wartung

```powershell
# DEB-Paket debuggen
.\mth-manager.ps1 debug

# Schnelle Reparatur
.\mth-manager.ps1 fix

# DEB-Paket validieren
.\mth-manager.ps1 validate
```

## 🚀 Pipeline-Management

```powershell
# Pipeline triggern
.\mth-manager.ps1 trigger

# Oder direkt
.\powershell-scripts\trigger-pipeline.ps1

# Auto-Release starten
.\powershell-scripts\trigger-auto-release.ps1
```

## ⚙️ Voraussetzungen

### Erforderliche Tools

- **PowerShell 5.1+** oder **PowerShell Core 7+**
- **Node.js 18+** LTS
- **npm** oder **yarn**
- **Git**
- **GitHub CLI** (für Release-Management)

### Optionale Tools

- **Azure CLI** (für Azure DevOps Integration)
- **Docker** (für Container-Builds)

## 📝 Tipps

### Best Practices

1. **Immer im Repository-Root ausführen**: Die meisten Skripte erwarten, dass sie vom Projektroot aus gestartet werden
2. **Execution Policy prüfen**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
3. **Git Status prüfen**: Vor Releases sicherstellen, dass alle Änderungen committed sind

### Häufige Probleme

```powershell
# PowerShell Execution Policy Fehler
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# NPM Permission Probleme
npm config set prefix %APPDATA%\npm

# Git Credential Probleme
git config --global credential.helper manager-core
```

## 🔗 Siehe auch

- [Haupt-Dokumentation](../MAIN_DOCUMENTATION.md)
- [Shell-Skripte](../shell-scripts/)
- [Azure DevOps Konfiguration](../azure-devops/)

---

Für weitere Hilfe siehe die [Haupt-Dokumentation](../MAIN_DOCUMENTATION.md) oder verwende `.\mth-manager.ps1 help`.
