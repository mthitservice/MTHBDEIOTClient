# PowerShell Deployment Script für Windows
# MthBdeIotClient Raspberry Pi Deployment

param(
    [string]$InventoryFile = "inventory/hosts.yml",
    [switch]$TestOnly,
    [string]$LimitHosts = "",
    [switch]$GenerateInventory
)

Write-Host "=== MthBdeIotClient Raspberry Pi Deployment ===" -ForegroundColor Green

if ($GenerateInventory) {
    Write-Host "Generiere Inventory-Datei..." -ForegroundColor Yellow

    # Erstelle Verzeichnisse
    New-Item -ItemType Directory -Force -Path "inventory", "playbooks"

    # Führe das Bash-Script aus (WSL erforderlich)
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        wsl bash generate-inventory.sh
    }
    else {
        Write-Host "WSL nicht gefunden. Bitte Inventory manuell erstellen." -ForegroundColor Red
        return
    }
}

# Prüfe ob Ansible verfügbar ist
try {
    $ansibleVersion = ansible --version 2>$null
    if (-not $ansibleVersion) {
        throw "Ansible nicht gefunden"
    }
    Write-Host "Ansible gefunden: $($ansibleVersion[0])" -ForegroundColor Green
}
catch {
    Write-Host "Ansible ist nicht installiert. Installation:" -ForegroundColor Red
    Write-Host "1. Python installieren: https://python.org" -ForegroundColor Yellow
    Write-Host "2. pip install ansible" -ForegroundColor Yellow
    Write-Host "3. Oder WSL mit Ubuntu verwenden" -ForegroundColor Yellow
    return
}

# Connectivity Test
Write-Host "Teste Verbindung zu allen Raspberry Pi Geräten..." -ForegroundColor Yellow

$pingResult = ansible all -i $InventoryFile -m ping 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Alle Geräte sind erreichbar" -ForegroundColor Green

    if ($TestOnly) {
        Write-Host "Test-Modus: Deployment wird nicht ausgeführt" -ForegroundColor Yellow
        ansible all -i $InventoryFile -a "hostname -I"
        return
    }

    # Deployment ausführen
    Write-Host "Starte Deployment..." -ForegroundColor Green

    $deployCommand = "ansible-playbook playbooks/deploy-mthbdeiotclient.yml -i $InventoryFile -v"

    if ($LimitHosts) {
        $deployCommand += " --limit $LimitHosts"
        Write-Host "Deployment limitiert auf: $LimitHosts" -ForegroundColor Yellow
    }

    Invoke-Expression $deployCommand

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Deployment erfolgreich abgeschlossen!" -ForegroundColor Green

        # Status prüfen
        Write-Host "Geräte-Status:" -ForegroundColor Cyan
        ansible all -i $InventoryFile -a "hostname -I" | Write-Host

    }
    else {
        Write-Host "✗ Deployment fehlgeschlagen" -ForegroundColor Red
    }

}
else {
    Write-Host "✗ Einige Geräte sind nicht erreichbar:" -ForegroundColor Red
    $pingResult | Write-Host

    Write-Host "Erreichbare Geräte:" -ForegroundColor Yellow
    ansible all -i $InventoryFile -m ping --one-line | Select-String "SUCCESS" | Write-Host -ForegroundColor Green
}

Write-Host "=== Deployment beendet ===" -ForegroundColor Green

# Verwendungsbeispiele anzeigen
Write-Host ""
Write-Host "Verwendungsbeispiele:" -ForegroundColor Cyan
Write-Host ".\deploy.ps1 -TestOnly                    # Nur Connectivity-Test" -ForegroundColor Gray
Write-Host ".\deploy.ps1 -LimitHosts pi-001          # Nur ein Gerät" -ForegroundColor Gray
Write-Host ".\deploy.ps1 -GenerateInventory          # Inventory neu generieren" -ForegroundColor Gray
