#!/bin/bash

# MthBdeIotClient - Automatic Version Management Script
# Automatische Versionsverwaltung mit Git Tags, package.json und .env Updates

set -e  # Exit on error

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\0echo -e "${INFO} ${BLUE}Useful links:${NC}"
echo "  • Azure DevOps: https://dev.azure.com/mth-it-service/MthBdeIotClient/_build"
echo "  • GitHub Repository: https://github.com/mth-it-service/MTHBDEIOTClient"
echo "  • Latest Release: https://github.com/mth-it-service/MTHBDEIOTClient/tree/master/releases/latest"
echo "  • Install on Raspberry Pi: https://raw.githubusercontent.com/mth-it-service/MTHBDEIOTClient/master/releases/latest/mthbdeiotclient_${NEW_VERSION}_armhf.deb"36m'
NC='\033[0m' # No Color

# Emoji für bessere Lesbarkeit
SUCCESS="✅"
ERROR="❌"
INFO="ℹ️"
ROCKET="🚀"
TAG="🏷️"
GEAR="⚙️"

# Projektverzeichnisse
PROJECT_ROOT="$(pwd)"
APP_DIR="$PROJECT_ROOT/App"
PACKAGE_JSON="$APP_DIR/package.json"
ENV_FILE="$APP_DIR/.env"

echo -e "${CYAN}=========================================="
echo -e "${ROCKET} MthBdeIotClient Version Manager"
echo -e "=========================================${NC}"
echo ""

# Prüfe ob wir im richtigen Verzeichnis sind
if [ ! -f "$PACKAGE_JSON" ]; then
    echo -e "${ERROR} ${RED}package.json not found in $PACKAGE_JSON${NC}"
    echo -e "${INFO} Please run this script from the project root directory"
    exit 1
fi

# Git Status prüfen
echo -e "${INFO} ${BLUE}Checking Git status...${NC}"
if ! git status --porcelain | grep -q "^"; then
    echo -e "${SUCCESS} ${GREEN}Working directory is clean${NC}"
else
    echo -e "${YELLOW}Working directory has uncommitted changes:${NC}"
    git status --porcelain
    echo ""
    read -p "Do you want to continue anyway? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${ERROR} ${RED}Aborted by user${NC}"
        exit 1
    fi
fi

# Aktuelle Version aus package.json lesen
echo -e "${INFO} ${BLUE}Reading current version...${NC}"
CURRENT_VERSION=$(node -p "require('$PACKAGE_JSON').version" 2>/dev/null || echo "0.0.0")
echo -e "${INFO} Current version in package.json: ${PURPLE}$CURRENT_VERSION${NC}"

# Letzte Git Tags abrufen
echo -e "${INFO} ${BLUE}Fetching Git tags...${NC}"
git fetch --tags --quiet 2>/dev/null || echo -e "${YELLOW}Warning: Could not fetch tags${NC}"

# Letzten Git Tag finden
LAST_TAG=$(git tag -l --sort=-version:refname "v*" | head -1 2>/dev/null || echo "")
if [ -n "$LAST_TAG" ]; then
    LAST_VERSION=${LAST_TAG#v}  # Remove 'v' prefix
    echo -e "${INFO} Last Git tag: ${PURPLE}$LAST_TAG${NC} (version: $LAST_VERSION)"
else
    LAST_VERSION="0.0.0"
    echo -e "${INFO} No previous Git tags found, starting from ${PURPLE}$LAST_VERSION${NC}"
fi

# Funktion: Version erhöhen
increment_version() {
    local version=$1
    local part=$2
    
    IFS='.' read -r major minor patch <<< "$version"
    
    case $part in
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "patch")
            patch=$((patch + 1))
            ;;
        *)
            echo "Invalid version part: $part"
            return 1
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

# Vorgeschlagene Versionen generieren
SUGGESTED_PATCH=$(increment_version "$LAST_VERSION" "patch")
SUGGESTED_MINOR=$(increment_version "$LAST_VERSION" "minor")
SUGGESTED_MAJOR=$(increment_version "$LAST_VERSION" "major")

echo ""
echo -e "${GEAR} ${CYAN}Version suggestions based on last tag ($LAST_VERSION):${NC}"
echo -e "  ${GREEN}1)${NC} Patch release: ${PURPLE}$SUGGESTED_PATCH${NC} (bugfixes)"
echo -e "  ${GREEN}2)${NC} Minor release: ${PURPLE}$SUGGESTED_MINOR${NC} (new features)"
echo -e "  ${GREEN}3)${NC} Major release: ${PURPLE}$SUGGESTED_MAJOR${NC} (breaking changes)"
echo -e "  ${GREEN}4)${NC} Custom version"
echo ""

# Benutzer nach Version fragen
while true; do
    read -p "Select version type (1-4) or enter custom version: " -r VERSION_INPUT
    
    case $VERSION_INPUT in
        "1")
            NEW_VERSION=$SUGGESTED_PATCH
            break
            ;;
        "2")
            NEW_VERSION=$SUGGESTED_MINOR
            break
            ;;
        "3")
            NEW_VERSION=$SUGGESTED_MAJOR
            break
            ;;
        "4")
            read -p "Enter custom version (e.g., 2.1.0): " -r NEW_VERSION
            if [[ $NEW_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                break
            else
                echo -e "${ERROR} ${RED}Invalid version format. Please use semantic versioning (e.g., 1.2.3)${NC}"
            fi
            ;;
        *)
            # Prüfe ob direkt eine Version eingegeben wurde
            if [[ $VERSION_INPUT =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                NEW_VERSION=$VERSION_INPUT
                break
            else
                echo -e "${ERROR} ${RED}Invalid input. Please select 1-4 or enter a valid version${NC}"
            fi
            ;;
    esac
done

NEW_TAG="v$NEW_VERSION"

echo ""
echo -e "${ROCKET} ${GREEN}Selected version: ${PURPLE}$NEW_VERSION${NC}"
echo -e "${TAG} ${GREEN}Git tag will be: ${PURPLE}$NEW_TAG${NC}"
echo ""

# Prüfe ob Tag bereits existiert
if git rev-parse "$NEW_TAG" >/dev/null 2>&1; then
    echo -e "${ERROR} ${RED}Tag $NEW_TAG already exists!${NC}"
    echo -e "${INFO} Existing tags:"
    git tag -l --sort=-version:refname "v*" | head -5
    exit 1
fi

# Bestätigung
echo -e "${INFO} ${YELLOW}This will:${NC}"
echo "  • Update package.json version to $NEW_VERSION"
echo "  • Update .env file with new version"
echo "  • Commit changes with message: 'Release $NEW_VERSION'"
echo "  • Create Git tag: $NEW_TAG"
echo "  • Push changes and tag to origin"
echo ""
read -p "Continue? (y/N): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${ERROR} ${RED}Aborted by user${NC}"
    exit 1
fi

# 1. Package.json aktualisieren
echo -e "${GEAR} ${BLUE}Updating package.json...${NC}"
node -e "
const fs = require('fs');
const packageJson = JSON.parse(fs.readFileSync('$PACKAGE_JSON', 'utf8'));
packageJson.version = '$NEW_VERSION';
fs.writeFileSync('$PACKAGE_JSON', JSON.stringify(packageJson, null, 2) + '\n');
console.log('✅ Updated package.json version to $NEW_VERSION');
"

# 2. .env Datei aktualisieren oder erstellen
echo -e "${GEAR} ${BLUE}Updating .env file...${NC}"
if [ -f "$ENV_FILE" ]; then
    # Prüfe ob VERSION bereits existiert
    if grep -q "^VERSION=" "$ENV_FILE"; then
        # Aktualisiere bestehende VERSION
        sed -i "s/^VERSION=.*/VERSION=$NEW_VERSION/" "$ENV_FILE"
        echo -e "${SUCCESS} ${GREEN}Updated VERSION in existing .env file${NC}"
    else
        # Füge VERSION hinzu
        echo "VERSION=$NEW_VERSION" >> "$ENV_FILE"
        echo -e "${SUCCESS} ${GREEN}Added VERSION to existing .env file${NC}"
    fi
else
    # Erstelle neue .env Datei
    cat > "$ENV_FILE" << EOF
# MthBdeIotClient Environment Variables
NODE_ENV=production
VERSION=$NEW_VERSION
ELECTRON_BUILDER_ALLOW_UNRESOLVED_DEPENDENCIES=true
EOF
    echo -e "${SUCCESS} ${GREEN}Created new .env file with VERSION=$NEW_VERSION${NC}"
fi

# 3. Zusätzliche Dateien aktualisieren (falls vorhanden)
if [ -f "$APP_DIR/release/app/package.json" ]; then
    echo -e "${GEAR} ${BLUE}Updating release/app/package.json...${NC}"
    node -e "
    const fs = require('fs');
    const path = '$APP_DIR/release/app/package.json';
    if (fs.existsSync(path)) {
        const packageJson = JSON.parse(fs.readFileSync(path, 'utf8'));
        packageJson.version = '$NEW_VERSION';
        fs.writeFileSync(path, JSON.stringify(packageJson, null, 2) + '\n');
        console.log('✅ Updated release/app/package.json version to $NEW_VERSION');
    }
    "
fi

# 4. Git Changes committen
echo -e "${GEAR} ${BLUE}Committing changes...${NC}"
git add "$PACKAGE_JSON" "$ENV_FILE"
if [ -f "$APP_DIR/release/app/package.json" ]; then
    git add "$APP_DIR/release/app/package.json"
fi

COMMIT_MESSAGE="Release $NEW_VERSION

- Updated package.json version to $NEW_VERSION
- Updated .env file with new version
- Prepared for release build

[skip ci]"

git commit -m "$COMMIT_MESSAGE"
echo -e "${SUCCESS} ${GREEN}Committed changes${NC}"

# 5. Git Tag erstellen
echo -e "${GEAR} ${BLUE}Creating Git tag...${NC}"
TAG_MESSAGE="Release $NEW_VERSION

MthBdeIotClient Raspberry Pi Release v$NEW_VERSION

Features:
- Electron App für Raspberry Pi 3+ (ARMv7l)
- Debian Package (.deb) für einfache Installation
- Automatische Pipeline mit Azure DevOps
- GitHub Release Integration

Installation:
wget https://raw.githubusercontent.com/mth-it-service/MTHBDEIOTClient/master/releases/latest/mthbdeiotclient_${NEW_VERSION}_armhf.deb
sudo dpkg -i mthbdeiotclient_${NEW_VERSION}_armhf.deb
sudo apt-get install -f
"

git tag -a "$NEW_TAG" -m "$TAG_MESSAGE"
echo -e "${SUCCESS} ${GREEN}Created tag $NEW_TAG${NC}"

# 6. Push zu origin (Commit und Tag zusammen)
echo -e "${GEAR} ${BLUE}Pushing changes and tag to origin...${NC}"
git push origin HEAD "$NEW_TAG"
echo -e "${SUCCESS} ${GREEN}Pushed changes and tag to origin (triggers pipeline)${NC}"

# 7. Zusammenfassung
echo ""
echo -e "${CYAN}=========================================="
echo -e "${SUCCESS} VERSION RELEASE COMPLETED"
echo -e "=========================================${NC}"
echo ""
echo -e "${INFO} ${GREEN}Summary:${NC}"
echo -e "  • Version: ${PURPLE}$NEW_VERSION${NC}"
echo -e "  • Tag: ${PURPLE}$NEW_TAG${NC}"
echo -e "  • Commit: $(git rev-parse --short HEAD)"
echo -e "  • Branch: $(git branch --show-current)"
echo ""
echo -e "${ROCKET} ${GREEN}Next steps:${NC}"
echo "  1. Azure DevOps Pipeline is starting automatically"
echo "  2. .deb package will be built for Raspberry Pi"
echo "  3. GitHub releases/ folder will be updated automatically"
echo "  4. Package will be available as 'latest' release"
echo ""
echo -e "${INFO} ${BLUE}Useful links:${NC}"
echo "  • Azure DevOps: https://dev.azure.com/mth-it-service/MthBdeIotClient/_build"
echo "  • GitHub Repository: https://github.com/MTHBDEIOTClient/MTHBDEIOTClient"
echo "  • Latest Release: https://github.com/MTHBDEIOTClient/MTHBDEIOTClient/tree/master/releases/latest"
echo "  • Install on Raspberry Pi: https://raw.githubusercontent.com/MTHBDEIOTClient/MTHBDEIOTClient/master/releases/latest/mthbdeiotclient_${NEW_VERSION}_armhf.deb"
echo ""
echo -e "${SUCCESS} ${GREEN}Version $NEW_VERSION released successfully!${NC}"
