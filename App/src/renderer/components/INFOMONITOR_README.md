# Infomonitor-Modus: Integration und Verwendung

## Übersicht

Die Client-App unterstützt nun **drei aufgabenbezogene Darstellungsmodi**:

1. **Druckmaschine** - Auftragsbearbeitung für Druckmaschinen (bestehende MainPage)
2. **Weiterverarbeitung** - Auftragsbearbeitung für Weiterverarbeitung (bestehende MainPage)
3. **Infomonitor** - Info-Terminal mit automatischer Rotation und dynamischem Text/Bild-Layout

## Infomonitor-Modus Details

### Visuelle Layout-Modi

Der Infomonitor rendert Inhalte dynamisch basierend auf verfügbaren Daten:

```
┌─────────────────────────────────────────────────────────────┐
│ INFORMATIONEN Druckerei Schütz GmbH   │ 26.04.2026 | 14:32  │ 1/5
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  [NUR TEXT]                [TEXT + BILD]    [NUR BILD]      │
│  Volltext                  Text  │  Bild    Vollbild        │
│  zentriert                       │          schwarz BG       │
│  volle Breite                    │                          │
│                                                               │
├─────────────────────────────────────────────────────────────┤
│ ← Zurück    Automatische Rotation: 15s     Weiter →         │
└─────────────────────────────────────────────────────────────┘
```

### Features

✅ **Dynamisches Layout**
- Erkennt automatisch Kombination von Text und Bild
- Responsive Größenanpassung für alle Bildschirme

✅ **Automatische Rotation**
- Wechsel alle 15 Sekunden (konfigurierbar)
- Manuelle Navigation mit Vor/Zurück-Buttons
- Seitennummer-Anzeige (z.B. "1/5")

✅ **Vollständige Textanzeige**
- Keine Truncation von Texten
- Scrollbar bei langen Texten (Text+Bild-Modus)
- Große, gut lesbare Font (28-32px)

✅ **Kiosk-Ready**
- Vollbildmodus (100vh × 100vw)
- Responsive Design
- Integriert mit bestehenden Electron-Kiosk-Settings

## Konfiguration

### 1. Modus Einstellen

In der **Konfigurationsseite** (`/config`):

```
Modus: [Dropdown]
├─ Druckmaschine
├─ Weiterverarbeitung
└─ Infomonitor
```

Wähle **"Infomonitor"** und speichern. Die App startet neu und lädt InfomonitorDisplay.

### 2. Portal-API Anforderungen

Die Portal-API `/workload`-Endpunkt muss für Infomonitor-Clients folgende Struktur unterstützen:

```json
{
  "Orders": [
    {
      "id": "info-001",
      "Objekt": "Willkommen in der Druckerei",
      "Beschreibung": "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor...",
      "Bild": null
    },
    {
      "id": "info-002",
      "Objekt": "Unser Team",
      "Beschreibung": "Wir sind ein motiviertes Team von Druckfachleuten.",
      "Bild": "https://portal.example.com/images/team.jpg"
    },
    {
      "id": "info-003",
      "Objekt": "Öffnungszeiten",
      "Beschreibung": "Mo-Fr: 8:00 - 17:00\nSa: 9:00 - 13:00",
      "Bild": null
    }
  ]
}
```

### 3. Datenfeld-Mapping

| Portal-Feld | Infomonitor-Feld | Beispiel |
|-------------|------------------|----------|
| `Objekt` / `title` | `title` | "Willkommen" |
| `Beschreibung` / `description` | `body` | "Lorem ipsum..." |
| `Bild` / `imageUrl` | `imageUrl` | "https://..." |

## Verwendung in der App

### Komponenten-Struktur

```
App.tsx
├─ Router
│  └─ MainPageWithRouter.tsx (Route: /main)
│     └─ ModeRouter.tsx
│        ├─ Infomonitor-Modus → InfomonitorDisplay.tsx
│        └─ Andere Modi → MainPage.tsx
```

### Automatisches Laden

1. **App-Start**: `ModeRouter` lädt `clientMode` aus DB
2. **Infomonitor erkannt**: Lädt Inhalte von Portal-API (`/workload`)
3. **Auto-Refresh**: Aktualisiert Inhalte alle 5 Minuten
4. **Display**: `InfomonitorDisplay` startet mit automatischer Rotation

## Development / Testing

### Lokales Testen ohne Portal

Bearbeite `ModeRouter.tsx` für Mock-Daten:

```typescript
const mockContent: InfoContent[] = [
  {
    title: "Test 1",
    body: "Dies ist ein Test-Text ohne Bild.",
    imageUrl: undefined
  },
  {
    title: "Test 2",
    body: "Dies ist ein Test mit Bild.",
    imageUrl: "https://via.placeholder.com/800x600"
  }
];

// In der useEffect, wenn Portal-Fehler:
setInfomonitorContent(mockContent);
```

### CSS Anpassungen

Alle Styling-Optionen in `InfomonitorDisplay.css`:
- Farben: `#f09609` (Orange), `#222` (Dunkelgrau)
- Fonts: Bootstrap-Standard (System Font)
- Responsive Breakpoints: 1200px, 768px

### Konfigurierbare Werte

In `InfomonitorDisplay.tsx`:
```typescript
// Rotations-Intervall (ms)
<InfomonitorDisplay
  items={items}
  autoRotateInterval={15000}  // ← Änderbar
/>
```

## Deployment-Checkliste für Infomonitor

- [ ] Portal-API unterstützt `Bild`/`imageUrl` in `/workload` für Infomonitor-Clients
- [ ] Test-Inhalte im Portal hinterlegt (mindestens 3-5 Items)
- [ ] Client konfiguriert mit Modus = "Infomonitor"
- [ ] Bilder-URLs im Portal erreichbar (HTTPS)
- [ ] Auto-Rotation funktioniert (Inhalt wechselt alle 15s)
- [ ] Manuelle Navigation (Buttons) funktioniert offline
- [ ] Kiosk-Modus startet automatisch auf Raspberry Pi
- [ ] TLS-Zertifikat für Portal auf Raspberry vorhanden

## Troubleshooting

### Inhalte laden nicht
- Prüfe: Ist Portal erreichbar?
- Prüfe: `clientIdentifier` korrekt in DB?
- Prüfe: Portal-API antwortet mit `Orders`-Array?
- Fallback: "Keine Inhalte verfügbar" wird angezeigt

### Bilder laden nicht
- Prüfe: Image-URL HTTPS und gültig?
- Prüfe: CORS-Headers vom Portal?
- Fallback: Zeigt nur Text (falls vorhanden)

### Rotation stoppt
- Browser-Console auf Fehler prüfen
- Timer-Logik in `useEffect` validieren
- Stellt Timer-Intervall korrekt ein?

## Erweiterungen (optional)

- Touch-Gesten für Bild-Navigation (Swipe)
- QR-Code-Scanning für Inhalts-Auswahl
- Admin-Panel für Portal-Inhalts-Verwaltung
- Video-Unterstützung (statt nur Bilder)
- Zeitbasierte Inhalts-Playlisten

---

**Stand**: April 2026  
**Status**: ✅ Implementiert und getestet
