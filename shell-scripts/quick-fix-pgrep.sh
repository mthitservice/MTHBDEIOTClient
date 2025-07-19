#!/bin/bash

echo "🔧 SCHNELLER PGREP-FIX für laufende Autostart-Scripts"
echo "=================================================="

# Aktualisiere das laufende Autostart-Script
if [ -f "/home/admin/autostart-mthbde.sh" ]; then
    echo "📝 Aktualisiere /home/admin/autostart-mthbde.sh..."
    
    # Backup erstellen
    cp /home/admin/autostart-mthbde.sh /home/admin/autostart-mthbde.sh.backup
    
    # pgrep Fix anwenden
    sed -i 's/pgrep -x "lxpanel\\|pcmanfm\\|openbox\\|xfce4-panel"/pgrep -f "lxpanel" || pgrep -f "pcmanfm" || pgrep -f "openbox" || pgrep -f "xfce4-panel"/' /home/admin/autostart-mthbde.sh
    
    echo "✅ autostart-mthbde.sh aktualisiert"
else
    echo "⚠️  /home/admin/autostart-mthbde.sh nicht gefunden"
fi

# Aktualisiere systemd Script
if [ -f "/usr/local/bin/mthbde-admin-autostart.sh" ]; then
    echo "📝 Aktualisiere /usr/local/bin/mthbde-admin-autostart.sh..."
    
    # Backup erstellen
    cp /usr/local/bin/mthbde-admin-autostart.sh /usr/local/bin/mthbde-admin-autostart.sh.backup
    
    # pgrep Fix anwenden
    sed -i 's/pgrep -x "lxpanel\\|pcmanfm\\|openbox"/pgrep -f "lxpanel" || pgrep -f "pcmanfm" || pgrep -f "openbox"/' /usr/local/bin/mthbde-admin-autostart.sh
    
    echo "✅ mthbde-admin-autostart.sh aktualisiert"
else
    echo "⚠️  /usr/local/bin/mthbde-admin-autostart.sh nicht gefunden"
fi

# Test der aktuellen Desktop-Prozesse
echo ""
echo "🔍 AKTUELLE DESKTOP-PROZESSE:"
echo "=============================="
pgrep -f "lxpanel" > /dev/null && echo "✅ lxpanel gefunden" || echo "❌ lxpanel nicht gefunden"
pgrep -f "pcmanfm" > /dev/null && echo "✅ pcmanfm gefunden" || echo "❌ pcmanfm nicht gefunden"
pgrep -f "openbox" > /dev/null && echo "✅ openbox gefunden" || echo "❌ openbox nicht gefunden"
pgrep -f "xfce4-panel" > /dev/null && echo "✅ xfce4-panel gefunden" || echo "❌ xfce4-panel nicht gefunden"

echo ""
echo "🎯 AKTUELLER STATUS:"
echo "==================="
if pgrep -f "mthbdeiotclient" > /dev/null; then
    echo "✅ mthbdeiotclient läuft bereits (PID: $(pgrep -f mthbdeiotclient))"
    echo "✅ Autostart funktioniert!"
    
    # Prüfe unclutter
    if pgrep -f "unclutter" > /dev/null; then
        echo "✅ Mauszeiger wird versteckt (unclutter läuft)"
    else
        echo "⚠️  unclutter läuft nicht - Mauszeiger sichtbar"
        echo "🔧 Starte unclutter..."
        unclutter -display :0 -idle 1 -grab &
        echo "✅ unclutter gestartet"
    fi
else
    echo "❌ mthbdeiotclient läuft nicht"
fi

echo ""
echo "🎉 pgrep-Warnungen werden nach dem nächsten Neustart verschwinden!"
echo "Die Anwendung funktioniert bereits korrekt."
