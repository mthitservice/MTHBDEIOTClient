# Raspberry Pi Performance-Optimierungen für MTH BDE IoT Client

## Übersicht
Diese Optimierungen verbessern die Performance der Electron-Anwendung auf dem Raspberry Pi, insbesondere bei Wayland-Desktop-Umgebungen wie Labwc.

## 1. System-Optimierungen

### CPU Governor auf Performance setzen:
```bash
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
sudo systemctl enable cpufrequtils
```

### GPU Memory Split anpassen (in /boot/config.txt):
```bash
sudo nano /boot/config.txt
# Füge hinzu:
gpu_mem=64
gpu_mem_256=64
gpu_mem_512=64
gpu_mem_1024=128
```

### Swap-Verhalten optimieren:
```bash
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
```

## 2. Wayland-Optimierungen

### Labwc Konfiguration optimieren:
```bash
mkdir -p ~/.config/labwc
cat > ~/.config/labwc/rc.xml << 'EOF'
<?xml version="1.0"?>
<labwc_config>
  <core>
    <decoration>server</decoration>
    <gap>0</gap>
    <adaptiveSync>no</adaptiveSync>
  </core>
  <theme>
    <dropShadows>no</dropShadows>
  </theme>
  <desktops>
    <number>1</number>
  </desktops>
</labwc_config>
EOF
```

### WLR Environment Variables:
```bash
cat >> ~/.bashrc << 'EOF'
# Wayland/WLR Performance-Optimierungen
export WLR_RENDERER=pixman
export WLR_NO_HARDWARE_CURSORS=1
export LIBGL_ALWAYS_SOFTWARE=1
export WLR_DRM_NO_ATOMIC=1
EOF
```

## 3. Electron-App Installation

### Optimierte Anwendung installieren:
```bash
# Anwendung extrahieren
sudo mkdir -p /opt/mthbdeiotclient
sudo tar -xzf mthbdeiotclient-*.tar.gz -C /opt/mthbdeiotclient --strip-components=1

# Startup-Skript ausführbar machen
sudo chmod +x /opt/mthbdeiotclient/start-raspberry.sh

# Desktop Entry installieren
cp mthbdeiotclient-optimized.desktop ~/.local/share/applications/
update-desktop-database ~/.local/share/applications/

# Systemd Service installieren (optional)
sudo cp mthbdeiotclient-optimized.service /etc/systemd/user/
systemctl --user daemon-reload
systemctl --user enable mthbdeiotclient-optimized
```

## 4. Zusätzliche System-Optimierungen

### Kernel Parameter optimieren:
```bash
sudo nano /boot/cmdline.txt
# Füge am Ende hinzu:
cgroup_memory=1 cgroup_enable=memory
```

### I/O Scheduler optimieren:
```bash
echo 'ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/scheduler}="mq-deadline"' | sudo tee /etc/udev/rules.d/60-ioschedulers.rules
```

### Thermisches Management:
```bash
sudo nano /boot/config.txt
# Füge hinzu:
temp_limit=80
initial_turbo=30
```

## 5. Performance-Monitoring

### System-Performance überwachen:
```bash
# CPU-Auslastung
htop

# Memory-Verbrauch
free -h

# GPU-Status (falls BCM2835 verfügbar)
vcgencmd measure_temp
vcgencmd get_mem arm
vcgencmd get_mem gpu
```

### Electron-Performance überwachen:
```bash
# Prozess-Details
ps aux | grep mthbdeiotclient

# Memory-Mapping
cat /proc/$(pgrep mthbdeiotclient)/smaps | grep -E "^(Size|Rss|Pss):" | awk '{sum+=$2} END {print sum" KB"}'
```

## 6. Troubleshooting

### Häufige Probleme und Lösungen:

**Problem**: Maus ist noch immer hakelig
**Lösung**: 
```bash
# Polling-Rate der Maus reduzieren
echo 'options usbhid mousepoll=8' | sudo tee /etc/modprobe.d/usbhid.conf
sudo reboot
```

**Problem**: Hoher CPU-Verbrauch
**Lösung**:
```bash
# Nice-Wert anpassen
sudo renice -n 5 $(pgrep mthbdeiotclient)
```

**Problem**: Speicher-Leaks
**Lösung**:
```bash
# Automatischer Neustart bei hohem Memory-Verbrauch
echo '*/30 * * * * if [ $(ps -o pid,vsz --no-headers -C mthbdeiotclient | awk "{print \$2}") -gt 500000 ]; then systemctl --user restart mthbdeiotclient-optimized; fi' | crontab -
```

## 7. Erweiterte Optimierungen

### Zram aktivieren (für mehr verfügbaren RAM):
```bash
sudo apt install zram-tools
echo 'ALGO=lz4' | sudo tee -a /etc/default/zramswap
echo 'PERCENT=25' | sudo tee -a /etc/default/zramswap
sudo service zramswap reload
```

### CPU Affinity setzen:
```bash
# App an bestimmte CPU-Kerne binden
taskset -cp 2,3 $(pgrep mthbdeiotclient)
```

Diese Optimierungen sollten die Maus-Responsivität deutlich verbessern und die allgemeine Performance der Anwendung auf dem Raspberry Pi steigern.
