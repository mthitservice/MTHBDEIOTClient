#!/usr/bin/env bash

# Automatischer Release-Trigger für Azure DevOps Pipeline
# Dieses Skript löst einen Build aus, ohne Git Tags manuell zu erstellen

set -e

echo "🚀 Automatischer Release-Trigger für MTH BDE IoT Client"
echo "================================================="

# Prüfe ob wir im richtigen Verzeichnis sind
if [ ! -f "App/package.json" ]; then
    echo "❌ Error: App/package.json nicht gefunden!"
    echo "   Bitte führe dieses Skript im Repository-Root aus."
    exit 1
fi

# Aktuelle Version aus package.json lesen
CURRENT_VERSION=$(node -p "require('./App/package.json').version")
echo "📋 Aktuelle Version in package.json: $CURRENT_VERSION"

# Git Status prüfen
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Es gibt uncommittete Änderungen:"
    git status --short
    echo ""
    read -p "Möchten Sie fortfahren? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Abgebrochen."
        exit 1
    fi
fi

# Aktuelle Branch prüfen
CURRENT_BRANCH=$(git branch --show-current)
echo "🌿 Aktuelle Branch: $CURRENT_BRANCH"

if [ "$CURRENT_BRANCH" != "master" ]; then
    echo "⚠️  Sie sind nicht auf der master branch!"
    read -p "Möchten Sie trotzdem fortfahren? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Abgebrochen."
        exit 1
    fi
fi

# Änderungen committen falls nötig
if [ -n "$(git status --porcelain)" ]; then
    echo "📝 Committe ausstehende Änderungen..."
    git add .
    git commit -m "Pre-release commit for version $CURRENT_VERSION

- Updated version to $CURRENT_VERSION
- Prepared for automatic Azure DevOps release
- Performance optimizations included

[automated-release]"
fi

# Push to Azure DevOps (triggert die Pipeline)
echo "🔄 Push zu Azure DevOps Repository..."
git push origin $CURRENT_BRANCH

echo ""
echo "✅ Release-Trigger erfolgreich!"
echo "================================================="
echo ""
echo "🔗 Die Azure DevOps Pipeline wird jetzt automatisch:"
echo "   1. Version $CURRENT_VERSION aus package.json lesen"
echo "   2. Git Tag 'v$CURRENT_VERSION' erstellen"  
echo "   3. ARM64 und ARMv7l .deb Pakete bauen"
echo "   4. GitHub Release mit Artefakten erstellen"
echo ""
echo "📊 Verfolgen Sie den Build-Status hier:"
echo "   https://dev.azure.com/mth-it-service/MthBdeIotClient/_build"
echo ""
echo "🎯 GitHub Release wird hier erstellt:"
echo "   https://github.com/mthitservice/MTHBDEIOTClient/releases"
echo ""
echo "⏱️  Der Build-Prozess dauert ca. 10-15 Minuten."

# Optional: Öffne Azure DevOps Build Pipeline im Browser
if command -v xdg-open > /dev/null; then
    read -p "🌐 Azure DevOps Pipeline im Browser öffnen? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        xdg-open "https://dev.azure.com/mth-it-service/MthBdeIotClient/_build"
    fi
elif command -v open > /dev/null; then
    read -p "🌐 Azure DevOps Pipeline im Browser öffnen? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "https://dev.azure.com/mth-it-service/MthBdeIotClient/_build"
    fi
fi

echo ""
echo "🎉 Automatischer Release-Prozess gestartet!"
