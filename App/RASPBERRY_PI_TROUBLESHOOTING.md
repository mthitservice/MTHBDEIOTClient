# Raspberry Pi Installation & Troubleshooting

## Automatische Installation

```bash
# Ein-Kommando Installation mit allen Abhängigkeiten
curl -sSL https://github.com/mthitservice/MTHBDEIOTClient/raw/master/scripts/install-raspberry.sh | bash
```

## Manuelle Installation

### 1. System vorbereiten

```bash
# System aktualisieren
sudo apt update && sudo apt upgrade -y

# Notwendige Abhängigkeiten installieren
sudo apt install -y curl wget gdebi-core

# X11-Server sicherstellen (für GUI)
sudo apt install -y xorg openbox lightdm
```

### 2. Paket herunterladen und installieren

```bash
# Neueste Version automatisch ermitteln und herunterladen
LATEST_VERSION=$(curl -s https://api.github.com/repos/mthitservice/MTHBDEIOTClient/releases/latest | grep tag_name | cut -d '"' -f 4)

# ARM64 (Raspberry Pi 4, Pi 400, Pi 5)
wget "https://github.com/mthitservice/MTHBDEIOTClient/releases/download/${LATEST_VERSION}/MthBdeIotClient_${LATEST_VERSION#v}_arm64.deb"
sudo gdebi -n "MthBdeIotClient_${LATEST_VERSION#v}_arm64.deb"

# ODER ARMv7l (Raspberry Pi 3, Pi Zero 2 W)
wget "https://github.com/mthitservice/MTHBDEIOTClient/releases/download/${LATEST_VERSION}/MthBdeIotClient_${LATEST_VERSION#v}_armv7l.deb"
sudo gdebi -n "MthBdeIotClient_${LATEST_VERSION#v}_armv7l.deb"
```

### 3. Desktop-Integration

```bash
# Desktop-Verknüpfung erstellen
cat > ~/Desktop/MTH-BDE-IoT-Client.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=MTH BDE IoT Client
Comment=MTH BDE IoT Management Application
Exec=/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox
Icon=/opt/MthBdeIotClient/resources/app.asar.unpacked/assets/icon.png
Terminal=false
StartupWMClass=MTH BDE IoT Client
Categories=Utility;
EOF

chmod +x ~/Desktop/MTH-BDE-IoT-Client.desktop
```

## Häufige Probleme & Lösungen

### Problem 1: "attempt to write a readonly database"

**Ursache**: SQLite-Datenbank ist im App-Bundle eingebettet und read-only
**Lösung**: Wurde bereits in der neuesten Version behoben (Database wird in User Data Directory erstellt)

```bash
# Manuelle Lösung für ältere Versionen:
sudo chmod 755 /opt/MthBdeIotClient/resources/
sudo chmod 666 /opt/MthBdeIotClient/resources/public/database/bde.sqlite

# Oder Datenbank in Home-Verzeichnis verschieben:
mkdir -p ~/.local/share/MthBdeIotClient/database
cp /opt/MthBdeIotClient/resources/public/database/bde.sqlite ~/.local/share/MthBdeIotClient/database/
```

### Problem 2: "Missing X server or $DISPLAY"

**Ursache**: Keine GUI-Umgebung verfügbar
**Lösung**:

```bash
# Option 1: Stelle sicher, dass X11 läuft
sudo systemctl start lightdm
export DISPLAY=:0

# Option 2: Anwendung mit --no-sandbox Flag starten
/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox

# Option 3: Virtual Display für Headless-Betrieb
sudo apt install -y xvfb
xvfb-run -a /opt/MthBdeIotClient/mthbdeiotclient --no-sandbox
```

### Problem 3: "Segmentation fault"

**Ursache**: GPU-Beschleunigung oder Sandbox-Probleme
**Lösung**:

```bash
# Anwendung mit zusätzlichen Flags starten
/opt/MthBdeIotClient/mthbdeiotclient \
  --no-sandbox \
  --disable-gpu \
  --disable-software-rasterizer \
  --disable-dev-shm-usage
```

### Problem 4: Berechtigungsprobleme

```bash
# Benutzer zu gpio/dialout Gruppen hinzufügen (für IoT-Funktionen)
sudo usermod -a -G gpio,dialout,i2c,spi $USER

# Anwendungsverzeichnis-Berechtigungen korrigieren
sudo chown -R $USER:$USER ~/.local/share/MthBdeIotClient/
sudo chmod 755 /opt/MthBdeIotClient/
```

## Raspberry Pi Optimierungen

### GPU Memory Split
```bash
# GPU Memory auf 128MB setzen für bessere Performance
sudo raspi-config
# -> Advanced Options -> Memory Split -> 128
```

### Service für Autostart erstellen

```bash
# Systemd Service erstellen
sudo tee /etc/systemd/system/mth-bde-iot-client.service > /dev/null << EOF
[Unit]
Description=MTH BDE IoT Client
After=graphical-session.target

[Service]
Type=simple
User=$USER
Environment=DISPLAY=:0
ExecStart=/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox
Restart=always
RestartSec=5

[Install]
WantedBy=graphical-session.target
EOF

# Service aktivieren
sudo systemctl enable mth-bde-iot-client.service
sudo systemctl start mth-bde-iot-client.service
```

### Konfiguration für Kiosk-Modus

```bash
# Automatischer Login ohne Desktop
sudo raspi-config
# -> System Options -> Boot / Auto Login -> Console Autologin

# Openbox für minimale GUI
echo "exec /opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --kiosk" > ~/.xinitrc

# Autostart X11 mit Anwendung
echo "startx" >> ~/.bashrc
```

## Performance-Tipps

### 1. Swap reduzieren
```bash
# Swap-Nutzung minimieren
echo 'vm.swappiness=1' | sudo tee -a /etc/sysctl.conf
```

### 2. GPU-Beschleunigung deaktivieren
```bash
# Für bessere Kompatibilität
echo 'gpu_mem=16' | sudo tee -a /boot/config.txt
```

### 3. Unnötige Services deaktivieren
```bash
sudo systemctl disable bluetooth
sudo systemctl disable wifi-country
sudo systemctl disable triggerhappy
```

## Logs und Debugging

### Anwendungs-Logs anzeigen
```bash
# Systemd Service Logs
sudo journalctl -u mth-bde-iot-client.service -f

# Anwendung mit Debug-Output starten
/opt/MthBdeIotClient/mthbdeiotclient --no-sandbox --enable-logging --v=1
```

### Datenbank-Pfad prüfen
```bash
# Prüfe wo die Datenbank erstellt wird
strace -e openat /opt/MthBdeIotClient/mthbdeiotclient --no-sandbox 2>&1 | grep -i sqlite
```

## Deinstallation

```bash
# Paket entfernen
sudo apt remove mthbdeiotclient

# Benutzerdaten entfernen
rm -rf ~/.local/share/MthBdeIotClient/
rm -f ~/Desktop/MTH-BDE-IoT-Client.desktop

# Service entfernen
sudo systemctl stop mth-bde-iot-client.service
sudo systemctl disable mth-bde-iot-client.service
sudo rm /etc/systemd/system/mth-bde-iot-client.service
```

## Support

Bei weiteren Problemen:
1. **GitHub Issues**: https://github.com/mthitservice/MTHBDEIOTClient/issues
2. **System-Info sammeln**:
```bash
# System-Informationen für Support-Anfragen
echo "=== SYSTEM INFO ===" > ~/mth-debug.log
uname -a >> ~/mth-debug.log
cat /proc/cpuinfo | grep -E "(model|Hardware|Revision)" >> ~/mth-debug.log
free -h >> ~/mth-debug.log
df -h >> ~/mth-debug.log
echo "=== DISPLAY INFO ===" >> ~/mth-debug.log
echo "DISPLAY=$DISPLAY" >> ~/mth-debug.log
ps aux | grep -i x11 >> ~/mth-debug.log
echo "=== APP LOGS ===" >> ~/mth-debug.log
sudo journalctl -u mth-bde-iot-client.service --no-pager >> ~/mth-debug.log
```

**💡 Tipp**: Die meisten Probleme können durch das `--no-sandbox` Flag gelöst werden!
