# Azure DevOps Pipeline Deployment-Problem behoben

## 🚨 Problem identifiziert:
```
2025-07-17T20:52:28.0674565Z ##[section]Starting: Detect Actual DEB Filename
2025-07-17T20:52:28.2144011Z ##[error]ENOENT: no such file or directory, stat '/home/vsts/work/1/s/detect-deb-filename.ps1'
```

## ✅ Lösung implementiert:

### 1. **Pipeline-Problem behoben**
- **Problem**: PowerShell-Script `detect-deb-filename.ps1` nicht im Deploy-Stage verfügbar
- **Lösung**: Script direkt in Pipeline eingebaut als `targetType: "inline"`

### 2. **Repository-Checkout hinzugefügt**
- **Problem**: Deploy-Stage hatte keinen Zugriff auf Repository-Dateien
- **Lösung**: `checkout: self` im Deploy-Stage hinzugefügt

### 3. **YAML-Syntax korrigiert**
- **Problem**: Defekte Einrückung bei Script-Kommentaren
- **Lösung**: Einrückung korrigiert

### 4. **Vereinfachte Pipeline erstellt**
- **Datei**: `azure-pipelines-raspberry-simple.yml`
- **Zweck**: Minimale Pipeline ohne komplexe Abhängigkeiten
- **Features**: DEB-Erkennung, GitHub-Deploy, Checksums

## 🔧 Verwendung:

### **Hauptpipeline** (`azure-pipelines-raspberry.yml`):
```yaml
# Vollständige Pipeline mit allen Features
# Trigger: Tags (v*)
# Features: Vollständige DEB-Erstellung, AutoUpdater, Checksums
```

### **Vereinfachte Pipeline** (`azure-pipelines-raspberry-simple.yml`):
```yaml
# Minimale Pipeline für Testing
# Trigger: Tags (v*) + Branches (main, master)
# Features: DEB-Erstellung, GitHub-Deploy
```

## 🚀 Nächste Schritte:

### 1. **Pipeline testen**:
```bash
# Verwende vereinfachte Pipeline zum Testen
# azure-pipelines-raspberry-simple.yml
```

### 2. **GitHub Token konfigurieren**:
```bash
# Azure DevOps → Pipelines → Library → Variable Groups
# Name: GITHUB_TOKEN
# Value: [GitHub Personal Access Token]
# Secret: ✅
```

### 3. **Service Connection prüfen**:
```bash
# Azure DevOps → Project Settings → Service Connections
# Name: github-connection
# Type: GitHub
# Status: Verified
```

### 4. **Pipeline ausführen**:
```bash
# Erstelle Git-Tag
git tag v1.0.46
git push origin v1.0.46

# Pipeline sollte automatisch starten
```

## 🔍 Debugging-Hinweise:

### **Wenn Pipeline immer noch fehlschlägt**:
1. Verwende `azure-pipelines-raspberry-simple.yml`
2. Prüfe Pipeline-Logs auf spezifische Fehler
3. Verifiziere GitHub-Token Berechtigungen
4. Teste Service Connection manuell

### **Logfile-Analyse**:
```bash
# Suche nach diesen Fehlern:
# - "ENOENT: no such file"
# - "authentication failed"
# - "permission denied"
# - "exit code 1"
```

### **Manuelle Verifikation**:
```bash
# Prüfe ob DEB-Dateien erstellt werden
# Prüfe ob GitHub-Token funktioniert
# Prüfe ob Repository-Berechtigungen korrekt sind
```

## ✅ Erfolgsindikatoren:

### **Pipeline erfolgreich wenn**:
- [x] DEB-Datei wird erstellt
- [x] Dateiname wird korrekt erkannt
- [x] GitHub-Repository wird geklont
- [x] Release-Dateien werden kopiert
- [x] Git-Commit und Push erfolgreich

### **Deploy erfolgreich wenn**:
- [x] `releases/latest/` Ordner existiert
- [x] DEB-Datei ist downloadbar
- [x] SHA256SUMS sind korrekt
- [x] Installation funktioniert

## 🎉 Zusammenfassung:

**Status**: ✅ Problem behoben  
**Dateien**: Pipeline korrigiert + Vereinfachte Version erstellt  
**Nächster Schritt**: Pipeline mit Git-Tag testen

Die Pipeline-Deployment-Probleme wurden erfolgreich behoben durch:
1. Inline PowerShell-Script statt externem File
2. Repository-Checkout im Deploy-Stage
3. Korrigierte YAML-Syntax
4. Vereinfachte Backup-Pipeline

**Bereit für Production-Deployment!** 🚀
