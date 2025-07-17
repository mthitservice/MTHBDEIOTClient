# AutoUpdater Implementation Guide

## 🔄 Übersicht

Die AutoUpdater-Funktionalität ermöglicht es der Electron-App, automatisch Updates von GitHub zu prüfen, herunterzuladen und zu installieren.

## 🏗️ Architektur

### 1. Main Process (main.ts)
- **AutoUpdater-Konfiguration**: GitHub Provider Setup
- **Event-Handler**: Update-Events verarbeiten
- **IPC-Handler**: Kommunikation mit Renderer Process

### 2. Renderer Process (AutoUpdater.tsx)
- **React-Komponente**: Benutzeroberfläche für Updates
- **IPC-Kommunikation**: Kommunikation mit Main Process
- **Update-Management**: Status-Tracking und Benutzerinteraktion

### 3. Preload Script (preload.ts)
- **API-Bereitstellung**: Sichere IPC-Kommunikation
- **Type-Definitionen**: TypeScript-Unterstützung

## 📁 Dateien

### Core Files
- `App/src/main/main.ts` - AutoUpdater-Konfiguration und Event-Handler
- `App/src/renderer/components/AutoUpdater.tsx` - React-Komponente
- `App/src/renderer/components/AutoUpdater.css` - Styling
- `App/src/main/preload.ts` - IPC-API-Definitionen

### Configuration Files
- `App/package.json` - Publish-Konfiguration
- `azure-pipelines-raspberry.yml` - Build und Deployment

## 🔧 Konfiguration

### Package.json
```json
{
  "build": {
    "publish": {
      "provider": "github",
      "owner": "mthitservice",
      "repo": "MTHBDEIOTClient"
    }
  },
  "scripts": {
    "package:raspberry-updater": "npm run build && electron-builder --linux --armv7l --publish=always"
  }
}
```

### AutoUpdater Main Process Setup
```typescript
// GitHub Provider Configuration
autoUpdater.setFeedURL({
  provider: 'github',
  owner: 'mthitservice',
  repo: 'MTHBDEIOTClient',
  private: false,
  releaseType: 'release'
});

// Event Handlers
autoUpdater.on('update-available', (info) => {
  webContents.send('update-available', info);
});

autoUpdater.on('download-progress', (progressObj) => {
  webContents.send('download-progress', progressObj);
});

autoUpdater.on('update-downloaded', () => {
  webContents.send('update-downloaded');
});
```

## 🚀 Deployment Structure

### GitHub Releases
```
Releases/
├── v1.0.0/
│   ├── releases/                    # Manuelle Downloads
│   │   ├── mthbdeiotclient_1.0.0_armv7l.deb
│   │   └── SHA512SUMS
│   └── update/                      # AutoUpdater Files
│       ├── mthbdeiotclient_1.0.0_armv7l.deb
│       ├── latest.yml               # Update-Metadata
│       └── SHA512SUMS
```

### latest.yml Beispiel
```yaml
version: 1.0.0
files:
  - url: mthbdeiotclient_1.0.0_armv7l.deb
    sha512: [hash]
    size: 12345678
path: mthbdeiotclient_1.0.0_armv7l.deb
sha512: [hash]
releaseDate: '2024-01-01T12:00:00.000Z'
```

## 🔗 Pipeline Integration

### Azure DevOps Pipeline
```yaml
# Build and Package
- script: |
    npm run package:raspberry-updater
  displayName: 'Build and Package with AutoUpdater'

# Deploy to GitHub
- script: |
    # Upload to releases/ folder (manual downloads)
    gh release upload $(Build.SourceBranchName) dist/*.deb --clobber
    
    # Create update/ folder structure for AutoUpdater
    mkdir -p update
    cp dist/*.deb update/
    cp dist/latest.yml update/
    cp dist/SHA512SUMS update/
    
    # Upload update files
    gh release upload $(Build.SourceBranchName) update/* --clobber
```

## 🎯 Verwendung

### 1. Benutzer-Interface
```typescript
// AutoUpdater-Komponente einbinden
import AutoUpdater from './components/AutoUpdater';

function ConfigPage() {
  return (
    <div>
      {/* Andere Komponenten */}
      <AutoUpdater />
    </div>
  );
}
```

### 2. Manuelle Update-Prüfung
```typescript
const checkForUpdates = async () => {
  try {
    await window.electron.autoUpdater.checkForUpdates();
  } catch (error) {
    console.error('Update check failed:', error);
  }
};
```

### 3. Event-Handling
```typescript
// Update verfügbar
window.electron.ipcRenderer.on('update-available', (updateInfo) => {
  console.log('Update available:', updateInfo.version);
});

// Download-Progress
window.electron.ipcRenderer.on('download-progress', (progress) => {
  console.log('Download progress:', progress.percent);
});

// Update bereit
window.electron.ipcRenderer.on('update-downloaded', () => {
  console.log('Update ready to install');
});
```

## 🏗️ Development vs Production

### Development Mode
- Update-Prüfung deaktiviert
- Lokale Entwicklung ohne GitHub-Abhängigkeit
- "Development Mode" Badge in UI

### Production Mode
- Automatische Update-Prüfung beim Start
- GitHub-basierte Update-Verteilung
- Vollständige AutoUpdater-Funktionalität

## 🔍 Testing

### 1. Lokales Testing
```bash
# Development Build
npm run build
npm run start

# Production Build
npm run package:raspberry-updater
```

### 2. GitHub Release Testing
```bash
# Release erstellen
git tag v1.0.0
git push origin v1.0.0

# Pipeline überwachen
# AutoUpdater in App testen
```

## 🛡️ Sicherheit

### 1. Signatur-Überprüfung
- SHA512-Hashes für alle Dateien
- Automatische Signatur-Validierung durch electron-updater

### 2. GitHub-Authentifizierung
- Personal Access Token für Pipeline
- Sichere Release-Verteilung

### 3. Update-Validierung
- Metadata-Überprüfung (latest.yml)
- Automatische Rollback bei Fehlern

## 📊 Monitoring

### Pipeline-Logs
```bash
# Azure DevOps Pipeline Status
echo "##[section]Creating update/ folder structure"
echo "##[section]Uploading AutoUpdater files"
echo "##[section]Update deployment completed"
```

### App-Logs
```typescript
// Main Process Logging
console.log('AutoUpdater initialized');
console.log('Checking for updates...');
console.log('Update available:', updateInfo);

// Renderer Process Logging
console.log('AutoUpdater component mounted');
console.log('Update check triggered');
```

## 🐛 Troubleshooting

### Häufige Probleme

1. **Update-Prüfung schlägt fehl**
   - GitHub-Repository-Zugriff prüfen
   - Internetverbindung überprüfen
   - latest.yml Format validieren

2. **Download-Fehler**
   - Dateigröße und SHA512 überprüfen
   - Netzwerk-Stabilität prüfen
   - GitHub-Rate-Limits beachten

3. **Installation schlägt fehl**
   - Berechtigungen überprüfen
   - Laufende Prozesse beenden
   - Temporäre Dateien löschen

### Debug-Kommandos
```bash
# AutoUpdater-Logs anzeigen
npm run start -- --enable-logging

# Netzwerk-Requests überwachen
npm run start -- --inspect

# Update-Cache löschen
rm -rf ~/.cache/electron-updater/
```

## 🔄 Wartung

### Regelmäßige Aufgaben
1. **Update-Metadata validieren**
2. **SHA512-Hashes überprüfen**
3. **Pipeline-Performance monitoren**
4. **GitHub-Storage überwachen**

### Version-Management
```bash
# Neue Version erstellen
npm version patch
git push origin main --tags

# Release-Notes aktualisieren
# Pipeline-Deployment überwachen
```

## 📈 Zukunft

### Geplante Verbesserungen
1. **Delta-Updates**: Nur Änderungen herunterladen
2. **Update-Scheduling**: Geplante Updates
3. **Rollback-Funktionalität**: Automatisches Rollback bei Fehlern
4. **Update-Channels**: Beta/Stable Channels

### Erweiterte Features
1. **Progressive Updates**: Schrittweise Verteilung
2. **A/B Testing**: Feature-Flags über Updates
3. **Offline-Updates**: Lokale Update-Pakete
4. **Multi-Platform**: Windows/macOS Unterstützung

---

*Diese Implementierung stellt eine vollständige AutoUpdater-Lösung für die MTH BDE IoT Client Electron-App dar.*
