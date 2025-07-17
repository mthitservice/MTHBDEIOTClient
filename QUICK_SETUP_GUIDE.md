# Pipeline Setup & Release Guide

## 🚀 Schnellanleitung für Azure DevOps Pipeline und GitHub Releases

Diese Anleitung führt Sie durch den kompletten Prozess vom Pipeline-Setup bis zur Raspberry Pi Installation.

---

## 📋 Voraussetzungen

### Benötigte Accounts & Tools
- [x] Azure DevOps Account
- [x] GitHub Repository mit Admin-Rechten
- [x] GitHub Personal Access Token
- [x] Azure CLI (für automatisches Setup)

### Optionale API Keys
- [ ] Produktions-API Schlüssel
- [ ] Code Signing Zertifikat
- [ ] Sentry DSN
- [ ] Analytics Keys

---

## ⚡ 1-Minute Setup (Automatisch)

### Step 1: Repository Files hinzufügen
```bash
# Alle Pipeline-Dateien sind bereits im Repository
git add .
git commit -m "Add Azure DevOps pipeline and release automation"
git push origin main
```

### Step 2: Pipeline Variables automatisch konfigurieren
```powershell
# PowerShell als Administrator öffnen
cd "C:\Users\Michael.Lindner\source\repos\MthBdeIotClient"

# Azure DevOps Pipeline Variables setzen
.\azure-devops\setup-pipeline-variables.ps1 `
    -OrganizationUrl "https://dev.azure.com/IhrOrg" `
    -ProjectName "IhrProjekt" `
    -PipelineId 123
```

### Step 3: Ersten Release erstellen
```bash
# Version Tag erstellen
git tag v1.0.1
git push origin v1.0.1

# Pipeline startet automatisch!
```

---

## 🔧 Manuelles Setup (Schritt-für-Schritt)

### 1. Azure DevOps Pipeline erstellen

1. **Azure DevOps öffnen:** `https://dev.azure.com/IhrOrg/IhrProjekt`
2. **Pipelines → New Pipeline**
3. **GitHub → Repository auswählen**
4. **Existing Azure Pipelines YAML file**
5. **Path:** `/azure-pipelines.yml`

### 2. Pipeline Variables konfigurieren

Gehen Sie zu: **Pipelines → Ihre Pipeline → Edit → Variables**

#### Erforderliche Variables:

| Variable Name        | Beispiel Wert                    | Secret |
| -------------------- | -------------------------------- | ------ |
| `GITHUB_TOKEN`       | `ghp_xxxxxxxxxxxx`               | ✅      |
| `GITHUB_REPOSITORY`  | `mthitservice/MTHBDEIOTClient` | ❌      |
| `API_ENDPOINT_URL`   | `https://api.mth-it-service.com` | ❌      |
| `API_KEY_PRODUCTION` | `prod_api_key_123`               | ✅      |

#### Optionale Variables:

| Variable Name             | Beschreibung         | Secret |
| ------------------------- | -------------------- | ------ |
| `SIGNING_CERT_THUMBPRINT` | Windows Code Signing | ✅      |
| `SIGNING_CERT_PASSWORD`   | Zertifikat Passwort  | ✅      |
| `SENTRY_DSN`              | Error Tracking URL   | ✅      |
| `ANALYTICS_KEY`           | Analytics API Key    | ✅      |
| `LICENSE_KEY`             | Software Lizenz      | ✅      |

### 3. GitHub Service Connection erstellen

**Azure DevOps → Project Settings → Service Connections → New**

- **Service Connection Type:** GitHub
- **Connection Name:** `github-connection`
- **GitHub PAT:** Ihr Personal Access Token
- **Berechtigung:** `repo`, `write:packages`

### 4. Pipeline testen

```bash
# Test-Release erstellen
git tag v0.0.1-test
git push origin v0.0.1-test
```

**Überprüfen:**
- Azure DevOps → Pipelines → Runs
- GitHub → Releases (nach erfolgreichem Build)

---

## 🏷️ Release-Erstellung

### Produktions-Release
```bash
# 1. Code finalisieren
git checkout main
git pull origin main

# 2. Version Tag erstellen
git tag v1.0.1
git push origin v1.0.1

# 3. Pipeline überwachen
# Azure DevOps → Pipelines → Runs
```

### Pre-Release (Beta)
```bash
# Beta-Version
git tag v1.0.1-beta
git push origin v1.0.1-beta
```

### Hotfix-Release
```bash
# Hotfix von Release Branch
git checkout release/1.0.x
git tag v1.0.2
git push origin v1.0.2
```

### Build-Status prüfen
```bash
# Pipeline-Status per CLI
az pipelines runs list --organization "https://dev.azure.com/IhrOrg" --project "IhrProjekt"
```

---

## 📦 Downloads nach Release

### Automatische Download-URLs

Nach erfolgreichem Release sind folgende Downloads verfügbar:

#### Windows
```
https://github.com/mthitservice/MthBdeIotClient/releases/latest/download/MthBdeIotClient-Setup.exe
https://github.com/mthitservice/MthBdeIotClient/releases/download/v1.0.1/MthBdeIotClient-Setup-1.0.1.exe
```

#### Raspberry Pi
```
https://github.com/mthitservice/MthBdeIotClient/releases/latest/download/mthbdeiotclient_latest_armhf.deb
https://github.com/mthitservice/MthBdeIotClient/releases/download/v1.0.1/mthbdeiotclient_1.0.1_armhf.deb
```

#### Linux (tar.gz)
```
https://github.com/mthitservice/MthBdeIotClient/releases/latest/download/MthBdeIotClient-linux-armv7l.tar.gz
```

---

## 🍓 Raspberry Pi Installation

### One-Line Installation (Neueste Version)
```bash
curl -fsSL https://raw.githubusercontent.com/mthitservice/MthBdeIotClient/main/scripts/install-raspberry.sh | bash
```

### Manuelle Installation
```bash
# 1. Neueste Version ermitteln und herunterladen
curl -s https://api.github.com/repos/mthitservice/MthBdeIotClient/releases/latest | \
  grep "browser_download_url.*armhf.deb" | \
  cut -d '"' -f 4 | \
  wget -qi -

# 2. Installation
sudo dpkg -i mthbdeiotclient_*_armhf.deb
sudo apt-get install -f

# 3. Kiosk-Modus aktivieren
sudo systemctl enable mthbdeiot-kiosk.service
```

### Spezifische Version installieren
```bash
# Version 1.0.1 installieren
VERSION="1.0.1"
curl -L "https://github.com/mthitservice/MthBdeIotClient/releases/download/v${VERSION}/mthbdeiotclient_${VERSION}_armhf.deb" -o mthbdeiotclient.deb
sudo dpkg -i mthbdeiotclient.deb
sudo apt-get install -f
```

### Update auf neueste Version
```bash
# Update-Script ausführen (wird automatisch installiert)
sudo /usr/local/bin/update-mthbdeiot.sh
```

### Automatische Updates aktivieren
```bash
# Cron-Job für wöchentliche Updates (Sonntag 2 Uhr)
echo "0 2 * * 0 /usr/local/bin/update-mthbdeiot.sh" | sudo tee -a /etc/crontab
```

---

## 🌐 Massendeployment (Ansible)

### 1. Inventory generieren
```bash
cd "C:\Users\Michael.Lindner\source\repos\MthBdeIotClient\App"

# IP-Bereiche anpassen in generate-inventory.sh
# Dann ausführen:
bash generate-inventory.sh
```

### 2. Ansible Deployment
```bash
# Alle Raspberry Pi's deployen
ansible-playbook playbooks/deploy-mthbdeiotclient.yml -v

# Einzelnes Gerät
ansible-playbook playbooks/deploy-mthbdeiotclient.yml --limit pi-001

# Connectivity Test
ansible all -m ping
```

### 3. Status prüfen
```bash
# IP-Adressen aller Geräte
ansible all -a "hostname -I"

# App-Status prüfen
ansible all -a "systemctl status mthbdeiot-kiosk.service"
```

---

## 🔍 Monitoring & Troubleshooting

### Pipeline-Logs
```bash
# Azure CLI Pipeline Logs
az pipelines runs show --id RUN_ID --organization "https://dev.azure.com/IhrOrg" --project "IhrProjekt"
```

### Build-Status Badges
```markdown
# Für README.md
[![Build Status](https://dev.azure.com/IhrOrg/IhrProjekt/_apis/build/status/PipelineId?branchName=main)](https://dev.azure.com/IhrOrg/IhrProjekt/_build/latest?definitionId=PipelineId&branchName=main)

[![Latest Release](https://img.shields.io/github/v/release/mthitservice/MthBdeIotClient)](https://github.com/mthitservice/MthBdeIotClient/releases/latest)

[![Downloads](https://img.shields.io/github/downloads/mthitservice/MthBdeIotClient/total)](https://github.com/mthitservice/MthBdeIotClient/releases)
```

### Häufige Probleme

#### Pipeline schlägt fehl
```bash
# 1. Variables prüfen
az pipelines variable list --pipeline-id PIPELINE_ID

# 2. Service Connection testen
az devops service-endpoint list --organization "https://dev.azure.com/IhrOrg" --project "IhrProjekt"

# 3. GitHub Token Berechtigung prüfen
curl -H "Authorization: token GITHUB_TOKEN" https://api.github.com/user
```

#### Raspberry Pi Installation fehlgeschlagen
```bash
# Debug-Modus
bash -x install-raspberry.sh

# Logs prüfen
journalctl -u mthbdeiot-kiosk.service -f

# Manuelle Installation
sudo dpkg -i mthbdeiotclient.deb
sudo apt-get install -f -y
```

#### Electron App startet nicht
```bash
# Debug-Modus
/opt/MthBdeIotClient/mthbdeiotclient --verbose --disable-gpu

# X11 Berechtigung
xhost +local:
export DISPLAY=:0
```

---

## 🔄 Update-Workflow

### 1. Code Changes
```bash
git checkout main
# ... Code ändern ...
git add .
git commit -m "Feature: New functionality"
git push origin main
```

### 2. Release erstellen
```bash
# Neue Version
git tag v1.0.2
git push origin v1.0.2
```

### 3. Automatisches Rollout
- ✅ Pipeline baut neue Version
- ✅ GitHub Release wird erstellt
- ✅ Latest Tag wird aktualisiert
- ✅ Raspberry Pi's können updaten

### 4. Raspberry Pi Update
```bash
# Einzelnes Gerät
sudo /usr/local/bin/update-mthbdeiot.sh

# Alle Geräte (Ansible)
ansible all -a "/usr/local/bin/update-mthbdeiot.sh"
```

---

## 📚 Quick Reference

### Wichtige URLs
- **Azure DevOps:** `https://dev.azure.com/IhrOrg/IhrProjekt`
- **GitHub Releases:** `https://github.com/mthitservice/MthBdeIotClient/releases`
- **Latest Download:** `https://github.com/mthitservice/MthBdeIotClient/releases/latest`

### Kommandos
```bash
# Release erstellen
git tag v1.0.1 && git push origin v1.0.1

# Raspberry Pi Installation
curl -fsSL https://raw.githubusercontent.com/mthitservice/MthBdeIotClient/main/scripts/install-raspberry.sh | bash

# Update
sudo /usr/local/bin/update-mthbdeiot.sh

# Ansible Deployment
ansible-playbook playbooks/deploy-mthbdeiotclient.yml

# Pipeline Status
az pipelines runs list --organization "https://dev.azure.com/IhrOrg" --project "IhrProjekt"
```

### Environment Variables (zur Laufzeit verfügbar)
```bash
NODE_ENV=production
APP_VERSION=1.0.1
REACT_APP_VERSION=1.0.1
REACT_APP_API_URL=https://api.mth-it-service.com
REACT_APP_API_KEY=your_api_key
KIOSK_MODE=true
FULLSCREEN_MODE=true
AUTO_UPDATE_ENABLED=true
```

---

## 🆘 Support

### Logs & Debugging
```bash
# Pipeline Logs: Azure DevOps → Pipelines → Runs → Logs
# App Logs: journalctl -u mthbdeiot-kiosk.service -f
# System Logs: tail -f /var/log/syslog
```

### Contacts
- **Repository:** https://github.com/mthitservice/MthBdeIotClient
- **Issues:** https://github.com/mthitservice/MthBdeIotClient/issues
- **Support:** info@mth-it-service.com

---

**🎉 Happy Deploying!**
