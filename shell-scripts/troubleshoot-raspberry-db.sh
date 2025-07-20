#!/bin/bash

# Raspberry Pi Database Troubleshooting Script
# Dieses Script hilft bei der Diagnose von Datenbankproblemen auf Raspberry Pi

echo "=== Raspberry Pi Database Troubleshooting ==="
echo

# 1. System-Information
echo "1. System-Information:"
echo "Architektur: $(uname -m)"
echo "Betriebssystem: $(lsb_release -d 2>/dev/null || echo "LSB nicht verfügbar")"
echo "Benutzer: $(whoami)"
echo "Home-Verzeichnis: $HOME"
echo "Freier Speicherplatz:"
df -h | grep -E '(Filesystem|/dev/)'
echo

# 2. Überprüfe mögliche Datenbankpfade
echo "2. Überprüfe Datenbankpfade:"
echo

database_paths=(
    "$HOME/.mthbdeiotclient/database"
    "/var/lib/mthbdeiotclient/database"
    "/tmp/mthbdeiotclient/database"
    "$HOME/mthbdeiotclient-data/database"
)

for db_path in "${database_paths[@]}"; do
    echo "📁 Pfad: $db_path"
    
    if [ -d "$db_path" ]; then
        echo "  ✅ Verzeichnis existiert"
        
        # Überprüfe Berechtigungen
        if [ -w "$db_path" ]; then
            echo "  ✅ Schreibberechtigung vorhanden"
            
            # Test schreiben
            test_file="$db_path/.write-test"
            if echo "test" > "$test_file" 2>/dev/null; then
                rm -f "$test_file"
                echo "  ✅ Schreibtest erfolgreich"
            else
                echo "  ❌ Schreibtest fehlgeschlagen"
            fi
        else
            echo "  ❌ Keine Schreibberechtigung"
        fi
        
        # Suche nach SQLite-Dateien
        sqlite_files=$(find "$db_path" -name "*.sqlite" 2>/dev/null)
        if [ -n "$sqlite_files" ]; then
            echo "  📄 SQLite-Dateien gefunden:"
            while IFS= read -r file; do
                size=$(du -h "$file" | cut -f1)
                echo "    - $(basename "$file") ($size)"
            done <<< "$sqlite_files"
        else
            echo "  ℹ️  Keine SQLite-Dateien gefunden"
        fi
        
        # Zeige Verzeichnis-Berechtigungen
        echo "  📋 Berechtigungen: $(ls -ld "$db_path" | awk '{print $1, $3, $4}')"
        
    else
        echo "  ❌ Verzeichnis existiert nicht"
        
        # Versuche Verzeichnis zu erstellen
        if mkdir -p "$db_path" 2>/dev/null; then
            echo "  ✅ Verzeichnis erfolgreich erstellt"
            chmod 755 "$db_path" 2>/dev/null
        else
            echo "  ❌ Verzeichnis konnte nicht erstellt werden"
            echo "     Grund: $(mkdir -p "$db_path" 2>&1 || echo "Unbekannt")"
        fi
    fi
    echo
done

# 3. Überprüfe Electron-Prozesse
echo "3. Electron-Prozesse:"
electron_processes=$(ps aux | grep -i electron | grep -v grep)
if [ -n "$electron_processes" ]; then
    echo "✅ Electron-Prozesse gefunden:"
    echo "$electron_processes"
else
    echo "ℹ️  Keine Electron-Prozesse gefunden"
fi
echo

# 4. Überprüfe Logs
echo "4. Log-Verzeichnisse:"
log_paths=(
    "$HOME/.config/mthbdeiotclient/logs"
    "$HOME/.local/share/mthbdeiotclient/logs"
    "/tmp/electron-logs"
    "/var/log/mthbdeiotclient"
)

for log_path in "${log_paths[@]}"; do
    if [ -d "$log_path" ]; then
        echo "✅ Log-Verzeichnis gefunden: $log_path"
        
        # Finde neueste Log-Dateien
        recent_logs=$(find "$log_path" -name "*.log" -type f -mtime -1 2>/dev/null | head -3)
        
        if [ -n "$recent_logs" ]; then
            while IFS= read -r log_file; do
                echo "📄 Log-Datei: $(basename "$log_file") ($(date -r "$log_file" '+%d.%m.%Y %H:%M:%S'))"
                
                # Suche nach Datenbankfehlern in den letzten 20 Zeilen
                db_errors=$(tail -20 "$log_file" | grep -i -E "(database|sqlite|permission|denied|error)" 2>/dev/null)
                
                if [ -n "$db_errors" ]; then
                    echo "  🔍 Relevante Log-Einträge:"
                    echo "$db_errors" | sed 's/^/    /'
                fi
            done <<< "$recent_logs"
        fi
    else
        echo "ℹ️  Log-Verzeichnis nicht gefunden: $log_path"
    fi
done
echo

# 5. Systemd Service Status
echo "5. Systemd Service Status:"
if command -v systemctl >/dev/null 2>&1; then
    if systemctl list-unit-files | grep -q mthbdeiotclient; then
        echo "✅ Service gefunden:"
        systemctl status mthbdeiotclient --no-pager 2>/dev/null || echo "Service nicht aktiv"
    else
        echo "ℹ️  Kein systemd Service namens 'mthbdeiotclient' gefunden"
    fi
else
    echo "ℹ️  Systemctl nicht verfügbar"
fi
echo

# 6. Node.js und Electron Information
echo "6. Node.js und Electron Information:"
if command -v node >/dev/null 2>&1; then
    echo "Node.js Version: $(node --version)"
else
    echo "❌ Node.js nicht gefunden"
fi

if command -v electron >/dev/null 2>&1; then
    echo "Electron Version: $(electron --version)"
else
    echo "ℹ️  Electron-Binary nicht im PATH"
fi
echo

# 7. Empfohlene Lösungen
echo "7. Empfohlene Lösungen:"
echo "🔧 Lösungsvorschläge für Raspberry Pi:"
echo "  1. Erstelle manuell Datenbankverzeichnis:"
echo "     mkdir -p ~/.mthbdeiotclient/database"
echo "     chmod 755 ~/.mthbdeiotclient/database"
echo
echo "  2. Setze Umgebungsvariable:"
echo "     export RASPBERRY_PI=true"
echo "     echo 'export RASPBERRY_PI=true' >> ~/.bashrc"
echo
echo "  3. Überprüfe verfügbaren Speicherplatz:"
echo "     df -h"
echo
echo "  4. Überprüfe Dateisystem-Berechtigungen:"
echo "     ls -la ~/.mthbdeiotclient/"
echo
echo "  5. Teste Datenbankverbindung manuell:"
echo "     touch ~/.mthbdeiotclient/database/test.sqlite"
echo "     rm ~/.mthbdeiotclient/database/test.sqlite"
echo
echo "  6. Prüfe auf Read-Only Filesystem:"
echo "     mount | grep ro"
echo

echo "=== Troubleshooting abgeschlossen ==="
