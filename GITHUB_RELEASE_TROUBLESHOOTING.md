# GitHub Release Problem Lösung - Azure DevOps Pipeline

## Problem: "validation failed" beim GitHub Release

### 🔧 1. GitHub Service Connection in Azure DevOps prüfen

**Schritte:**
1. Gehe zu Azure DevOps → Projekt → Project Settings
2. Service connections → Suche nach "github-connection"
3. Falls nicht vorhanden oder fehlerhaft → Neu erstellen:

#### GitHub Service Connection erstellen:
1. **New service connection** → **GitHub** → **Grant authorization**
2. **Connection name**: `github-connection`
3. **Repository**: `https://github.com/mthitservice/MTHBDEIOTClient`
4. **Grant access permission to all pipelines**: ✅

### 🔧 2. GitHub Token Berechtigungen prüfen

Dein GitHub Personal Access Token braucht diese Scopes:
- `repo` (Full control of private repositories)
- `write:packages` (Write packages to GitHub Package Registry)
- `read:packages` (Read packages from GitHub Package Registry)

#### Token erneuern:
1. GitHub → Settings → Developer settings → Personal access tokens
2. Generate new token (classic)
3. Scopes auswählen: `repo`, `write:packages`, `read:packages`
4. Token in Azure DevOps Service Connection aktualisieren

### 🔧 3. Alternative: Pipeline ohne automatisches Release

Falls die Service Connection Probleme macht, können wir das Release manuell machen:

```yaml
# In azure-pipelines-raspberry.yml die Deploy Stage durch folgendes ersetzen:
  - stage: Deploy
    displayName: "Prepare Release Assets"
    dependsOn: Build
    condition: and(succeeded(), eq(variables.isRelease, true))
    jobs:
      - job: PrepareReleaseAssets
        displayName: "Prepare Release Assets"
        pool:
          vmImage: "ubuntu-latest"
        
        steps:
          - task: DownloadPipelineArtifact@2
            displayName: "Download Build Artifacts"
            inputs:
              artifact: $(artifactName)
              path: "$(Pipeline.Workspace)/$(artifactName)"

          - script: |
              echo "=== RELEASE ASSETS READY ==="
              echo "Release Version: $(releaseVersion)"
              echo "Tag: $(Build.SourceBranchName)"
              echo ""
              echo "📦 Download-Links für manuelle GitHub Release:"
              echo ""
              find $(Pipeline.Workspace) -name "*.deb" -exec basename {} \;
              echo ""
              echo "🔗 Gehe zu: https://github.com/mthitservice/MTHBDEIOTClient/releases/new"
              echo "Tag: $(Build.SourceBranchName)"
              echo "Title: MthBdeIotClient $(releaseVersion)"
              echo ""
              echo "Lade die .deb Dateien aus den Artifacts hoch!"
            displayName: "Release Instructions"
```

### 🔧 4. Manuelle Lösung (Temporär)

**Option A: Pipeline Assets herunterladen und manuell hochladen**
1. Nach Pipeline-Erfolg → Artifacts herunterladen
2. GitHub → Releases → Create new release
3. Tag: Gleicher Tag wie Pipeline (z.B. `v1.0.87`)
4. Upload der .deb Dateien

**Option B: Git Tag manuell erstellen**
```bash
git tag v1.0.87
git push origin v1.0.87
```

### 🔧 5. Pipeline Debug-Version

Soll ich eine Debug-Version der Pipeline erstellen, die mehr Informationen über den GitHub-Fehler zeigt?
