# Automatischer Release-Trigger für Azure DevOps Pipeline
# PowerShell Version für Windows

param(
    [switch]$Force = $false
)

Write-Host "🚀 Automatischer Release-Trigger für MTH BDE IoT Client" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

# Prüfe ob wir im richtigen Verzeichnis sind
if (-not (Test-Path "App\package.json")) {
    Write-Host "❌ Error: App\package.json nicht gefunden!" -ForegroundColor Red
    Write-Host "   Bitte führe dieses Skript im Repository-Root aus." -ForegroundColor Red
    exit 1
}

# Aktuelle Version aus package.json lesen
try {
    $packageJson = Get-Content "App\package.json" | ConvertFrom-Json
    $currentVersion = $packageJson.version
    Write-Host "📋 Aktuelle Version in package.json: $currentVersion" -ForegroundColor Cyan
}
catch {
    Write-Host "❌ Fehler beim Lesen der package.json: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Git Status prüfen
$gitStatus = git status --porcelain
if ($gitStatus -and -not $Force) {
    Write-Host "⚠️  Es gibt uncommittete Änderungen:" -ForegroundColor Yellow
    git status --short
    Write-Host ""
    $response = Read-Host "Möchten Sie fortfahren? (y/N)"
    if ($response -notmatch "^[Yy]$") {
        Write-Host "❌ Abgebrochen." -ForegroundColor Red
        exit 1
    }
}

# Aktuelle Branch prüfen
$currentBranch = git branch --show-current
Write-Host "🌿 Aktuelle Branch: $currentBranch" -ForegroundColor Cyan

if ($currentBranch -ne "master" -and -not $Force) {
    Write-Host "⚠️  Sie sind nicht auf der master branch!" -ForegroundColor Yellow
    $response = Read-Host "Möchten Sie trotzdem fortfahren? (y/N)"
    if ($response -notmatch "^[Yy]$") {
        Write-Host "❌ Abgebrochen." -ForegroundColor Red
        exit 1
    }
}

# Änderungen committen falls nötig
if ($gitStatus) {
    Write-Host "📝 Committe ausstehende Änderungen..." -ForegroundColor Yellow
    git add .
    $commitMessage = @"
Pre-release commit for version $currentVersion

- Updated version to $currentVersion
- Prepared for automatic Azure DevOps release
- Performance optimizations included

[automated-release]
"@
    git commit -m $commitMessage
}

# Push to Azure DevOps (triggert die Pipeline)
Write-Host "🔄 Push zu Azure DevOps Repository..." -ForegroundColor Yellow
try {
    git push origin $currentBranch
    Write-Host "✅ Push erfolgreich!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Fehler beim Push: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Release-Trigger erfolgreich!" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""
Write-Host "🔗 Die Azure DevOps Pipeline wird jetzt automatisch:" -ForegroundColor Cyan
Write-Host "   1. Version $currentVersion aus package.json lesen" -ForegroundColor White
Write-Host "   2. Git Tag 'v$currentVersion' erstellen" -ForegroundColor White
Write-Host "   3. ARM64 und ARMv7l .deb Pakete bauen" -ForegroundColor White
Write-Host "   4. GitHub Release mit Artefakten erstellen" -ForegroundColor White
Write-Host ""
Write-Host "📊 Verfolgen Sie den Build-Status hier:" -ForegroundColor Cyan
Write-Host "   https://dev.azure.com/mth-it-service/MthBdeIotClient/_build" -ForegroundColor Blue
Write-Host ""
Write-Host "🎯 GitHub Release wird hier erstellt:" -ForegroundColor Cyan  
Write-Host "   https://github.com/mthitservice/MTHBDEIOTClient/releases" -ForegroundColor Blue
Write-Host ""
Write-Host "⏱️  Der Build-Prozess dauert ca. 10-15 Minuten." -ForegroundColor Yellow

# Optional: Öffne Azure DevOps Build Pipeline im Browser
$response = Read-Host "🌐 Azure DevOps Pipeline im Browser öffnen? (y/N)"
if ($response -match "^[Yy]$") {
    Start-Process "https://dev.azure.com/mth-it-service/MthBdeIotClient/_build"
}

Write-Host ""
Write-Host "🎉 Automatischer Release-Prozess gestartet!" -ForegroundColor Green
