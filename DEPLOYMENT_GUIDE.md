# MthBdeIotClient - Setup und Deployment Anleitung

## 🚀 Komplette Azure DevOps zu GitHub Release Pipeline

Diese Anleitung zeigt Ihnen, wie Sie eine vollautomatisierte Pipeline einrichten, die:

1. ✅ Builds bei jedem Release-Tag erstellt
2. ✅ Versionsnummern automatisch verwaltet
3. ✅ Environment Variables integriert
4. ✅ Electron-Apps für alle Plattformen baut
5. ✅ GitHub Releases automatisch erstellt
6. ✅ Latest-Tag automatisch aktualisiert
7. ✅ Raspberry Pi Installation ermöglicht

## 📋 Voraussetzungen

### 1. Azure DevOps
- Azure DevOps Projekt
- Pipeline erstellt mit `azure-pipelines.yml`
- Service Connection zu GitHub

### 2. GitHub Repository
- Repository mit Admin-Rechten
- Personal Access Token mit `repo` und `write:packages` Berechtigung

### 3. API Keys (Optional)
- Produktions-API Schlüssel
- Code Signing Zertifikate
- Analytics Keys (Sentry, etc.)

## 🔧 Setup-Schritte

### Schritt 1: Repository vorbereiten

```bash
# 1. Dateien in Ihr Repository kopieren
git add azure-pipelines.yml
git add azure-devops/
git add .github/workflows/
git add App/scripts/
git commit -m "Add Azure DevOps pipeline and release automation"
git push origin main
```

### Schritt 2: Azure DevOps Pipeline konfigurieren

```powershell
# Pipeline Variables automatisch konfigurieren
.\azure-devops\setup-pipeline-variables.ps1 -OrganizationUrl "https://dev.azure.com/YourOrg" -ProjectName "YourProject" -PipelineId 123
```

**Manuelle Alternative:**
1. Gehen Sie zu Azure DevOps → Pipelines → Ihre Pipeline → Variables
2. Fügen Sie folgende Variables hinzu:

| Variable Name        | Wert                             | Secret |
| -------------------- | -------------------------------- | ------ |
| `GITHUB_TOKEN`       | Ihr GitHub PAT                   | ✅      |
| `GITHUB_REPOSITORY`  | `mthitservice/MthBdeIotClient`   | ❌      |
| `API_KEY_PRODUCTION` | Ihr API Key                      | ✅      |
| `API_ENDPOINT_URL`   | `https://api.mth-it-service.com` | ❌      |

### Schritt 3: GitHub Service Connection erstellen

```bash
# Azure DevOps Service Connection
az devops service-endpoint github create \
  --organization "https://dev.azure.com/YourOrg" \
  --project "YourProject" \
  --name "github-connection" \
  --github-url "https://github.com" \
  --github-pat "YOUR_GITHUB_TOKEN"
```

### Schritt 4: Ersten Release erstellen

```bash
# Version Tag erstellen und push
git tag v1.0.1
git push origin v1.0.1
```

## 🎯 Workflow

### Entwicklung → Release

1. **Code entwickeln** auf `main` Branch
2. **Release vorbereiten:**
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```
3. **Azure Pipeline** startet automatisch:
   - ✅ Build für Windows, Linux, macOS
   - ✅ Raspberry Pi ARM7l Build
   - ✅ Environment Variables einbetten
   - ✅ GitHub Release erstellen
   - ✅ Latest Tag aktualisieren

### Environment Variables zur Laufzeit

Die Pipeline erstellt automatisch eine `.env.production` Datei:

```env
NODE_ENV=production
APP_VERSION=1.0.1
REACT_APP_VERSION=1.0.1
REACT_APP_API_URL=https://api.mth-it-service.com
REACT_APP_API_KEY=your_api_key
BUILD_DATE=2025-07-16T10:30:00.000Z
ELECTRON_UPDATE_URL=https://github.com/mthitservice/MthBdeIotClient
AUTO_UPDATE_ENABLED=true
KIOSK_MODE=true
FULLSCREEN_MODE=true
```

### Zugriff in der App

```typescript
// In Ihrem Electron/React Code
const appVersion = process.env.REACT_APP_VERSION;
const apiUrl = process.env.REACT_APP_API_URL;
const apiKey = process.env.REACT_APP_API_KEY;

// Beispiel API Call
const response = await fetch(`${apiUrl}/data`, {
  headers: {
    'Authorization': `Bearer ${apiKey}`,
    'X-App-Version': appVersion
  }
});
```

## 📦 Download und Installation

### Windows
```bash
# Neueste Version
https://github.com/mthitservice/MthBdeIotClient/releases/latest/download/MthBdeIotClient-Setup.exe

# Spezifische Version
https://github.com/mthitservice/MthBdeIotClient/releases/download/v1.0.1/MthBdeIotClient-Setup-1.0.1.exe
```

### Raspberry Pi
```bash
# Automatische Installation der neuesten Version
curl -s https://api.github.com/repos/mthitservice/MthBdeIotClient/releases/latest | \
  grep "browser_download_url.*armhf.deb" | \
  cut -d '"' -f 4 | \
  wget -qi - && \
  sudo dpkg -i mthbdeiotclient_*_armhf.deb && \
  sudo apt-get install -f

# One-Liner für Raspberry Pi Setup
curl -fsSL https://raw.githubusercontent.com/mthitservice/MthBdeIotClient/main/scripts/install-raspberry.sh | bash
```

## 🔄 Automatische Updates

### Electron Auto-Updater
Die App prüft automatisch auf Updates vom GitHub Releases:

```typescript
// In main.ts
import { autoUpdater } from 'electron-updater';

autoUpdater.setFeedURL({
  provider: 'github',
  owner: 'mthitservice',
  repo: 'MthBdeIotClient'
});

autoUpdater.checkForUpdatesAndNotify();
```

### Raspberry Pi Cron-Job
```bash
# Automatisches Update jeden Sonntag um 2 Uhr
echo "0 2 * * 0 /usr/local/bin/update-mthbdeiot.sh" | sudo tee -a /etc/crontab
```

### Kiosk-Modus Autostart
```bash
# Systemd Service für automatischen Kiosk-Start
sudo tee /etc/systemd/system/mthbdeiot-kiosk.service > /dev/null << EOF
[Unit]
Description=MTH BDE IoT Client Kiosk Mode
After=graphical-session.target

[Service]
Type=simple
User=pi
Environment=DISPLAY=:0
ExecStart=/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk --fullscreen
Restart=always
RestartSec=5

[Install]
WantedBy=graphical-session.target
EOF

# Service aktivieren
sudo systemctl enable mthbdeiot-kiosk.service
sudo systemctl start mthbdeiot-kiosk.service
```

## 🛠 Pipeline Anpassungen

### Weitere API Keys hinzufügen

1. **Azure DevOps Variable hinzufügen:**
   ```powershell
   az pipelines variable create --name "NEW_API_KEY" --value "your_key" --secret true
   ```

2. **Pipeline YAML erweitern:**
   ```yaml
   - script: |
       export NEW_API_KEY=$(NEW_API_KEY)
       npm run build
     env:
       NEW_API_KEY: $(NEW_API_KEY)
   ```

3. **In der App verwenden:**
   ```typescript
   const newApiKey = process.env.REACT_APP_NEW_API_KEY;
   ```

### Code Signing aktivieren

```yaml
# In azure-pipelines.yml hinzufügen
- task: PowerShell@2
  displayName: 'Code Signing'
  inputs:
    script: |
      # Windows Code Signing
      signtool sign /sha1 $(SIGNING_CERT_THUMBPRINT) /p $(SIGNING_CERT_PASSWORD) /t http://timestamp.comodoca.com App/release/build/*.exe
  condition: and(succeeded(), ne(variables['SIGNING_CERT_THUMBPRINT'], ''))
```

## 📊 Monitoring und Logs

### Build Status Badge
```markdown
[![Build Status](https://dev.azure.com/YourOrg/YourProject/_apis/build/status/PipelineId?branchName=main)](https://dev.azure.com/YourOrg/YourProject/_build/latest?definitionId=PipelineId&branchName=main)

[![Latest Release](https://img.shields.io/github/v/release/mthitservice/MthBdeIotClient)](https://github.com/mthitservice/MthBdeIotClient/releases/latest)
```

### Pipeline Logs überwachen
- Azure DevOps: Pipeline → Runs → Logs
- GitHub: Actions → Workflow runs

## 🔒 Sicherheit

### Secrets Management
- ✅ Alle API Keys als Azure DevOps Variables (Secret)
- ✅ GitHub Token mit minimalen Berechtigungen
- ✅ Code Signing Zertifikate sicher gespeichert
- ✅ Environment Variables nur zur Build-Zeit eingebettet

### Best Practices
- Regelmäßige Token-Rotation
- Monitoring von Failed Builds
- Dependency Updates
- Vulnerability Scanning

---

## 🆘 Support

- **Dokumentation:** [RASPBERRY_INSTALLATION.md](App/RASPBERRY_INSTALLATION.md)
- **Issues:** [GitHub Issues](https://github.com/mthitservice/MthBdeIotClient/issues)
- **Support:** info@mth-it-service.com

**Happy Deploying! 🚀**
