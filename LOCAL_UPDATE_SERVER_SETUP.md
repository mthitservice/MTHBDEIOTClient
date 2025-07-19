# Lokaler Update-Server Setup

## Übersicht

Das MTH BDE IoT Client Update-System verwendet ein intelligentes Fallback-System:

1. **Primär**: Internet-Updates von GitHub
2. **Fallback**: Lokaler Update-Server unter `http://<ipv4Address>/update`

## Server-Setup

### 1. Verzeichnisstruktur

```text
/var/www/html/update/
├── version.json          # Versions-Metadaten
├── mthbdeiotclient_*.deb # DEB-Pakete für ARM/Linux
├── MTH-BDE-IOT-Client-*.exe # Windows-Installer (optional)
└── MTH-BDE-IOT-Client-*.dmg # macOS-Installer (optional)
```

### 2. version.json Format

```json
{
  "version": "1.0.108",
  "filename": "mthbdeiotclient_1.0.108_arm64.deb",
  "releaseNotes": "Bugfixes und Performance-Verbesserungen",
  "publishedAt": "2025-07-19T20:00:00Z",
  "checksum": "sha256:abcd1234...",
  "platform": {
    "linux": "mthbdeiotclient_1.0.108_arm64.deb",
    "win32": "MTH-BDE-IOT-Client-Setup-1.0.108.exe",
    "darwin": "MTH-BDE-IOT-Client-1.0.108.dmg"
  }
}
```

### 3. Apache/Nginx Konfiguration

#### Apache

```apache
<VirtualHost *:80>
    DocumentRoot /var/www/html
    
    <Directory "/var/www/html/update">
        Options Indexes
        AllowOverride None
        Require all granted
        
        # CORS für Cross-Origin Requests
        Header always set Access-Control-Allow-Origin "*"
        Header always set Access-Control-Allow-Methods "GET, OPTIONS"
        Header always set Access-Control-Allow-Headers "Content-Type"
    </Directory>
</VirtualHost>
```

#### Nginx

```nginx
server {
    listen 80;
    root /var/www/html;
    
    location /update/ {
        autoindex on;
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods 'GET, OPTIONS';
        add_header Access-Control-Allow-Headers 'Content-Type';
    }
}
```

## Update-Logik

### Client-Verhalten

1. **Internet Check**: Versucht GitHub API (5s Timeout)
2. **Fallback**: Lokaler Server `http://<IP>/update/version.json` (3s Timeout)
3. **Fehler**: Zeigt "Kein Update verfügbar" wenn beide fehlschlagen

### IPv4-Adresse Konfiguration

Die IP-Adresse wird aus der globalen Konfiguration gelesen:

```sql
-- In der SQLite-Datenbank
INSERT INTO config (key, value) VALUES ('ipv4Address', '192.168.1.100');
```

## Installation Script

### update-server-setup.sh

```bash
#!/bin/bash

# Lokaler Update-Server Setup für MTH BDE IoT Client
echo "🔄 Setting up local update server..."

# Erstelle Update-Verzeichnis
sudo mkdir -p /var/www/html/update
sudo chown www-data:www-data /var/www/html/update

# Installiere Apache/Nginx falls nicht vorhanden
if ! command -v apache2 &> /dev/null; then
    echo "Installing Apache..."
    sudo apt update
    sudo apt install -y apache2
    sudo a2enmod headers
    sudo systemctl restart apache2
fi

# Erstelle Standard version.json
cat > /var/www/html/update/version.json << EOF
{
  "version": "1.0.107",
  "filename": "mthbdeiotclient_1.0.107_arm64.deb",
  "releaseNotes": "Initial local server setup",
  "publishedAt": "$(date -Iseconds)",
  "platform": {
    "linux": "mthbdeiotclient_1.0.107_arm64.deb"
  }
}
EOF

sudo chown www-data:www-data /var/www/html/update/version.json

echo "✅ Update server setup complete!"
echo "📁 Upload updates to: /var/www/html/update/"
echo "🌐 Access via: http://$(hostname -I | awk '{print $1}')/update/"
```

## Deployment-Workflow

### 1. Automatisches Deployment

```bash
# Script zum Hochladen neuer Versionen
#!/bin/bash
VERSION=$1
DEB_FILE=$2

if [ -z "$VERSION" ] || [ -z "$DEB_FILE" ]; then
    echo "Usage: $0 <version> <deb-file>"
    exit 1
fi

# Upload DEB-Datei
sudo cp "$DEB_FILE" /var/www/html/update/

# Update version.json
cat > /tmp/version.json << EOF
{
  "version": "$VERSION",
  "filename": "$(basename $DEB_FILE)",
  "releaseNotes": "Update auf Version $VERSION",
  "publishedAt": "$(date -Iseconds)",
  "platform": {
    "linux": "$(basename $DEB_FILE)"
  }
}
EOF

sudo mv /tmp/version.json /var/www/html/update/version.json
sudo chown www-data:www-data /var/www/html/update/*

echo "✅ Version $VERSION deployed to local update server"
```

### 2. Manuelles Deployment

1. DEB-Datei nach `/var/www/html/update/` kopieren
2. `version.json` mit neuer Version aktualisieren
3. Berechtigungen setzen: `sudo chown www-data:www-data /var/www/html/update/*`

## Testing

### Update-Check testen

```bash
# Von einem Client aus:
curl http://192.168.1.100/update/version.json

# Erwartete Antwort:
{
  "version": "1.0.108",
  "filename": "mthbdeiotclient_1.0.108_arm64.deb",
  ...
}
```

### Client-Logs überprüfen

Die MTH BDE IoT Client Anwendung zeigt im Terminal:

```text
✅ Internet update check successful: { source: 'internet', ... }
# oder
❌ Internet update failed, trying local server...
✅ Local server update check successful: { source: 'local', ... }
```

## Sicherheit

### 1. Checksums

- Immer SHA256-Checksums in `version.json` angeben
- Client sollte Downloads validieren

### 2. HTTPS (empfohlen)

```bash
# SSL-Zertifikat für lokalen Server
sudo apt install certbot
sudo certbot --apache -d update.local
```

### 3. IP-Beschränkungen

```apache
<Directory "/var/www/html/update">
    # Nur lokales Netzwerk
    Require ip 192.168.1.0/24
    Require ip 10.0.0.0/8
</Directory>
```

## Monitoring

### 1. Access-Logs überwachen

```bash
# Apache
sudo tail -f /var/log/apache2/access.log | grep update

# Nginx  
sudo tail -f /var/log/nginx/access.log | grep update
```

### 2. Update-Statistiken

```bash
# Anzahl Update-Checks pro Tag
sudo grep "$(date +%Y-%m-%d)" /var/log/apache2/access.log | grep "version.json" | wc -l
```
