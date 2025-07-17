# MthBdeIotClient Raspberry Pi Releases

## Latest Release: v1.0.49

**Erstellt:** 17.07.2025 21:35  
**Build:** 20250717.46  
**Commit:** 3e412fb

### 📦 Download & Installation

#### Direkte Installation (Empfohlen):
```bash
# Eine Zeile Installation - Latest Release (prüfe korrekten Dateinamen)
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/mthbdeiotclient_1.0.49_armv7l.deb && sudo dpkg -i mthbdeiotclient_1.0.49_armv7l.deb && sudo apt-get install -f

# ODER - Automatische Erkennung des Dateinamens:
wget -O /tmp/install-latest.sh https://github.com/mthitservice/MTHBDEIOTClient/raw/main/install-latest.sh && chmod +x /tmp/install-latest.sh && /tmp/install-latest.sh
```

#### Manuelle Installation:
```bash
# 1. Download Latest Release (prüfe den korrekten Dateinamen auf GitHub)
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/mthbdeiotclient_1.0.49_armv7l.deb

# 2. Installation
sudo dpkg -i mthbdeiotclient_1.0.49_armv7l.deb

# 3. Abhängigkeiten installieren
sudo apt-get install -f

# 4. Anwendung starten
mthbdeiotclient
```

### 📋 Systemanforderungen
- ✅ Raspberry Pi 3, 3+, 4 oder Zero 2 W
- ✅ Raspberry Pi OS (32-bit, ARMv7l)
- ✅ Mindestens 1GB RAM
- ✅ Desktop-Umgebung (X11)

### 🔧 Troubleshooting
```bash
# Fehlende Abhängigkeiten
sudo apt-get update && sudo apt-get install -f

# Berechtigungsprobleme
sudo chmod +x /usr/bin/mthbdeiotclient

# Display-Probleme
export DISPLAY=:0 && mthbdeiotclient

# Deinstallation
sudo dpkg -r mthbdeiotclient
```

### 📖 Weitere Informationen
- [📋 Raspberry Pi Installation Guide](../App/RASPBERRY_INSTALLATION.md)
- [🚀 Deployment Guide](../DEPLOYMENT_GUIDE.md)
- [❓ Issues & Support](https://github.com/mthitservice/MTHBDEIOTClient/issues)

---
**🔧 Technische Details:**  
Architektur: ARMv7l | Package: DEB | Build System: Azure DevOps
