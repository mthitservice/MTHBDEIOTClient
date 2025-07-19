# Azure Pipeline Script - Version.json Upload
# Wird automatisch nach erfolgreichem Release-Build aufgerufen

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [Parameter(Mandatory=$true)]
    [string]$GitHubToken
)

Write-Host "🚀 Azure Pipeline: Version.json Upload für Version $Version"

# Arbeitsverzeichnis setzen
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Version.json laden und aktualisieren
$versionJsonPath = "version.json"
if (Test-Path $versionJsonPath) {
    try {
        $versionData = Get-Content $versionJsonPath -Raw | ConvertFrom-Json
        
        # Pipeline-spezifische Informationen hinzufügen
        $versionData.version = $Version
        $versionData.releaseDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        $versionData.buildInfo = @{
            pipeline = "Azure DevOps"
            buildId = $env:BUILD_BUILDID
            buildNumber = $env:BUILD_BUILDNUMBER
            sourceVersion = $env:BUILD_SOURCEVERSION
            buildDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        }
        
        # Platfor-spezifische URLs aktualisieren
        $baseUrl = "https://github.com/mthitservice/MTHBDEIOTClient/releases/download/v$Version"
        
        if ($versionData.platform.linux.arm64) {
            $versionData.platform.linux.arm64.filename = "mthbdeiotclient_${Version}_arm64.deb"
            $versionData.platform.linux.arm64.downloadUrl = "$baseUrl/mthbdeiotclient_${Version}_arm64.deb"
        }
        
        if ($versionData.platform.linux.armv7l) {
            $versionData.platform.linux.armv7l.filename = "mthbdeiotclient_${Version}_armv7l.deb"
            $versionData.platform.linux.armv7l.downloadUrl = "$baseUrl/mthbdeiotclient_${Version}_armv7l.deb"
        }
        
        if ($versionData.platform.windows.x64) {
            $versionData.platform.windows.x64.filename = "MTH-BDE-IOT-Client-Setup-$Version.exe"
            $versionData.platform.windows.x64.downloadUrl = "$baseUrl/MTH-BDE-IOT-Client-Setup-$Version.exe"
        }
        
        # Changelog mit aktueller Version erweitern
        $currentChangelog = @{
            version = $Version
            buildDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd")
            changes = @(
                "🤖 Automatisches Release via Azure Pipeline",
                "✅ ARM/Linux intelligentes Update-System",
                "🔄 GitHub API + lokaler Server Fallback",
                "🍓 Raspberry Pi Optimierungen",
                "📱 Verbesserte ARM64/ARMv7l Unterstützung"
            )
        }
        
        # Changelog aktualisieren (neuste Version an den Anfang)
        $versionData.changelog = @($currentChangelog) + $versionData.changelog
        
        # Aktualisierte Datei speichern
        $updatedJson = $versionData | ConvertTo-Json -Depth 10 -Compress:$false
        $updatedJson | Set-Content $versionJsonPath -Encoding UTF8
        
        Write-Host "✅ version.json aktualisiert für Azure Pipeline Build" -ForegroundColor Green
        
    } catch {
        Write-Error "Fehler beim Aktualisieren der version.json: $_"
        exit 1
    }
} else {
    Write-Error "version.json nicht gefunden im Arbeitsverzeichnis"
    exit 1
}

# GitHub Upload über das Haupt-Script
try {
    Write-Host "📤 Führe GitHub Upload aus..."
    $uploadScript = Join-Path $scriptDir "upload-version-json.ps1"
    
    if (Test-Path $uploadScript) {
        & $uploadScript -Version $Version -GitHubToken $GitHubToken
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Version.json erfolgreich zu GitHub Release hinzugefügt!" -ForegroundColor Green
        } else {
            Write-Error "GitHub Upload fehlgeschlagen mit Exit-Code: $LASTEXITCODE"
            exit 1
        }
    } else {
        Write-Error "Upload-Script nicht gefunden: $uploadScript"
        exit 1
    }
    
} catch {
    Write-Error "Fehler beim GitHub Upload: $_"
    exit 1
}

# Erfolg-Meldung
Write-Host ""
Write-Host "🎉 Azure Pipeline: Version.json Upload abgeschlossen!" -ForegroundColor Green
Write-Host "📋 Verfügbar unter: https://github.com/mthitservice/MTHBDEIOTClient/releases/download/v$Version/version.json" -ForegroundColor Cyan
Write-Host "🔍 Test-URL für Update-System:" -ForegroundColor Yellow
Write-Host "   curl https://github.com/mthitservice/MTHBDEIOTClient/releases/download/v$Version/version.json" -ForegroundColor Gray
