# PowerShell Deployment Script fuer Windows
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

    New-Item -ItemType Directory -Force -Path "inventory", "playbooks" | Out-Null

    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        wsl bash generate-inventory.sh
    }
    else {
        Write-Host "WSL nicht gefunden. Bitte Inventory manuell erstellen." -ForegroundColor Red
        return
    }
}

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

Write-Host "Teste Verbindung zu allen Raspberry Pi Geräten..." -ForegroundColor Yellow
$pingResult = ansible all -i $InventoryFile -m ping 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Einige Geräte sind nicht erreichbar:" -ForegroundColor Red
    $pingResult | Out-Host

    Write-Host "Erreichbare Geräte:" -ForegroundColor Yellow
    ansible all -i $InventoryFile -m ping --one-line | Select-String "SUCCESS" | Out-Host

    Write-Host "=== Deployment beendet ===" -ForegroundColor Green
    return
}

Write-Host "Alle Geräte sind erreichbar" -ForegroundColor Green

if ($TestOnly) {
    Write-Host "Test-Modus: Deployment wird nicht ausgeführt" -ForegroundColor Yellow
    ansible all -i $InventoryFile -a "hostname -I" | Out-Host

    Write-Host "=== Deployment beendet ===" -ForegroundColor Green
    return
}

Write-Host "Starte Deployment..." -ForegroundColor Green
$deployCommand = "ansible-playbook playbooks/deploy-mthbdeiotclient.yml -i $InventoryFile -v"

if ($LimitHosts) {
    $deployCommand += " --limit $LimitHosts"
    Write-Host "Deployment limitiert auf: $LimitHosts" -ForegroundColor Yellow
}

Invoke-Expression $deployCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host "Deployment erfolgreich abgeschlossen!" -ForegroundColor Green
    Write-Host "Geräte-Status:" -ForegroundColor Cyan
    ansible all -i $InventoryFile -a "hostname -I" | Out-Host
}
else {
    Write-Host "Deployment fehlgeschlagen" -ForegroundColor Red
}

Write-Host "=== Deployment beendet ===" -ForegroundColor Green
Write-Host ""
Write-Host "Verwendungsbeispiele:" -ForegroundColor Cyan
Write-Host ".\deploy.ps1 -TestOnly                    # Nur Connectivity-Test" -ForegroundColor Gray
Write-Host ".\deploy.ps1 -LimitHosts pi-001          # Nur ein Gerät" -ForegroundColor Gray
Write-Host ".\deploy.ps1 -GenerateInventory          # Inventory neu generieren" -ForegroundColor Gray
