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
   Aktuelle Pipelines verwenden: MTHBDEIOTClient
   GitHub Repository sollte existieren: https://github.com/MTHBDEIOTClient
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
  githubRepository: "MTHBDEIOTClient"
  githubConnection: "github-connection"
```

## 🚀 Automatischer GitHub Release Workflow

### Raspberry Pi Pipeline (azure-pipelines-raspberry.yml)

**Trigger:** Git Tag `v*` (z.B. `v1.0.0`)

**Stages:**
1. **Build** - Erstellt .deb Paket für Raspberry Pi
2. **Release** - Erstellt Release-Paket (nur bei Tags)
3. **GitHubDeploy** - Kopiert .deb in GitHub releases/ Ordner (nur bei Tags)
4. **Documentation** - Zeigt nützliche Links und nächste Schritte

**Besonderheit:** Erstellt einen `releases/` Ordner direkt im GitHub Repository mit öffentlich zugänglichen Links.

## 📋 Release-Prozess

### 1. Neuen Release erstellen

```bash
# 1. Release-Skript verwenden (empfohlen)
./release-version.sh
# oder
./release-version.ps1

# Das Skript fragt nach der Version und erstellt automatisch:
# - Tag v1.0.0
# - Commit mit Version Updates
# - Push zu GitHub
```

### 2. Pipeline läuft automatisch

1. **Raspberry Pi Pipeline startet:**
   - Baut .deb Paket für Raspberry Pi ARMv7l
   - Erstellt Release-Artifacts
   - Kopiert .deb in GitHub releases/ Ordner
   - Erstellt öffentliche Download-Links

2. **GitHub releases/ Ordner wird erstellt:**
   - `releases/latest/` - Neueste Version (für direkte Installation)
   - `releases/v1.0.0/` - Spezifische Version (für Archivierung)
   - Automatisch SHA256SUMS und Dokumentation

### 3. Raspberry Pi Installation

**Direkt von GitHub (empfohlen):**
```bash
# Eine Zeile Installation - Latest Release
wget https://raw.githubusercontent.com/MTHBDEIOTClient/MTHBDEIOTClient/master/releases/latest/mthbdeiotclient_1.0.0_armhf.deb && sudo dpkg -i mthbdeiotclient_1.0.0_armhf.deb && sudo apt-get install -f
```

**Schritt-für-Schritt Installation:**
```bash
# 1. Download Latest Release
wget https://raw.githubusercontent.com/MTHBDEIOTClient/MTHBDEIOTClient/master/releases/latest/mthbdeiotclient_1.0.0_armhf.deb

# 2. Installation
sudo dpkg -i mthbdeiotclient_1.0.0_armhf.deb

# 3. Abhängigkeiten installieren
sudo apt-get install -f

# 4. Anwendung starten
mthbdeiotclient
```

## 🐛 Troubleshooting

### Service Connection Fehler

**Fehler:** "Could not authenticate to GitHub"

```text
Lösung:
1. GitHub Token prüfen und erneuern
2. Token-Scopes prüfen (repo, write:packages erforderlich)
3. Service Connection neu erstellen
```

**Fehler:** "Repository not found"

```text
Lösung:
1. Repository-Name prüfen: MTHBDEIOTClient
2. Repository auf GitHub existiert?
3. Token hat Zugriff auf Repository?
```

### Pipeline Fehler

**Fehler:** "Environment 'GitHub-Production' not found"

```text
Lösung:
1. Environment in Azure DevOps erstellen
2. Namen exakt verwenden: GitHub-Production
```

**Fehler:** "GitHubDeploy task failed"

```text
Lösung:
1. Service Connection prüfen
2. GitHub Token erneuern
3. Repository-Permissions prüfen
4. Pipeline-Variablen prüfen
```

### GitHub Deploy Fehler

**Fehler:** "Push rejected - permission denied"

```text
Lösung:
1. Token-Permissions prüfen (repo scope erforderlich)
2. Service Connection erneuern
3. GitHub Repository-Settings prüfen
```

**Fehler:** "releases/ folder not created"

```text
Lösung:
1. Pipeline-Logs prüfen
2. Git-Konfiguration in Pipeline prüfen
3. Manueller Push-Test mit Token
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
- **Deployment Status:** GitHub releases/ Ordner Status

### GitHub Monitoring

- **Release Downloads:** GitHub Raw File Downloads
- **Asset Downloads:** Tracking von .deb Downloads via GitHub
- **Issue Reports:** Feedback zu Releases

## 🎯 Next Steps

1. **Service Connection einrichten** (siehe oben)
2. **Test Release erstellen:** `./release-version.sh` verwenden
3. **Pipeline testen:** Vollständigen Workflow durchlaufen
4. **Dokumentation aktualisieren:** README mit neuen Raw GitHub Links
5. **Monitoring einrichten:** Success/Failure Notifications

## 🔗 Öffentliche Links

Nach erfolgreichem Release sind folgende Links öffentlich verfügbar:

- **Latest DEB:** `https://raw.githubusercontent.com/MTHBDEIOTClient/MTHBDEIOTClient/master/releases/latest/mthbdeiotclient_{version}_armhf.deb`
- **Latest SHA256:** `https://raw.githubusercontent.com/MTHBDEIOTClient/MTHBDEIOTClient/master/releases/latest/SHA256SUMS`
- **Installation Guide:** `https://raw.githubusercontent.com/MTHBDEIOTClient/MTHBDEIOTClient/master/releases/latest/RASPBERRY_INSTALLATION.md`
- **Releases Folder:** `https://github.com/MTHBDEIOTClient/MTHBDEIOTClient/tree/master/releases`
