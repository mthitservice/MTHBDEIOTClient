#!/bin/bash

# Raspberry Pi DPI Testing Tool (Linux Version)
# Test verschiedene Zoom-Level für optimale Darstellung

ZOOM_LEVEL=${1:-"auto"}

show_header() {
    echo ""
    echo "🍓 Raspberry Pi DPI Testing Tool"
    echo "================================="
    echo ""
}

test_zoom_level() {
    local level=$1
    echo "🔍 Testing zoom level: $level"
    
    # Setze Umgebungsvariablen für den Test
    export RASPBERRY_DPI_ZOOM=$level
    export RASPBERRY_PI=true
    
    echo "   Starting app with zoom level $level..."
    echo "   Press Ctrl+C to stop and try next level"
    echo ""
    
    # Starte App im Test-Modus
    if command -v npm > /dev/null; then
        npm start
    else
        echo "❌ npm nicht gefunden. Bitte Node.js installieren."
        exit 1
    fi
}

show_help() {
    echo "Verfügbare Zoom-Level:"
    echo ""
    echo "1.0   - Standard (100%)"
    echo "1.1   - Leicht vergrößert (110%)"
    echo "1.2   - Empfohlen für Raspberry Pi (120%)"
    echo "1.3   - Groß (130%)"
    echo "1.4   - Sehr groß (140%)"
    echo "1.5   - Maximum (150%)"
    echo "auto  - Automatische Erkennung"
    echo "reset - Alle Einstellungen zurücksetzen"
    echo ""
    echo "Verwendung:"
    echo "  ./test-raspberry-dpi.sh 1.2"
    echo "  ./test-raspberry-dpi.sh auto"
    echo ""
}

reset_settings() {
    echo "🔄 Zurücksetzen der DPI-Einstellungen..."
    
    unset RASPBERRY_DPI_ZOOM
    unset RASPBERRY_PI
    
    echo "✅ Einstellungen zurückgesetzt"
}

auto_detect() {
    echo "🔍 Automatische DPI-Erkennung..."
    echo ""
    
    # Prüfe Bildschirmauflösung
    if command -v xrandr > /dev/null; then
        resolution=$(xrandr | grep '\*' | awk '{print $1}' | head -1)
        if [[ "$resolution" == "1920x1080" ]]; then
            echo "📺 1920x1080 erkannt - empfohlener Zoom: 1.2"
            return 0
        fi
    fi
    
    # Prüfe ob Raspberry Pi
    if [[ -f /proc/device-tree/model ]] && grep -q "Raspberry Pi" /proc/device-tree/model; then
        echo "🍓 Raspberry Pi erkannt - verwende empfohlenen Zoom: 1.2"
        return 0
    fi
    
    echo "🖥️  Standard-System - verwende Basis-Zoom: 1.0"
    return 0
}

interactive_test() {
    echo "🧪 Interaktiver DPI-Test"
    echo "========================"
    echo ""
    echo "Dieser Test führt Sie durch verschiedene Zoom-Level."
    echo "Drücken Sie Ctrl+C um zum nächsten Level zu wechseln."
    echo ""
    
    test_levels=("1.0" "1.1" "1.2" "1.3" "1.4" "1.5")
    
    for level in "${test_levels[@]}"; do
        echo "Teste Zoom-Level: $level"
        read -p "Drücken Sie Enter um fortzufahren oder Ctrl+C zum Abbrechen"
        test_zoom_level "$level"
        echo ""
    done
    
    echo "🎯 Test abgeschlossen!"
    echo "Welches Zoom-Level war am besten lesbar?"
    read -p "Eingabe (1.0-1.5): " preferred
    
    if [[ "$preferred" =~ ^1\.[0-5]$ ]]; then
        echo "💾 Empfohlenes Zoom-Level: $preferred"
        echo "Setzen Sie RASPBERRY_DPI_ZOOM=$preferred in der .env Datei"
        
        # Optional: Automatisch in .env schreiben
        if [[ -f ".env" ]]; then
            if grep -q "RASPBERRY_DPI_ZOOM" .env; then
                sed -i "s/RASPBERRY_DPI_ZOOM=.*/RASPBERRY_DPI_ZOOM=$preferred/" .env
            else
                echo "RASPBERRY_DPI_ZOOM=$preferred" >> .env
            fi
            echo "✅ .env Datei wurde aktualisiert"
        fi
    fi
}

get_system_info() {
    echo "📊 System-Informationen:"
    echo "  OS: $(uname -s)"
    echo "  Architektur: $(uname -m)"
    
    if [[ -f /proc/device-tree/model ]]; then
        echo "  Hardware: $(cat /proc/device-tree/model)"
    fi
    
    if command -v xrandr > /dev/null; then
        echo "  Auflösung: $(xrandr | grep '\*' | awk '{print $1}' | head -1)"
    fi
    
    echo ""
}

# Hauptlogik
show_header

# Prüfe ob wir im App-Verzeichnis sind
if [[ ! -f "package.json" ]]; then
    echo "❌ Fehler: package.json nicht gefunden!"
    echo "   Bitte führen Sie dieses Skript im App-Verzeichnis aus."
    exit 1
fi

case "$ZOOM_LEVEL" in
    "reset")
        reset_settings
        ;;
    "auto")
        auto_detect
        # Verwende 1.2 als Standard für Raspberry Pi
        test_zoom_level "1.2"
        ;;
    "interactive")
        interactive_test
        ;;
    "info")
        get_system_info
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        if [[ "$ZOOM_LEVEL" =~ ^1\.[0-5]$ ]]; then
            test_zoom_level "$ZOOM_LEVEL"
        else
            echo "❌ Ungültiges Zoom-Level: $ZOOM_LEVEL"
            show_help
            exit 1
        fi
        ;;
esac

echo ""
