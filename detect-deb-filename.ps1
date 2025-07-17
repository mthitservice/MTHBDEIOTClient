# DEB-Dateiname-Erkennung für MTH BDE IoT Client Pipeline
# Erkennt automatisch den korrekten Dateinamen basierend auf electron-builder Output

param(
    [string]$WorkspacePath = "$(Pipeline.Workspace)/MthBdeIotClient-RaspberryPi",
    [string]$Version = "$(releaseVersion)"
)

Write-Host "=== DEB FILENAME DETECTION ==="
Write-Host "Workspace: $WorkspacePath"
Write-Host "Version: $Version"

# Suche nach DEB-Dateien in allen möglichen Pfaden
$searchPaths = @(
    "$WorkspacePath/packages",
    "$WorkspacePath/release/build",
    "$WorkspacePath/dist",
    "$WorkspacePath"
)

$foundDebFiles = @()

foreach ($searchPath in $searchPaths) {
    if (Test-Path $searchPath) {
        Write-Host "Searching in: $searchPath"
        $debFiles = Get-ChildItem -Path $searchPath -Filter "*.deb" -Recurse -ErrorAction SilentlyContinue
        foreach ($file in $debFiles) {
            $foundDebFiles += $file
            Write-Host "  Found: $($file.Name) (Size: $([math]::Round($file.Length/1MB, 2)) MB)"
        }
    }
}

if ($foundDebFiles.Count -eq 0) {
    Write-Host "❌ ERROR: No DEB files found in any search path!"
    Write-Host "Available files in workspace:"
    Get-ChildItem -Path $WorkspacePath -Recurse -File | Select-Object Name, Length, DirectoryName | Format-Table -AutoSize
    exit 1
}

# Wähle das erste/größte DEB-File
$selectedDebFile = $foundDebFiles | Sort-Object Length -Descending | Select-Object -First 1
$debFileName = $selectedDebFile.Name

Write-Host "=== SELECTED DEB FILE ==="
Write-Host "Filename: $debFileName"
Write-Host "Size: $([math]::Round($selectedDebFile.Length/1MB, 2)) MB"
Write-Host "Path: $($selectedDebFile.FullName)"

# Analysiere Dateiname-Muster
$patterns = @{
    "armv7l"  = $debFileName -match "armv7l"
    "armhf"   = $debFileName -match "armhf"
    "aarch64" = $debFileName -match "aarch64"
    "arm64"   = $debFileName -match "arm64"
}

Write-Host "=== FILENAME ANALYSIS ==="
foreach ($pattern in $patterns.GetEnumerator()) {
    $status = if ($pattern.Value) { "✅" } else { "❌" }
    Write-Host "$status Architecture $($pattern.Key): $($pattern.Value)"
}

# Bestimme erwartete Dateinamen für verschiedene Architekturen
$expectedNames = @(
    "mthbdeiotclient_${Version}_armv7l.deb",
    "mthbdeiotclient_${Version}_armhf.deb",
    "mthbdeiotclient-${Version}-armv7l.deb",
    "mthbdeiotclient-${Version}-armhf.deb"
)

Write-Host "=== EXPECTED VS ACTUAL ==="
Write-Host "Actual filename: $debFileName"
Write-Host "Expected patterns:"
foreach ($expected in $expectedNames) {
    $match = $debFileName -eq $expected
    $status = if ($match) { "✅ MATCH" } else { "❌" }
    Write-Host "  $status $expected"
}

# Erstelle Installationskommandos mit korrektem Dateinamen
$downloadUrl = "https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/$debFileName"
$installCommands = @"
# MTH BDE IoT Client Installation - Korrekte Dateinamen
# Automatisch erkannter Dateiname: $debFileName

# Schnell-Installation (eine Zeile):
wget $downloadUrl && sudo dpkg -i $debFileName && sudo apt-get install -f

# Schritt-für-Schritt Installation:
wget $downloadUrl
sudo dpkg -i $debFileName
sudo apt-get install -f

# Mit Prüfsummen-Verifikation:
wget https://github.com/mthitservice/MTHBDEIOTClient/raw/main/releases/latest/SHA256SUMS
wget $downloadUrl
sha256sum -c SHA256SUMS
sudo dpkg -i $debFileName && sudo apt-get install -f

# Automatisches Installations-Script (empfohlen):
wget -O /tmp/install-latest.sh https://github.com/mthitservice/MTHBDEIOTClient/raw/main/install-latest.sh
chmod +x /tmp/install-latest.sh
/tmp/install-latest.sh
"@

Write-Host "=== INSTALLATION COMMANDS ==="
Write-Host $installCommands

# Setze Pipeline-Variablen
Write-Host "=== SETTING PIPELINE VARIABLES ==="
Write-Host "##vso[task.setvariable variable=ACTUAL_DEB_FILENAME]$debFileName"
Write-Host "##vso[task.setvariable variable=DEB_DOWNLOAD_URL]$downloadUrl"
Write-Host "##vso[task.setvariable variable=DEB_FILE_SIZE]$($selectedDebFile.Length)"

Write-Host "✅ DEB filename detection completed: $debFileName"
