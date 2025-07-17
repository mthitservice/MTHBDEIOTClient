# GitHub Service Connection Setup

## 🔧 GitHub Service Connection einrichten

### 1. GitHub Personal Access Token erstellen

1. **GitHub Settings öffnen:**
   - Gehe zu: https://github.com/settings/tokens
   - Oder: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)

2. **Neuen Token erstellen:**
   ```
   Name: Azure DevOps - MTH BDE IoT Client
   Expiration: 1 year (oder nach Bedarf)
   ```

3. **Erforderliche Scopes auswählen:**
   ```
   ✅ repo (Full control of private repositories)
   ✅ write:packages (Upload packages to GitHub Package Registry)
   ✅ read:org (Read org and team membership)
   ✅ workflow (Update GitHub Action workflows)
   ```

4. **Token generieren und kopieren:**
   - Token SOFORT kopieren und sicher speichern
   - Token wird nur einmal angezeigt!

### 2. Azure DevOps Service Connection einrichten

1. **Azure DevOps Project Settings:**
   - Gehe zu: `https://dev.azure.com/{organization}/{project}/_settings/adminservices`
   - Oder: Project Settings → Service connections

2. **Neue Service Connection erstellen:**
   ```
   Service connection type: GitHub
   ```

3. **GitHub Connection konfigurieren:**
   ```
   Connection name: github-connection
   Server URL: https://github.com
   Authentication method: Personal Access Token
   Personal access token: [Den kopierten Token einfügen]
   ```

4. **Repository Access:**
   ```
   Grant access permission to all pipelines: ✅
   ```

5. **Verbindung testen:**
   - "Verify connection" klicken
   - Bei Erfolg: "Connection verified successfully"

### 3. Repository-Einstellungen prüfen

1. **Repository-Name korrigieren:**
   ```
   Aktuelle Pipelines verwenden: mthitservice/MTHBDEIOTClient
   GitHub Repository sollte existieren: https://github.com/mthitservice/MTHBDEIOTClient
   ```

2. **Falls Repository nicht existiert:**
   - Repository auf GitHub erstellen
   - Oder Repository-Name in Pipelines anpassen

### 4. Environment für GitHub erstellen

1. **Azure DevOps Environments:**
   - Gehe zu: Pipelines → Environments
   - "New environment" klicken

2. **GitHub-Production Environment:**
   ```
   Name: GitHub-Production
   Description: Production environment for GitHub releases
   Resource: None (Virtual environment)
   ```

3. **Approvals einrichten (optional):**
   ```
   Approvals and checks → Required reviewers
   Reviewers: [Ihr Name/Team]
   Instructions: "Review and approve GitHub release"
   ```

### 5. Pipeline-Variablen prüfen

Stelle sicher, dass beide Pipelines die korrekten Variablen haben:

```yaml
variables:
  githubRepository: "mthitservice/MTHBDEIOTClient"
  githubConnection: "github-connection"
```

## 🚀 Automatischer GitHub Release Workflow

### Build Pipeline (azure-pipelines-raspberry.yml)

**Trigger:** Git Tag `v*` (z.B. `v1.0.0`)

**Stages:**
1. **Build** - Erstellt .deb Paket
2. **Release** - Erstellt Release-Paket (nur bei Tags)
3. **GitHubRelease** - Publiziert automatisch auf GitHub (nur bei Tags)

### Release Pipeline (azure-pipelines-release.yml)

**Trigger:** Build Pipeline bei Tags

**Stages:**
1. **ValidateRelease** - Validiert Artifacts
2. **CreateInternalRelease** - Erstellt strukturierte Release-Pakete
3. **PublishGitHubRelease** - Publiziert auf GitHub

## 📋 Release-Prozess

### 1. Neuen Release erstellen

```bash
# 1. Code committen
git add .
git commit -m "Release v1.0.0 - Neue Features und Bugfixes"

# 2. Tag erstellen
git tag v1.0.0

# 3. Tag pushen (triggert Pipeline)
git push origin v1.0.0
```

### 2. Pipeline läuft automatisch

1. **Build Pipeline startet:**
   - Baut .deb Paket
   - Erstellt Release-Artifacts
   - Publiziert automatisch auf GitHub

2. **GitHub Release wird erstellt:**
   - Tag: `v1.0.0`
   - Title: "MthBdeIotClient Raspberry Pi v1.0.0"
   - Assets: .deb Datei, SHA256SUMS, Dokumentation
   - Automatisch als "latest" markiert

### 3. Raspberry Pi Installation

**Direkt von GitHub:**
```bash
# Download latest release
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/latest/download/mthbdeiotclient_1.0.0_armhf.deb

# Installation
sudo dpkg -i mthbdeiotclient_1.0.0_armhf.deb
sudo apt-get install -f
```

**Eine Zeile Installation:**
```bash
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/latest/download/mthbdeiotclient_1.0.0_armhf.deb && sudo dpkg -i mthbdeiotclient_1.0.0_armhf.deb && sudo apt-get install -f
```

## 🐛 Troubleshooting

### Service Connection Fehler

**Fehler:** "Could not authenticate to GitHub"
```
Lösung:
1. GitHub Token prüfen und erneuern
2. Token-Scopes prüfen (repo, write:packages erforderlich)
3. Service Connection neu erstellen
```

**Fehler:** "Repository not found"
```
Lösung:
1. Repository-Name prüfen: mthitservice/MTHBDEIOTClient
2. Repository auf GitHub existiert?
3. Token hat Zugriff auf Repository?
```

### Pipeline Fehler

**Fehler:** "Environment 'GitHub-Production' not found"
```
Lösung:
1. Environment in Azure DevOps erstellen
2. Namen exakt verwenden: GitHub-Production
```

**Fehler:** "GitHubRelease task failed"
```
Lösung:
1. Service Connection prüfen
2. GitHub Token erneuern
3. Repository-Permissions prüfen
4. Pipeline-Variablen prüfen
```

### GitHub Release Fehler

**Fehler:** "Tag already exists"
```
Lösung:
1. Bestehendes Release löschen
2. Tag löschen: git tag -d v1.0.0 && git push origin :refs/tags/v1.0.0
3. Neuen Tag erstellen
```

## 🔒 Security Best Practices

### 1. Token Security
- **Minimale Scopes:** Nur erforderliche Permissions
- **Expiration:** Regelmäßig erneuern (max. 1 Jahr)
- **Rotation:** Bei Verdacht auf Kompromittierung sofort erneuern

### 2. Pipeline Security
- **Environment Approvals:** Für Production Environments
- **Variable Groups:** Für sensible Daten
- **Pipeline Permissions:** Minimale erforderliche Rechte

### 3. Repository Security
- **Branch Protection:** Für master/main Branch
- **Required Reviews:** Für Pull Requests
- **Status Checks:** Pipeline muss erfolgreich sein

## 📊 Monitoring

### Pipeline Monitoring
- **Build Success Rate:** Überwachung in Azure DevOps
- **Release Frequency:** Tracking von Releases
- **Deployment Status:** GitHub Release Status

### GitHub Monitoring
- **Release Downloads:** GitHub Insights
- **Asset Downloads:** Tracking von .deb Downloads
- **Issue Reports:** Feedback zu Releases

## 🎯 Next Steps

1. **Service Connection einrichten** (siehe oben)
2. **Test Release erstellen:** `git tag v0.1.0-test`
3. **Pipeline testen:** Vollständigen Workflow durchlaufen
4. **Dokumentation aktualisieren:** README mit neuen Links
5. **Monitoring einrichten:** Success/Failure Notifications
