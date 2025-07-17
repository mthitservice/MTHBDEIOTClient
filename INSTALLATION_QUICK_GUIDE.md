# MTH BDE IoT Client - Installation Quick Guide

## 🚀 Schnellste Installation (Empfohlen)

### Ein-Kommando-Installation:
```bash
wget -O /tmp/install-latest.sh https://github.com/mthitservice/MTHBDEIOTClient/raw/main/install-latest.sh && chmod +x /tmp/install-latest.sh && /tmp/install-latest.sh
```

**Das Script:**
- ✅ Erkennt automatisch die korrekte DEB-Datei
- ✅ Überprüft Systemvoraussetzungen
- ✅ Verifikation der Prüfsummen
- ✅ Installiert alle Abhängigkeiten
- ✅ Bereinigt temporäre Dateien

## 🔧 Manuelle Installation

### 1. Prüfe verfügbare Dateien:
```bash
# Zeige alle verfügbaren DEB-Dateien
wget -q https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/SHA256SUMS -O - | grep '.deb'
```

### 2. Download und Installation:
```bash
# Ersetze [FILENAME] mit dem korrekten Dateinamen aus Schritt 1
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/[FILENAME]
sudo dpkg -i [FILENAME]
sudo apt-get install -f
```

### 3. Beispiel für typische Dateinamen:
```bash
# Für Raspberry Pi 3+ (ARMv7l):
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/mthbdeiotclient_1.0.45_armv7l.deb
# ODER
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/mthbdeiotclient_1.0.45_armhf.deb
```

## 📋 Systemvoraussetzungen

- ✅ **Raspberry Pi 3, 3+, 4** oder **Zero 2 W**
- ✅ **Raspberry Pi OS (32-bit)** - ARMv7l Architektur
- ✅ **Desktop-Umgebung** (X11) installiert
- ✅ **Mindestens 1GB RAM** verfügbar
- ✅ **Internetverbindung** für Download

## 🚀 Anwendung starten

```bash
# Kommandozeile
mthbdeiotclient

# Hintergrund
nohup mthbdeiotclient &

# Desktop
# Anwendungsmenü > Development oder Office > MTH BDE IoT Client
```

## 🔍 Problemlösung

### Datei nicht gefunden:
```bash
# Prüfe verfügbare Dateien
curl -s https://api.github.com/repos/mthitservice/MTHBDEIOTClient/contents/releases/latest | grep '"name"' | grep '.deb'
```

### Installation reparieren:
```bash
sudo apt-get update
sudo apt-get install -f
```

### Abhängigkeiten nachinstallieren:
```bash
sudo apt-get install -y libgtk-3-0 libx11-xcb1 libxcomposite1 libxdamage1 libxrandr2 libasound2 libpangocairo-1.0-0 libatk1.0-0 libcairo-gobject2 libgtk-3-0 libgdk-pixbuf2.0-0 libxss1 libgconf-2-4 libxcomposite1 libxdamage1 libxrandr2 libgtk-3-0 libxss1 libasound2
```

### Deinstallation:
```bash
sudo dpkg -r mthbdeiotclient
```

## 🔗 Nützliche Links

- 📦 **Releases**: https://github.com/mthitservice/MTHBDEIOTClient/releases
- 📁 **Release Files**: https://github.com/mthitservice/MTHBDEIOTClient/tree/main/releases
- 🐛 **Issues**: https://github.com/mthitservice/MTHBDEIOTClient/issues
- 📖 **Documentation**: https://github.com/mthitservice/MTHBDEIOTClient/blob/main/README.md

## 💡 Tipps

1. **Immer neueste Version verwenden**:
   ```bash
   # Prüfe aktuelle Version
   dpkg -l | grep mthbdeiotclient
   ```

2. **Logs bei Problemen anzeigen**:
   ```bash
   journalctl -u mthbdeiotclient
   ```

3. **Automatisches Update prüfen**:
   ```bash
   # Die App hat einen integrierten AutoUpdater
   # Wird automatisch beim Start geprüft
   ```

---

**🎉 Viel Erfolg mit MTH BDE IoT Client!**
