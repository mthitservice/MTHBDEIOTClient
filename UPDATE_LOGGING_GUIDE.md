# Update-System Logging Guide

## Übersicht

Das MTH BDE IoT Client Update-System verfügt über ein umfassendes Logging-System, das alle Update-Aktivitäten aufzeichnet und sowohl in der Konsole als auch in Log-Dateien ausgibt.

## Log-Ausgaben

### 1. Console-Logging (Entwicklung)

**Farbkodierte Console-Ausgaben:**
- 🔵 **INFO** (Cyan): Allgemeine Informationen
- 🟡 **WARN** (Gelb): Warnungen (z.B. Internet-Fallback)
- 🔴 **ERROR** (Rot): Fehler
- 🟢 **SUCCESS** (Grün): Erfolgreiche Operationen
- ⚫ **DEBUG** (Grau): Debug-Informationen

**Beispiel Console-Output:**
```
[2025-07-19T20:30:45.123Z] INFO  UPDATE_CHECK: Update check started
[2025-07-19T20:30:45.456Z] INFO  INTERNET_CHECK: Checking for updates from GitHub API
[2025-07-19T20:30:48.789Z] WARN  INTERNET_CHECK: Internet update check failed, trying local server fallback
[2025-07-19T20:30:49.012Z] INFO  LOCAL_SERVER: Checking for updates from local server: http://192.168.1.100/update
[2025-07-19T20:30:49.345Z] SUCCESS LOCAL_SERVER: Local server update check successful
```

### 2. Datei-Logging (Produktion)

**Log-Datei Speicherort:**
- **Windows**: `%APPDATA%/MTH-BDE-IOT-Client/logs/update-system.log`
- **macOS**: `~/Library/Application Support/MTH-BDE-IOT-Client/logs/update-system.log`
- **Linux**: `~/.config/MTH-BDE-IOT-Client/logs/update-system.log`

**JSON-Format für maschinelle Auswertung:**
```json
{
  "timestamp": "2025-07-19T20:30:45.123Z",
  "level": "INFO",
  "category": "UPDATE_CHECK",
  "message": "Update check started",
  "data": null,
  "pid": 1234,
  "platform": "linux",
  "arch": "arm64"
}
```

## Log-Kategorien

### UPDATE_CHECK
- Update-Check gestartet/beendet
- Erfolgreiche/fehlgeschlagene Update-Checks
- Versionsinformationen

### INTERNET_CHECK
- GitHub API Anfragen
- Erfolgreiche Internet-Updates
- Timeout-Fehler

### LOCAL_SERVER
- Lokaler Server Anfragen
- Erfolgreiche lokale Updates
- Verbindungsfehler

### AUTO_UPDATE
- Electron AutoUpdater Events
- Download-Progress
- Update-Installation

### DOWNLOAD
- Download-Start/Ende
- Erfolg/Fehler Status

### SYSTEM
- System-Informationen
- Plattform-Details
- Architektur-Info

## Logs anzeigen

### 1. Terminal/Console

**Während der Anwendung:**
Die Logs werden automatisch in der Konsole angezeigt wenn die Anwendung im Terminal gestartet wird:

```bash
# Windows
MTH-BDE-IOT-Client.exe

# Linux
./mthbdeiotclient

# Development
npm start
```

**Live-Monitoring (Linux/macOS):**
```bash
# Alle Update-Logs live verfolgen
tail -f ~/.config/MTH-BDE-IOT-Client/logs/update-system.log | jq '.'

# Nur Errors anzeigen
tail -f ~/.config/MTH-BDE-IOT-Client/logs/update-system.log | jq 'select(.level=="ERROR")'

# Update-Checks verfolgen
tail -f ~/.config/MTH-BDE-IOT-Client/logs/update-system.log | jq 'select(.category=="UPDATE_CHECK")'
```

### 2. Über die Anwendung (IPC)

**Im Renderer-Prozess (React):**
```typescript
// Letzten 50 Log-Einträge abrufen
const logs = await window.electron.ipcRenderer.invoke('get-update-logs', 50);

// Log-Datei Pfad abrufen
const logPath = await window.electron.ipcRenderer.invoke('get-log-path');

// Logs löschen
await window.electron.ipcRenderer.invoke('clear-update-logs');
```

### 3. Direkte Datei-Zugriff

**Windows PowerShell:**
```powershell
# Logs anzeigen
Get-Content "$env:APPDATA\MTH-BDE-IOT-Client\logs\update-system.log" | Select-Object -Last 20

# Logs live verfolgen
Get-Content "$env:APPDATA\MTH-BDE-IOT-Client\logs\update-system.log" -Wait -Tail 10

# Nur Update-Checks
Select-String -Path "$env:APPDATA\MTH-BDE-IOT-Client\logs\update-system.log" -Pattern "UPDATE_CHECK"
```

**Linux/macOS:**
```bash
# Letzten 20 Einträge
tail -20 ~/.config/MTH-BDE-IOT-Client/logs/update-system.log

# Nach Fehlern suchen
grep "ERROR" ~/.config/MTH-BDE-IOT-Client/logs/update-system.log

# Nach erfolgreichen Updates suchen
grep "SUCCESS.*update.*successful" ~/.config/MTH-BDE-IOT-Client/logs/update-system.log
```

## Debug-Szenarien

### 1. Internet-Update Probleme

**Logs überprüfen:**
```bash
grep -A5 -B5 "INTERNET_CHECK.*failed" ~/.config/MTH-BDE-IOT-Client/logs/update-system.log
```

**Häufige Fehler:**
- `timeout: true` - GitHub API Timeout (>5s)
- `code: "ENOTFOUND"` - DNS/Netzwerk Problem
- `code: "ECONNREFUSED"` - Firewall/Proxy Problem

### 2. Lokaler Server Probleme

**Logs überprüfen:**
```bash
grep -A5 -B5 "LOCAL_SERVER.*failed" ~/.config/MTH-BDE-IOT-Client/logs/update-system.log
```

**Häufige Fehler:**
- `code: "ECONNREFUSED"` - Server nicht erreichbar
- `timeout: true` - Server antwortet nicht (>3s)
- `404` - Version.json nicht gefunden

### 3. System-Diagnose

**System-Info aus Logs extrahieren:**
```bash
grep "SYSTEM" ~/.config/MTH-BDE-IOT-Client/logs/update-system.log | tail -1 | jq '.data'
```

**Ausgabe:**
```json
{
  "platform": "linux",
  "arch": "arm64",
  "version": "1.0.107",
  "isArmSystem": true,
  "nodeEnv": "production"
}
```

## Log-Rotation

**Automatische Rotation:**
- Log-Dateien werden automatisch rotiert bei >10MB
- Alte Logs werden mit Timestamp archiviert
- Format: `update-system-1642617600000.log`

**Manuelle Rotation:**
```javascript
// Im Main-Prozess
updateLogger.rotateLogs();
```

## Log-Analyse Tools

### 1. jq (JSON Processing)

**Installation:**
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq

# Windows
choco install jq
```

**Nützliche jq-Filter:**
```bash
# Alle Errors der letzten Stunde
jq 'select(.level=="ERROR" and (.timestamp | fromdateiso8601) > (now - 3600))' < logs/update-system.log

# Update-Erfolgsrate
jq 'select(.category=="UPDATE_CHECK" and .message=="Update check completed") | .data.hasUpdate' < logs/update-system.log | sort | uniq -c

# Durchschnittliche Update-Check Dauer
jq -r 'select(.category=="UPDATE_CHECK") | .timestamp' < logs/update-system.log | head -20
```

### 2. Log-Monitoring Script

**monitor-updates.sh:**
```bash
#!/bin/bash
LOG_FILE="$HOME/.config/MTH-BDE-IOT-Client/logs/update-system.log"

echo "🔍 Monitoring MTH BDE IoT Client Updates..."
echo "📁 Log file: $LOG_FILE"
echo "---"

tail -f "$LOG_FILE" | while IFS= read -r line; do
    level=$(echo "$line" | jq -r '.level // "INFO"')
    category=$(echo "$line" | jq -r '.category // ""')
    message=$(echo "$line" | jq -r '.message // ""')
    timestamp=$(echo "$line" | jq -r '.timestamp // ""' | cut -d'T' -f2 | cut -d'.' -f1)
    
    case $level in
        "ERROR") echo "🔴 [$timestamp] $category: $message" ;;
        "WARN")  echo "🟡 [$timestamp] $category: $message" ;;
        "SUCCESS") echo "🟢 [$timestamp] $category: $message" ;;
        *) echo "ℹ️  [$timestamp] $category: $message" ;;
    esac
done
```

## Troubleshooting

### 1. Keine Logs werden geschrieben

**Mögliche Ursachen:**
- Keine Schreibberechtigung für Log-Verzeichnis
- Festplatte voll
- Logger nicht initialisiert

**Lösung:**
```bash
# Berechtigungen prüfen
ls -la ~/.config/MTH-BDE-IOT-Client/logs/

# Speicherplatz prüfen
df -h ~/.config/MTH-BDE-IOT-Client/

# Log-Verzeichnis neu erstellen
mkdir -p ~/.config/MTH-BDE-IOT-Client/logs
```

### 2. Log-Datei zu groß

**Manuelle Bereinigung:**
```bash
# Backup erstellen
cp ~/.config/MTH-BDE-IOT-Client/logs/update-system.log ~/update-system-backup.log

# Logs löschen
echo "" > ~/.config/MTH-BDE-IOT-Client/logs/update-system.log

# Oder über IPC
# await window.electron.ipcRenderer.invoke('clear-update-logs');
```

### 3. JSON-Parsing Fehler

**Fehlerhafte Log-Einträge finden:**
```bash
# Alle Zeilen die nicht valides JSON sind
grep -v '^{' ~/.config/MTH-BDE-IOT-Client/logs/update-system.log

# Log-Datei validieren
jq empty ~/.config/MTH-BDE-IOT-Client/logs/update-system.log
```

## Beispiel-Ausgaben

### Erfolgreicher Internet-Update

```json
{"timestamp":"2025-07-19T20:30:45.123Z","level":"INFO","category":"UPDATE_CHECK","message":"Update check started","data":null,"pid":1234,"platform":"linux","arch":"arm64"}
{"timestamp":"2025-07-19T20:30:45.456Z","level":"INFO","category":"INTERNET_CHECK","message":"Checking for updates from GitHub API","data":null,"pid":1234,"platform":"linux","arch":"arm64"}
{"timestamp":"2025-07-19T20:30:47.789Z","level":"SUCCESS","category":"INTERNET_CHECK","message":"Internet update check successful","data":{"source":"internet","currentVersion":"1.0.107","latestVersion":"1.0.108","hasUpdate":true},"pid":1234,"platform":"linux","arch":"arm64"}
```

### Fallback auf lokalen Server

```json
{"timestamp":"2025-07-19T20:30:45.123Z","level":"WARN","category":"INTERNET_CHECK","message":"Internet update check failed, trying local server fallback","data":{"error":"fetch failed","timeout":true},"pid":1234,"platform":"linux","arch":"arm64"}
{"timestamp":"2025-07-19T20:30:45.456Z","level":"INFO","category":"LOCAL_SERVER","message":"Checking for updates from local server: http://192.168.1.100/update","data":null,"pid":1234,"platform":"linux","arch":"arm64"}
{"timestamp":"2025-07-19T20:30:46.789Z","level":"SUCCESS","category":"LOCAL_SERVER","message":"Local server update check successful","data":{"source":"local","currentVersion":"1.0.107","latestVersion":"1.0.108","hasUpdate":true},"pid":1234,"platform":"linux","arch":"arm64"}
```

---

**Tipp**: Verwenden Sie `grep`, `jq` und `tail` für effiziente Log-Analyse in Unix-Umgebungen oder PowerShell-Equivalente unter Windows.
