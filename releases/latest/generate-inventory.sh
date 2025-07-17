#!/bin/bash

# IP-Adress-Generator für Raspberry Pi Deployment
# Dieses Script generiert automatisch die Ansible Inventory-Datei

# Konfiguration
BASE_IP_RANGE="192.168.1"
TARGET_IP_RANGE="10.10.0"
START_IP=100
END_IP=120
GATEWAY="10.10.0.1"
DNS_SERVERS="8.8.8.8 8.8.4.4"

# Repository-URL anpassen
REPOSITORY_URL="https://github.com/mthitservice/MthBdeIotClient.git"

# Inventory-Header erstellen
cat > inventory/hosts.yml << EOF
---
all:
  children:
    raspberry_pis:
      hosts:
EOF

# IP-Adressen generieren
COUNTER=1
for i in $(seq $START_IP $END_IP); do
    TARGET_IP_SUFFIX=$((100 + $COUNTER))
    cat >> inventory/hosts.yml << EOF
        pi-$(printf "%03d" $COUNTER):
          ansible_host: ${BASE_IP_RANGE}.${i}
          target_ip: ${TARGET_IP_RANGE}.${TARGET_IP_SUFFIX}
          hostname: mth-bde-$(printf "%03d" $COUNTER)
EOF
    COUNTER=$((COUNTER + 1))
done

# Inventory-Footer erstellen
cat >> inventory/hosts.yml << EOF
      vars:
        ansible_user: pi
        ansible_ssh_pass: raspberry
        ansible_become: yes
        ansible_become_method: sudo
        ansible_become_pass: raspberry
        app_directory: /home/pi/apps/MthBdeIotClient
        repository_url: "${REPOSITORY_URL}"
        gateway_ip: ${GATEWAY}
        dns_servers: "${DNS_SERVERS}"
EOF

echo "Inventory-Datei erstellt: inventory/hosts.yml"
echo "Anzahl generierte Hosts: $((COUNTER - 1))"
echo ""
echo "Bitte anpassen:"
echo "1. Repository-URL in der Datei"
echo "2. IP-Bereiche falls nötig"
echo "3. Standard-Passwörter"
