#!/bin/bash

# MTH BDE IoT Client - Raspberry Pi Installation Script
# Automatische Installation mit Problemlösungen für SQLite und Display

set -e

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  MTH BDE IoT Client - Raspberry Pi Setup  ${NC}"
echo -e "${BLUE}============================================${NC}"

# Funktion für farbigen Output
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# System-Check
log_info "Prüfe System-Kompatibilität..."

# Raspberry Pi Check
if ! grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null; then
    log_warning "Dieses System scheint kein Raspberry Pi zu sein. Installation wird fortgesetzt..."
fi

# Root-Rechte prüfen
if [[ $EUID -eq 0 ]]; then
    log_error "Bitte nicht als Root ausführen!"
    exit 1
fi

# Architektur ermitteln
ARCH=$(uname -m)
log_info "Erkannte Architektur: $ARCH"

case $ARCH in
    aarch64|arm64)
        DEB_ARCH="arm64"
        log_info "ARM64 Architektur erkannt (Raspberry Pi 4/400/5)"
        ;;
    armv7l)
        DEB_ARCH="armv7l"
        log_info "ARMv7l Architektur erkannt (Raspberry Pi 3/Zero 2 W)"
        ;;
    *)
        log_error "Nicht unterstützte Architektur: $ARCH"
        exit 1
        ;;
esac

# Prüfe Internetverbindung
log_info "Prüfe Internetverbindung..."
if ! ping -c 1 github.com &> /dev/null; then
    log_error "Keine Internetverbindung verfügbar!"
    exit 1
fi
log_success "Internetverbindung verfügbar"

# System aktualisieren
log_info "Aktualisiere System-Pakete..."
sudo apt update -qq
sudo apt upgrade -y -qq

# Abhängigkeiten installieren
log_info "Installiere notwendige Abhängigkeiten..."
sudo apt install -y curl wget gdebi-core xorg openbox lightdm

# X11 Server sicherstellen
log_info "Konfiguriere X11 Server..."
if ! systemctl is-active --quiet lightdm; then
    sudo systemctl enable lightdm
    sudo systemctl start lightdm
    log_success "X11 Display Manager gestartet"
fi

# Neueste Version ermitteln
log_info "Ermittle neueste Version..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/mthitservice/MTHBDEIOTClient/releases/latest | grep tag_name | cut -d '"' -f 4)
if [ -z "$LATEST_VERSION" ]; then
    log_error "Konnte neueste Version nicht ermitteln"
    exit 1
fi
log_success "Neueste Version: $LATEST_VERSION"

# Download URL konstruieren
PACKAGE_NAME="MthBdeIotClient_${LATEST_VERSION#v}_${DEB_ARCH}.deb"
DOWNLOAD_URL="https://github.com/mthitservice/MTHBDEIOTClient/releases/download/${LATEST_VERSION}/${PACKAGE_NAME}"

log_info "Download URL: $DOWNLOAD_URL"

# Temporäres Verzeichnis erstellen
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Paket herunterladen
log_info "Lade Paket herunter: $PACKAGE_NAME"
if ! wget -q --show-progress "$DOWNLOAD_URL"; then
    log_error "Download fehlgeschlagen!"
    exit 1
fi
log_success "Download abgeschlossen"

# Alte Installation entfernen (falls vorhanden)
if dpkg -l | grep -q mthbdeiotclient; then
    log_info "Entferne alte Installation..."
    sudo apt remove -y mthbdeiotclient || true
fi

# Paket installieren
log_info "Installiere MTH BDE IoT Client..."
sudo gdebi -n "$PACKAGE_NAME"

# Abhängigkeiten reparieren
sudo apt install -f -y

log_success "Installation abgeschlossen"

# User Data Directory vorbereiten
log_info "Bereite Benutzer-Verzeichnisse vor..."
mkdir -p ~/.local/share/MthBdeIotClient/database
mkdir -p ~/.config/MthBdeIotClient

# Desktop-Verknüpfung erstellen
log_info "Erstelle Desktop-Verknüpfung..."
cat > ~/Desktop/MTH-BDE-IoT-Client.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=MTH BDE IoT Client
Comment=MTH BDE IoT Management Application
Exec=/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --disable-gpu
Icon=/opt/MthBdeIotClient/resources/app/assets/icon.png
Terminal=false
StartupWMClass=MTH BDE IoT Client
Categories=Utility;Development;
EOF

chmod +x ~/Desktop/MTH-BDE-IoT-Client.desktop

# Applications Menu Eintrag erstellen
sudo mkdir -p /usr/share/applications
sudo cat > /usr/share/applications/mth-bde-iot-client.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=MTH BDE IoT Client
Comment=MTH BDE IoT Management Application
Exec=/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --disable-gpu
Icon=/opt/MthBdeIotClient/resources/app/assets/icon.png
Terminal=false
StartupWMClass=MTH BDE IoT Client
Categories=Utility;Development;
EOF

# Cleanup
cd ~
rm -rf "$TEMP_DIR"

log_success "Installation erfolgreich abgeschlossen!"

echo
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}           Installation abgeschlossen!     ${NC}"
echo -e "${GREEN}============================================${NC}"
echo
echo -e "${BLUE}Starten der Anwendung:${NC}"
echo "1. Desktop-Verknüpfung: Doppelklick auf 'MTH BDE IoT Client'"
echo "2. Terminal: /opt/MthBdeIotClient/mthbdeiotclient --no-sandbox"
echo
echo -e "${BLUE}Wichtige Hinweise:${NC}"
echo "• Datenbank wird in ~/.local/share/MthBdeIotClient/ gespeichert"
echo "• Bei Display-Problemen: export DISPLAY=:0"
echo "• Für Troubleshooting siehe: RASPBERRY_PI_TROUBLESHOOTING.md"
echo
echo -e "${BLUE}Support:${NC} https://github.com/mthitservice/MTHBDEIOTClient/issues"

# Frage nach Neustart
read -p "Jetzt neustarten? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "System wird neu gestartet..."
    sudo reboot
fi

# GitHub Repository
GITHUB_REPO="mthitservice/MTHBDEIOTClient"
TEMP_DIR="/tmp/mthbdeiot-install"

echo "🔍 Neueste Version ermitteln..."
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/${GITHUB_REPO}/releases/latest")
LATEST_VERSION=$(echo "$LATEST_RELEASE" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | grep '"browser_download_url":' | grep 'armhf.deb' | sed -E 's/.*"([^"]+)".*/\1/')

if [[ -z "$DOWNLOAD_URL" ]]; then
    echo "❌ Keine ARM-Version gefunden!"
    exit 1
fi

echo "✅ Neueste Version: $LATEST_VERSION"
echo "📦 Download URL: $DOWNLOAD_URL"
echo ""

# Arbeitsverzeichnis erstellen
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo "⬇️  Lade Version $LATEST_VERSION herunter..."
curl -L "$DOWNLOAD_URL" -o "mthbdeiotclient.deb" --progress-bar

echo "� Validiere heruntergeladene Datei..."
if [[ ! -f "mthbdeiotclient.deb" ]]; then
    echo "❌ Download fehlgeschlagen - Datei nicht gefunden!"
    exit 1
fi

# Dateigröße prüfen
FILE_SIZE=$(stat -c%s "mthbdeiotclient.deb")
if [[ $FILE_SIZE -lt 30000000 ]]; then  # Weniger als 30MB
    echo "⚠️  Warnung: Datei ist ungewöhnlich klein ($FILE_SIZE Bytes)"
fi

echo "📋 Datei-Informationen:"
echo "   Größe: $FILE_SIZE Bytes ($(echo "scale=2; $FILE_SIZE/1024/1024" | bc) MB)"
echo "   Typ: $(file mthbdeiotclient.deb)"

# DEB-Paket validieren
echo "🔍 Validiere DEB-Paket..."
if ! dpkg-deb --info "mthbdeiotclient.deb" >/dev/null 2>&1; then
    echo "❌ Fehler: Heruntergeladene Datei ist kein gültiges DEB-Paket!"
    echo "Datei-Header: $(head -c 100 mthbdeiotclient.deb | xxd -l 50)"
    exit 1
fi

echo "✅ DEB-Paket erfolgreich validiert"

echo "�📦 Installiere Paket..."
sudo dpkg -i "mthbdeiotclient.deb" || true
sudo apt-get install -f -y

echo "🔧 Konfiguriere Autostart..."

# Desktop-Umgebung prüfen
if [[ -z "$DISPLAY" ]] && [[ -z "$WAYLAND_DISPLAY" ]]; then
    echo "⚠️  Keine Desktop-Umgebung erkannt. Konfiguriere für Desktop-Autostart..."
    
    # Systemd Service für Kiosk-Modus erstellen
    sudo tee /etc/systemd/system/mthbdeiot-kiosk.service > /dev/null <<EOF
[Unit]
Description=MthBdeIotClient Kiosk Mode
After=graphical-session.target

[Service]
Type=simple
User=pi
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/pi/.Xauthority
ExecStartPre=/bin/bash -c 'until pgrep -x Xorg; do sleep 1; done'
ExecStart=/usr/bin/mthbdeiotclient --kiosk --disable-features=VizDisplayCompositor
Restart=always
RestartSec=10

[Install]
WantedBy=graphical-session.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable mthbdeiot-kiosk.service
fi

# Bildschirmschoner deaktivieren
echo "🖥️  Konfiguriere Display-Einstellungen..."
mkdir -p /home/pi/.config/autostart

cat > /home/pi/.config/autostart/disable-screensaver.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=sh -c "xset s off; xset -dpms; xset s noblank"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Disable Screensaver
EOF

# Update-Script erstellen
echo "🔄 Erstelle Update-Script..."
sudo tee /usr/local/bin/update-mthbdeiot.sh > /dev/null <<'EOF'
#!/bin/bash
echo "🔄 Updating MthBdeIotClient..."

GITHUB_REPO="mthitservice/MTHBDEIOTClient"
TEMP_DIR="/tmp/mthbdeiot-update"

mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Neueste Version ermitteln
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/${GITHUB_REPO}/releases/latest")
DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | grep '"browser_download_url":' | grep 'armhf.deb' | sed -E 's/.*"([^"]+)".*/\1/')

if [[ -n "$DOWNLOAD_URL" ]]; then
    echo "⬇️  Downloading update..."
    curl -L "$DOWNLOAD_URL" -o "mthbdeiotclient_update.deb" --progress-bar
    
    echo "📦 Installing update..."
    sudo dpkg -i "mthbdeiotclient_update.deb"
    sudo apt-get install -f -y
    
    echo "✅ Update completed!"
    
    # Service neustarten falls aktiv
    if systemctl is-active --quiet mthbdeiot-kiosk.service; then
        sudo systemctl restart mthbdeiot-kiosk.service
    fi
else
    echo "❌ Update failed - no download URL found"
fi

# Cleanup
rm -rf "$TEMP_DIR"
EOF

sudo chmod +x /usr/local/bin/update-mthbdeiot.sh

# Version anzeigen
echo ""
echo "✅ Installation abgeschlossen!"
echo ""
echo "📊 Installierte Version: $LATEST_VERSION"
echo "📁 Installationsort: /opt/MthBdeIotClient"
echo "🔄 Update-Command: sudo /usr/local/bin/update-mthbdeiot.sh"
echo ""

# Netzwerk-Konfiguration anbieten
read -p "🌐 Möchten Sie die Netzwerk-Konfiguration anpassen? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "📡 Netzwerk-Konfiguration:"
    echo "Aktuelle IP: $(hostname -I | awk '{print $1}')"
    read -p "Neue statische IP (z.B. 10.10.0.101): " NEW_IP
    read -p "Gateway (z.B. 10.10.0.1): " GATEWAY
    
    if [[ -n "$NEW_IP" ]] && [[ -n "$GATEWAY" ]]; then
        echo "Konfiguriere statische IP..."
        sudo tee -a /etc/dhcpcd.conf > /dev/null <<EOF

# MthBdeIotClient Static IP Configuration
interface eth0
static ip_address=${NEW_IP}/24
static routers=${GATEWAY}
static domain_name_servers=8.8.8.8 8.8.4.4

interface wlan0
static ip_address=${NEW_IP}/24
static routers=${GATEWAY}
static domain_name_servers=8.8.8.8 8.8.4.4
EOF
        echo "✅ Netzwerk konfiguriert. Neustart erforderlich."
    fi
fi

# Automatisches Update konfigurieren
read -p "🕐 Automatische Updates aktivieren? (Sonntags 2 Uhr) (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "0 2 * * 0 /usr/local/bin/update-mthbdeiot.sh" | sudo tee -a /etc/crontab
    echo "✅ Automatische Updates aktiviert."
fi

echo ""
echo "🚀 Nächste Schritte:"
echo "1. Raspberry Pi neustarten: sudo reboot"
echo "2. Anwendung startet automatisch im Kiosk-Modus"
echo "3. Updates: sudo /usr/local/bin/update-mthbdeiot.sh"
echo ""
echo "📖 Weitere Informationen: https://github.com/${GITHUB_REPO}"
echo ""

# Cleanup
rm -rf "$TEMP_DIR"

echo "Installation abgeschlossen! 🎉"
