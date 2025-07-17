# Azure DevOps Pipeline Konfiguration

## 🚀 Pipeline-Übersicht

Dieses Projekt verwendet zwei spezialisierte Azure DevOps Pipelines:

### 1. **azure-pipelines-raspberry.yml** - Release Pipeline
- **Zweck**: Vollständige Raspberry Pi DEB-Paket-Erstellung und GitHub-Deployment
- **Trigger**: Nur bei Git-Tags (z.B. `v1.0.0`)
- **Ausgabe**: Produktions-DEB-Pakete, GitHub-Releases, AutoUpdater-Support

### 2. **azure-pipelines-test.yml** - Test Pipeline
- **Zweck**: Schnelle Tests bei Branch-Commits
- **Trigger**: Bei jedem Commit auf main/master/develop
- **Ausgabe**: Build-Validierung, Dependency-Tests, Package-Tests

## 🔧 Pipeline-Trigger konfigurieren

### Problem: Pipeline wird nicht ausgelöst

**Häufige Ursachen:**
1. **Falscher Trigger-Syntax** in YAML
2. **Fehlende Branch-Berechtigung** in Azure DevOps
3. **Service Connection** nicht konfiguriert
4. **GitHub Integration** nicht aktiviert

### Lösung 1: Trigger-Syntax prüfen

```yaml
# ✅ KORREKT - Nur Tags
trigger:
  branches:
    exclude:
      - "*"
  tags:
    include:
      - "v*"

# ✅ KORREKT - Branches + Tags
trigger:
  branches:
    include:
      - main
      - master
      - develop
  tags:
    include:
      - "v*"

# ❌ FALSCH - Ungültige Syntax
trigger:
  branches:
    exclude:
      - "*"
  tags:
    - "v*"  # <-- Fehlt 'include:'
```

### Lösung 2: Azure DevOps Service Connection

```bash
# 1. Azure DevOps → Project Settings → Service Connections
# 2. New Service Connection → GitHub
# 3. Authorize mit GitHub Account
# 4. Connection Name: "github-connection"
# 5. Grant access to all pipelines: ✅
```

### Lösung 3: GitHub Personal Access Token

```bash
# 1. GitHub → Settings → Developer Settings → Personal Access Tokens
# 2. Generate new token mit permissions:
#    - repo (full control)
#    - contents:write
#    - actions:write
# 3. Copy token
# 4. Azure DevOps → Pipelines → Variables → New Variable
#    - Name: GITHUB_TOKEN
#    - Value: [YOUR_TOKEN]
#    - Keep this value secret: ✅
```

## 🚀 Pipeline manuell ausführen

### Option 1: Über Azure DevOps UI
```bash
# 1. Azure DevOps → Pipelines → [Your Pipeline]
# 2. Run Pipeline Button
# 3. Select Branch/Tag
# 4. Run
```

### Option 2: Git Tag erstellen
```bash
# Lokales Repository
git tag v1.0.0
git push origin v1.0.0

# Pipeline wird automatisch ausgelöst
```

### Option 3: Branch Push
```bash
# Für Test-Pipeline
git push origin main

# Für Release-Pipeline mit Tag
git checkout main
git pull origin main
git tag v1.0.1
git push origin v1.0.1
```

## 🔍 Pipeline-Debugging

### 1. Test-Pipeline verwenden
```bash
# Verwende azure-pipelines-test.yml für schnelle Tests
# Trigger: Bei jedem Commit
# Dauer: ~5-10 Minuten
# Zweck: Validierung ohne vollständiges Packaging
```

### 2. Pipeline-Logs analysieren
```bash
# Azure DevOps → Pipelines → [Failed Build] → View Logs
# Suche nach:
# - "ERROR" oder "FAILED"
# - "exit code 1"
# - "permission denied"
# - "authentication failed"
```

### 3. Häufige Fehler-Muster

#### Trigger-Probleme:
```yaml
# Symptom: Pipeline startet nicht
# Prüfe: Trigger-Syntax, Branch-Namen, Tag-Format
```

#### Authentifizierung:
```bash
# Symptom: "authentication failed"
# Prüfe: GITHUB_TOKEN Variable, Service Connection
```

#### Build-Fehler:
```bash
# Symptom: "npm install failed"
# Prüfe: package.json, Node.js Version, Dependencies
```

#### Packaging-Fehler:
```bash
# Symptom: "no .deb files found"
# Prüfe: electron-builder config, ARM target, file permissions
```

## 🛠️ Pipeline-Konfiguration anpassen

### Für andere Branches:
```yaml
# azure-pipelines-raspberry.yml
trigger:
  branches:
    include:
      - main
      - release/*
  tags:
    include:
      - "v*"
```

### Für andere Architekturen:
```yaml
# In App/package.json
"build": {
  "linux": {
    "target": [
      {
        "target": "deb",
        "arch": ["x64", "armv7l", "arm64"]
      }
    ]
  }
}
```

### Für verschiedene Node.js Versionen:
```yaml
# azure-pipelines-*.yml
variables:
  nodeVersion: "20.x"  # oder "18.x", "22.x"
```

## 📋 Pipeline-Checklist

### Vor dem ersten Run:
- [ ] GitHub Service Connection konfiguriert
- [ ] GITHUB_TOKEN Variable gesetzt
- [ ] Repository-Berechtigungen korrekt
- [ ] Trigger-Syntax validiert

### Bei Problemen:
- [ ] Test-Pipeline verwenden
- [ ] Pipeline-Logs analysieren
- [ ] Service Connection testen
- [ ] GitHub Token-Berechtigungen prüfen
- [ ] Branch/Tag-Namen validieren

### Nach erfolgreichem Run:
- [ ] Artifacts downloadbar
- [ ] GitHub Release erstellt
- [ ] DEB-Paket funktioniert
- [ ] Installation-Links korrekt

## 🎯 Erweiterte Konfiguration

### Multi-Architecture Build:
```yaml
# Verschiedene Architekturen parallel
strategy:
  matrix:
    armv7l:
      targetArch: "armv7l"
    arm64:
      targetArch: "arm64"
    x64:
      targetArch: "x64"
```

### Conditional Deployment:
```yaml
# Nur bei bestimmten Branches deployen
condition: and(succeeded(), in(variables['Build.SourceBranch'], 'refs/heads/main', 'refs/heads/master'))
```

### Environment-spezifische Builds:
```yaml
# Verschiedene Umgebungen
environments:
  - deployment: Production
    environment: 'raspberry-pi-prod'
  - deployment: Staging
    environment: 'raspberry-pi-staging'
```

---

**🔧 Bei weiteren Problemen:** 
- Überprüfe Azure DevOps Service Status
- Teste GitHub-Integration separat
- Verwende Test-Pipeline für Debugging
- Prüfe Repository-Berechtigungen
