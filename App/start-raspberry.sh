#!/bin/bash

# Raspberry Pi Startup-Skript für optimale Performance
# Dieses Skript sollte vor dem Start der Electron-App ausgeführt werden

echo "Raspberry Pi Performance-Optimierungen werden angewendet..."

# CPU Governor auf Performance setzen (falls beschreibbar)
if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
  if [ -w /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
    for cpu_gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
      [ -w "$cpu_gov" ] && echo "performance" > "$cpu_gov"
    done
    echo "CPU Governor auf 'performance' gesetzt"
  else
    echo "CPU Governor nicht beschreibbar - überspringe"
  fi
fi

# GPU Memory Split optimieren (falls config.txt editierbar)
# echo "gpu_mem=64" | sudo tee -a /boot/config.txt

# Session-Umgebungsvariablen nur setzen, wenn noch nicht vorhanden
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-1}
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}
export XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-wayland}

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

# Prozess-Priorität setzen (best effort)
echo "Setze hohe Prozess-Priorität für bessere UI-Responsivität..."
renice -n -10 -p $$ >/dev/null 2>&1 || echo "renice ohne Berechtigung - übersprungen"

# Swap-Nutzung reduzieren (falls beschreibbar)
if [ -w /proc/sys/vm/swappiness ]; then
  echo 10 > /proc/sys/vm/swappiness
fi

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
