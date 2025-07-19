#!/bin/bash
# MthBdeIotClient - Automatisches Installations-Script für Raspberry Pi
# Korrigierte GitHub-URLs und Dateinamen-Erkennung

set -e

# Variablen
GITHUB_REPO="mthitservice/MTHBDEIOTClient"
GITHUB_RAW_URL="https://github.com/$GITHUB_REPO/raw/main"
RELEASES_URL="$GITHUB_RAW_URL/releases/latest"
TEMP_DIR="/tmp/mthbdeiotclient-install"
LOG_FILE="/tmp/mthbdeiotclient-install.log"

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging-Funktion
log() {
    echo -e "${2:-$BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}" | tee -a "$LOG_FILE"
}

log_error() {
    log "ERROR: $1" "$RED"
}

log_success() {
    log "SUCCESS: $1" "$GREEN"
}

log_warning() {
    log "WARNING: $1" "$YELLOW"
}

log_info() {
    log "INFO: $1" "$BLUE"
}

# Cleanup-Funktion
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        log_info "Cleanup completed"
    fi
}

# Trap für Cleanup bei Exit
trap cleanup EXIT

# Titel
echo "=========================================="
echo "🍓 MthBdeIotClient - Raspberry Pi Installer"
echo "=========================================="
echo ""

# System-Checks
log_info "Starting system checks..."

# Prüfe Architektur
ARCH=$(uname -m)
if [[ "$ARCH" != "armv7l" && "$ARCH" != "aarch64" ]]; then
    log_error "Unsupported architecture: $ARCH"
    log_error "This package is designed for Raspberry Pi (armv7l/aarch64)"
    exit 1
fi
log_success "Architecture check passed: $ARCH"

# Prüfe Raspberry Pi OS
if ! grep -q "Raspberry Pi" /proc/device-tree/model 2>/dev/null; then
    log_warning "Not running on Raspberry Pi hardware"
    log_warning "Continuing anyway..."
fi

# Prüfe Root-Berechtigungen
if [[ $EUID -eq 0 ]]; then
    log_error "Please do not run this script as root"
    log_error "The script will ask for sudo when needed"
    exit 1
fi

# Prüfe sudo
if ! sudo -n true 2>/dev/null; then
    log_info "Testing sudo access..."
    if ! sudo true; then
        log_error "Sudo access required for package installation"
        exit 1
    fi
fi
log_success "Sudo access confirmed"

# Prüfe Internet-Verbindung
log_info "Testing internet connection..."
if ! ping -c 1 github.com >/dev/null 2>&1; then
    log_error "No internet connection to github.com"
    exit 1
fi
log_success "Internet connection confirmed"

# Erstelle Temp-Verzeichnis
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Lade verfügbare DEB-Dateien
log_info "Fetching available DEB files from GitHub..."

# Verschiedene mögliche Dateinamen-Muster
POSSIBLE_PATTERNS=(
    "mthbdeiotclient_*_armv7l.deb"
    "mthbdeiotclient_*_armhf.deb"
    "MthBdeIotClient_*_armv7l.deb"
    "MthBdeIotClient_*_armhf.deb"
    "mthbdeiotclient-*-armv7l.deb"
    "mthbdeiotclient*.deb"
)

# Versuche DEB-Dateiname zu ermitteln
DEB_FILENAME=""
for pattern in "${POSSIBLE_PATTERNS[@]}"; do
    # Teste GitHub API für verfügbare Dateien
    if command -v curl >/dev/null 2>&1; then
        # Verwende curl für API-Aufruf
        response=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/contents/releases/latest" 2>/dev/null || echo "")
        if [[ -n "$response" ]]; then
            # Extrahiere DEB-Dateinamen aus JSON
            potential_file=$(echo "$response" | grep -o '"name":"[^"]*\.deb"' | head -1 | sed 's/"name":"//;s/"//')
            if [[ -n "$potential_file" ]]; then
                DEB_FILENAME="$potential_file"
                log_success "Found DEB file via API: $DEB_FILENAME"
                break
            fi
        fi
    fi
done

# Fallback: Verwende neueste bekannte Namenskonvention
if [[ -z "$DEB_FILENAME" ]]; then
    # Versuche die neueste Version zu erraten
    DEB_FILENAME="mthbdeiotclient_1.0.52_armv7l.deb"
    log_warning "Could not detect exact filename, using fallback: $DEB_FILENAME"
fi

# Download URL
DOWNLOAD_URL="$RELEASES_URL/$DEB_FILENAME"
log_info "Download URL: $DOWNLOAD_URL"

# Download DEB-Datei
log_info "Downloading DEB package..."
if command -v wget >/dev/null 2>&1; then
    if ! wget -q --show-progress "$DOWNLOAD_URL" -O "$DEB_FILENAME"; then
        log_error "Download failed with wget"
        exit 1
    fi
elif command -v curl >/dev/null 2>&1; then
    if ! curl -L -o "$DEB_FILENAME" "$DOWNLOAD_URL"; then
        log_error "Download failed with curl"
        exit 1
    fi
else
    log_error "Neither wget nor curl available"
    exit 1
fi

# Prüfe Download
if [[ ! -f "$DEB_FILENAME" ]]; then
    log_error "Download failed - file not found: $DEB_FILENAME"
    exit 1
fi

FILE_SIZE=$(stat -c%s "$DEB_FILENAME")
if [[ $FILE_SIZE -lt 10000000 ]]; then  # < 10MB
    log_error "Downloaded file is too small ($FILE_SIZE bytes)"
    log_error "This might be an error page instead of the actual package"
    exit 1
fi

log_success "Download completed ($(echo "scale=2; $FILE_SIZE/1024/1024" | bc) MB)"

# Prüfe DEB-Paket
log_info "Validating DEB package..."
if ! dpkg-deb --info "$DEB_FILENAME" >/dev/null 2>&1; then
    log_error "Downloaded file is not a valid DEB package"
    exit 1
fi
log_success "DEB package validation passed"

# Zeige Paket-Informationen
log_info "Package information:"
dpkg-deb --info "$DEB_FILENAME" | grep -E "(Package|Version|Architecture|Description)" | sed 's/^/  /'

# Prüfe ob bereits installiert
if dpkg -l mthbdeiotclient 2>/dev/null | grep -q "^ii"; then
    INSTALLED_VERSION=$(dpkg -l mthbdeiotclient | grep "^ii" | awk '{print $3}')
    PACKAGE_VERSION=$(dpkg-deb --info "$DEB_FILENAME" | grep "Version:" | awk '{print $2}')
    
    log_info "Currently installed version: $INSTALLED_VERSION"
    log_info "Package version: $PACKAGE_VERSION"
    
    if [[ "$INSTALLED_VERSION" == "$PACKAGE_VERSION" ]]; then
        log_info "Same version already installed"
        read -p "Reinstall anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled by user"
            exit 0
        fi
    fi
fi

# Installation
log_info "Installing DEB package..."
if ! sudo dpkg -i "$DEB_FILENAME"; then
    log_warning "dpkg installation had issues, trying to fix dependencies..."
    
    # Versuche Abhängigkeiten zu reparieren
    log_info "Updating package lists..."
    sudo apt-get update
    
    log_info "Fixing broken dependencies..."
    if ! sudo apt-get install -f -y; then
        log_error "Failed to fix dependencies"
        exit 1
    fi
    
    log_info "Retrying installation..."
    if ! sudo dpkg -i "$DEB_FILENAME"; then
        log_error "Installation failed even after fixing dependencies"
        exit 1
    fi
fi

log_success "Package installed successfully"

# Prüfe Installation
log_info "Verifying installation..."
if ! dpkg -l mthbdeiotclient 2>/dev/null | grep -q "^ii"; then
    log_error "Package not properly installed"
    exit 1
fi

# Prüfe Executable
if [[ ! -x "/usr/bin/mthbdeiotclient" ]]; then
    log_warning "Executable not found or not executable"
    log_info "Checking alternative locations..."
    
    # Suche nach möglichen Pfaden
    POSSIBLE_PATHS=(
        "/opt/MthBdeIotClient/mthbdeiotclient"
        "/usr/local/bin/mthbdeiotclient"
        "/opt/mthbdeiotclient/mthbdeiotclient"
    )
    
    FOUND_EXECUTABLE=""
    for path in "${POSSIBLE_PATHS[@]}"; do
        if [[ -x "$path" ]]; then
            FOUND_EXECUTABLE="$path"
            break
        fi
    done
    
    if [[ -n "$FOUND_EXECUTABLE" ]]; then
        log_info "Found executable at: $FOUND_EXECUTABLE"
        log_info "Creating symlink..."
        sudo ln -sf "$FOUND_EXECUTABLE" "/usr/bin/mthbdeiotclient"
        sudo chmod +x "/usr/bin/mthbdeiotclient"
    else
        log_error "Could not find executable"
        log_error "Manual verification required"
    fi
fi

# Prüfe Desktop-Umgebung
if [[ -n "$DISPLAY" ]]; then
    log_success "Desktop environment detected"
else
    log_warning "No desktop environment detected"
    log_warning "Application requires X11 desktop environment"
fi

# Abschluss
echo ""
echo "=========================================="
echo "🎉 Installation completed successfully!"
echo "=========================================="
echo ""
echo "📋 Installation Details:"
echo "   Package: $(dpkg -l mthbdeiotclient | grep "^ii" | awk '{print $2" "$3}')"
echo "   Architecture: $(dpkg -l mthbdeiotclient | grep "^ii" | awk '{print $4}')"
echo "   Installed files: $(dpkg -L mthbdeiotclient | wc -l) files"
echo ""
echo "🚀 Start the application:"
echo "   Command: mthbdeiotclient"
echo "   Desktop: Look for 'MTH BDE IoT Client' in Applications menu"
echo ""
echo "🔧 Troubleshooting:"
echo "   Logs: $LOG_FILE"
echo "   Uninstall: sudo dpkg -r mthbdeiotclient"
echo "   Support: https://github.com/$GITHUB_REPO/issues"
echo ""
echo "✅ Installation log saved to: $LOG_FILE"
echo "=========================================="
