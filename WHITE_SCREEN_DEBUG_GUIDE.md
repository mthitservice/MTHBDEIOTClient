# White Screen Debug Guide - v1.0.97

## 🎯 Ziel
Diese Version v1.0.97 enthält erweiterte Debugging-Funktionen, um das White Screen Problem auf Raspberry Pi zu diagnostizieren und zu beheben.

## 🔧 Was wurde hinzugefügt?

### 1. Erweiterte Console-Logs
- **HTML-Pfad Validierung**: Überprüfung ob die index.html gefunden wird
- **WebContents Events**: Monitoring aller Ladephasen
- **ARM-spezifische Debugging**: Zusätzliche Logs nur für ARM-Systeme
- **URL-Auflösung**: Detaillierte Pfad-Informationen

### 2. Automatische DevTools (Development Mode)
- DevTools öffnen sich automatisch auf ARM-Systemen im Development Mode
- Ermöglicht direktes Debugging im Browser

### 3. Fallback-Strategie
- Automatischer Fallback bei HTML-Lade-Fehlern
- Alternative URL-Auflösung für ARM-Systeme

## 📋 Test-Anleitung

### Installation auf Raspberry Pi
```bash
# Download und Installation der neuen Version
wget https://github.com/yourusername/yourrepo/releases/download/v1.0.97/mthbdeiotclient_1.0.97_armhf.deb
sudo dpkg -i mthbdeiotclient_1.0.97_armhf.deb

# Bei Abhängigkeitsproblemen:
sudo apt-get install -f
```

### Debug-Modus starten
```bash
# Mit erweiterten Debug-Ausgaben
NODE_ENV=development mthbdeiotclient

# Oder mit Standard-Modus
mthbdeiotclient
```

## 🔍 Was zu beachten ist

### Console-Ausgaben analysieren
Achten Sie auf folgende Log-Meldungen:

1. **HTML-Pfad Validierung**:
   ```
   📁 Aufgelöster HTML-Pfad: file:///path/to/index.html
   ✅ HTML-Datei gefunden: 12345 bytes
   ```

2. **WebContents Events**:
   ```
   📄 Webinhalt hat angefangen zu laden...
   ✅ Webinhalt wurde vollständig geladen
   🎯 DOM ist bereit
   ```

3. **Fehler-Indikatoren**:
   ```
   ❌ Fehler beim Laden des Webinhalts: { errorCode, errorDescription }
   💥 Render-Prozess ist gestorben: details
   ```

### DevTools nutzen
- Wenn DevTools sich öffnen, überprüfen Sie die Console auf JavaScript-Fehler
- Prüfen Sie die Network-Tab auf fehlgeschlagene Ressourcen
- Kontrollieren Sie die Sources-Tab auf verfügbare Dateien

## 🐛 Häufige Probleme und Lösungen

### Problem: HTML-Datei nicht gefunden
**Symptom**: `❌ HTML-Datei nicht gefunden`
**Lösung**: Fallback-URL wird automatisch versucht

### Problem: Shared Memory Fehler
**Symptom**: Weiterhin Shared Memory Fehler in den Logs
**Status**: Diese Version enthält bereits Fixes (--disable-shared-memory, etc.)

### Problem: Render-Prozess stirbt
**Symptom**: `💥 Render-Prozess ist gestorben`
**Diagnose**: Prüfen Sie die Details in der Fehlermeldung

## 📊 Erwartete Verbesserungen

1. **Detaillierte Diagnose**: Genauere Fehlermeldungen zeigen die Ursache
2. **Automatische Fallbacks**: Robustere HTML-Ladung
3. **Bessere ARM-Unterstützung**: Spezifische Optimierungen für Raspberry Pi

## 🔄 Nach dem Test

### Erfolgreich (kein White Screen mehr):
- Notieren Sie sich die Console-Ausgaben
- Teilen Sie die erfolgreichen Log-Meldungen mit

### Weiterhin White Screen:
- Kopieren Sie die vollständigen Console-Ausgaben
- Besonders wichtig: Alle ❌ Fehler-Meldungen
- Screenshots der DevTools (falls verfügbar)

## 📞 Support-Informationen

Bei weiteren Problemen bitte folgende Informationen bereitstellen:
- Vollständige Console-Ausgaben
- Raspberry Pi Modell und OS-Version
- Verfügbarer RAM und Speicherplatz
- Screenshots der DevTools (falls verfügbar)

---

**Version**: 1.0.97  
**Datum**: $(Get-Date -Format "yyyy-MM-dd")  
**Zweck**: White Screen Debugging für ARM/Raspberry Pi Systeme
