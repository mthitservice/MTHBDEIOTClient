# MthBdeIotClient - Raspberry Pi Pipelines mit GitHub Auto-Release

## 🚀 Automatische Pipeline-Struktur

### 1. Build Pipeline: `azure-pipelines-raspberry.yml`
**Zweck:** Baut Raspberry Pi 3+ .deb Pakete und publiziert automatisch auf GitHub

- **Trigger:** master, release/*, develop, Tags v*
- **Target:** ARMv7l (Raspberry Pi 3+)
- **Output:** .deb Paket + GitHub Release
- **Befehl:** `npm run package:raspberry-deb`
- **GitHub:** Automatisches Release bei Tags

### 2. Release Pipeline: `azure-pipelines-release.yml`
**Zweck:** Erweiterte Release-Pakete mit GitHub Publikation

- **Trigger:** Manuell / Build Pipeline bei Tags
- **Output:** GitHub Release mit Assets
- **Environment:** RaspberryPi-Production + GitHub-Production

## 🎯 Automatischer GitHub Release

### ✅ Was passiert automatisch:
1. **Git Tag erstellen** → `git tag v1.0.0 && git push origin v1.0.0`
2. **Pipeline läuft** → Baut .deb Paket
3. **GitHub Release** → Automatisch als "latest" veröffentlicht
4. **Assets hochgeladen** → .deb, SHA256SUMS, Dokumentation

### 📦 GitHub Release Inhalte:
- **mthbdeiotclient_1.0.0_armhf.deb** - Installationspaket
- **SHA256SUMS** - Checksums für Verifikation
- **RASPBERRY_INSTALLATION.md** - Installations-Anleitung
- **deploy.ps1** - Deployment-Script

## 📦 Quick Start

### 1. GitHub Setup (WICHTIG!)
```bash
# 1. GitHub Personal Access Token erstellen
# 2. Azure DevOps Service Connection einrichten
# 3. Environments erstellen
```
**Detaillierte Anleitung:** `GITHUB_SETUP.md`

### 2. Pipeline Setup
```bash
# Build Pipeline
Name: MthBdeIotClient-RaspberryPi-Build
YAML: azure-pipelines-raspberry.yml

# Release Pipeline (optional)
Name: MthBdeIotClient-RaspberryPi-Release
YAML: azure-pipelines-release.yml
```

### 3. Automatischer Release
```bash
# Neuen Release erstellen
git tag v1.0.0
git push origin v1.0.0

# Pipeline läuft automatisch
# GitHub Release wird erstellt
# .deb ist sofort verfügbar
```

## 🍓 Installation auf Raspberry Pi

### ⚡ Eine-Zeile Installation:
```bash
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/latest/download/mthbdeiotclient_1.0.0_armhf.deb && sudo dpkg -i mthbdeiotclient_1.0.0_armhf.deb && sudo apt-get install -f
```

### 🔧 Schritt-für-Schritt:
```bash
# 1. Download latest release
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/latest/download/mthbdeiotclient_1.0.0_armhf.deb

# 2. Installation
sudo dpkg -i mthbdeiotclient_1.0.0_armhf.deb
sudo apt-get install -f

# 3. Starten
mthbdeiotclient
```

## 🔗 GitHub Links
- **Repository:** https://github.com/mthitservice/MTHBDEIOTClient
- **Latest Release:** https://github.com/mthitservice/MTHBDEIOTClient/releases/latest
- **Alle Releases:** https://github.com/mthitservice/MTHBDEIOTClient/releases

## 📋 Nächste Schritte

1. **GitHub Setup** (siehe GITHUB_SETUP.md)
2. **Service Connection einrichten**
3. **Environments erstellen**
4. **Test-Release:** `git tag v0.1.0-test`
5. **Ersten produktiven Release:** `git tag v1.0.0`

## 📚 Dokumentation

- **GitHub Setup:** `GITHUB_SETUP.md` ⭐ **WICHTIG ZUERST!**
- **Pipeline Details:** `PIPELINE_GUIDE.md`
- **Azure Setup:** `AZURE_DEVOPS_SETUP.md`
- **Raspberry Pi:** `RASPBERRY_INSTALLATION.md`
