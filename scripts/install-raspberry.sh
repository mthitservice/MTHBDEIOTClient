#!/bin/bash

# MthBdeIotClient Raspberry Pi Installation Script
# Automatische Installation der neuesten Version von GitHub

set -e

echo "🚀 MthBdeIotClient Raspberry Pi Installation"
echo "============================================="

# System prüfen
if [[ ! -f /proc/device-tree/model ]] || ! grep -q "Raspberry Pi" /proc/device-tree/model; then
    echo "❌ Dieses Script ist nur für Raspberry Pi gedacht!"
    exit 1
fi

# Root-Rechte prüfen
if [[ $EUID -eq 0 ]]; then
    echo "⚠️  Bitte nicht als Root ausführen!"
    exit 1
fi

echo "📋 System-Informationen:"
echo "   OS: $(lsb_release -d | cut -f2)"
echo "   Architektur: $(uname -m)"
echo "   Modell: $(cat /proc/device-tree/model | tr -d '\0')"
echo ""

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

echo "📦 Installiere Paket..."
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
