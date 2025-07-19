# GitHub Release Version.json Uploader
# Lädt version.json zu einem GitHub Release hoch

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [Parameter(Mandatory=$false)]
    [string]$GitHubToken = $env:GITHUB_TOKEN,
    
    [Parameter(Mandatory=$false)]
    [string]$RepoOwner = "mthitservice",
    
    [Parameter(Mandatory=$false)]
    [string]$RepoName = "MTHBDEIOTClient"
)

# Prüfen ob GitHub Token verfügbar ist
if (-not $GitHubToken) {
    Write-Error "GitHub Token ist erforderlich. Setzen Sie die Umgebungsvariable GITHUB_TOKEN oder übergeben Sie -GitHubToken"
    exit 1
}

# Version.json Pfad
$versionJsonPath = Join-Path $PSScriptRoot "version.json"
if (-not (Test-Path $versionJsonPath)) {
    Write-Error "version.json wurde nicht gefunden: $versionJsonPath"
    exit 1
}

# Version.json laden und Version aktualisieren
try {
    $versionData = Get-Content $versionJsonPath -Raw | ConvertFrom-Json
    $versionData.version = $Version
    $versionData.releaseDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    
    # Update download URLs for the current version
    if ($versionData.platform.linux.arm64) {
        $versionData.platform.linux.arm64.filename = "mthbdeiotclient_${Version}_arm64.deb"
        $versionData.platform.linux.arm64.downloadUrl = "https://github.com/$RepoOwner/$RepoName/releases/download/v$Version/mthbdeiotclient_${Version}_arm64.deb"
    }
    
    if ($versionData.platform.linux.armv7l) {
        $versionData.platform.linux.armv7l.filename = "mthbdeiotclient_${Version}_armv7l.deb"
        $versionData.platform.linux.armv7l.downloadUrl = "https://github.com/$RepoOwner/$RepoName/releases/download/v$Version/mthbdeiotclient_${Version}_armv7l.deb"
    }
    
    if ($versionData.platform.windows.x64) {
        $versionData.platform.windows.x64.filename = "MTH-BDE-IOT-Client-Setup-$Version.exe"
        $versionData.platform.windows.x64.downloadUrl = "https://github.com/$RepoOwner/$RepoName/releases/download/v$Version/MTH-BDE-IOT-Client-Setup-$Version.exe"
    }
    
    # Aktualisierte version.json speichern
    $updatedVersionJson = $versionData | ConvertTo-Json -Depth 10 -Compress:$false
    $updatedVersionJson | Set-Content $versionJsonPath -Encoding UTF8
    
    Write-Host "✅ version.json aktualisiert für Version $Version" -ForegroundColor Green
} catch {
    Write-Error "Fehler beim Verarbeiten der version.json: $_"
    exit 1
}

# GitHub API Headers
$headers = @{
    "Authorization" = "Bearer $GitHubToken"
    "Accept" = "application/vnd.github.v3+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

# Release ID abrufen
$releaseTag = "v$Version"
try {
    Write-Host "🔍 Suche Release für Tag: $releaseTag"
    $releaseUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/tags/$releaseTag"
    $release = Invoke-RestMethod -Uri $releaseUrl -Headers $headers -Method Get
    $releaseId = $release.id
    Write-Host "✅ Release gefunden: ID $releaseId" -ForegroundColor Green
} catch {
    Write-Error "Release für Tag $releaseTag nicht gefunden: $_"
    exit 1
}

# Prüfen ob version.json bereits existiert
try {
    $assetsUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/$releaseId/assets"
    $assets = Invoke-RestMethod -Uri $assetsUrl -Headers $headers -Method Get
    $existingVersionJson = $assets | Where-Object { $_.name -eq "version.json" }
    
    if ($existingVersionJson) {
        Write-Host "⚠️ version.json existiert bereits, lösche alte Version..." -ForegroundColor Yellow
        $deleteUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/releases/assets/$($existingVersionJson.id)"
        Invoke-RestMethod -Uri $deleteUrl -Headers $headers -Method Delete
        Write-Host "✅ Alte version.json gelöscht" -ForegroundColor Green
    }
} catch {
    Write-Warning "Fehler beim Prüfen existierender Assets: $_"
}

# version.json hochladen
try {
    Write-Host "📤 Lade version.json hoch..."
    
    # Upload URL
    $uploadUrl = $release.upload_url -replace '\{\?name,label\}', '?name=version.json&label=Version Information'
    
    # Datei-Content lesen
    $fileContent = Get-Content $versionJsonPath -Raw -Encoding UTF8
    $fileBytes = [System.Text.Encoding]::UTF8.GetBytes($fileContent)
    
    # Upload-Headers
    $uploadHeaders = $headers.Clone()
    $uploadHeaders["Content-Type"] = "application/json"
    
    # Upload durchführen
    $uploadResponse = Invoke-RestMethod -Uri $uploadUrl -Headers $uploadHeaders -Method Post -Body $fileBytes
    
    Write-Host "✅ version.json erfolgreich hochgeladen!" -ForegroundColor Green
    Write-Host "📍 Download URL: $($uploadResponse.browser_download_url)" -ForegroundColor Cyan
    
} catch {
    Write-Error "Fehler beim Hochladen der version.json: $_"
    Write-Error "Details: $($_.Exception.Message)"
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Error "Response: $responseBody"
    }
    exit 1
}

Write-Host ""
Write-Host "🎉 Version.json Upload abgeschlossen!" -ForegroundColor Green
Write-Host "🔗 Release URL: $($release.html_url)" -ForegroundColor Cyan
Write-Host "📋 Version.json URL: https://github.com/$RepoOwner/$RepoName/releases/download/v$Version/version.json" -ForegroundColor Cyan
