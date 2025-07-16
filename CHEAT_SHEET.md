# 🚀 MthBdeIotClient - Deployment Cheat Sheet

## Schnellstart

### 🏗️ Pipeline Setup (Einmalig)
```powershell
# 1. Azure DevOps Pipeline Variables konfigurieren
.\azure-devops\setup-pipeline-variables.ps1 -OrganizationUrl "https://dev.azure.com/IhrOrg" -ProjectName "IhrProjekt" -PipelineId 123

# 2. Service Connection erstellen
az devops service-endpoint github create --name "github-connection" --github-pat "ghp_xxxxx"
```

### 🏷️ Release erstellen
```bash
# Produktions-Release
git tag v1.0.1 && git push origin v1.0.1

# Beta-Release  
git tag v1.0.1-beta && git push origin v1.0.1-beta
```

## Raspberry Pi Installation

### 🍓 Einzelgerät Installation
```bash
# One-Line Installation (Empfohlen)
curl -fsSL https://raw.githubusercontent.com/mthitservice/MthBdeIotClient/main/scripts/install-raspberry.sh | bash

# Manuelle Installation
curl -s https://api.github.com/repos/mthitservice/MthBdeIotClient/releases/latest | grep "browser_download_url.*armhf.deb" | cut -d '"' -f 4 | wget -qi - && sudo dpkg -i mthbdeiotclient_*_armhf.deb && sudo apt-get install -f

# Update
sudo /usr/local/bin/update-mthbdeiot.sh
```

### 🌐 Massendeployment (Ansible)
```bash
# 1. Inventory generieren
bash generate-inventory.sh

# 2. Alle Geräte deployen
ansible-playbook playbooks/deploy-mthbdeiotclient.yml -v

# 3. Einzelnes Gerät
ansible-playbook playbooks/deploy-mthbdeiotclient.yml --limit pi-001

# 4. Status prüfen
ansible all -m ping
ansible all -a "hostname -I"
```

## Download URLs

### 🔗 Direkte Downloads
```bash
# Windows (Latest)
https://github.com/mthitservice/MthBdeIotClient/releases/latest/download/MthBdeIotClient-Setup.exe

# Raspberry Pi (Latest)
https://github.com/mthitservice/MthBdeIotClient/releases/latest/download/mthbdeiotclient_latest_armhf.deb

# Spezifische Version (v1.0.1)
https://github.com/mthitservice/MthBdeIotClient/releases/download/v1.0.1/mthbdeiotclient_1.0.1_armhf.deb
```

## Troubleshooting

### 🔍 Pipeline Debugging
```bash
# Pipeline Status
az pipelines runs list --organization "https://dev.azure.com/IhrOrg" --project "IhrProjekt"

# Pipeline Logs
az pipelines runs show --id RUN_ID --organization "https://dev.azure.com/IhrOrg" --project "IhrProjekt"

# Variables prüfen
az pipelines variable list --pipeline-id PIPELINE_ID
```

### 🍓 Raspberry Pi Debugging
```bash
# Service Status
sudo systemctl status mthbdeiot-kiosk.service

# Logs anzeigen
journalctl -u mthbdeiot-kiosk.service -f

# App manuell starten (Debug)
/opt/MthBdeIotClient/mthbdeiotclient --verbose --disable-gpu

# Neuinstallation
sudo dpkg -r mthbdeiotclient && sudo apt-get autoremove -y
curl -fsSL https://raw.githubusercontent.com/mthitservice/MthBdeIotClient/main/scripts/install-raspberry.sh | bash
```

## Environment Variables

### 🔧 Zur Build-Zeit verfügbar
```env
NODE_ENV=production
APP_VERSION=1.0.1
REACT_APP_VERSION=1.0.1
REACT_APP_API_URL=https://api.mth-it-service.com
REACT_APP_API_KEY=your_api_key
KIOSK_MODE=true
FULLSCREEN_MODE=true
AUTO_UPDATE_ENABLED=true
```

### 📱 In der App nutzen
```typescript
const version = process.env.REACT_APP_VERSION;
const apiUrl = process.env.REACT_APP_API_URL;
const apiKey = process.env.REACT_APP_API_KEY;
```

## Nützliche Links

- **Azure DevOps:** `https://dev.azure.com/IhrOrg/IhrProjekt`
- **GitHub Releases:** `https://github.com/mthitservice/MthBdeIotClient/releases`
- **Latest Download:** `https://github.com/mthitservice/MthBdeIotClient/releases/latest`
- **Issues:** `https://github.com/mthitservice/MthBdeIotClient/issues`

---
**📖 Vollständige Anleitung:** [QUICK_SETUP_GUIDE.md](QUICK_SETUP_GUIDE.md)
