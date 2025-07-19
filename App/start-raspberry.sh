#!/bin/bash

# Raspberry Pi Startup-Skript für optimale Performance
# Dieses Skript sollte vor dem Start der Electron-App ausgeführt werden

echo "Raspberry Pi Performance-Optimierungen werden angewendet..."

# CPU Governor auf Performance setzen (falls verfügbar)
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
    echo "performance" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null
    echo "CPU Governor auf 'performance' gesetzt"
fi

# GPU Memory Split optimieren (falls config.txt editierbar)
# echo "gpu_mem=64" | sudo tee -a /boot/config.txt

# Wayland-spezifische Umgebungsvariablen setzen
export WAYLAND_DISPLAY=wayland-1
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export XDG_SESSION_TYPE=wayland

# Electron-spezifische Optimierungen
export ELECTRON_DISABLE_SECURITY_WARNINGS=true
export ELECTRON_NO_ASAR=true
export ELECTRON_ENABLE_LOGGING=false

# Node.js Memory-Optimierungen
export NODE_OPTIONS="--max-old-space-size=512 --gc-interval=100"

# Wayland-spezifische Flags für bessere Performance
export LIBGL_ALWAYS_SOFTWARE=1
export WLR_RENDERER=pixman
export WLR_NO_HARDWARE_CURSORS=1

# Prozess-Priorität setzen
echo "Setze hohe Prozess-Priorität für bessere UI-Responsivität..."
sudo renice -10 $$

# Swap-Nutzung reduzieren (falls genug RAM vorhanden)
echo 10 | sudo tee /proc/sys/vm/swappiness > /dev/null

echo "Performance-Optimierungen angewendet. Starte Anwendung..."

# Anwendung mit optimierten Flags starten
exec ./mthbdeiotclient \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --disable-gpu-compositing \
  --disable-software-rasterizer \
  --disable-background-timer-throttling \
  --disable-backgrounding-occluded-windows \
  --disable-renderer-backgrounding \
  --enable-features=VaapiVideoDecoder \
  --disable-features=TranslateUI,VizDisplayCompositor \
  --disable-ipc-flooding-protection \
  --memory-pressure-off \
  --max_old_space_size=512 \
  --ozone-platform=wayland \
  --enable-wayland-ime \
  "$@"
