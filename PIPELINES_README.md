# MthBdeIotClient - Raspberry Pi Pipelines

## 🚀 Neue Pipeline-Struktur

### 1. Build Pipeline: `azure-pipelines-raspberry.yml`
**Zweck:** Baut Raspberry Pi 3+ .deb Pakete

- **Trigger:** master, release/*, develop, Tags v*
- **Target:** ARMv7l (Raspberry Pi 3+)
- **Output:** .deb Paket
- **Befehl:** `npm run package:raspberry-deb`

### 2. Release Pipeline: `azure-pipelines-release.yml`
**Zweck:** Erstellt Release-Pakete

- **Trigger:** Manuell / Build Pipeline bei Tags
- **Output:** GitHub-ready Release Assets
- **Environment:** RaspberryPi-Production

## 📦 Quick Start

### 1. Azure DevOps Setup

```bash
# 1. Build Pipeline erstellen
Name: MthBdeIotClient-RaspberryPi-Build
YAML: azure-pipelines-raspberry.yml

# 2. Release Pipeline erstellen  
Name: MthBdeIotClient-RaspberryPi-Release
YAML: azure-pipelines-release.yml

# 3. Environment erstellen
Name: RaspberryPi-Production
Type: Virtual Environment
```

### 2. Release erstellen

```bash
# Tag erstellen und pushen
git tag v1.0.0
git push origin v1.0.0

# Pipeline läuft automatisch
# Artifacts werden erstellt
# Release-Pipeline wird getriggert
```

### 3. GitHub Release (manuell)

```bash
# 1. Artifacts downloaden
# 2. GitHub Release erstellen: v1.0.0
# 3. .deb Datei hochladen
# 4. Release Notes hinzufügen
```

## 🍓 Installation auf Raspberry Pi

```bash
# Download
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/download/v1.0.0/mthbdeiotclient_1.0.0_armhf.deb

# Installation
sudo dpkg -i mthbdeiotclient_1.0.0_armhf.deb
sudo apt-get install -f

# Starten
mthbdeiotclient
```

## 📋 Nächste Schritte

1. **Environment einrichten** (siehe AZURE_DEVOPS_SETUP.md)
2. **Pipelines in Azure DevOps importieren**
3. **Test-Release mit Tag erstellen**
4. **GitHub Service Connection konfigurieren** (für späteren automatischen Upload)

## 📚 Dokumentation

- **Detailliert:** `PIPELINE_GUIDE.md`
- **Azure Setup:** `AZURE_DEVOPS_SETUP.md`
- **Raspberry Pi:** `RASPBERRY_INSTALLATION.md`
