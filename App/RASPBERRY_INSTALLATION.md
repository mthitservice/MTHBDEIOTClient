# Raspberry Pi 3+ Installation - MthBdeIotClient

## Übersicht

Diese Anleitung beschreibt die Installation der MthBdeIotClient Electron-Anwendung auf Raspberry Pi 3+ Geräten. Die Anwendung wird im Kiosk-Modus (Vollbild) gestartet und automatisch beim Boot geladen.

## Systemanforderungen

- Raspberry Pi 3+ (ARMv7l)
- Raspberry Pi OS (32-bit) - neueste Version
- Mindestens 1GB RAM (empfohlen: 2GB+)
- 8GB+ SD-Karte (empfohlen: 16GB+)
- Node.js 22.x oder höher
- NPM 9.x oder höher
- Netzwerkverbindung

---

## 1. Manuelle Installation

### 1.1 Raspberry Pi OS vorbereiten

```bash
# System aktualisieren
sudo apt update && sudo apt upgrade -y

# Desktop-Umgebung installieren (falls nicht vorhanden)
sudo apt install raspberrypi-ui-mods -y

# Erforderliche Pakete installieren
sudo apt install -y \
    chromium-browser \
    unclutter \
    xdotool \
    nodejs \
    npm \
    git \
    libasound2-dev \
    libgtk-3-dev \
    libgconf-2-4 \
    libnss3-dev \
    libxrandr2 \
    libasound2 \
    libpangocairo-1.0-0 \
    libatk1.0-0 \
    libcairo-gobject2 \
    libgtk-3-0 \
    libgdk-pixbuf2.0-0
```

### 1.2 Node.js Version aktualisieren

```bash
# Node.js 22 installieren (erforderlich für Electron 35+ und aktuelle Dependencies)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

# Version prüfen (sollte 22.x oder höher sein)
node --version
npm --version

# Überprüfung der Mindestanforderungen
echo "Node.js Version: $(node --version)"
echo "NPM Version: $(npm --version)"
if node -e "if (process.version.slice(1).split('.')[0] < 22) process.exit(1)"; then
  echo "✅ Node.js Version ist kompatibel"
else
  echo "❌ Node.js Version zu alt - mindestens 22.x erforderlich"
  exit 1
fi
```

### 1.3 Anwendung installieren

```bash
# Arbeitsverzeichnis erstellen
mkdir -p /home/pi/apps
cd /home/pi/apps

# Repository klonen
git clone [YOUR_REPOSITORY_URL] MthBdeIotClient
cd MthBdeIotClient/App

# Abhängigkeiten installieren
npm install --production

# Anwendung kompilieren
npm run build

# Desktop-Datei erstellen
sudo tee /usr/share/applications/mthbdeiotclient.desktop > /dev/null <<EOF
[Desktop Entry]
Name=MthBdeIotClient
Comment=Betriebsdatenerfassung
Exec=/home/pi/apps/MthBdeIotClient/App/node_modules/.bin/electron /home/pi/apps/MthBdeIotClient/App/dist/main/main.js --kiosk --disable-features=VizDisplayCompositor
Icon=/home/pi/apps/MthBdeIotClient/App/assets/icon.png
Type=Application
Terminal=false
Categories=Office;
StartupNotify=true
EOF
```

### 1.4 Autostart konfigurieren

```bash
# Autostart-Verzeichnis erstellen
mkdir -p /home/pi/.config/autostart

# Autostart-Datei erstellen
tee /home/pi/.config/autostart/mthbdeiotclient.desktop > /dev/null <<EOF
[Desktop Entry]
Name=MthBdeIotClient
Exec=/home/pi/apps/MthBdeIotClient/App/node_modules/.bin/electron /home/pi/apps/MthBdeIotClient/App/dist/main/main.js --kiosk --disable-features=VizDisplayCompositor
Type=Application
Terminal=false
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

# Bildschirmschoner deaktivieren
tee -a /home/pi/.config/autostart/disable-screensaver.desktop > /dev/null <<EOF
[Desktop Entry]
Type=Application
Exec=sh -c "xset s off; xset -dpms; xset s noblank"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Disable Screensaver
EOF
```

### 1.5 Netzwerk-Konfiguration

```bash
# Statische IP konfigurieren
sudo tee -a /etc/dhcpcd.conf > /dev/null <<EOF

# Statische IP-Konfiguration
interface eth0
static ip_address=10.10.0.100/24
static routers=10.10.0.1
static domain_name_servers=8.8.8.8 8.8.4.4

interface wlan0
static ip_address=10.10.0.100/24
static routers=10.10.0.1
static domain_name_servers=8.8.8.8 8.8.4.4
EOF

# SSH aktivieren
sudo systemctl enable ssh

# Neustart
sudo reboot
```

---

## 2. Automatisierte Installation mit Ansible

### 2.1 Ansible Setup (auf dem Control-Computer)

```bash
# Ansible installieren
pip install ansible

# Inventory-Struktur erstellen
mkdir -p raspberry-deployment/{inventory,playbooks,roles,group_vars}
cd raspberry-deployment
```

### 2.2 Inventory-Datei erstellen

```bash
# inventory/hosts.yml
tee inventory/hosts.yml > /dev/null <<EOF
---
all:
  children:
    raspberry_pis:
      hosts:
        pi-001:
          ansible_host: 192.168.1.100
          target_ip: 10.10.0.101
          hostname: mth-bde-001
        pi-002:
          ansible_host: 192.168.1.101
          target_ip: 10.10.0.102
          hostname: mth-bde-002
        pi-003:
          ansible_host: 192.168.1.102
          target_ip: 10.10.0.103
          hostname: mth-bde-003
        pi-004:
          ansible_host: 192.168.1.103
          target_ip: 10.10.0.104
          hostname: mth-bde-004
        pi-005:
          ansible_host: 192.168.1.104
          target_ip: 10.10.0.105
          hostname: mth-bde-005
      vars:
        ansible_user: pi
        ansible_ssh_pass: raspberry
        ansible_become: yes
        ansible_become_method: sudo
        ansible_become_pass: raspberry
        app_directory: /home/pi/apps/MthBdeIotClient
        repository_url: "https://github.com/[YOUR_USERNAME]/MthBdeIotClient.git"
        gateway_ip: 10.10.0.1
        dns_servers: "8.8.8.8 8.8.4.4"
EOF
```

### 2.3 Haupt-Playbook erstellen

```bash
# playbooks/deploy-mthbdeiotclient.yml
tee playbooks/deploy-mthbdeiotclient.yml > /dev/null <<EOF
---
- name: Deploy MthBdeIotClient to Raspberry Pi 3+
  hosts: raspberry_pis
  become: yes
  vars:
    node_version: "22"
    
  tasks:
    - name: Update system packages
      apt:
        update_cache: yes
        upgrade: yes
        cache_valid_time: 86400

    - name: Install required system packages
      apt:
        name:
          - curl
          - git
          - unclutter
          - xdotool
          - libasound2-dev
          - libgtk-3-dev
          - libgconf-2-4
          - libnss3-dev
          - libxrandr2
          - libasound2
          - libpangocairo-1.0-0
          - libatk1.0-0
          - libcairo-gobject2
          - libgtk-3-0
          - libgdk-pixbuf2.0-0
          - chromium-browser
          - raspberrypi-ui-mods
        state: present

    - name: Add NodeSource repository key
      apt_key:
        url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
        state: present

    - name: Add NodeSource repository
      apt_repository:
        repo: "deb https://deb.nodesource.com/node_{{ node_version }}.x {{ ansible_distribution_release }} main"
        state: present
        update_cache: yes

    - name: Install Node.js
      apt:
        name: nodejs
        state: present

    - name: Set hostname
      hostname:
        name: "{{ hostname }}"

    - name: Update /etc/hosts
      lineinfile:
        path: /etc/hosts
        regexp: '^127\.0\.1\.1'
        line: "127.0.1.1\t{{ hostname }}"

    - name: Create app directory
      file:
        path: "{{ app_directory }}"
        state: directory
        owner: pi
        group: pi
        mode: '0755'

    - name: Clone application repository
      git:
        repo: "{{ repository_url }}"
        dest: "{{ app_directory }}"
        force: yes
      become_user: pi

    - name: Install npm dependencies
      npm:
        path: "{{ app_directory }}/App"
        production: yes
      become_user: pi

    - name: Build application
      command: npm run build
      args:
        chdir: "{{ app_directory }}/App"
      become_user: pi

    - name: Configure static IP address
      blockinfile:
        path: /etc/dhcpcd.conf
        block: |
          
          # Static IP configuration for {{ inventory_hostname }}
          interface eth0
          static ip_address={{ target_ip }}/24
          static routers={{ gateway_ip }}
          static domain_name_servers={{ dns_servers }}
          
          interface wlan0
          static ip_address={{ target_ip }}/24
          static routers={{ gateway_ip }}
          static domain_name_servers={{ dns_servers }}
        marker: "# {mark} ANSIBLE MANAGED BLOCK - {{ inventory_hostname }}"

    - name: Create desktop application file
      copy:
        content: |
          [Desktop Entry]
          Name=MthBdeIotClient
          Comment=Betriebsdatenerfassung
          Exec={{ app_directory }}/App/node_modules/.bin/electron {{ app_directory }}/App/dist/main/main.js --kiosk --disable-features=VizDisplayCompositor
          Icon={{ app_directory }}/App/assets/icon.png
          Type=Application
          Terminal=false
          Categories=Office;
          StartupNotify=true
        dest: /usr/share/applications/mthbdeiotclient.desktop
        mode: '0644'

    - name: Create autostart directory
      file:
        path: /home/pi/.config/autostart
        state: directory
        owner: pi
        group: pi
        mode: '0755'

    - name: Create autostart file for application
      copy:
        content: |
          [Desktop Entry]
          Name=MthBdeIotClient
          Exec={{ app_directory }}/App/node_modules/.bin/electron {{ app_directory }}/App/dist/main/main.js --kiosk --disable-features=VizDisplayCompositor
          Type=Application
          Terminal=false
          Hidden=false
          NoDisplay=false
          X-GNOME-Autostart-enabled=true
        dest: /home/pi/.config/autostart/mthbdeiotclient.desktop
        owner: pi
        group: pi
        mode: '0644'

    - name: Disable screensaver autostart
      copy:
        content: |
          [Desktop Entry]
          Type=Application
          Exec=sh -c "xset s off; xset -dpms; xset s noblank"
          Hidden=false
          NoDisplay=false
          X-GNOME-Autostart-enabled=true
          Name=Disable Screensaver
        dest: /home/pi/.config/autostart/disable-screensaver.desktop
        owner: pi
        group: pi
        mode: '0644'

    - name: Enable SSH service
      systemd:
        name: ssh
        enabled: yes
        state: started

    - name: Configure boot to desktop
      lineinfile:
        path: /etc/systemd/system/getty@tty1.service.d/autologin.conf
        create: yes
        line: |
          [Service]
          ExecStart=
          ExecStart=-/sbin/agetty --autologin pi --noclear %I $TERM
        mode: '0644'

    - name: Create desktop autologin directory
      file:
        path: /etc/systemd/system/getty@tty1.service.d
        state: directory
        mode: '0755'

    - name: Set desktop environment to start on boot
      copy:
        content: |
          [Service]
          ExecStart=
          ExecStart=-/sbin/agetty --autologin pi --noclear %I $TERM
        dest: /etc/systemd/system/getty@tty1.service.d/autologin.conf
        mode: '0644'

    - name: Reboot the Raspberry Pi
      reboot:
        reboot_timeout: 300
      when: ansible_facts['os_family'] == "Debian"
EOF
```

### 2.4 Ansible-Konfiguration erstellen

```bash
# ansible.cfg
tee ansible.cfg > /dev/null <<EOF
[defaults]
inventory = inventory/hosts.yml
host_key_checking = False
timeout = 30
retry_files_enabled = False

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
pipelining = True
EOF
```

### 2.5 Deployment-Script

```bash
# deploy.sh
tee deploy.sh > /dev/null <<EOF
#!/bin/bash

echo "=== MthBdeIotClient Raspberry Pi Deployment ==="
echo "Deploying to multiple Raspberry Pi devices..."

# Ping-Test für alle Hosts
echo "Testing connectivity to all Raspberry Pi devices..."
ansible all -m ping

if [ $? -eq 0 ]; then
    echo "All devices are reachable. Starting deployment..."
    
    # Hauptdeployment ausführen
    ansible-playbook playbooks/deploy-mthbdeiotclient.yml -v
    
    echo "Deployment completed!"
    echo "Device status:"
    ansible all -a "hostname -I"
else
    echo "Some devices are not reachable. Please check network configuration."
    echo "Available devices:"
    ansible all -m ping --one-line | grep SUCCESS
fi

echo "=== Deployment finished ==="
EOF

chmod +x deploy.sh
```

### 2.6 Ausführung der automatisierten Installation

```bash
# 1. Alle Raspberry Pis mit Standard-IP (192.168.1.x) vorbereiten
# 2. SSH auf allen Pis aktivieren
# 3. Deployment ausführen:

./deploy.sh

# Oder einzelne Geräte:
ansible-playbook playbooks/deploy-mthbdeiotclient.yml --limit pi-001

# Status prüfen:
ansible all -a "ip addr show eth0"
```

## 3. Netzwerk-Schema

```
Vor der Installation:
192.168.1.100 -> pi-001
192.168.1.101 -> pi-002
192.168.1.102 -> pi-003
192.168.1.103 -> pi-004
192.168.1.104 -> pi-005

Nach der Installation:
10.10.0.101 -> mth-bde-001
10.10.0.102 -> mth-bde-002
10.10.0.103 -> mth-bde-003
10.10.0.104 -> mth-bde-004
10.10.0.105 -> mth-bde-005
```

## 3.1 Automatische Installation von GitHub Releases

### 🚀 Direkte Installation vom Latest Release:
```bash
# Automatischer Download der neuesten Version
curl -s https://api.github.com/repos/mthitservice/MthBdeIotClient/releases/latest \
  | grep "browser_download_url.*armhf.deb" \
  | cut -d '"' -f 4 \
  | wget -qi -

# Installation
sudo dpkg -i mthbdeiotclient_*_armhf.deb
sudo apt-get install -f

# Update-Script erstellen
sudo tee /usr/local/bin/update-mthbdeiot.sh > /dev/null <<'EOF'
#!/bin/bash
echo "🔄 Updating MthBdeIotClient..."

# Überprüfe Node.js Version
if ! node -e "if (process.version.slice(1).split('.')[0] < 22) process.exit(1)"; then
  echo "❌ Node.js Version zu alt - mindestens 22.x erforderlich"
  echo "Führe 'curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt-get install -y nodejs' aus"
  exit 1
fi

cd /tmp
curl -s https://api.github.com/repos/mthitservice/MthBdeIotClient/releases/latest \
  | grep "browser_download_url.*armhf.deb" \
  | cut -d '"' -f 4 \
  | wget -qi - -O mthbdeiotclient_latest.deb
sudo dpkg -i mthbdeiotclient_latest.deb
sudo apt-get install -f
echo "✅ Update completed!"
EOF
sudo chmod +x /usr/local/bin/update-mthbdeiot.sh

# Automatisches Update (Optional)
echo "0 2 * * 0 /usr/local/bin/update-mthbdeiot.sh" | sudo tee -a /etc/crontab
```

### 📦 Spezifische Version installieren:
```bash
# Beispiel für Version 1.0.1
VERSION="1.0.1"
curl -L "https://github.com/mthitservice/MthBdeIotClient/releases/download/v${VERSION}/mthbdeiotclient_${VERSION}_armhf.deb" -o mthbdeiotclient.deb
sudo dpkg -i mthbdeiotclient.deb
sudo apt-get install -f
```

## 3.2 Ansible Deployment mit GitHub Integration

```yaml
# Erweiterte Ansible-Task für GitHub Downloads
- name: Get latest release info from GitHub
  uri:
    url: "https://api.github.com/repos/{{ github_repository }}/releases/latest"
    method: GET
    return_content: yes
  register: github_release
  delegate_to: localhost
  run_once: true

- name: Extract download URL for Raspberry Pi
  set_fact:
    download_url: "{{ github_release.json.assets | selectattr('name', 'match', '.*armhf.deb$') | map(attribute='browser_download_url') | first }}"
    release_version: "{{ github_release.json.tag_name | regex_replace('^v', '') }}"

- name: Download latest release
  get_url:
    url: "{{ download_url }}"
    dest: "/tmp/mthbdeiotclient_{{ release_version }}_armhf.deb"
    mode: '0644'

- name: Install downloaded package
  apt:
    deb: "/tmp/mthbdeiotclient_{{ release_version }}_armhf.deb"
    state: present
```

## 4. Troubleshooting

### Häufige Probleme

1. **Node.js Version zu alt:**
   ```bash
   # Überprüfe aktuelle Version
   node --version
   
   # Update auf Node.js 22
   curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
   sudo apt-get install -y nodejs
   
   # Neuinstallation der Abhängigkeiten
   cd /home/pi/apps/MthBdeIotClient/App
   rm -rf node_modules package-lock.json
   npm install --production
   ```

2. **Electron startet nicht:**
   ```bash
   # Debug-Modus starten
   /home/pi/apps/MthBdeIotClient/App/node_modules/.bin/electron /home/pi/apps/MthBdeIotClient/App/dist/main/main.js --verbose
   ```

3. **Netzwerk funktioniert nicht:**
   ```bash
   # IP-Konfiguration prüfen
   ip addr show
   ping 10.10.0.1
   ```

4. **Autostart funktioniert nicht:**
   ```bash
   # Autostart-Dateien prüfen
   ls -la /home/pi/.config/autostart/
   ```

5. **Performance-Probleme:**
   ```bash
   # GPU-Memory erhöhen
   echo "gpu_mem=128" | sudo tee -a /boot/config.txt
   sudo reboot
   ```

## 5. Wartung

### Updates ausführen:
```bash
# Mit Ansible alle Geräte aktualisieren
ansible all -m git -a "repo={{ repository_url }} dest={{ app_directory }} force=yes" --become-user=pi
ansible all -m command -a "npm run build" --become-user=pi -a "chdir={{ app_directory }}/App"
ansible all -m reboot
```

### Logs überprüfen:
```bash
# Systemlogs
journalctl -f

# Anwendungslogs
tail -f /home/pi/.config/Electron/logs/main.log
```

## 6. Sicherheitshinweise

- Standard-Passwörter ändern
- SSH-Keys verwenden statt Passwort-Authentifizierung
- Firewall konfigurieren
- Regelmäßige Updates durchführen

---

**Support:** info@mth-it-service.com  
**Version:** 1.0  
**Datum:** Juli 2025
