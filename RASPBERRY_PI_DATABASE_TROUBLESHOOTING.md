# Raspberry Pi Database Troubleshooting Guide

Dieses Dokument hilft bei der Lösung von Datenbankproblemen auf Raspberry Pi Systemen.

## Typische Fehlermeldungen

```
permission denied
EACCES: permission denied, open 'path/to/bde.sqlite'
Cannot create database directory
```

## Automatische Problemdiagnose

### 1. PowerShell Script (Windows/Cross-Platform)
```powershell
# Auf dem Raspberry Pi (wenn PowerShell verfügbar)
./troubleshoot-raspberry-db.ps1
```

### 2. Bash Script (Linux/Raspberry Pi)
```bash
# Script ausführbar machen
chmod +x ./shell-scripts/troubleshoot-raspberry-db.sh

# Script ausführen
./shell-scripts/troubleshoot-raspberry-db.sh
```

## Manuelle Lösungsschritte

### Schritt 1: Datenbankverzeichnis erstellen
```bash
# Erstelle das bevorzugte Datenbankverzeichnis
mkdir -p ~/.mthbdeiotclient/database

# Setze korrekte Berechtigungen
chmod 755 ~/.mthbdeiotclient/database
```

### Schritt 2: Umgebungsvariable setzen
```bash
# Temporär für aktuelle Session
export RASPBERRY_PI=true

# Permanent in .bashrc
echo 'export RASPBERRY_PI=true' >> ~/.bashrc
source ~/.bashrc
```

### Schritt 3: Alternative Datenbankpfade
Die App versucht automatisch folgende Pfade in dieser Reihenfolge:

1. `~/.mthbdeiotclient/database/` (Empfohlen)
2. `/var/lib/mthbdeiotclient/database/` (System-wide)
3. `/tmp/mthbdeiotclient/database/` (Temporär)
4. `~/mthbdeiotclient-data/database/` (Alternative)

### Schritt 4: Systemd Service (optional)
Wenn die App als systemd Service läuft:

```bash
# Service Status prüfen
sudo systemctl status mthbdeiotclient

# Service Logs anzeigen
sudo journalctl -u mthbdeiotclient -f

# Service neu starten
sudo systemctl restart mthbdeiotclient
```

## Häufige Ursachen und Lösungen

### 1. Read-Only Filesystem
**Problem:** SD-Karte ist read-only
```bash
# Überprüfen
mount | grep ro

# Lösung: SD-Karte reparieren oder remounten
sudo mount -o remount,rw /
```

### 2. Speicherplatz voll
**Problem:** Kein freier Speicherplatz
```bash
# Überprüfen
df -h

# Lösung: Logs löschen, Cache leeren
sudo apt-get clean
sudo rm -rf /tmp/*
```

### 3. Falsche Berechtigungen
**Problem:** Benutzer hat keine Schreibrechte
```bash
# Überprüfen
ls -la ~/.mthbdeiotclient/

# Lösung: Besitzer ändern
sudo chown -R $USER:$USER ~/.mthbdeiotclient/
```

### 4. AppImage Probleme
**Problem:** AppImage kann nicht in temporäre Dateien extrahieren
```bash
# Lösung: Sandbox deaktivieren
./MTHBDEIOTClient.AppImage --no-sandbox

# Oder: TMPDIR setzen
export TMPDIR=$HOME/tmp
mkdir -p $HOME/tmp
```

## Erweiterte Diagnose

### Log-Dateien finden
```bash
# Häufige Log-Verzeichnisse
find ~ -name "*.log" -path "*mthbde*" 2>/dev/null
find /tmp -name "*electron*" 2>/dev/null
```

### SQLite Test
```bash
# Test ob SQLite funktioniert
sqlite3 /tmp/test.db "CREATE TABLE test (id INTEGER); DROP TABLE test;"
rm /tmp/test.db
```

### Elektron-Prozesse überwachen
```bash
# Aktive Electron-Prozesse
ps aux | grep -i electron

# Ressourcenverbrauch
top -p $(pgrep -d',' -f electron)
```

## Umgebungsvariablen

Die App erkennt Raspberry Pi automatisch durch:
- `process.arch === 'arm'` oder `process.arch === 'arm64'`
- `process.env.RASPBERRY_PI === 'true'`

Zusätzliche Umgebungsvariablen:
```bash
export RASPBERRY_PI=true           # Aktiviert Raspberry Pi Modus
export DB_NAME=bde.sqlite          # Datenbankname (optional)
export NODE_ENV=production         # Produktionsumgebung
```

## Kontakt und Support

Bei anhaltenden Problemen:
1. Führe das Troubleshooting-Script aus
2. Sammle die Log-Ausgaben
3. Überprüfe die System-Voraussetzungen
4. Erstelle ein GitHub Issue mit den gesammelten Informationen

## Systemvoraussetzungen

- Raspberry Pi 3B+ oder neuer
- Debian 10 (Buster) oder neuer
- Node.js 18.x oder neuer
- Mindestens 1GB freier Speicherplatz
- Schreibzugriff auf das Home-Verzeichnis
