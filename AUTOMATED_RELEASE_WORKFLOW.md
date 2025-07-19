# Automatisierter Release-Workflow

## 🎯 Überblick

Dieser neue Workflow automatisiert den gesamten Release-Prozess:
- **Keine manuellen Git Tags** mehr nötig
- **Kein Quellcode-Push** zu GitHub
- **Automatische Pipeline-Auslösung** bei Code-Änderungen
- **GitHub Releases** nur mit fertigen .deb Paketen

## 🏗️ Branch-Architektur

**Azure DevOps (Quellcode & Build):**
- Branch: `master` 
- Enthält: Vollständiger Quellcode, Entwicklung, Pipeline
- Zweck: Development und automatische Builds

**GitHub (Release Distribution):**
- Branch: `main`
- Enthält: Nur fertige Release-Pakete (.deb Dateien)
- Zweck: Public Release Downloads für Endnutzer

## 🚀 Workflow-Schritte

### 1. Version in package.json aktualisieren
```bash
cd App
npm version patch  # oder minor/major
```

### 2. Automatischen Release auslösen

**Option A: PowerShell (Windows)**
```powershell
.\trigger-auto-release.ps1
```

**Option B: Bash (Linux/Mac)**
```bash
chmod +x trigger-auto-release.sh
./trigger-auto-release.sh
```

**Option C: Manuell**
```bash
git add .
git commit -m "Release preparation"
git push origin master
```

### 3. Pipeline automatisch ausgeführt

Die Azure DevOps Pipeline wird automatisch:

1. **Version Detection**: Liest Version aus `App/package.json`
2. **Git Tag Creation**: Erstellt Tag `v1.0.87` (automatisch)
3. **Multi-Arch Build**: 
   - ARM64 .deb (Raspberry Pi 4/5)
   - ARMv7l .deb (Raspberry Pi 3)
4. **GitHub Release**: Erstellt Release mit .deb Dateien

## 📦 Was GitHub enthält

**✅ GitHub Repository enthält:**
- Fertige .deb Pakete in Releases
- Release Notes mit Installation-Anweisungen
- Download-Links für wget

**❌ GitHub Repository enthält NICHT:**
- Quellcode
- Development-Dateien
- Build-Artefakte

## 🔗 Links

### Azure DevOps Dashboard:
```
https://dev.azure.com/mth-it-service/MTHUABDEDS/_dashboards/index
```

### Build-Übersicht:
```
https://dev.azure.com/mth-it-service/MTHUABDEDS/_build
```

### GitHub Releases:
```
https://github.com/mthitservice/MTHBDEIOTClient/releases
```

## 🎛️ Konfiguration

### Pipeline-Trigger (azure-pipelines-raspberry.yml):
```yaml
trigger:
  branches:
    include:
      - "master"  # Trigger auf master commits (Azure DevOps Quellcode)
  tags:
    exclude:
      - "*"      # Keine Tag-Trigger (werden automatisch erstellt)
```

### Version-Management:
- **Source of Truth**: `App/package.json`
- **Git Tags**: Automatisch erstellt als `v{version}`
- **Release Titel**: `MthBdeIotClient {version}`

## 🔧 Troubleshooting

### Problem: Pipeline läuft nicht an
**Lösung**: Prüfe Azure DevOps Trigger-Konfiguration

### Problem: GitHub Release fehlschlägt
**Lösung**: Prüfe GitHub Service Connection in Azure DevOps

### Problem: Version nicht erkannt
**Lösung**: Prüfe Format in `package.json` (muss semver sein: x.y.z)

## 📋 Checkliste vor Release

- [ ] Version in `App/package.json` aktualisiert
- [ ] Performance-Optimierungen getestet
- [ ] Alle Änderungen committed
- [ ] Azure DevOps Service Connection funktioniert
- [ ] GitHub Connection hat richtige Berechtigung

## ⚡ Quick Commands

### Patch Release (1.0.86 → 1.0.87):
```bash
cd App && npm version patch && cd .. && ./trigger-auto-release.sh
```

### Minor Release (1.0.86 → 1.1.0):
```bash
cd App && npm version minor && cd .. && ./trigger-auto-release.sh
```

### Major Release (1.0.86 → 2.0.0):
```bash
cd App && npm version major && cd .. && ./trigger-auto-release.sh
```

## 🎉 Vorteile des neuen Workflows

1. **Voll automatisiert** - Ein Kommando startet alles
2. **Keine Git-Tag-Verwaltung** - Pipeline übernimmt das
3. **Separation of Concerns** - GitHub nur für Releases
4. **Performance-optimiert** - Alle Optimierungen automatisch dabei
5. **Konsistente Releases** - Immer gleicher Prozess
6. **Einfache Installation** - wget-Links in Release Notes
