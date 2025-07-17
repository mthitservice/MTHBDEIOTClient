# MTH BDE IoT Client - Raspberry Pi Installation

## 🚀 Ein-Kommando-Installation (Empfohlen)

```bash
wget -O /tmp/install-latest.sh https://github.com/mthitservice/MTHBDEIOTClient/raw/main/install-latest.sh && chmod +x /tmp/install-latest.sh && /tmp/install-latest.sh
```

Das automatische Installations-Script:
- ✅ Erkennt den korrekten DEB-Dateinamen automatisch
- ✅ Überprüft Systemvoraussetzungen (Raspberry Pi + ARMv7l)
- ✅ Lädt die neueste Version herunter
- ✅ Verifiziert SHA256-Prüfsummen
- ✅ Entfernt alte Versionen
- ✅ Installiert alle Abhängigkeiten
- ✅ Bereinigt temporäre Dateien

## 📦 Manuelle Installation

### Schritt 1: Verfügbare Dateien anzeigen
```bash
wget -q https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/SHA256SUMS -O - | grep '.deb'
```

### Schritt 2: Download und Installation
```bash
# Ersetze [FILENAME] mit dem korrekten Dateinamen aus Schritt 1
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/[FILENAME]
sudo dpkg -i [FILENAME]
sudo apt-get install -f
```

### Beispiel für typische Dateinamen:
```bash
# Raspberry Pi 3+ (ARMv7l) - Mögliche Dateinamen:
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/mthbdeiotclient_1.0.45_armv7l.deb
# ODER
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/mthbdeiotclient_1.0.45_armhf.deb

# Installation
sudo dpkg -i mthbdeiotclient_*.deb
sudo apt-get install -f
```

## 📋 Systemvoraussetzungen

- ✅ **Raspberry Pi 3, 3+, 4** oder **Zero 2 W**
- ✅ **Raspberry Pi OS (32-bit)** mit ARMv7l Architektur
- ✅ **Desktop-Umgebung** (X11/Wayland)
- ✅ **Mindestens 1GB RAM** verfügbar
- ✅ **Internetverbindung** für Download und Updates

## 🚀 Anwendung starten

```bash
# Kommandozeile
mthbdeiotclient

# Hintergrund-Prozess
nohup mthbdeiotclient &

# Desktop-Anwendung
# Im Anwendungsmenü unter "Development" oder "Office"
```

## 🔧 Problemlösung

### Problem: "Datei nicht gefunden"
```bash
# Prüfe verfügbare Dateien
curl -s https://api.github.com/repos/mthitservice/MTHBDEIOTClient/contents/releases/latest | grep '"name"' | grep '.deb'

# Oder direkt SHA256SUMS prüfen
wget -q https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/SHA256SUMS -O - | grep '.deb'
```

### Problem: Installation schlägt fehl
```bash
# Abhängigkeiten reparieren
sudo apt-get update
sudo apt-get install -f

# Fehlende Bibliotheken nachinstallieren
sudo apt-get install -y libgtk-3-0 libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 libasound2 libpangocairo-1.0-0 libatk1.0-0 libcairo-gobject2 libgtk-3-0 libgdk-pixbuf2.0-0 libxss1 libgconf-2-4
```

### Problem: Anwendung startet nicht
```bash
# Display-Variable setzen
export DISPLAY=:0

# Berechtigungen prüfen
sudo chmod +x /usr/bin/mthbdeiotclient

# Logs anzeigen
journalctl -u mthbdeiotclient
```

### Vollständige Deinstallation
```bash
sudo dpkg -r mthbdeiotclient
sudo apt-get autoremove
```

## 🔄 AutoUpdater

Die Anwendung verfügt über einen integrierten AutoUpdater:
- ✅ Automatische Update-Prüfung beim Start
- ✅ GitHub-basierte Release-Erkennung
- ✅ Sichere SHA512-Verifikation
- ✅ Ein-Klick-Installation neuer Versionen

## 🔗 Links

- 📦 **GitHub Releases**: https://github.com/mthitservice/MTHBDEIOTClient/releases
- 📁 **Release Files**: https://github.com/mthitservice/MTHBDEIOTClient/tree/main/releases
- 📄 **SHA256SUMS**: https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/SHA256SUMS
- 🤖 **Auto-Installer**: https://github.com/mthitservice/MTHBDEIOTClient/raw/main/install-latest.sh
- 🐛 **Issues**: https://github.com/mthitservice/MTHBDEIOTClient/issues
- 📖 **Documentation**: https://github.com/mthitservice/MTHBDEIOTClient/blob/main/README.md

## 💡 Tipps

1. **Aktualisierung prüfen**:
   ```bash
   dpkg -l | grep mthbdeiotclient
   ```

2. **Neueste Version installieren**:
   ```bash
   /tmp/install-latest.sh  # Falls bereits heruntergeladen
   ```

3. **Architektur prüfen**:
   ```bash
   uname -m  # Sollte "armv7l" anzeigen
   ```

4. **Speicherplatz prüfen**:
   ```bash
   df -h  # Mindestens 500MB frei
   ```

---

**🎉 Viel Erfolg mit MTH BDE IoT Client auf Ihrem Raspberry Pi!**

*Erstellt mit ❤️ für die Raspberry Pi Community*
