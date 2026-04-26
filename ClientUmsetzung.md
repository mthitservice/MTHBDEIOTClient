#BDE Clienterstellung

Ich habe im BDE Portalprojekt Schnitstellen und eine Beschreibung geschaffen damit du den Client anbinden kannst. Aktuell hat der Client den Teststatus ob mann mit einem BArcodescanner alles auswählen kann. Das hat funktioniert.

Erstelle jetzt den den neuen BDE CLient(Elektron App) produktiv.

Nutze den alten Client und die aktuelle Teststellung . Um zu wissen was der Drucker alles auswählen muss oder kann.
Den alten BDE Client findest du hier.
C:\Users\Michael.Lindner\source\repos\MTHBDEClientApp
es ist eine Universal Windows App.


Nutze das neue Portal für die Datenanbindung. Es kann sein das das neue Portal dann noch mal ein Update in der APIU brauch. Das musst du ermitteln. Das Neue Portal bzw die Beschreibung findest du hier. 
C:\Users\Michael.Lindner\source\repos\MTHBdeIotDS\BDECLient\IOT-CLIENT.md

Wenn die neue Client App erst mal so funktioniert wie die alte wäre das gut. So müssen sich die Drucker oder Weiterverarbeiter an nichts neues gewöhnen.

## Umsetzungsstand (April 2026)

### Bereits im Client umgesetzt

- Portal-API-Bridge im Electron Main-Prozess eingebaut (Basis: `/api/BDEClient`)
	- `GET /bootstrap`
	- `POST /register`
	- `POST /heartbeat`
	- `GET /{clientIdentifier}/workload`
	- `POST /{clientIdentifier}/acknowledge-command`
- TLS-Zertifikatsunterstützung für Portal-HTTPS vorbereitet
	- unterstützt `PORTAL_CA_CERT_PATH`
	- sucht zusätzlich nach lokalen Zertifikatspfaden im Projekt
- Konfigurationsseite erweitert
	- Portal URL
	- Client Identifier
	- Client Modus (`druckmaschine`, `weiterverarbeitung`, `infomonitor`)
	- optionale Maschinenzuordnung (`assignedDeviceId`)
	- Registrierung im Portal beim Speichern
- Auftragsansicht lädt Workload aus der Portal-API
	- Fallback auf lokale Testdaten, falls Portal nicht erreichbar
- **Raspberry-Startskript stabilisiert** für produktiven Kiosk-Betrieb
	- entfernt sudo-abhängige Schritte im Laufbetrieb
	- systemd-Unit auf `KIOSK_MODE=true` und `RASPBERRY_PI=true` gesetzt
- **Drei Darstellungsmodi implementiert**:
	- **Druckmaschine**: Auftragsübersicht mit Barcode-Scanning
	- **Weiterverarbeitung**: Auftragsübersicht (ähnlich Druckmaschine)
	- **Infomonitor**: Info-Terminal mit dynamischem Text/Bild-Layout
		- Nur Text → vollständige Textanzeige (volle Breite)
		- Text + Bild → Zweieinhalb-Layout (Links: Text, Rechts: Bild)
		- Nur Bild → Vollbild
		- Automatische Rotation alle 15 Sekunden
		- Manuelle Navigation mit Vor/Zurück-Buttons

### Offene Portal- und Infrastrukturpunkte

- Portal-API auf Produktionsserver veröffentlichen (Backend-Stand mit BDEClient-Endpunkten)
- Zertifikatsdatei für `bdeds.druckerei-schuetz.local` in den Client-Build übernehmen
- DNS/VPN-Routing im Druckereinetz prüfen:
	- primär `10.0.1.0/24` (BDEIOT-Netz)
	- Fallback `192.168.1.0/24`
- Device-Zuordnungen im Portal für alle realen Clients pflegen
- **Infomonitor-API-Felder prüfen**: Die Portal-API sollte folgende Felder in der Workload für Infomonitor-Inhalte enthalten:
	- `Objekt` oder `title`: Titel/Überschrift
	- `Beschreibung` oder `description`: Textinhalt (wird vollständig angezeigt)
	- `Bild` oder `imageUrl`: URL zum Bild (optional)
	- Falls `clientMode === 'infomonitor'`: Objekte sollten als Inhalts-Items behandelt werden (nicht als Aufträge)

### Rollout-Checkliste Raspberry (Kiosk)

1. Portal-API produktiv deployen und via VPN testen.
2. Client-Paket (`.deb`) installieren.
3. Erstkonfiguration am Gerät scannen/eintragen:
	 - Gerätename
	 - Portal URL
	 - Client Identifier
	 - Modus
	 - optional Maschinen-ID
4. Nach Neustart prüfen:
	 - Kiosk startet automatisch
	 - Workload wird aus Portal geladen
	 - Heartbeat aktualisiert `lastSeenUtc`
5. Remote-Kommando im Portal testen (`restart` oder `reconfigure-network`).
