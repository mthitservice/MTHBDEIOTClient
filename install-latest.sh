#!/bin/bash

# Auto-Installation Script für MTH BDE IoT Client auf Raspberry Pi
# Erkennt automatisch den korrekten DEB-Dateinamen und installiert die neueste Version

set -e

echo "======================================"
echo "🍓 MTH BDE IoT Client Auto-Installer"
echo "======================================"
echo ""

# Konfiguration
GITHUB_REPO="mthitservice/MTHBDEIOTClient"
RELEASES_URL="https://github.com/${GITHUB_REPO}/blob/main/releases/latest"
TEMP_DIR="/tmp/mthbdeiot-install"

# Überprüfe Systemvoraussetzungen
echo "🔍 Überprüfe Systemvoraussetzungen..."

# Prüfe Architektur
ARCH=$(uname -m)
if [[ "$ARCH" != "armv7l" ]]; then
    echo "❌ Fehler: Diese Version ist nur für ARMv7l (Raspberry Pi 3+) geeignet."
    echo "   Aktuelle Architektur: $ARCH"
    exit 1
fi

# Prüfe OS
if ! command -v dpkg &> /dev/null; then
    echo "❌ Fehler: dpkg nicht gefunden. Debian/Ubuntu-basiertes System erforderlich."
    exit 1
fi

# Prüfe Berechtigungen
if [[ $EUID -eq 0 ]]; then
    echo "❌ Fehler: Führe dieses Script nicht als root aus."
    echo "   Das Script wird sudo verwenden, wenn nötig."
    exit 1
fi

echo "✅ Systemvoraussetzungen erfüllt"
echo ""

# Erstelle temporäres Verzeichnis
echo "📁 Erstelle temporäres Verzeichnis..."
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Lade SHA256SUMS zur Dateinamenerkennung
echo "🔍 Erkenne verfügbare DEB-Dateien..."
if ! wget -q "$RELEASES_URL/SHA256SUMS" -O SHA256SUMS; then
    echo "❌ Fehler: Kann SHA256SUMS nicht herunterladen."
    echo "   URL: $RELEASES_URL/SHA256SUMS"
    echo "   Prüfe Internetverbindung und Repository-Verfügbarkeit."
    exit 1
fi

# Mögliche Dateinamen (in Prioritätsreihenfolge)
POSSIBLE_PATTERNS=(
    "MthBdeIotClient_.*_armv7l\.deb"
    "MthBdeIotClient_.*_armhf\.deb"
    "mthbdeiotclient_.*_armv7l\.deb"
    "mthbdeiotclient_.*_armhf\.deb"
)

DEB_FILENAME=""
for pattern in "${POSSIBLE_PATTERNS[@]}"; do
    if DEB_FILENAME=$(grep -oE "$pattern" SHA256SUMS | head -1); then
        echo "✅ Gefundene DEB-Datei: $DEB_FILENAME"
        break
    fi
done

if [[ -z "$DEB_FILENAME" ]]; then
    echo "❌ Fehler: Keine passende DEB-Datei in SHA256SUMS gefunden!"
    echo "📋 Verfügbare Dateien:"
    cat SHA256SUMS
    exit 1
fi
echo ""
echo "🎯 Ausgewählte DEB-Datei: $DEB_FILENAME"

# Lade DEB-Datei herunter
echo "⬇️ Lade $DEB_FILENAME herunter..."
if ! wget -q "$RELEASES_URL/$DEB_FILENAME" -O "$DEB_FILENAME"; then
    echo "❌ Fehler: Kann DEB-Datei nicht herunterladen."
    echo "   URL: $RELEASES_URL/$DEB_FILENAME"
    exit 1
fi

# Prüfe Dateigröße
FILE_SIZE=$(stat -c%s "$DEB_FILENAME")
if [[ $FILE_SIZE -lt 1000000 ]]; then  # < 1MB
    echo "❌ Fehler: DEB-Datei ist zu klein ($FILE_SIZE bytes)."
    echo "   Möglicherweise ist ein Download-Fehler aufgetreten."
    exit 1
fi

echo "✅ DEB-Datei heruntergeladen ($(numfmt --to=iec $FILE_SIZE))"

# Validiere DEB-Paket vor Installation
echo "🔍 Validiere DEB-Paket..."
if ! dpkg-deb --info "$DEB_FILENAME" >/dev/null 2>&1; then
    echo "❌ Fehler: Heruntergeladene Datei ist kein gültiges DEB-Paket!"
    echo "   Datei-Typ: $(file "$DEB_FILENAME")"
    echo "   Datei-Header: $(head -c 100 "$DEB_FILENAME" | xxd -l 50)"
    exit 1
fi

echo "✅ DEB-Paket erfolgreich validiert"

# Überprüfe Prüfsumme
echo "🔒 Überprüfe Integrität der Datei..."
if sha256sum -c SHA256SUMS 2>/dev/null | grep -q "$DEB_FILENAME: OK"; then
    echo "✅ Prüfsumme korrekt"
else
    echo "❌ Fehler: Prüfsumme stimmt nicht überein."
    echo "   Die Datei könnte beschädigt oder manipuliert sein."
    exit 1
fi

# Entferne alte Version falls vorhanden
echo "🗑️ Entferne eventuelle alte Version..."
if dpkg -l | grep -q "mthbdeiotclient"; then
    echo "  Alte Version gefunden, entferne..."
    sudo dpkg -r mthbdeiotclient 2>/dev/null || true
    echo "  ✅ Alte Version entfernt"
else
    echo "  ℹ️ Keine alte Version gefunden"
fi

# Installiere DEB-Paket
echo "📦 Installiere MTH BDE IoT Client..."
if sudo dpkg -i "$DEB_FILENAME"; then
    echo "✅ DEB-Paket installiert"
else
    echo "⚠️ Installation mit Fehlern, versuche Abhängigkeiten zu reparieren..."
    sudo apt-get update
    sudo apt-get install -f -y
    echo "✅ Abhängigkeiten repariert"
fi

# Überprüfe Installation
echo "🔍 Überprüfe Installation..."
if command -v mthbdeiotclient &> /dev/null; then
    echo "✅ MTH BDE IoT Client erfolgreich installiert"
    
    # Zeige Versionsinformationen
    echo ""
    echo "📋 Installierte Version:"
    dpkg -l | grep mthbdeiotclient || echo "  Version: $(dpkg -s mthbdeiotclient | grep Version | cut -d' ' -f2)"
    
    # Zeige Dateipfade
    echo ""
    echo "📁 Installationspfade:"
    echo "  Executable: $(which mthbdeiotclient)"
    echo "  Desktop File: $(find /usr/share/applications -name "*mthbdeiot*" 2>/dev/null | head -1)"
    
else
    echo "❌ Fehler: MTH BDE IoT Client nicht im PATH gefunden."
    echo "   Prüfe die Installation manuell."
    exit 1
fi

# Aufräumen
echo "🧹 Räume temporäre Dateien auf..."
cd /
rm -rf "$TEMP_DIR"

echo ""
echo "======================================"
echo "🎉 INSTALLATION ABGESCHLOSSEN!"
echo "======================================"
echo ""
echo "🚀 ANWENDUNG STARTEN:"
echo "  Desktop:     Anwendungsmenü > MTH BDE IoT Client"
echo "  Terminal:    mthbdeiotclient"
echo "  Hintergrund: nohup mthbdeiotclient &"
echo ""
echo "🔧 BEI PROBLEMEN:"
echo "  Dependencies: sudo apt-get install -f"
echo "  Neustart:     sudo systemctl restart mthbdeiotclient"
echo "  Logs:         journalctl -u mthbdeiotclient"
echo "  Deinstall:    sudo dpkg -r mthbdeiotclient"
echo ""
echo "📖 WEITERE HILFE:"
echo "  GitHub: https://github.com/$GITHUB_REPO"
echo "  Issues: https://github.com/$GITHUB_REPO/issues"
echo ""
echo "✅ Installation erfolgreich abgeschlossen!"
echo "======================================"
