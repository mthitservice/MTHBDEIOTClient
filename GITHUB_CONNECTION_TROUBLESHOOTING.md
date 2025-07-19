# GitHub Connection Troubleshooting Guide

## 🔍 Problem: GitHub Release Task fehlgeschlagen

**Fehlermeldung:** `Version: 20250710.1.0` bei GitHub-Prozess

---

## 🛠️ Lösungsansätze

### 1. GitHub Service Connection prüfen

**In Azure DevOps:**
1. Gehe zu **Project Settings** → **Service connections**
2. Suche nach `github-connection`
3. Prüfe Status und Berechtigungen

**Mögliche Probleme:**
- ❌ Service Connection existiert nicht
- ❌ Token ist abgelaufen
- ❌ Unzureichende Berechtigungen

### 2. Service Connection neu erstellen

**Schritt-für-Schritt:**

1. **Neuen GitHub Token erstellen:**
   ```
   GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
   ```

2. **Token-Berechtigungen:**
   ```
   ✅ repo (Full control of private repositories)
   ✅ admin:repo_hook (Full control of repository hooks)
   ✅ write:packages
   ✅ read:packages
   ```

3. **Service Connection in Azure DevOps:**
   ```
   Project Settings → Service connections → New service connection → GitHub
   Name: github-connection
   Authentication method: Personal Access Token
   ```

### 3. Alternative Service Connection Namen

**Falls `github-connection` nicht funktioniert:**

```yaml
# In azure-pipelines-raspberry.yml ändern:
variables:
  githubConnection: "GitHub"  # Oder anderen Namen verwenden
```

**Häufig verwendete Namen:**
- `GitHub`
- `github`
- `GitHubServiceConnection`
- `gh-connection`

### 4. Repository-Berechtigungen prüfen

**GitHub Repository Settings:**
1. Repository → Settings → Actions → General
2. **Workflow permissions:**
   ```
   ✅ Read and write permissions
   ✅ Allow GitHub Actions to create and approve pull requests
   ```

### 5. Pipeline-Variable überprüfen

**Prüfe Variable in der Pipeline:**
```yaml
variables:
  githubRepository: "mthitservice/MTHBDEIOTClient"  # Korrekt?
  githubConnection: "github-connection"            # Existiert?
```

---

## 🔧 Schnelle Fixes

### Fix 1: Service Connection Name ändern

```bash
# Azure DevOps CLI (falls installiert)
az devops service-endpoint list --organization https://dev.azure.com/mth-it-service --project MTHUABDEDS
```

### Fix 2: Repository Name korrigieren

```yaml
# Falls Repository Name falsch ist:
variables:
  githubRepository: "mthitservice/MTHBDEIOTClient"  # Exakt so wie in GitHub
```

### Fix 3: Manuelle GitHub Release

**Falls Pipeline weiterhin fehlschlägt:**
```bash
# Download der .deb Dateien aus Azure Artifacts
# Manuelle Upload zu GitHub Releases
```

---

## 📋 Diagnose-Checkliste

### GitHub Service Connection
- [ ] Service Connection `github-connection` existiert
- [ ] Token ist gültig (nicht abgelaufen)
- [ ] Token hat korrekte Berechtigungen
- [ ] Repository Name ist korrekt geschrieben

### Azure DevOps Pipeline
- [ ] Variable `githubConnection` korrekt gesetzt
- [ ] Variable `githubRepository` korrekt gesetzt
- [ ] Task `GitHubRelease@1` verwendet richtige Version

### GitHub Repository
- [ ] Repository existiert und ist erreichbar
- [ ] Service Account hat Write-Zugriff
- [ ] Actions sind aktiviert
- [ ] Releases sind erlaubt

---

## 🚀 Lösung implementieren

### Option A: Service Connection reparieren
1. Neuen GitHub Token erstellen
2. Service Connection aktualisieren
3. Pipeline erneut ausführen

### Option B: Neue Service Connection
1. `github-connection-new` erstellen
2. Pipeline-Variable aktualisieren
3. Pipeline testen

### Option C: Alternative Pipeline
1. GitHub Actions verwenden statt Azure DevOps
2. Direkte Integration ohne Service Connection

---

## 🔗 Hilfreiche Links

- **Azure DevOps Service Connections:** https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints
- **GitHub Personal Access Tokens:** https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
- **GitHub Release Task:** https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/utility/github-release

---

## 📧 Support

**Bei weiteren Problemen:**
1. Azure DevOps Build-Log vollständig prüfen
2. Service Connection Status verifizieren  
3. GitHub Token Berechtigungen überprüfen
4. Alternative Deployment-Strategie erwägen
