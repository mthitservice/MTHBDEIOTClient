# Release Management System - Usage Guide

## Übersicht

Das **MthBdeIotClient Release Management System** bietet eine vollständige Automatisierung für Versionierung, Building und Deployment der Electron-App für Raspberry Pi Systeme. Das System umfasst:

- **Automatische Versionierung** mit Semantic Versioning
- **Cross-Platform Skripte** für Windows, Linux und macOS
- **Azure DevOps Pipeline Integration** für automatisches Building
- **GitHub Release Automation** für Distribution
- **Raspberry Pi Debian Package** (.deb) Generation für ARM64 und ARMv7l

## 🚀 Schnellstart

### NPM Scripts (Empfohlen)

```bash
# Interaktive Versionswahl
npm run release

# Automatische Patch-Version (z.B. 1.0.0 → 1.0.1)
npm run release:patch

# Automatische Minor-Version (z.B. 1.0.0 → 1.1.0)
npm run release:minor

# Automatische Major-Version (z.B. 1.0.0 → 2.0.0)
npm run release:major
```

### Direkte Skript-Ausführung

```bash
# Node.js Version (Cross-Platform)
node scripts/release-version.js

# PowerShell Version (Windows)
powershell -ExecutionPolicy Bypass -File scripts/release-version.ps1

# Bash Version (Linux/macOS)
bash scripts/release-version.sh
```

## 📋 Verfügbare Kommandos

### NPM Scripts

| Kommando                | Beschreibung                             |
| ----------------------- | ---------------------------------------- |
| `npm run release`       | Interaktive Versionswahl mit Menü        |
| `npm run release:patch` | Patch-Version erhöhen (Bugfixes)         |
| `npm run release:minor` | Minor-Version erhöhen (neue Features)    |
| `npm run release:major` | Major-Version erhöhen (Breaking Changes) |

### Kommandozeilen-Parameter

#### Node.js Version (`release-version.js`)
```bash
# Versiontyp angeben
node scripts/release-version.js --type patch|minor|major

# Spezifische Version setzen
node scripts/release-version.js --version 1.2.3

# Bestätigungen überspringen
node scripts/release-version.js --force

# Nur anzeigen was passieren würde
node scripts/release-version.js --dry-run

# Hilfe anzeigen
node scripts/release-version.js --help
```

#### PowerShell Version (`release-version.ps1`)
```powershell
# Versiontyp angeben
.\scripts\release-version.ps1 -Type patch|minor|major

# Spezifische Version setzen
.\scripts\release-version.ps1 -Version "1.2.3"

# Bestätigungen überspringen
.\scripts\release-version.ps1 -Force

# Nur anzeigen was passieren würde
.\scripts\release-version.ps1 -DryRun

# Hilfe anzeigen
.\scripts\release-version.ps1 -Help
```

#### Bash Version (`release-version.sh`)
```bash
# Versiontyp angeben
bash scripts/release-version.sh patch|minor|major

# Spezifische Version setzen
bash scripts/release-version.sh 1.2.3

# Bestätigungen überspringen
bash scripts/release-version.sh --force

# Nur anzeigen was passieren würde
bash scripts/release-version.sh --dry-run

# Hilfe anzeigen
bash scripts/release-version.sh --help
```

## 🛠️ Was passiert beim Release?

### 1. Versionierung
- **package.json** wird mit neuer Version aktualisiert
- **.env** Datei wird mit `VERSION=x.x.x` ergänzt
- **release/app/package.json** wird synchronisiert (falls vorhanden)

### 2. Git Operations
- Alle Änderungen werden committed
- Git Tag wird erstellt (Format: `vX.X.X`)
- Push zu origin repository

### 3. Pipeline Triggering
- **Azure DevOps Pipeline** startet automatisch
- **Raspberry Pi .deb Package** wird gebaut
- **GitHub Release** wird automatisch erstellt

### 4. Deployment
- Package wird als GitHub Release Asset verfügbar
- Automatische "Latest" Release Kennzeichnung
- Debian Packages für `arm64` (aarch64) und `armv7l` Architekturen

## 📁 Dateistruktur

```
MthBdeIotClient/
├── scripts/
│   ├── release-version.js      # Node.js Version Manager
│   ├── release-version.ps1     # PowerShell Version Manager
│   └── release-version.sh      # Bash Version Manager
├── App/
│   ├── package.json           # Hauptkonfiguration
│   └── .env                   # Environment Variables
├── azure-pipelines-raspberry.yml  # Azure DevOps Pipeline
└── azure-pipelines-release.yml    # GitHub Release Pipeline
```

## 🍓 Raspberry Pi Unterstützung

### Unterstützte Architekturen

| Raspberry Pi Modell        | Architektur     | DEB Package    | Empfehlung       |
| -------------------------- | --------------- | -------------- | ---------------- |
| Raspberry Pi 4 (64-bit OS) | ARM64 (aarch64) | `*arm64*.deb`  | ✅ **Empfohlen**  |
| Raspberry Pi 4 (32-bit OS) | ARMv7l          | `*armv7l*.deb` | ✅ Kompatibilität |
| Raspberry Pi 3/3+          | ARMv7l          | `*armv7l*.deb` | ✅ Standard       |
| Raspberry Pi Zero 2 W      | ARMv7l          | `*armv7l*.deb` | ✅ Unterstützt    |

### Installation je nach System

```bash
# Systemarchitektur prüfen
uname -m
# arm64/aarch64 = ARM64 Package verwenden
# armv7l = ARMv7l Package verwenden

# Für ARM64 (Raspberry Pi 4 mit 64-bit OS)
sudo dpkg -i mthbdeiotclient_*_arm64.deb

# Für ARMv7l (Raspberry Pi 3/3+/4 mit 32-bit OS)
sudo dpkg -i mthbdeiotclient_*_armv7l.deb
```

## 🔧 Konfiguration

### Environment Variables (.env)
```env
# MthBdeIotClient Environment Variables
NODE_ENV=production
VERSION=1.0.0
ELECTRON_BUILDER_ALLOW_UNRESOLVED_DEPENDENCIES=true
```

### Package.json Scripts
```json
{
  "scripts": {
    "release": "node ../scripts/release-version.js",
    "release:patch": "node ../scripts/release-version.js --type patch",
    "release:minor": "node ../scripts/release-version.js --type minor",
    "release:major": "node ../scripts/release-version.js --type major"
  }
}
```

## 🎯 Semantic Versioning

Das System folgt **Semantic Versioning 2.0.0** (semver.org):

- **MAJOR** (z.B. 1.0.0 → 2.0.0): Breaking Changes
- **MINOR** (z.B. 1.0.0 → 1.1.0): Neue Features (rückwärtskompatibel)
- **PATCH** (z.B. 1.0.0 → 1.0.1): Bugfixes (rückwärtskompatibel)

### Beispiele

```bash
# Bugfix Release (Patch)
npm run release:patch  # 1.0.0 → 1.0.1

# Feature Release (Minor) - wird geschützt
npm run release:minor  # 1.0.1 → 1.1.0

# Breaking Change Release (Major) - wird geschützt
npm run release:major  # 1.1.0 → 2.0.0
```

## 🧹 Automatische Säuberung

Das Release Management System beinhaltet **intelligente Cleanup-Features** um Speicherplatz zu sparen:

### GitHub Release Cleanup

- **Schützt Major Releases** (x.0.0) - werden nie gelöscht
- **Schützt Minor Releases** (x.Y.0) - werden nie gelöscht  
- **Behält die letzten 10 Patch Releases** (konfigurierbar)
- **Löscht automatisch ältere Patch Releases**

### Azure Pipeline Artifacts Cleanup

- **Behält die letzten 20 erfolgreichen Builds** (konfigurierbar)
- **Löscht automatisch ältere Pipeline Builds**
- **Spart Speicherplatz in Azure DevOps**

### Konfiguration der Säuberung

```yaml
# In azure-pipelines-raspberry.yml
variables:
  keepPatchReleases: 10    # Anzahl Patch-Releases behalten
  keepPipelineBuilds: 20   # Anzahl Pipeline Builds behalten
```

## 🔍 Debugging & Troubleshooting

### Common Issues

#### 1. Git Working Directory nicht sauber
```bash
git status
git add .
git commit -m "Prepare for release"
```

#### 2. Tag existiert bereits
```bash
git tag -d v1.0.0           # Lokal löschen
git push origin --delete v1.0.0  # Remote löschen
```

#### 3. NPM Scripts nicht gefunden
```bash
cd App/  # Sicherstellen dass wir im App/ Verzeichnis sind
npm run release
```

### Verbose Logging

```bash
# Detaillierte Ausgabe
DEBUG=* npm run release

# Nur Git Operations anzeigen
GIT_TRACE=1 npm run release
```

## 🔗 Pipeline Integration

### Azure DevOps Pipeline
- **Trigger**: Git Tag Push (Pattern: `v*`)
- **Build**: Raspberry Pi ARM64 und ARMv7l .deb Packages
- **Test**: Automatische Tests vor Release
- **Deploy**: GitHub Release Creation

### GitHub Integration
- **Service Connection**: Azure DevOps ↔ GitHub
- **Release Assets**: .deb Package automatisch attached
- **Release Notes**: Auto-generated aus Git commits
- **Latest Tag**: Automatische Kennzeichnung

## 📊 Monitoring & Reporting

### Nützliche Links

- **Azure DevOps Builds**: https://dev.azure.com/mth-it-service/MthBdeIotClient/_build
- **GitHub Repository**: https://github.com/mthitservice/MTHBDEIOTClient
- **Latest Release**: https://github.com/mthitservice/MTHBDEIOTClient/releases/latest

### Status Checking

```bash
# Letzte Git Tags anzeigen
git tag -l --sort=-version:refname "v*" | head -5

# Pipeline Status prüfen
az pipelines show --name "MthBdeIotClient-Raspberry-CI" --organization https://dev.azure.com/mth-it-service

# GitHub Release Status
curl -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/mthitservice/MTHBDEIOTClient/releases/latest
```

## 🎉 Best Practices

### 1. Testing vor Release
```bash
# Dry-run verwenden
npm run release -- --dry-run

# Lokale Tests durchführen
npm test
npm run build
```

### 2. Commit Messages
- Verwende konventionelle Commit Messages
- Beschreibe Breaking Changes explizit
- Referenziere Issue Numbers

### 3. Version Planning
- **Patch**: Nur Bugfixes
- **Minor**: Neue Features + Bugfixes
- **Major**: Breaking Changes + Features + Bugfixes

### 4. Documentation
- Changelog pflegen
- Release Notes schreiben
- API Changes dokumentieren

## 🚨 Notfälle

### Rollback Release
```bash
# Tag löschen
git tag -d v1.0.0
git push origin --delete v1.0.0

# Commit rückgängig machen
git reset --hard HEAD~1
git push --force-with-lease origin main
```

### Pipeline Fehler
```bash
# Pipeline neu starten
az pipelines run --name "MthBdeIotClient-Raspberry-CI"

# Logs anzeigen
az pipelines logs --run-id <run-id>
```

## 📝 Changelog

### Version 1.0.0
- ✅ Implementierung des Release Management Systems
- ✅ Azure DevOps Pipeline für Raspberry Pi
- ✅ GitHub Release Automation
- ✅ Cross-Platform Version Manager Scripts
- ✅ NPM Scripts Integration
- ✅ Semantic Versioning Support
- ✅ Comprehensive Documentation

---

**Erstellt von**: MTH IT Service  
**Datum**: 2024  
**Version**: 1.0.0
