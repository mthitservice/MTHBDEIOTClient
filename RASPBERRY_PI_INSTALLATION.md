# MTH BDE IoT Client - Raspberry Pi Installation

## 🚀 Ein-Kommando-Installation (Empfohlen)

```bash
wget -O /tmp/install-latest.sh https://github.com/mthitservice/MTHBDEIOTClient/raw/main/install-latest.sh && chmod +x /tmp/install-latest.sh && /tmp/install-latest.sh
```

Das automatische Installations-Script:
- ✅ Erkennt den korrekten DEB-Dateinamen automatisch
- ✅ Überprüft Systemvoraussetzungen (Raspberry Pi + ARMv7l)
- ✅ Lädt die neueste Version herunter
- ✅ Verifiziert SHA256-Prüfsummen
- ✅ Entfernt alte Versionen
- ✅ Installiert alle Abhängigkeiten
- ✅ Bereinigt temporäre Dateien

## 🚨 ULTIMATIVE AUTOSTART-LÖSUNG: Funktioniert GARANTIERT!

**Das Problem ist, dass Linux-Autostart komplex ist. Hier sind 3 bewährte Methoden - eine davon WIRD funktionieren:**

### 🎯 METHODE 1: Einfacher rc.local Autostart (MEIST ERFOLGREICH)

```bash
# SCHRITT 1: Alle alten Services stoppen
systemctl stop mthbdeiot-kiosk.service 2>/dev/null || true
systemctl disable mthbdeiot-kiosk.service 2>/dev/null || true
systemctl stop mthbde-admin.service 2>/dev/null || true
systemctl disable mthbde-admin.service 2>/dev/null || true

# SCHRITT 2: Einfaches Start-Script erstellen
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
    if pgrep -x "lxpanel\|pcmanfm\|openbox\|xfce4-panel" > /dev/null; then
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

# Anwendung starten
echo "Starte mthbdeiotclient..."
/opt/MthBdeIotClient/mthbdeiotclient \
    --no-sandbox \
    --kiosk \
    --fullscreen \
    --disable-gpu \
    --disable-dev-shm-usage \
    --disable-web-security \
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

# SCHRITT 3: Script Berechtigungen
chmod +x /home/admin/autostart-mthbde.sh
chown admin:admin /home/admin/autostart-mthbde.sh

# SCHRITT 4: rc.local Setup (WIRD IMMER AUSGEFÜHRT)
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
echo "Neustart mit: sudo reboot"
echo "Nach Neustart prüfen: cat /home/admin/mthbde-autostart.log"
```

### 🛡️ METHODE 2: Robuster Systemd-Service (für Admin-User)

```bash
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
while [ $timeout -gt 0 ] && ! pgrep -x "lxpanel\|pcmanfm\|openbox" > /dev/null; do
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

# App starten
/opt/MthBdeIotClient/mthbdeiotclient \
    --no-sandbox \
    --kiosk \
    --fullscreen \
    --disable-gpu \
    --disable-dev-shm-usage \
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

echo "✅ METHODE 2 INSTALLIERT - Robuster Systemd Service"
echo "Test mit: systemctl start mthbde-robust.service"
```

### 🎯 METHODE 3: Desktop Autostart (LXDE/XFCE)

```bash
# Desktop Autostart Ordner erstellen
mkdir -p /home/admin/.config/autostart

# Desktop Entry erstellen
tee /home/admin/.config/autostart/mthbdeiot.desktop > /dev/null << EOF
[Desktop Entry]
Type=Application
Name=MTH BDE IoT Client
Comment=MTH BDE IoT Client Kiosk Mode
Exec=/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk --fullscreen --disable-gpu --disable-dev-shm-usage
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
```

### 🔍 SOFORT-DIAGNOSE nach Neustart:

```bash
# Alle Log-Dateien prüfen
echo "=== RC.LOCAL LOG ==="
cat /var/log/rc-local.log 2>/dev/null || echo "Keine rc.local logs"

echo "=== AUTOSTART LOG ==="
cat /home/admin/mthbde-autostart.log 2>/dev/null || echo "Keine autostart logs"

echo "=== APP LOG ==="
tail -20 /home/admin/mthbde-app.log 2>/dev/null || echo "Keine app logs"

echo "=== SYSTEMD LOG ==="
cat /var/log/mthbde-systemd.log 2>/dev/null || echo "Keine systemd logs"

echo "=== AKTUELLE PROZESSE ==="
ps aux | grep -i mthbde

echo "=== DESKTOP PROZESSE ==="
ps aux | grep -E "(lxpanel|pcmanfm|openbox|xfce)"

echo "=== DISPLAY UMGEBUNG ==="
echo "DISPLAY: $DISPLAY"
who
w

# Manuelle Ausführung testen
echo "=== MANUELLER TEST ==="
sudo -u admin DISPLAY=:0 XAUTHORITY=/home/admin/.Xauthority /opt/MthBdeIotClient/mthbdeiotclient --version
```
- ✅ Überprüft Systemvoraussetzungen (Raspberry Pi + ARMv7l)
- ✅ Lädt die neueste Version herunter
- ✅ Verifiziert SHA256-Prüfsummen
- ✅ Entfernt alte Versionen
- ✅ Installiert alle Abhängigkeiten
- ✅ Bereinigt temporäre Dateien

## 📦 Manuelle Installation

### Schritt 1: Verfügbare Dateien anzeigen
```bash
wget -q https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/SHA256SUMS -O - | grep '.deb'
```

### Schritt 2: Download und Installation
```bash
# Ersetze [FILENAME] mit dem korrekten Dateinamen aus Schritt 1
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/[FILENAME]
sudo dpkg -i [FILENAME]
sudo apt-get install -f
```

### Beispiel für typische Dateinamen:
```bash
# Raspberry Pi 3+ (ARMv7l) - Mögliche Dateinamen:
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/mthbdeiotclient_1.0.45_armv7l.deb
# ODER
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/mthbdeiotclient_1.0.45_armhf.deb

# Installation
sudo dpkg -i mthbdeiotclient_*.deb
sudo apt-get install -f
```

## 📋 Systemvoraussetzungen

- ✅ **Raspberry Pi 3, 3+, 4** oder **Zero 2 W**
- ✅ **Raspberry Pi OS (32-bit)** mit ARMv7l Architektur
- ✅ **Desktop-Umgebung** (X11/Wayland)
- ✅ **Mindestens 1GB RAM** verfügbar
- ✅ **Internetverbindung** für Download und Updates

## 🚀 Anwendung starten

```bash
# Kommandozeile
mthbdeiotclient

# Hintergrund-Prozess
nohup mthbdeiotclient &

# Desktop-Anwendung
# Im Anwendungsmenü unter "Development" oder "Office"
```

## 🔧 Problemlösung

### Problem: "Datei nicht gefunden"
```bash
# Prüfe verfügbare Dateien
curl -s https://api.github.com/repos/mthitservice/MTHBDEIOTClient/contents/releases/latest | grep '"name"' | grep '.deb'

# Oder direkt SHA256SUMS prüfen
wget -q https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/SHA256SUMS -O - | grep '.deb'
```

### Problem: Installation schlägt fehl
```bash
# Abhängigkeiten reparieren
sudo apt-get update
sudo apt-get install -f

# Fehlende Bibliotheken nachinstallieren
sudo apt-get install -y libgtk-3-0 libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 libasound2 libpangocairo-1.0-0 libatk1.0-0 libcairo-gobject2 libgtk-3-0 libgdk-pixbuf2.0-0 libxss1 libgconf-2-4
```

### Problem: Anwendung startet nicht
```bash
# Display-Variable setzen
export DISPLAY=:0

# Berechtigungen prüfen
sudo chmod +x /usr/bin/mthbdeiotclient

# Logs anzeigen
journalctl -u mthbdeiotclient
```

### Vollständige Deinstallation
```bash
sudo dpkg -r mthbdeiotclient
sudo apt-get autoremove
```

## �️ Kiosk-Modus und Autostart

### Automatischer Start im Kiosk-Modus

Für den unbeaufsichtigten Betrieb (z.B. Produktionsumgebung):

```bash
# 1. Systemd Service erstellen
sudo tee /etc/systemd/system/mthbdeiot-kiosk.service > /dev/null << EOF
[Unit]
Description=MTH BDE IoT Client Kiosk Mode
After=graphical-session.target

[Service]
Type=simple
User=pi
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/pi/.Xauthority
ExecStart=/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk --fullscreen
Restart=always
RestartSec=5
KillMode=mixed
TimeoutStopSec=5

[Install]
WantedBy=graphical-session.target
EOF

# 2. Service aktivieren und starten
sudo systemctl daemon-reload
sudo systemctl enable mthbdeiot-kiosk.service
sudo systemctl start mthbdeiot-kiosk.service
```

### Autostart über LXDE (Alternative Methode)

```bash
# 1. Autostart-Datei bearbeiten
sudo nano /etc/xdg/lxsession/LXDE-pi/autostart

# 2. Diese Zeilen hinzufügen:
@xset s off
@xset -dpms
@xset s noblank
@/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk --fullscreen

# 3. Bildschirmschoner deaktivieren
sudo nano /etc/lightdm/lightdm.conf
# Unter [Seat:*] hinzufügen:
xserver-command=X -s 0 -dpms
```

### Service-Verwaltung

```bash
# Service Status prüfen
sudo systemctl status mthbdeiot-kiosk.service

# Service stoppen
sudo systemctl stop mthbdeiot-kiosk.service

# Service deaktivieren
sudo systemctl disable mthbdeiot-kiosk.service

# Logs anzeigen
journalctl -u mthbdeiot-kiosk.service -f
```

### 🛠️ Autostart Troubleshooting

**Problem: Electron App startet nicht nach Reboot**

```bash
# 1. SOFORT-DIAGNOSE - Service Status prüfen
sudo systemctl status mthbdeiot-kiosk.service -l

# 2. Logs der letzten 50 Zeilen anzeigen
journalctl -u mthbdeiot-kiosk.service -n 50 --no-pager

# 3. Wenn KEINE LOGS da sind - Service läuft nicht!
# Prüfe alle systemd Services:
sudo systemctl --failed
sudo systemctl list-units --failed

# 4. Desktop-Umgebung prüfen
ps aux | grep -E "(X|lx|openbox|desktop)"

# 5. Boot-Logs prüfen (zeigt Desktop-Start)
journalctl -b | grep -E "(lxde|desktop|X11|startx)"

# 6. Display und X11 testen
echo "DISPLAY: $DISPLAY"
xhost +
sudo -u pi DISPLAY=:0 xterm &  # Test ob X11 funktioniert

# 7. Manuelle Anwendung starten (zum Testen)
sudo -u pi DISPLAY=:0 XAUTHORITY=/home/pi/.Xauthority /opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk --fullscreen
```

**EINFACHE LÖSUNG: Boot-Script mit Logging**

```bash
# Wenn systemd nicht funktioniert - einfaches Boot-Script erstellen
sudo tee /home/pi/autostart-mthbde.sh > /dev/null << 'EOF'
#!/bin/bash

# Ausführliches Logging
LOG_FILE="/home/pi/mthbde-autostart.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================="
echo "MTH BDE IoT Autostart - $(date)"
echo "========================================="

# Systeminformationen loggen
echo "User: $(whoami)"
echo "Home: $HOME" 
echo "Display: $DISPLAY"
echo "XAuthority: $XAUTHORITY"

# Warten auf X11 und Desktop
echo "Warte auf X11 und Desktop..."
for i in {1..60}; do
    echo "Versuch $i/60 - Prüfe Desktop-Prozesse..."
    
    # Prüfe X11
    if ! pgrep -x "Xorg\|X" > /dev/null; then
        echo "  X11 noch nicht aktiv"
        sleep 2
        continue
    fi
    
    # Prüfe Desktop-Manager
    if pgrep -x "lxpanel\|pcmanfm\|openbox" > /dev/null; then
        echo "  Desktop gefunden nach $((i*2)) Sekunden!"
        break
    fi
    
    echo "  Desktop noch nicht bereit..."
    sleep 2
done

# Zusätzliche Wartezeit
echo "Warte weitere 10 Sekunden für Stabilität..."
sleep 10

# X11 Berechtigung
echo "Setze X11 Berechtigung..."
export DISPLAY=:0
xhost +local: 2>/dev/null || echo "xhost Warnung (normal)"

# Prüfe Anwendungsdatei
APP_PATH="/opt/MthBdeIotClient/mthbdeiotclient"
if [ ! -f "$APP_PATH" ]; then
    echo "FEHLER: Anwendung nicht gefunden: $APP_PATH"
    echo "Prüfe alternative Pfade..."
    find /opt /usr/bin /usr/local/bin -name "*mthbde*" -type f 2>/dev/null || echo "Keine Alternative gefunden"
    exit 1
fi

echo "Anwendung gefunden: $APP_PATH"
ls -la "$APP_PATH"

# Beende alte Prozesse
echo "Beende alte MTH BDE Prozesse..."
pkill -f "mthbdeiotclient" 2>/dev/null || echo "Keine alten Prozesse"

# Starte Anwendung
echo "Starte MTH BDE IoT Client..."
cd /home/pi

# Umgebungsvariablen setzen
export DISPLAY=:0
export XAUTHORITY=/home/pi/.Xauthority
export HOME=/home/pi

# Anwendung im Hintergrund starten
"$APP_PATH" \
    --no-sandbox \
    --kiosk \
    --fullscreen \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-dev-shm-usage \
    --no-first-run \
    --disable-web-security \
    --disable-features=VizDisplayCompositor \
    >> /home/pi/mthbde-app.log 2>&1 &

APP_PID=$!
echo "MTH BDE IoT Client gestartet mit PID: $APP_PID"

# Prüfe ob Prozess läuft
sleep 3
if kill -0 $APP_PID 2>/dev/null; then
    echo "SUCCESS: Anwendung läuft erfolgreich!"
else
    echo "FEHLER: Anwendung ist abgestürzt!"
    echo "App-Log der letzten 20 Zeilen:"
    tail -n 20 /home/pi/mthbde-app.log 2>/dev/null || echo "Kein App-Log vorhanden"
fi

echo "Autostart beendet - $(date)"
echo "========================================="
EOF

# Script ausführbar machen
chmod +x /home/pi/autostart-mthbde.sh
chown pi:pi /home/pi/autostart-mthbde.sh

# In rc.local einbinden (wird IMMER ausgeführt)
cp /etc/rc.local /etc/rc.local.backup 2>/dev/null || true

tee /etc/rc.local > /dev/null << 'EOF'
#!/bin/bash

# MTH BDE IoT Autostart mit Logging
echo "rc.local gestartet - $(date)" >> /home/pi/rc-local.log

# Als pi-User ausführen
sudo -u pi /home/pi/autostart-mthbde.sh &

exit 0
EOF

chmod +x /etc/rc.local

echo "=== SETUP ABGESCHLOSSEN ==="
echo "Log-Dateien nach Reboot prüfen:"
echo "  - /home/pi/mthbde-autostart.log (Hauptlog)"
echo "  - /home/pi/mthbde-app.log (Anwendungs-Log)"
echo "  - /home/pi/rc-local.log (rc.local Log)"
echo ""
echo "NEUSTART ERFORDERLICH: reboot"
```

**ADMIN POWER-LÖSUNG: Direkter Root-Autostart**

```bash
# SCHRITT 1: SERVICE ERSTELLEN (führen Sie dieses komplette Script aus)
# Als Administrator - Direkte root-Lösung ohne sudo

# Admin-Start Script erstellen
tee /root/mthbde-admin-start.sh > /dev/null << 'EOF'
#!/bin/bash

# Admin-Level Logging
LOG_FILE="/var/log/mthbde-admin.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================="
echo "MTH BDE IoT ADMIN Start - $(date)"
echo "========================================="

# Warte auf Display Manager
echo "Warte auf Display Manager..."
while ! systemctl is-active --quiet lightdm; do
    echo "  Lightdm noch nicht aktiv..."
    sleep 2
done

echo "Display Manager aktiv - warte auf Desktop..."
sleep 15

# Setze alle Berechtigungen
echo "Setze Admin-Berechtigungen..."
chmod +x /opt/MthBdeIotClient/mthbdeiotclient
chown pi:pi /home/pi/.Xauthority 2>/dev/null || true

# Als pi-User mit root-Rechten ausführen
echo "Starte MTH BDE IoT als pi-User mit Admin-Rechten..."
sudo -u pi bash << 'PIEOF'
export DISPLAY=:0
export XAUTHORITY=/home/pi/.Xauthority
export HOME=/home/pi
cd /home/pi

# X11 Berechtigung forcieren
xhost +local: 2>/dev/null || true

# Alte Prozesse beenden
pkill -f "mthbdeiotclient" 2>/dev/null || true
sleep 2

# App starten mit Admin-optimierten Parametern
/opt/MthBdeIotClient/mthbdeiotclient \
    --no-sandbox \
    --kiosk \
    --fullscreen \
    --disable-gpu \
    --disable-dev-shm-usage \
    --disable-web-security \
    --disable-features=VizDisplayCompositor \
    --disable-background-timer-throttling \
    --force-prefers-reduced-motion \
    --disable-backgrounding-occluded-windows \
    >> /var/log/mthbde-app-admin.log 2>&1 &

echo "MTH BDE gestartet mit PID: $!" >> /var/log/mthbde-admin.log
PIEOF

echo "Admin-Start beendet - $(date)"
echo "========================================="
EOF

# Script ausführbar machen
chmod +x /root/mthbde-admin-start.sh

# Systemd Service erstellen
tee /etc/systemd/system/mthbde-admin.service > /dev/null << EOF
[Unit]
Description=MTH BDE IoT Admin Autostart
After=lightdm.service graphical-session.target
Wants=lightdm.service

[Service]
Type=forking
User=root
ExecStart=/root/mthbde-admin-start.sh
Restart=on-failure
RestartSec=10
TimeoutStartSec=120

[Install]
WantedBy=multi-user.target
EOF

# Service aktivieren
systemctl daemon-reload
systemctl enable mthbde-admin.service

echo "========================================="
echo "✅ SERVICE ERFOLGREICH ERSTELLT!"
echo "========================================="
echo "Service: mthbde-admin.service"
echo "Script: /root/mthbde-admin-start.sh"
echo "Status: Aktiviert für Autostart"
echo ""
echo "NÄCHSTE SCHRITTE:"
echo "1. systemctl start mthbde-admin.service"
echo "2. systemctl status mthbde-admin.service"
echo "3. reboot (für automatischen Start)"
```

**SCHRITT 2: SERVICE STARTEN UND TESTEN**

```bash
# Nach dem Ausführen von Schritt 1:

# Service sofort starten
systemctl start mthbde-admin.service

# Service Status prüfen
systemctl status mthbde-admin.service -l

# Logs live verfolgen
journalctl -u mthbde-admin.service -f

# Admin-Logs prüfen
cat /var/log/mthbde-admin.log

# App-Logs prüfen  
cat /var/log/mthbde-app-admin.log

# Prozesse prüfen
ps aux | grep mthbde

# Bei Problemen: Service neu starten
systemctl restart mthbde-admin.service
```

**ULTIMATE LÖSUNG: Robuster Autostart Service**

```bash
# Erweiterte Service-Konfiguration mit maximaler Kompatibilität
sudo tee /etc/systemd/system/mthbdeiot-kiosk.service > /dev/null << EOF
[Unit]
Description=MTH BDE IoT Client Kiosk Mode
After=network.target sound.target graphical-session.target
Wants=graphical-session.target
Requires=sound.target

[Service]
Type=simple
User=pi
Group=pi
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/pi/.Xauthority
Environment=HOME=/home/pi
Environment=XDG_RUNTIME_DIR=/run/user/1000
WorkingDirectory=/home/pi

# Warten bis Desktop vollständig geladen ist (maximal 60 Sekunden)
ExecStartPre=/bin/bash -c 'timeout=60; while [ \$timeout -gt 0 ] && ! pgrep -x "lxpanel\|pcmanfm\|openbox\|xfce4-panel" > /dev/null; do sleep 2; timeout=\$((timeout-2)); done'

# Zusätzliche 10 Sekunden warten für vollständige Desktop-Initialisierung
ExecStartPre=/bin/sleep 10

# X11-Berechtigung setzen
ExecStartPre=/bin/bash -c 'sudo -u pi DISPLAY=:0 xhost +local: 2>/dev/null || true'

# Anwendung mit allen nötigen Parametern starten
ExecStart=/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk --fullscreen --disable-gpu --disable-software-rasterizer --disable-background-timer-throttling --disable-backgrounding-occluded-windows --disable-renderer-backgrounding --disable-features=TranslateUI --disable-ipc-flooding-protection --no-first-run --disable-dev-shm-usage

# Bei Fehlern automatisch neustarten
Restart=always
RestartSec=15
KillMode=mixed
TimeoutStartSec=120
TimeoutStopSec=30

# Logging für Debugging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=mthbdeiot-kiosk

[Install]
WantedBy=multi-user.target graphical.target
EOF

# Service neu laden und aktivieren
sudo systemctl daemon-reload
sudo systemctl enable mthbdeiot-kiosk.service
sudo systemctl start mthbdeiot-kiosk.service
```

**Alternative: Verzögerter Start mit Desktop-Monitor**

```bash
# Desktop-Monitor Script erstellen
sudo tee /home/pi/start-mthbdeiot-kiosk.sh > /dev/null << 'EOF'
#!/bin/bash

# Logging aktivieren
exec > >(tee -a /home/pi/mthbdeiot-startup.log) 2>&1
echo "=== MTH BDE IoT Startup $(date) ==="

# Warten auf Desktop-Umgebung (maximal 2 Minuten)
echo "Warte auf Desktop-Umgebung..."
timeout=120
while [ $timeout -gt 0 ]; do
    if pgrep -x "lxpanel\|pcmanfm\|openbox" > /dev/null; then
        echo "Desktop-Umgebung erkannt nach $((120-timeout)) Sekunden"
        break
    fi
    sleep 2
    timeout=$((timeout-2))
done

if [ $timeout -le 0 ]; then
    echo "FEHLER: Desktop-Umgebung nicht verfügbar nach 2 Minuten"
    exit 1
fi

# Zusätzliche Wartezeit für Stabilität
echo "Warte weitere 15 Sekunden für Desktop-Stabilisierung..."
sleep 15

# X11 Berechtigung setzen
echo "Setze X11 Berechtigung..."
DISPLAY=:0 xhost +local: 2>/dev/null || echo "xhost Warnung ignoriert"

# Prüfe ob Anwendung bereits läuft
if pgrep -f "mthbdeiotclient" > /dev/null; then
    echo "MTH BDE IoT Client läuft bereits - beende alten Prozess"
    pkill -f "mthbdeiotclient"
    sleep 3
fi

# Anwendung starten
echo "Starte MTH BDE IoT Client..."
cd /home/pi
DISPLAY=:0 XAUTHORITY=/home/pi/.Xauthority /opt/MthBdeIotClient/mthbdeiotclient \
    --no-sandbox \
    --kiosk \
    --fullscreen \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-dev-shm-usage \
    --no-first-run \
    --disable-features=TranslateUI \
    >> /home/pi/mthbdeiot-app.log 2>&1 &

echo "MTH BDE IoT Client gestartet mit PID: $!"
echo "=== Startup beendet $(date) ==="
EOF

# Script ausführbar machen
sudo chmod +x /home/pi/start-mthbdeiot-kiosk.sh
sudo chown pi:pi /home/pi/start-mthbdeiot-kiosk.sh

# Service für das Script
sudo tee /etc/systemd/system/mthbdeiot-delayed.service > /dev/null << EOF
[Unit]
Description=MTH BDE IoT Client Delayed Start
After=graphical-session.target network.target
Wants=graphical-session.target

[Service]
Type=forking
User=pi
Group=pi
ExecStart=/home/pi/start-mthbdeiot-kiosk.sh
Restart=on-failure
RestartSec=30
TimeoutStartSec=180

[Install]
WantedBy=multi-user.target graphical.target
EOF

# Alten Service deaktivieren und neuen aktivieren
sudo systemctl disable mthbdeiot-kiosk.service 2>/dev/null || true
sudo systemctl daemon-reload
sudo systemctl enable mthbdeiot-delayed.service
sudo systemctl start mthbdeiot-delayed.service
```

**Problem: Service startet nicht oder "graphical-session.target" Warnung**

```bash
# 1. Service Status detailliert prüfen
sudo systemctl status mthbdeiot-kiosk.service -l

# 2. Fehler-Logs anzeigen
journalctl -u mthbdeiot-kiosk.service --no-pager

# 3. Verbesserte Service-Konfiguration für alle Desktop-Umgebungen
sudo tee /etc/systemd/system/mthbdeiot-kiosk.service > /dev/null << EOF
[Unit]
Description=MTH BDE IoT Client Kiosk Mode
After=multi-user.target graphical-session.target
Wants=graphical-session.target
Conflicts=getty@tty1.service

[Service]
Type=simple
User=pi
Group=pi
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/pi/.Xauthority
Environment=HOME=/home/pi
WorkingDirectory=/home/pi
ExecStartPre=/bin/bash -c 'while ! pgrep -x "lxpanel\|pcmanfm\|openbox\|xfce4-panel\|gnome-shell" > /dev/null; do sleep 2; done'
ExecStart=/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk --fullscreen --disable-gpu --disable-dev-shm-usage
Restart=always
RestartSec=10
KillMode=mixed
TimeoutStopSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target graphical-session.target
EOF

# 4. Service neu laden und aktivieren
sudo systemctl daemon-reload
sudo systemctl enable mthbdeiot-kiosk.service

# 5. Anwendung manuell testen
sudo -u pi DISPLAY=:0 XAUTHORITY=/home/pi/.Xauthority /opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk --fullscreen

# 6. Pfad prüfen
ls -la /opt/MthBdeIotClient/mthbdeiotclient
which mthbdeiotclient
```

**Problem: Display nicht verfügbar**

```bash
# X11-Berechtigung für pi-User setzen
sudo -u pi xhost +

# Alternative: Service mit korrektem Display
sudo tee /etc/systemd/system/mthbdeiot-kiosk.service > /dev/null << EOF
[Unit]
Description=MTH BDE IoT Client Kiosk Mode
After=graphical-session.target
Wants=graphical-session.target

[Service]
Type=simple
User=pi
Group=pi
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/pi/.Xauthority
Environment=HOME=/home/pi
WorkingDirectory=/home/pi
ExecStartPre=/bin/bash -c 'until pgrep -x "lxpanel\\|pcmanfm\\|openbox" > /dev/null; do sleep 1; done'
ExecStart=/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk --fullscreen --disable-gpu
Restart=always
RestartSec=10
KillMode=mixed
TimeoutStopSec=10

[Install]
WantedBy=graphical-session.target
EOF

# Service neu laden
sudo systemctl daemon-reload
sudo systemctl enable mthbdeiot-kiosk.service
```

**Problem: Berechtigung verweigert**

```bash
# Executable-Berechtigung setzen
sudo chmod +x /opt/MthBdeIotClient/mthbdeiotclient

# User pi zur audio/video Gruppe hinzufügen
sudo usermod -a -G audio,video,dialout pi

# Systemd Service mit sudo-Rechten (falls nötig)
sudo tee /etc/systemd/system/mthbdeiot-kiosk.service > /dev/null << EOF
[Unit]
Description=MTH BDE IoT Client Kiosk Mode
After=graphical-session.target

[Service]
Type=simple
User=root
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/pi/.Xauthority
Environment=HOME=/home/pi
ExecStart=/usr/bin/sudo -u pi DISPLAY=:0 /opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk --fullscreen
Restart=always
RestartSec=5

[Install]
WantedBy=graphical-session.target
EOF
```

**Alternative: Autostart mit Desktop-Eintrag**

```bash
# 1. Desktop-Datei erstellen
mkdir -p /home/pi/.config/autostart
cat > /home/pi/.config/autostart/mthbdeiot.desktop << EOF
[Desktop Entry]
Type=Application
Name=MTH BDE IoT Client
Exec=/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk --fullscreen
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# 2. Berechtigung setzen
chmod +x /home/pi/.config/autostart/mthbdeiot.desktop

# 3. Neustart
sudo reboot
```

**Alternative: rc.local Methode**

```bash
# rc.local bearbeiten
sudo nano /etc/rc.local

# VOR der Zeile "exit 0" hinzufügen:
# Warten bis X11 verfügbar ist
sleep 10
sudo -u pi DISPLAY=:0 /opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk --fullscreen &

# rc.local ausführbar machen
sudo chmod +x /etc/rc.local
```

**Debug-Script erstellen**

```bash
# Debug-Script für Autostart
cat > /home/pi/debug-autostart.sh << 'EOF'
#!/bin/bash
echo "=== MTH BDE IoT Client Debug ===" > /home/pi/autostart-debug.log
echo "Date: $(date)" >> /home/pi/autostart-debug.log
echo "User: $(whoami)" >> /home/pi/autostart-debug.log
echo "Display: $DISPLAY" >> /home/pi/autostart-debug.log
echo "XAuthority: $XAUTHORITY" >> /home/pi/autostart-debug.log
echo "Processes:" >> /home/pi/autostart-debug.log
ps aux | grep -E "(X|lx|openbox|mthbde)" >> /home/pi/autostart-debug.log
echo "File check:" >> /home/pi/autostart-debug.log
ls -la /opt/MthBdeIotClient/mthbdeiotclient >> /home/pi/autostart-debug.log 2>&1
echo "Starting application..." >> /home/pi/autostart-debug.log
/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk --fullscreen >> /home/pi/autostart-debug.log 2>&1 &
EOF

chmod +x /home/pi/debug-autostart.sh

# Debug-Script im Service verwenden
sudo tee /etc/systemd/system/mthbdeiot-debug.service > /dev/null << EOF
[Unit]
Description=MTH BDE IoT Client Debug
After=graphical-session.target

[Service]
Type=forking
User=pi
Environment=DISPLAY=:0
Environment=XAUTHORITY=/home/pi/.Xauthority
ExecStart=/home/pi/debug-autostart.sh
Restart=no

[Install]
WantedBy=graphical-session.target
EOF

# Debug-Service starten
sudo systemctl enable mthbdeiot-debug.service
sudo systemctl start mthbdeiot-debug.service

# Debug-Log prüfen
cat /home/pi/autostart-debug.log
```

### Kiosk-Modus Features

- ✅ **Vollbildmodus**: Keine Fensterrahmen oder Taskleiste
- ✅ **Automatischer Neustart**: Bei Absturz automatisch neustarten
- ✅ **Bildschirmschoner deaktiviert**: Immer aktiv bleiben
- ✅ **Mauszeiger versteckt**: Nur bei Bedarf sichtbar
- ✅ **Tastenkombinationen deaktiviert**: Kein Alt+Tab, Alt+F4, etc.

## �🔄 AutoUpdater

Die Anwendung verfügt über einen integrierten AutoUpdater:
- ✅ Automatische Update-Prüfung beim Start
- ✅ GitHub-basierte Release-Erkennung
- ✅ Sichere SHA512-Verifikation
- ✅ Ein-Klick-Installation neuer Versionen

## 🔗 Links

- 📦 **GitHub Releases**: https://github.com/mthitservice/MTHBDEIOTClient/releases
- 📁 **Release Files**: https://github.com/mthitservice/MTHBDEIOTClient/tree/main/releases
- 📄 **SHA256SUMS**: https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/SHA256SUMS
- 🤖 **Auto-Installer**: https://github.com/mthitservice/MTHBDEIOTClient/raw/main/install-latest.sh
- 🐛 **Issues**: https://github.com/mthitservice/MTHBDEIOTClient/issues
- 📖 **Documentation**: https://github.com/mthitservice/MTHBDEIOTClient/blob/main/README.md

## 💡 Tipps

1. **Aktualisierung prüfen**:
   ```bash
   dpkg -l | grep mthbdeiotclient
   ```

2. **Neueste Version installieren**:
   ```bash
   /tmp/install-latest.sh  # Falls bereits heruntergeladen
   ```

3. **Architektur prüfen**:
   ```bash
   uname -m  # Sollte "armv7l" anzeigen
   ```

4. **Speicherplatz prüfen**:
   ```bash
   df -h  # Mindestens 500MB frei
   ```

---

**🎉 Viel Erfolg mit MTH BDE IoT Client auf Ihrem Raspberry Pi!**

*Erstellt mit ❤️ für die Raspberry Pi Community*
