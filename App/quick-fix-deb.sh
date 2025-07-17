#!/bin/bash

# Quick Fix für DEB Package Problem
# Dieses Skript behebt häufige Probleme mit DEB-Paket-Generierung

echo "🔧 MTH BDE IoT Client - DEB Package Quick Fix"
echo "=============================================="

# Prüfe Arbeitsverzeichnis
if [[ ! -f "package.json" ]]; then
    echo "❌ Fehler: package.json nicht gefunden. Bitte im App-Verzeichnis ausführen."
    exit 1
fi

# Prüfe Node.js Version
NODE_VERSION=$(node --version)
echo "Node.js Version: $NODE_VERSION"

# Empfohlene Node.js Version prüfen
if [[ "$NODE_VERSION" < "v18.0.0" ]]; then
    echo "⚠️  Warnung: Node.js Version ist zu alt. Empfohlen: v18.0.0 oder höher"
fi

# 1. Cache und temporäre Dateien bereinigen
echo "🧹 Bereinige Cache und temporäre Dateien..."
rm -rf release/build
rm -rf dist
rm -rf node_modules/.cache
rm -rf ~/.npm/_cacache
rm -rf /tmp/electron-*

# 2. Electron-Builder aktualisieren
echo "📦 Aktualisiere electron-builder..."
npm update electron-builder

# 3. Native Module neu kompilieren
echo "🔨 Kompiliere native Module neu..."
npm run rebuild || npm rebuild

# 4. Dependencies neu installieren
echo "📥 Installiere Dependencies neu..."
npm ci

# 5. Build mit Debug-Informationen
echo "🔍 Führe Build mit Debug-Informationen aus..."
export DEBUG=electron-builder
npm run build

# 6. DEB-Paket erstellen
echo "📦 Erstelle DEB-Paket..."
npm run package:raspberry-deb

# 7. Validierung
echo "✅ Validiere generierte DEB-Pakete..."
DEB_DIR="release/build"

if [[ ! -d "$DEB_DIR" ]]; then
    echo "❌ Fehler: Build-Verzeichnis nicht gefunden: $DEB_DIR"
    exit 1
fi

find "$DEB_DIR" -name "*.deb" | while read debfile; do
    echo "📋 Prüfe: $(basename "$debfile")"

    # Dateigröße
    size=$(stat -c%s "$debfile")
    size_mb=$(echo "scale=2; $size/1024/1024" | bc)
    echo "   Größe: $size Bytes ($size_mb MB)"

    # Mindestgröße prüfen
    if [[ $size -lt 30000000 ]]; then
        echo "   ⚠️  Warnung: Datei ist sehr klein für eine Electron-App"
    fi

    # Dateityp prüfen
    filetype=$(file "$debfile")
    echo "   Typ: $filetype"

    # DEB-Validierung
    if command -v dpkg-deb >/dev/null 2>&1; then
        if dpkg-deb --info "$debfile" >/dev/null 2>&1; then
            echo "   ✅ DEB-Paket ist gültig"
        else
            echo "   ❌ DEB-Paket ist NICHT gültig"
            echo "   💡 Versuche manuelle Reparatur..."

            # Versuche 7zip Test
            if command -v 7z >/dev/null 2>&1; then
                if 7z t "$debfile" >/dev/null 2>&1; then
                    echo "   ✅ Archiv-Struktur ist OK (7zip)"
                else
                    echo "   ❌ Archiv-Struktur ist beschädigt"
                fi
            fi
        fi
    else
        echo "   ⚠️  dpkg-deb nicht verfügbar für Validierung"
    fi
done

echo ""
echo "🎯 Quick Fix abgeschlossen!"
echo ""
echo "Nächste Schritte:"
echo "1. Teste DEB-Installation auf Raspberry Pi"
echo "2. Falls Probleme bestehen, verwende das debug-deb.sh Skript"
echo "3. Prüfe die DEB_TROUBLESHOOTING.md Dokumentation"
echo ""
echo "Support-Informationen:"
echo "- Node.js: $(node --version)"
echo "- NPM: $(npm --version)"
echo "- Electron-Builder: $(npm list electron-builder --depth=0 2>/dev/null | grep electron-builder || echo 'Nicht gefunden')"
echo "- OS: $(uname -a)"
