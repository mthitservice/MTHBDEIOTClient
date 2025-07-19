#!/bin/bash

echo "🚀 MTH BDE AUTOSTART FIX für ADMIN-USER"
echo "======================================"

# Alle alten Services stoppen
echo "Stoppe alte Services..."
systemctl stop mthbdeiot-kiosk.service 2>/dev/null || true
systemctl disable mthbdeiot-kiosk.service 2>/dev/null || true
systemctl stop mthbde-admin.service 2>/dev/null || true
systemctl disable mthbde-admin.service 2>/dev/null || true

# METHODE 1: rc.local Autostart (MEIST ERFOLGREICH)
echo "📦 Installiere METHODE 1: rc.local Autostart..."

# Einfaches Start-Script erstellen
tee /home/admin/autostart-mthbde.sh > /dev/null << 'EOF'
#!/bin/bash

# Umfassendes Logging
LOG_FILE="/home/admin/mthbde-autostart.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================="
echo "MTH BDE Autostart - $(date)"
echo "========================================="
echo "User: $(whoami)"
echo "Display: $DISPLAY"
echo "Home: $HOME"

# Warte auf Desktop (maximal 60 Sekunden)
echo "Warte auf Desktop-Umgebung..."
for i in {1..30}; do
    if pgrep -f "lxpanel" > /dev/null || pgrep -f "pcmanfm" > /dev/null || pgrep -f "openbox" > /dev/null || pgrep -f "xfce4-panel" > /dev/null; then
        echo "Desktop gefunden nach $((i*2)) Sekunden!"
        break
    fi
    echo "Versuch $i/30..."
    sleep 2
done

# Warte weitere 10 Sekunden für Stabilität
echo "Warte 10 Sekunden für Desktop-Stabilität..."
sleep 10

# X11 Setup
echo "Setze X11 Umgebung..."
export DISPLAY=:0
export XAUTHORITY=/home/admin/.Xauthority
export HOME=/home/admin
cd /home/admin

# X11 Berechtigung
xhost +local: 2>/dev/null || echo "xhost Warnung (normal)"

# Alte Prozesse beenden
echo "Beende alte mthbdeiotclient Prozesse..."
pkill -f "mthbdeiotclient" 2>/dev/null || true
sleep 2

# Mauszeiger verstecken
echo "Verstecke Mauszeiger für Kiosk-Modus..."
unclutter -display :0 -idle 1 -grab &

# Anwendung starten
echo "Starte mthbdeiotclient..."
/opt/MthBdeIotClient/mthbdeiotclient \
    --no-sandbox \
    --kiosk \
    --fullscreen \
    --disable-dev-shm-usage \
    --disable-web-security \
    --disable-features=VizDisplayCompositor,TranslateUI \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-ipc-flooding-protection \
    --no-first-run \
    --no-default-browser-check \
    --disable-default-apps \
    --disable-extensions \
    --disable-plugins \
    --memory-pressure-off \
    --max_old_space_size=512 \
    >> /home/admin/mthbde-app.log 2>&1 &

APP_PID=$!
echo "mthbdeiotclient gestartet mit PID: $APP_PID"

# Kurz warten und prüfen
sleep 3
if kill -0 $APP_PID 2>/dev/null; then
    echo "✅ SUCCESS: Anwendung läuft!"
else
    echo "❌ FEHLER: Anwendung abgestürzt!"
fi

echo "Autostart beendet - $(date)"
echo "========================================="
EOF

# Script Berechtigungen
chmod +x /home/admin/autostart-mthbde.sh
chown admin:admin /home/admin/autostart-mthbde.sh

# rc.local Setup (WIRD IMMER AUSGEFÜHRT)
cp /etc/rc.local /etc/rc.local.backup 2>/dev/null || true

tee /etc/rc.local > /dev/null << 'EOF'
#!/bin/bash

# MTH BDE Autostart Logging
echo "rc.local gestartet - $(date)" >> /var/log/rc-local.log

# Als admin-User ausführen mit 30 Sekunden Verzögerung
(sleep 30; sudo -u admin /home/admin/autostart-mthbde.sh) &

exit 0
EOF

chmod +x /etc/rc.local

echo "✅ METHODE 1 INSTALLIERT - rc.local Autostart"

# METHODE 2: Robuster Systemd-Service
echo "📦 Installiere METHODE 2: Systemd Service..."

# Admin-Autostart Script erstellen
tee /usr/local/bin/mthbde-admin-autostart.sh > /dev/null << 'EOF'
#!/bin/bash

# Logging
exec > /var/log/mthbde-systemd.log 2>&1

echo "=== MTH BDE Systemd Start - $(date) ==="

# Warte auf lightdm/gdm
echo "Warte auf Display Manager..."
timeout=60
while [ $timeout -gt 0 ] && ! systemctl is-active --quiet lightdm gdm3; do
    sleep 1
    timeout=$((timeout-1))
done

# Warte auf Desktop-Prozesse
echo "Warte auf Desktop-Prozesse..."
timeout=60
while [ $timeout -gt 0 ] && ! (pgrep -f "lxpanel" > /dev/null || pgrep -f "pcmanfm" > /dev/null || pgrep -f "openbox" > /dev/null); do
    sleep 1
    timeout=$((timeout-1))
done

echo "Desktop bereit - starte als admin-User..."
sleep 10

# Als admin ausführen
sudo -u admin bash << 'ADMINBLOCK'
export DISPLAY=:0
export XAUTHORITY=/home/admin/.Xauthority
export HOME=/home/admin
cd /home/admin

# Alte Prozesse beenden
pkill -f "mthbdeiotclient" 2>/dev/null || true
sleep 2

# Mauszeiger verstecken
unclutter -display :0 -idle 1 -grab &

# App starten
/opt/MthBdeIotClient/mthbdeiotclient \
    --no-sandbox \
    --kiosk \
    --fullscreen \
    --disable-dev-shm-usage \
    --disable-web-security \
    --disable-features=VizDisplayCompositor,TranslateUI \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-ipc-flooding-protection \
    --no-first-run \
    --no-default-browser-check \
    --disable-default-apps \
    --disable-extensions \
    --disable-plugins \
    --memory-pressure-off \
    --max_old_space_size=512 \
    >> /var/log/mthbde-app-systemd.log 2>&1 &

echo "App gestartet mit PID: $!"
ADMINBLOCK

echo "=== Systemd Start beendet - $(date) ==="
EOF

chmod +x /usr/local/bin/mthbde-admin-autostart.sh

# Systemd Service
tee /etc/systemd/system/mthbde-robust.service > /dev/null << EOF
[Unit]
Description=MTH BDE Admin Robust Autostart
After=graphical-session.target lightdm.service
Wants=graphical-session.target

[Service]
Type=oneshot
RemainAfterExit=yes
User=root
ExecStart=/usr/local/bin/mthbde-admin-autostart.sh
TimeoutStartSec=180

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable mthbde-robust.service

echo "✅ METHODE 2 INSTALLIERT - Systemd Service"

# METHODE 3: Desktop Autostart
echo "📦 Installiere METHODE 3: Desktop Autostart..."

# Desktop Autostart Ordner erstellen
mkdir -p /home/admin/.config/autostart

# Desktop Entry erstellen
tee /home/admin/.config/autostart/mthbdeiot.desktop > /dev/null << EOF
[Desktop Entry]
Type=Application
Name=MTH BDE IoT Client
Comment=MTH BDE IoT Client Kiosk Mode
Exec=/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk --fullscreen --disable-dev-shm-usage --disable-web-security --disable-features=VizDisplayCompositor,TranslateUI --disable-background-timer-throttling --disable-backgrounding-occluded-windows --disable-renderer-backgrounding --disable-ipc-flooding-protection --no-first-run --no-default-browser-check --disable-default-apps --disable-extensions --disable-plugins --memory-pressure-off --max_old_space_size=512
Icon=application-default-icon
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=15
EOF

# Berechtigungen setzen
chown admin:admin /home/admin/.config/autostart/mthbdeiot.desktop
chmod +x /home/admin/.config/autostart/mthbdeiot.desktop

echo "✅ METHODE 3 INSTALLIERT - Desktop Autostart"

echo ""
echo "🎉 ALLE 3 METHODEN INSTALLIERT!"
echo "================================="

# unclutter für Mauszeiger-Verstecken installieren
echo "📦 Installiere unclutter für Mauszeiger-Verstecken..."
apt-get update > /dev/null 2>&1
apt-get install -y unclutter > /dev/null 2>&1 || echo "⚠️  unclutter bereits installiert oder nicht verfügbar"

echo ""
echo "✅ SETUP ABGESCHLOSSEN mit verstecktem Mauszeiger!"
echo "JETZT NEUSTARTEN: sudo reboot"
echo ""
echo "Nach Neustart Diagnose ausführen mit:"
echo "curl -s https://raw.githubusercontent.com/mthitservice/MTHBDEIOTClient/main/diagnose-autostart.sh | bash"
echo ""
echo "Oder manuell prüfen:"
echo "cat /home/admin/mthbde-autostart.log"
echo "cat /var/log/rc-local.log"
echo "ps aux | grep mthbde"
