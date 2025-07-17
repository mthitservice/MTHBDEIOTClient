# Azure DevOps Pipelines für MthBdeIotClient Raspberry Pi

## 📋 Übersicht

Dieses Projekt verwendet zwei spezialisierte Azure DevOps Pipelines für die Raspberry Pi 3+ Distribution:

1. **Build Pipeline** (`azure-pipelines-raspberry.yml`)
2. **Release Pipeline** (`azure-pipelines-release.yml`)

## 🔧 Build Pipeline - Raspberry Pi

### Datei: `azure-pipelines-raspberry.yml`

**Zweck:** Baut die Electron App speziell für Raspberry Pi 3+ (ARMv7l) und erstellt .deb Pakete.

### Trigger:
- Branches: `master`, `release/*`, `develop`
- Tags: `v*`

### Was wird gebaut:
- **Target:** Raspberry Pi 3+ (ARMv7l)
- **Format:** `.deb` Debian Package
- **Befehl:** `npm run package:raspberry-deb`

### Stages:

#### 1. Build Stage
- **Node.js Setup:** Version 22.x
- **Dependency Installation:** npm ci mit dotenv-cli
- **Version Management:** Automatisch aus Git Tags oder Build Number
- **Application Build:** Webpack für Main und Renderer Process
- **Packaging:** Electron-builder für ARMv7l .deb Pakete

#### 2. Release Stage (nur bei Tags)
- **Environment:** RaspberryPi-Production
- **Artifact Download:** Build-Ergebnisse
- **Release Notes:** Automatische Generierung
- **Package Summary:** Übersicht der erstellten Pakete

#### 3. Documentation Stage
- **Next Steps:** Anweisungen für weitere Schritte
- **Testing Guide:** Manuelle Test-Anweisungen

### Artifacts:
- **Name:** `MthBdeIotClient-RaspberryPi`
- **Inhalt:**
  - `.deb` Pakete für ARMv7l
  - Installation Dokumentation
  - Deployment Scripts

## 🚀 Release Pipeline

### Datei: `azure-pipelines-release.yml`

**Zweck:** Erstellt Release-Pakete und bereitet GitHub Releases vor.

### Trigger:
- **Manuell** oder über Build Pipeline bei Tags
- **Resource Pipeline:** MthBdeIotClient-RaspberryPi-Build

### Stages:

#### 1. Validate Release
- **Artifact Validation:** Prüfung der .deb Pakete
- **Quality Check:** DEB Package Struktur Validation
- **Version Extraction:** Automatische Versionserkennung

#### 2. Create Internal Release
- **Environment:** RaspberryPi-Production
- **Release Package:** Strukturierte Release-Pakete
- **Documentation:** Automatische Release-Dokumentation
- **Checksums:** SHA256 für alle Pakete

#### 3. Prepare GitHub Release
- **Asset Preparation:** GitHub-ready Assets
- **Manual Instructions:** Detaillierte Anweisungen für GitHub Release
- **Quick Links:** Direkte Links zu GitHub

## 📦 Setup in Azure DevOps

### 1. Build Pipeline einrichten:

1. **Neue Pipeline erstellen:**
   ```
   Azure DevOps > Pipelines > Create Pipeline
   ```

2. **YAML Datei auswählen:**
   ```
   Existing Azure Pipelines YAML file
   Path: /azure-pipelines-raspberry.yml
   ```

3. **Pipeline benennen:**
   ```
   Name: MthBdeIotClient-RaspberryPi-Build
   ```

### 2. Release Pipeline einrichten:

1. **Neue Pipeline erstellen:**
   ```
   Azure DevOps > Pipelines > Create Pipeline
   ```

2. **YAML Datei auswählen:**
   ```
   Existing Azure Pipelines YAML file
   Path: /azure-pipelines-release.yml
   ```

3. **Pipeline benennen:**
   ```
   Name: MthBdeIotClient-RaspberryPi-Release
   ```

### 3. Environment einrichten:

1. **Environment erstellen:**
   ```
   Azure DevOps > Pipelines > Environments
   Name: RaspberryPi-Production
   ```

2. **Approvals hinzufügen (optional):**
   ```
   Settings > Approvals and checks
   Required reviewers: [Ihre Email]
   ```

## 🏷️ Versioning & Releases

### Automatische Versioning:

#### Release Tags (v1.0.0):
```bash
git tag v1.0.0
git push origin v1.0.0
```
- **Version:** 1.0.0 (aus Tag)
- **Trigger:** Beide Pipelines
- **Release:** Automatisch

#### Development Builds:
```bash
git push origin develop
```
- **Version:** 1.0.0-dev.{BuildNumber}+{CommitHash}
- **Trigger:** Nur Build Pipeline
- **Release:** Nein

### Package Naming:
```
mthbdeiotclient_{version}_armhf.deb
```

Beispiel: `mthbdeiotclient_1.0.0_armhf.deb`

## 📥 Artifacts Download

### Build Artifacts:
1. Pipeline Run öffnen
2. "Summary" Tab
3. Artifacts Section: "MthBdeIotClient-RaspberryPi"
4. Download ZIP

### Release Artifacts:
1. Release Pipeline Run öffnen
2. "Summary" Tab
3. Artifacts Section: "GitHub-Release-Assets"
4. Download ZIP

## 🍓 Raspberry Pi Installation

### Direkte Installation:
```bash
# Download des DEB Pakets
wget https://your-url/mthbdeiotclient_1.0.0_armhf.deb

# Installation
sudo dpkg -i mthbdeiotclient_1.0.0_armhf.deb

# Abhängigkeiten reparieren
sudo apt-get install -f
```

### Verification:
```bash
# Prüfe Installation
dpkg -l | grep mthbdeiotclient

# Starte Anwendung
mthbdeiotclient
```

## 🐛 Troubleshooting

### Pipeline Fehler:

#### npm install Fehler:
```yaml
# Lösung: Cache leeren
- script: npm cache clean --force
```

#### electron-builder Fehler:
```yaml
# Lösung: Environment Variables prüfen
env:
  ELECTRON_BUILDER_ALLOW_UNRESOLVED_DEPENDENCIES: true
```

#### dotenv Fehler:
```bash
# Lösung: dotenv-cli installieren
npm install dotenv-cli --save-dev
```

### Raspberry Pi Installation Fehler:

#### Missing Dependencies:
```bash
sudo apt-get update
sudo apt-get install -f
```

#### Permission Issues:
```bash
sudo chmod +x /usr/bin/mthbdeiotclient
```

#### Display Issues:
```bash
export DISPLAY=:0
mthbdeiotclient
```

## 📚 Weitere Dokumentation

- **Raspberry Pi Setup:** `RASPBERRY_INSTALLATION.md`
- **Deployment Guide:** `DEPLOYMENT_GUIDE.md`
- **Quick Setup:** `QUICK_SETUP_GUIDE.md`
- **Original Pipeline:** `azure-pipelines.yml`

## 🔗 Links

- **GitHub Repository:** https://github.com/mthitservice/MTHBDEIOTClient
- **Azure DevOps:** [Ihr Azure DevOps URL]
- **Releases:** https://github.com/mthitservice/MTHBDEIOTClient/releases

## 📞 Support

Bei Fragen oder Problemen:
- **Issues:** https://github.com/mthitservice/MTHBDEIOTClient/issues
- **Email:** info@mth-it-service.com
