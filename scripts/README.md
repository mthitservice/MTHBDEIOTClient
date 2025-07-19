# Update System Scripts

Dieses Verzeichnis enthält alle Scripts für das intelligente Update-System des MTH BDE IoT Clients.

## 📁 Verzeichnisstruktur

```
scripts/
├── update-system/           # Update-System Kern-Scripts
│   ├── version.json        # Template für Release-Metadaten
│   └── upload-version-json.ps1  # GitHub Upload Script
├── azure-devops/           # Azure Pipeline Integration
│   └── azure-upload-version-json.ps1  # Pipeline Upload Script
└── testing/                # Test- und Diagnose-Scripts
    └── test-update-system.ps1      # Update-System Tester
```

## 🚀 Verwendung

### Schnell-Zugriff (Root-Verzeichnis)

```powershell
# Update-System testen
.\update-tools.ps1 test

# Version.json zu GitHub Release uploaden
.\update-tools.ps1 upload -Version 1.0.111

# Azure Pipeline Upload (benötigt GitHub Token)
.\update-tools.ps1 azure -Version 1.0.111 -GitHubToken "ghp_xxxx"
```

### Direkte Script-Aufrufe

```powershell
# Test-Script ausführen
.\scripts\testing\test-update-system.ps1

# GitHub Upload (manuell)
.\scripts\update-system\upload-version-json.ps1 -Version 1.0.111

# Azure Pipeline Upload
.\scripts\azure-devops\azure-upload-version-json.ps1 -Version 1.0.111 -GitHubToken $env:GITHUB_TOKEN
```

## 🔧 Azure Pipeline Integration

In `azure-pipelines.yml` hinzufügen:

```yaml
- task: PowerShell@2
  displayName: 'Upload version.json to GitHub Release'
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/master'))
  inputs:
    targetType: 'filePath'
    filePath: 'scripts/azure-devops/azure-upload-version-json.ps1'
    arguments: '-Version $(Build.BuildNumber) -GitHubToken $(GITHUB_TOKEN)'
  env:
    GITHUB_TOKEN: $(GITHUB_TOKEN)
```

## 📋 Konfiguration

### GitHub Token

Erstellen Sie einen Personal Access Token mit `repo`-Berechtigung:

1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token → Repo-Berechtigung wählen
3. Token als Umgebungsvariable setzen:

```powershell
$env:GITHUB_TOKEN = "ghp_xxxxxxxxxxxxxxxxxxxx"
```

### Version.json Template

Die `scripts/update-system/version.json` dient als Template und wird automatisch mit aktuellen Daten gefüllt:

- Version wird aus Parameter übernommen
- Download-URLs werden automatisch generiert
- Build-Informationen werden aus Azure DevOps übernommen
- Changelog wird automatisch erweitert

## 🧪 Testing

```powershell
# Vollständiger Test aller Update-Quellen
.\scripts\testing\test-update-system.ps1
```

Testet:
- ✅ GitHub API Erreichbarkeit
- ✅ Version.json Download
- ✅ Download-URLs Verfügbarkeit
- ✅ Lokaler Server Simulation
- ✅ Script-Pfade und -Verfügbarkeit

## 🎯 Workflow

### 1. Entwicklung
```powershell
# Scripts testen
.\update-tools.ps1 test
```

### 2. Manueller Release
```powershell
# Version.json zu GitHub hinzufügen
.\update-tools.ps1 upload -Version 1.0.111
```

### 3. Automatischer Release (Azure Pipeline)
- Pipeline erstellt Release
- Script wird automatisch aufgerufen
- Version.json wird zu Release hinzugefügt

### 4. Client Update
- Client startet Update-Check
- Lädt version.json von GitHub
- Fallback zu lokaler Server bei Bedarf

## 🔍 Troubleshooting

### Script nicht gefunden
```powershell
# Pfade prüfen
Get-ChildItem scripts -Recurse -Name "*.ps1"
```

### GitHub Upload schlägt fehl
```powershell
# Token prüfen
curl -H "Authorization: Bearer $env:GITHUB_TOKEN" https://api.github.com/user

# Release existiert prüfen
curl https://api.github.com/repos/mthitservice/MTHBDEIOTClient/releases/tags/v1.0.111
```

### Version.json ungültig
```powershell
# Lokale version.json validieren
Get-Content scripts\update-system\version.json | ConvertFrom-Json
```

---

**Status**: ✅ Organisiert und ready-to-use
**Letztes Update**: 2025-07-19
**Wartung**: Scripts sind self-contained und benötigen nur GitHub Token
