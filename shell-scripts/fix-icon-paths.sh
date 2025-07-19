#!/bin/bash

# Fix Icon Paths Script
# Repariert falsche Icon-Pfade nach der Umbenennung von MthBdeIotClient -> mthbdeiotclient

echo "🔧 Repariere Icon-Pfade für MTH BDE IoT Client..."

# Prüfe ob die App installiert ist
if [[ ! -d "/opt/mthbdeiotclient" ]]; then
    echo "❌ MTH BDE IoT Client ist nicht in /opt/mthbdeiotclient installiert."
    echo "   Prüfe ob eine ältere Installation unter /opt/MthBdeIotClient existiert..."
    
    if [[ -d "/opt/MthBdeIotClient" ]]; then
        echo "💡 Alte Installation gefunden. Bitte führen Sie eine Neuinstallation durch:"
        echo "   curl -fsSL https://raw.githubusercontent.com/mthitservice/MTHBDEIOTClient/master/shell-scripts/install-latest.sh | bash"
    fi
    exit 1
fi

# Desktop-Verknüpfung reparieren
DESKTOP_FILE="$HOME/Desktop/MTH-BDE-IoT-Client.desktop"
if [[ -f "$DESKTOP_FILE" ]]; then
    echo "🔄 Repariere Desktop-Verknüpfung..."
    sed -i 's|/opt/MthBdeIotClient/|/opt/mthbdeiotclient/|g' "$DESKTOP_FILE"
    chmod +x "$DESKTOP_FILE"
    echo "✅ Desktop-Verknüpfung repariert"
else
    echo "📝 Erstelle neue Desktop-Verknüpfung..."
    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=MTH BDE IoT Client
Comment=MTH BDE IoT Management Application
Exec=/opt/mthbdeiotclient/mthbdeiotclient --no-sandbox --disable-gpu
Icon=/opt/mthbdeiotclient/resources/app/assets/icon.png
Terminal=false
StartupWMClass=MTH BDE IoT Client
Categories=Utility;Development;
EOF
    chmod +x "$DESKTOP_FILE"
    echo "✅ Desktop-Verknüpfung erstellt"
fi

# Applications Menu Eintrag reparieren
APPS_FILE="/usr/share/applications/mth-bde-iot-client.desktop"
if [[ -f "$APPS_FILE" ]]; then
    echo "🔄 Repariere Applications Menu Eintrag..."
    sudo sed -i 's|/opt/MthBdeIotClient/|/opt/mthbdeiotclient/|g' "$APPS_FILE"
    echo "✅ Applications Menu Eintrag repariert"
else
    echo "📝 Erstelle neuen Applications Menu Eintrag..."
    sudo tee "$APPS_FILE" > /dev/null << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=MTH BDE IoT Client
Comment=MTH BDE IoT Management Application
Exec=/opt/mthbdeiotclient/mthbdeiotclient --no-sandbox --disable-gpu
Icon=/opt/mthbdeiotclient/resources/app/assets/icon.png
Terminal=false
StartupWMClass=MTH BDE IoT Client
Categories=Utility;Development;
EOF
    echo "✅ Applications Menu Eintrag erstellt"
fi

# Icon-Cache aktualisieren
echo "🔄 Aktualisiere Icon-Cache..."
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    sudo gtk-update-icon-cache -f /usr/share/icons/hicolor/ 2>/dev/null || true
fi

if command -v update-desktop-database >/dev/null 2>&1; then
    sudo update-desktop-database /usr/share/applications/ 2>/dev/null || true
fi

echo ""
echo "🎉 Icon-Pfade erfolgreich repariert!"
echo ""
echo "💡 Wenn das Icon immer noch nicht angezeigt wird:"
echo "   1. Loggen Sie sich ab und wieder ein"
echo "   2. Oder führen Sie einen Neustart durch"
echo "   3. Das Icon sollte dann korrekt angezeigt werden"
echo ""
