#!/bin/bash

echo "🚨 SOFORT-FIX: Electron App Crash nach 1 Minute"
echo "==============================================="

echo "🔍 Analysiere aktuelles Problem..."

# Prüfe aktuelle Prozesse
if pgrep -f "mthbdeiotclient" > /dev/null; then
    echo "✅ mthbdeiotclient läuft aktuell (PID: $(pgrep -f mthbdeiotclient))"
    
    # Zeige aktuelle Parameter
    echo "📋 Aktuelle Kommandozeile:"
    ps aux | grep mthbdeiotclient | grep -v grep
else
    echo "❌ mthbdeiotclient läuft nicht"
fi

# Prüfe die Logs
echo ""
echo "🔍 LETZTE APP-LOGS (Crash-Diagnose):"
echo "====================================="
if [ -f "/home/admin/mthbde-app.log" ]; then
    echo "--- Letzte 20 Zeilen von /home/admin/mthbde-app.log ---"
    tail -20 /home/admin/mthbde-app.log
else
    echo "❌ /home/admin/mthbde-app.log nicht gefunden"
fi

if [ -f "/var/log/mthbde-app-systemd.log" ]; then
    echo ""
    echo "--- Letzte 20 Zeilen von /var/log/mthbde-app-systemd.log ---"
    tail -20 /var/log/mthbde-app-systemd.log
fi

echo ""
echo "🔧 INSTALLIERE CRASH-FIX..."
echo "=========================="

# 1. Stoppe aktuell laufende Anwendung
echo "⏹️  Stoppe laufende mthbdeiotclient..."
pkill -f "mthbdeiotclient" 2>/dev/null || true
sleep 2

# 2. Installiere fehlende Abhängigkeiten (häufiger Crash-Grund)
echo "📦 Installiere fehlende Abhängigkeiten..."
apt-get update > /dev/null 2>&1
apt-get install -y \
    libnss3 \
    libxss1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libgtk-3-0 \
    libxkbcommon0 \
    > /dev/null 2>&1

echo "✅ Abhängigkeiten installiert"

# 3. Aktualisiere autostart-Script mit stabilen Parametern
echo "📝 Aktualisiere Autostart-Script..."

tee /home/admin/autostart-mthbde-stable.sh > /dev/null << 'EOF'
#!/bin/bash

# Crash-sicheres Logging
LOG_FILE="/home/admin/mthbde-stable.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================="
echo "MTH BDE STABLE Start - $(date)"
echo "========================================="

# Umgebung korrekt setzen
export DISPLAY=:0
export XAUTHORITY=/home/admin/.Xauthority
export HOME=/home/admin
cd /home/admin

# Warte auf Desktop
echo "Warte auf Desktop..."
for i in {1..20}; do
    if pgrep -f "lxpanel" > /dev/null || pgrep -f "pcmanfm" > /dev/null || pgrep -f "openbox" > /dev/null; then
        echo "Desktop bereit nach $((i*2)) Sekunden"
        break
    fi
    sleep 2
done

sleep 5

# X11 Setup
xhost +local: 2>/dev/null || true

# Alte Prozesse beenden
pkill -f "mthbdeiotclient" 2>/dev/null || true
sleep 2

# Mauszeiger verstecken
unclutter -display :0 -idle 1 -grab &

# STABILE PARAMETER - weniger Features = weniger Crashes
echo "Starte mthbdeiotclient mit stabilen Parametern..."
/opt/mthbdeiotclient/mthbdeiotclient \
    --no-sandbox \
    --kiosk \
    --fullscreen \
    --disable-dev-shm-usage \
    --disable-web-security \
    --no-first-run \
    --disable-extensions \
    --disable-plugins \
    --disable-default-apps \
    --memory-pressure-off \
    --max_old_space_size=256 \
    --js-flags="--max-old-space-size=256" \
    >> /home/admin/mthbde-stable-app.log 2>&1 &

APP_PID=$!
echo "App gestartet mit PID: $APP_PID ($(date))"

# Warten und prüfen
sleep 5
if kill -0 $APP_PID 2>/dev/null; then
    echo "✅ App läuft stabil"
    
    # Monitor-Loop für Crash-Erkennung
    for i in {1..12}; do  # 12 * 10 = 120 Sekunden überwachen
        sleep 10
        if ! kill -0 $APP_PID 2>/dev/null; then
            echo "❌ CRASH erkannt nach $((i*10)) Sekunden!"
            echo "Letzte Zeilen der App-Logs:"
            tail -10 /home/admin/mthbde-stable-app.log
            break
        fi
        echo "⏰ App läuft seit $((i*10)) Sekunden..."
    done
    
    if kill -0 $APP_PID 2>/dev/null; then
        echo "🎉 App läuft stabil über 2 Minuten - Problem gelöst!"
    fi
else
    echo "❌ App sofort abgestürzt!"
    echo "Crash-Logs:"
    tail -10 /home/admin/mthbde-stable-app.log
fi

echo "Monitor beendet - $(date)"
echo "========================================="
EOF

chmod +x /home/admin/autostart-mthbde-stable.sh
chown admin:admin /home/admin/autostart-mthbde-stable.sh

# 4. Teste das stabile Script sofort
echo ""
echo "🧪 TESTE STABILES SCRIPT SOFORT:"
echo "==============================="
sudo -u admin /home/admin/autostart-mthbde-stable.sh &

echo ""
echo "⏱️  Test läuft im Hintergrund..."
echo "📝 Logs verfolgbar mit: tail -f /home/admin/mthbde-stable.log"
echo ""
echo "Nach 2-3 Minuten prüfen:"
echo "cat /home/admin/mthbde-stable.log"
echo ""
echo "🔧 Wenn stabil: rc.local durch stabiles Script ersetzen mit:"
echo "sudo nano /etc/rc.local"
echo "# Zeile ändern zu: sudo -u admin /home/admin/autostart-mthbde-stable.sh &"
