# Version.json Integration in Azure Pipeline

## Übersicht

Diese Anleitung zeigt, wie die `version.json`-Datei automatisch bei jedem Release-Build zu GitHub hinzugefügt wird.

## 🔧 Azure Pipeline Integration

### 1. Pipeline YAML erweitern

Fügen Sie folgenden Task nach dem erfolgreichen Build hinzu:

```yaml
# Nach dem Build-Task, vor dem Publish
- task: PowerShell@2
  displayName: 'Upload version.json to GitHub Release'
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/master'))
  inputs:
    targetType: 'filePath'
    filePath: 'scripts/azure-devops/azure-upload-version-json.ps1'
    arguments: '-Version $(RELEASE_VERSION) -GitHubToken $(GITHUB_TOKEN)'
    workingDirectory: '$(Build.SourcesDirectory)'
  env:
    GITHUB_TOKEN: $(GITHUB_TOKEN)
    BUILD_BUILDID: $(Build.BuildId)
    BUILD_BUILDNUMBER: $(Build.BuildNumber)
    BUILD_SOURCEVERSION: $(Build.SourceVersion)
```

### 2. Pipeline-Variablen konfigurieren

In Azure DevOps → Pipelines → Ihre Pipeline → Variables:

```
GITHUB_TOKEN: <Personal Access Token mit repo-Berechtigung>
RELEASE_VERSION: $(MAJOR).$(MINOR).$(BUILD_NUMBER)
```

### 3. Service Connection (optional)

Alternativ über Service Connection:
1. Project Settings → Service connections
2. New service connection → GitHub
3. Name: `github-mthitservice`
4. In Pipeline verwenden: `$(github-mthitservice.token)`

## 🔄 Manueller Upload

Für sofortige Tests oder manuelle Uploads:

```powershell
# Setzen Sie Ihr GitHub Token
$env:GITHUB_TOKEN = "ghp_xxxxxxxxxxxxxxxxxxxx"

# Upload für aktuelle Version
.\scripts\update-system\upload-version-json.ps1 -Version "1.0.111"

# Upload für spezifische Version
.\scripts\update-system\upload-version-json.ps1 -Version "1.0.112" -GitHubToken "ghp_xxxxxxxxxxxxxxxxxxxx"

# Oder verwenden Sie das Wrapper-Script
.\update-tools.ps1 upload -Version "1.0.111"
```

## 🧪 Testing

### 1. Update-System testen

```powershell
.\scripts\testing\test-update-system.ps1
# Oder mit Wrapper-Script
.\update-tools.ps1 test
```

### 2. Manueller API-Test
```bash
# GitHub Release API
curl https://api.github.com/repos/mthitservice/MTHBDEIOTClient/releases/latest

# Version.json direkt
curl https://github.com/mthitservice/MTHBDEIOTClient/releases/download/v1.0.111/version.json

# Client-Update-Test im Terminal
cd App
npm start
# In der App: Ctrl+Shift+U für Update-Check
```

## 📋 Version.json Struktur

Die `version.json` enthält:

```json
{
  "version": "1.0.111",
  "name": "MTH BDE IoT Client 1.0.111",
  "releaseDate": "2025-07-19T20:57:54Z",
  "platform": {
    "linux": {
      "arm64": {
        "filename": "mthbdeiotclient_1.0.111_arm64.deb",
        "downloadUrl": "https://github.com/.../releases/download/v1.0.111/mthbdeiotclient_1.0.111_arm64.deb"
      },
      "armv7l": {
        "filename": "mthbdeiotclient_1.0.111_armv7l.deb",
        "downloadUrl": "https://github.com/.../releases/download/v1.0.111/mthbdeiotclient_1.0.111_armv7l.deb"
      }
    }
  },
  "features": {
    "autoUpdate": {
      "linux": true
    },
    "intelligentFallback": {
      "linux": true
    }
  }
}
```

## 🔧 Intelligentes Update-System Flow

```
1. Client startet Update-Check
   ↓
2. Versuche GitHub Release API
   ↓
3. Lade version.json vom Release
   ↓ (Falls erfolgreich)
4. Parse Version & Download-URLs
   ↓ (Falls fehlschlägt)
5. Fallback: GitHub API direkt
   ↓ (Falls auch das fehlschlägt)
6. Fallback: Lokaler Server
   ↓
7. Zeige Ergebnis im Client
```

## 🎯 Vorteile

### ✅ Für Entwickler
- Automatische Version-Metadaten
- Zentrale Konfiguration
- Einfache Pipeline-Integration

### ✅ Für Benutzer
- Schnellere Update-Checks
- Detaillierte Release-Informationen
- Platform-spezifische Downloads
- Intelligenter Fallback

### ✅ Für ARM/Linux
- Dedicated DEB-Package URLs
- Architecture-spezifische Informationen
- Lokaler Server Support

## 🚨 Fehlerbehebung

### GitHub Upload schlägt fehl
```powershell
# Token-Berechtigung prüfen
curl -H "Authorization: Bearer $GITHUB_TOKEN" https://api.github.com/user

# Release existiert prüfen
curl https://api.github.com/repos/mthitservice/MTHBDEIOTClient/releases/tags/v1.0.111
```

### Version.json nicht gefunden
```powershell
# Direkte URL testen
curl -I https://github.com/mthitservice/MTHBDEIOTClient/releases/download/v1.0.111/version.json

# Assets im Release prüfen
curl https://api.github.com/repos/mthitservice/MTHBDEIOTClient/releases/233709913/assets
```

### Client Update schlägt fehl
```javascript
// Im Browser DevTools (F12)
window.electron.ipcRenderer.invoke('check-for-updates')
  .then(result => console.log('Update Check:', result))
  .catch(err => console.error('Update Error:', err));
```

## 📝 Pipeline-Integration Beispiel

Komplette Pipeline-Sektion:

```yaml
stages:
- stage: Build
  jobs:
  - job: BuildARM64
    steps:
    # ... Build-Steps ...
    
    - task: PowerShell@2
      displayName: 'Update version.json and Upload to GitHub'
      condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/master'))
      inputs:
        targetType: 'filePath'
        filePath: 'scripts/azure-devops/azure-upload-version-json.ps1'
        arguments: '-Version $(Build.BuildNumber) -GitHubToken $(GITHUB_TOKEN)'
      env:
        GITHUB_TOKEN: $(GITHUB_TOKEN)
```

---

**Status**: ✅ Bereit zur Pipeline-Integration
**Test-Status**: 🧪 Manuelle Tests verfügbar
**Nächste Schritte**: Pipeline konfigurieren, GitHub Token hinzufügen, ersten automatischen Upload testen
