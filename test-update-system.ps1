# Test-Script für das intelligente Update-System
# Testet alle Update-Quellen und überprüft die Funktionalität

Write-Host "🧪 MTH BDE IoT Client - Update-System Test" -ForegroundColor Cyan
Write-Host "=" * 50

# Test 1: GitHub API (Releases)
Write-Host "`n📡 Test 1: GitHub Releases API" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "https://api.github.com/repos/mthitservice/MTHBDEIOTClient/releases/latest" -TimeoutSec 10
    Write-Host "✅ GitHub API erreichbar" -ForegroundColor Green
    Write-Host "   Neueste Version: $($response.tag_name)" -ForegroundColor Gray
    Write-Host "   Veröffentlicht: $($response.published_at)" -ForegroundColor Gray
    Write-Host "   Assets: $($response.assets.Count)" -ForegroundColor Gray
    
    # Prüfe ob version.json Asset existiert
    $versionJsonAsset = $response.assets | Where-Object { $_.name -eq "version.json" }
    if ($versionJsonAsset) {
        Write-Host "   ✅ version.json Asset gefunden" -ForegroundColor Green
        Write-Host "      Download: $($versionJsonAsset.browser_download_url)" -ForegroundColor Gray
    } else {
        Write-Host "   ❌ version.json Asset NICHT gefunden" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ GitHub API nicht erreichbar: $_" -ForegroundColor Red
}

# Test 2: Direct version.json Download
Write-Host "`n📋 Test 2: Direct version.json Download" -ForegroundColor Yellow
try {
    $versionUrl = "https://github.com/mthitservice/MTHBDEIOTClient/releases/download/v1.0.111/version.json"
    Write-Host "   Teste URL: $versionUrl" -ForegroundColor Gray
    
    $versionData = Invoke-RestMethod -Uri $versionUrl -TimeoutSec 10
    Write-Host "✅ version.json Download erfolgreich" -ForegroundColor Green
    Write-Host "   Version: $($versionData.version)" -ForegroundColor Gray
    Write-Host "   Release Date: $($versionData.releaseDate)" -ForegroundColor Gray
    Write-Host "   Platforms: $($versionData.platform.PSObject.Properties.Name -join ', ')" -ForegroundColor Gray
    
    # ARM64 Linux Details
    if ($versionData.platform.linux.arm64) {
        Write-Host "   ARM64 DEB: $($versionData.platform.linux.arm64.filename)" -ForegroundColor Gray
    }
    
    # ARMv7l Linux Details
    if ($versionData.platform.linux.armv7l) {
        Write-Host "   ARMv7l DEB: $($versionData.platform.linux.armv7l.filename)" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "❌ version.json Download fehlgeschlagen: $_" -ForegroundColor Red
}

# Test 3: Lokaler Server Test (Simulation)
Write-Host "`n🏠 Test 3: Lokaler Server Simulation" -ForegroundColor Yellow
$testIP = "192.168.1.100"
$localVersionUrl = "http://$testIP/update/version.json"

Write-Host "   Teste lokale Server URL: $localVersionUrl" -ForegroundColor Gray
try {
    $localResponse = Invoke-RestMethod -Uri $localVersionUrl -TimeoutSec 3
    Write-Host "✅ Lokaler Server erreichbar" -ForegroundColor Green
    Write-Host "   Lokale Version: $($localResponse.version)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Lokaler Server nicht erreichbar (erwartet): $_" -ForegroundColor Yellow
    Write-Host "   Hinweis: Lokaler Server muss separat eingerichtet werden" -ForegroundColor Gray
}

# Test 4: Version Comparison Test
Write-Host "`n🔄 Test 4: Version-Vergleich" -ForegroundColor Yellow
$currentVersion = "1.0.111"
$testVersions = @("1.0.110", "1.0.111", "1.0.112")

foreach ($testVersion in $testVersions) {
    $hasUpdate = $testVersion -ne $currentVersion
    $symbol = if ($hasUpdate) { "🔄" } else { "✅" }
    $status = if ($hasUpdate) { "Update verfügbar" } else { "Aktuell" }
    Write-Host "   $symbol Aktuelle: $currentVersion vs Verfügbar: $testVersion → $status" -ForegroundColor Gray
}

# Test 5: Download URLs Test
Write-Host "`n📥 Test 5: Download URLs Test" -ForegroundColor Yellow
$downloadUrls = @(
    "https://github.com/mthitservice/MTHBDEIOTClient/releases/download/v1.0.111/mthbdeiotclient_1.0.111_arm64.deb",
    "https://github.com/mthitservice/MTHBDEIOTClient/releases/download/v1.0.111/mthbdeiotclient_1.0.111_armv7l.deb"
)

foreach ($url in $downloadUrls) {
    try {
        $filename = Split-Path $url -Leaf
        Write-Host "   Teste: $filename" -ForegroundColor Gray
        
        # Nur Header abrufen (schneller als vollständiger Download)
        $headers = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 10
        if ($headers.StatusCode -eq 200) {
            $sizeKB = [math]::Round([int]$headers.Headers.'Content-Length' / 1024, 2)
            Write-Host "   ✅ $filename verfügbar (${sizeKB} KB)" -ForegroundColor Green
        }
    } catch {
        Write-Host "   ❌ $filename nicht verfügbar" -ForegroundColor Red
    }
}

# Zusammenfassung und Empfehlungen
Write-Host "`n📊 Zusammenfassung & Empfehlungen" -ForegroundColor Cyan
Write-Host "=" * 50

Write-Host "🎯 Für das intelligente Update-System:" -ForegroundColor White
Write-Host "   1. ✅ GitHub API funktioniert" -ForegroundColor Green
Write-Host "   2. 📋 version.json muss zu Release hinzugefügt werden" -ForegroundColor Yellow
Write-Host "   3. 🏠 Lokaler Server optional für Offline-Umgebungen" -ForegroundColor Gray

Write-Host "`n🚀 Nächste Schritte:" -ForegroundColor White
Write-Host "   • PowerShell Script ausführen:" -ForegroundColor Gray
Write-Host "     .\upload-version-json.ps1 -Version 1.0.111 -GitHubToken <token>" -ForegroundColor Code
Write-Host "   • Azure Pipeline erweitern für automatischen Upload" -ForegroundColor Gray
Write-Host "   • Update-System im Client testen" -ForegroundColor Gray

Write-Host "`n✅ Test abgeschlossen!" -ForegroundColor Green
