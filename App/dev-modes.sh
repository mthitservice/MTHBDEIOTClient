#!/bin/bash

echo "🖥️  MTH BDE IoT Client - Entwicklungsmodi"
echo "========================================"
echo ""
echo "Wählen Sie einen Entwicklungsmodus:"
echo ""
echo "1️⃣  Standard (jetzt 1920x1080!)"
echo "2️⃣  Klassisch (1024x728)"
echo "3️⃣  1920x1080 Fullscreen"
echo "4️⃣  Kiosk-Modus (1920x1080)"
echo "5️⃣  Raspberry Pi Test-Modus"
echo ""
read -p "Ihre Wahl (1-5): " choice

case $choice in
    1)
        echo "🚀 Starte Standard-Modus (1920x1080)..."
        npm start
        ;;
    2)
        echo "🚀 Starte klassischen Modus (1024x728)..."
        npm run start:standard
        ;;
    3)
        echo "🚀 Starte 1920x1080 Fullscreen-Modus..."
        npm run start:fullscreen
        ;;
    4)
        echo "🚀 Starte Kiosk-Modus (1920x1080)..."
        npm run start:kiosk
        ;;
    5)
        echo "🚀 Starte Raspberry Pi Test-Modus..."
        cross-env RASPBERRY_PI=true DEV_1080=true npm start
        ;;
    *)
        echo "❌ Ungültige Auswahl"
        exit 1
        ;;
esac
