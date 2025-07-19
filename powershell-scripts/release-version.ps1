# MthBdeIotClient - Automatic Version Management Script (PowerShell)
# Automatische Versionsverwaltung mit Git Tags, package.json und .env Updates

param(
    [string]$Version = $null,
    [switch]$Force = $false,
    [switch]$DryRun = $false
)

# Farben für Output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Magenta = "Magenta"
    Cyan = "Cyan"
    White = "White"
}

# Emojis für bessere Lesbarkeit
$Emojis = @{
    Success = "✅"
    Error = "❌"
    Info = "ℹ️"
    Rocket = "🚀"
    Tag = "🏷️"
    Gear = "⚙️"
}

# Projektverzeichnisse
$ProjectRoot = Get-Location
$AppDir = Join-Path $ProjectRoot "App"
$PackageJson = Join-Path $AppDir "package.json"
$EnvFile = Join-Path $AppDir ".env"

function Write-ColoredOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [string]$Emoji = ""
    )
    
    $output = if ($Emoji) { "$Emoji $Message" } else { $Message }
    Write-Host $output -ForegroundColor $Color
}

function Get-PackageVersion {
    param([string]$PackageJsonPath)
    
    try {
        $packageContent = Get-Content $PackageJsonPath -Raw | ConvertFrom-Json
        return $packageContent.version
    }
    catch {
        return "0.0.0"
    }
}

function Set-PackageVersion {
    param(
        [string]$PackageJsonPath,
        [string]$Version
    )
    
    try {
        $packageContent = Get-Content $PackageJsonPath -Raw | ConvertFrom-Json
        $packageContent.version = $Version
        $packageContent | ConvertTo-Json -Depth 100 | Out-File $PackageJsonPath -Encoding UTF8
        return $true
    }
    catch {
        Write-ColoredOutput "Error updating $PackageJsonPath`: $_" $Colors.Red $Emojis.Error
        return $false
    }
}

function Get-IncrementedVersion {
    param(
        [string]$Version,
        [string]$Type
    )
    
    $versionParts = $Version.Split('.')
    $major = [int]$versionParts[0]
    $minor = [int]$versionParts[1]
    $patch = [int]$versionParts[2]
    
    switch ($Type) {
        "major" { 
            $major++
            $minor = 0
            $patch = 0
        }
        "minor" { 
            $minor++
            $patch = 0
        }
        "patch" { 
            $patch++
        }
    }
    
    return "$major.$minor.$patch"
}

function Update-EnvFile {
    param(
        [string]$EnvFilePath,
        [string]$Version
    )
    
    try {
        if (Test-Path $EnvFilePath) {
            $envContent = Get-Content $EnvFilePath
            $versionLineExists = $false
            
            # Aktualisiere bestehende VERSION Zeile
            $updatedContent = $envContent | ForEach-Object {
                if ($_ -match "^VERSION=") {
                    $versionLineExists = $true
                    "VERSION=$Version"
                } else {
                    $_
                }
            }
            
            # Füge VERSION hinzu falls nicht vorhanden
            if (-not $versionLineExists) {
                $updatedContent += "VERSION=$Version"
            }
            
            $updatedContent | Out-File $EnvFilePath -Encoding UTF8
        } else {
            # Erstelle neue .env Datei
            $envContent = @(
                "# MthBdeIotClient Environment Variables",
                "NODE_ENV=production",
                "VERSION=$Version",
                "ELECTRON_BUILDER_ALLOW_UNRESOLVED_DEPENDENCIES=true"
            )
            $envContent | Out-File $EnvFilePath -Encoding UTF8
        }
        return $true
    }
    catch {
        Write-ColoredOutput "Error updating .env file: $_" $Colors.Red $Emojis.Error
        return $false
    }
}

# Header
Write-ColoredOutput "==========================================" $Colors.Cyan
Write-ColoredOutput "MthBdeIotClient Version Manager" $Colors.Cyan $Emojis.Rocket
Write-ColoredOutput "==========================================" $Colors.Cyan
Write-Host ""

# Prüfe ob wir im richtigen Verzeichnis sind
if (-not (Test-Path $PackageJson)) {
    Write-ColoredOutput "package.json not found in $PackageJson" $Colors.Red $Emojis.Error
    Write-ColoredOutput "Please run this script from the project root directory" $Colors.Yellow $Emojis.Info
    exit 1
}

# Git Status prüfen
Write-ColoredOutput "Checking Git status..." $Colors.Blue $Emojis.Info
$gitStatus = git status --porcelain 2>$null
if ($gitStatus -and -not $Force) {
    Write-ColoredOutput "Working directory has uncommitted changes:" $Colors.Yellow
    git status --porcelain
    Write-Host ""
    $continue = Read-Host "Do you want to continue anyway? (y/N)"
    if ($continue -notmatch "^[Yy]$") {
        Write-ColoredOutput "Aborted by user" $Colors.Red $Emojis.Error
        exit 1
    }
} else {
    Write-ColoredOutput "Working directory is clean" $Colors.Green $Emojis.Success
}

# Aktuelle Version aus package.json lesen
Write-ColoredOutput "Reading current version..." $Colors.Blue $Emojis.Info
$currentVersion = Get-PackageVersion $PackageJson
Write-ColoredOutput "Current version in package.json: $currentVersion" $Colors.Magenta $Emojis.Info

# Letzte Git Tags abrufen
Write-ColoredOutput "Fetching Git tags..." $Colors.Blue $Emojis.Info
git fetch --tags --quiet 2>$null

# Letzten Git Tag finden
try {
    $lastTag = git tag -l --sort=-version:refname "v*" | Select-Object -First 1
    if ($lastTag) {
        $lastVersion = $lastTag.Substring(1)  # Remove 'v' prefix
        Write-ColoredOutput "Last Git tag: $lastTag (version: $lastVersion)" $Colors.Magenta $Emojis.Info
    } else {
        $lastVersion = "0.0.0"
        Write-ColoredOutput "No previous Git tags found, starting from $lastVersion" $Colors.Magenta $Emojis.Info
    }
} catch {
    $lastVersion = "0.0.0"
    Write-ColoredOutput "Could not read Git tags, starting from $lastVersion" $Colors.Yellow $Emojis.Info
}

# Wenn Version als Parameter übergeben wurde
if ($Version) {
    if ($Version -match "^[0-9]+\.[0-9]+\.[0-9]+$") {
        $newVersion = $Version
        Write-ColoredOutput "Using provided version: $newVersion" $Colors.Green $Emojis.Success
    } else {
        Write-ColoredOutput "Invalid version format: $Version" $Colors.Red $Emojis.Error
        Write-ColoredOutput "Please use semantic versioning (e.g., 1.2.3)" $Colors.Yellow $Emojis.Info
        exit 1
    }
} else {
    # Vorgeschlagene Versionen generieren
    $suggestedPatch = Get-IncrementedVersion $lastVersion "patch"
    $suggestedMinor = Get-IncrementedVersion $lastVersion "minor"
    $suggestedMajor = Get-IncrementedVersion $lastVersion "major"
    
    Write-Host ""
    Write-ColoredOutput "Version suggestions based on last tag ($lastVersion):" $Colors.Cyan $Emojis.Gear
    Write-Host "  1) Patch release: $suggestedPatch (bugfixes)" -ForegroundColor Green
    Write-Host "  2) Minor release: $suggestedMinor (new features)" -ForegroundColor Green
    Write-Host "  3) Major release: $suggestedMajor (breaking changes)" -ForegroundColor Green
    Write-Host "  4) Custom version" -ForegroundColor Green
    Write-Host ""
    
    # Benutzer nach Version fragen
    do {
        $versionInput = Read-Host "Select version type (1-4) or enter custom version"
        
        switch ($versionInput) {
            "1" { $newVersion = $suggestedPatch; break }
            "2" { $newVersion = $suggestedMinor; break }
            "3" { $newVersion = $suggestedMajor; break }
            "4" { 
                $newVersion = Read-Host "Enter custom version (e.g., 2.1.0)"
                if ($newVersion -notmatch "^[0-9]+\.[0-9]+\.[0-9]+$") {
                    Write-ColoredOutput "Invalid version format. Please use semantic versioning (e.g., 1.2.3)" $Colors.Red $Emojis.Error
                    $newVersion = $null
                }
                break
            }
            default {
                # Prüfe ob direkt eine Version eingegeben wurde
                if ($versionInput -match "^[0-9]+\.[0-9]+\.[0-9]+$") {
                    $newVersion = $versionInput
                } else {
                    Write-ColoredOutput "Invalid input. Please select 1-4 or enter a valid version" $Colors.Red $Emojis.Error
                    $newVersion = $null
                }
            }
        }
    } while (-not $newVersion)
}

$newTag = "v$newVersion"

Write-Host ""
Write-ColoredOutput "Selected version: $newVersion" $Colors.Green $Emojis.Rocket
Write-ColoredOutput "Git tag will be: $newTag" $Colors.Green $Emojis.Tag
Write-Host ""

# Prüfe ob Tag bereits existiert
$tagExists = git rev-parse $newTag 2>$null
if ($tagExists -and -not $Force) {
    Write-ColoredOutput "Tag $newTag already exists!" $Colors.Red $Emojis.Error
    Write-ColoredOutput "Existing tags:" $Colors.Yellow $Emojis.Info
    git tag -l --sort=-version:refname "v*" | Select-Object -First 5
    exit 1
}

# DryRun Modus
if ($DryRun) {
    Write-ColoredOutput "DRY RUN MODE - No changes will be made" $Colors.Yellow $Emojis.Info
    Write-Host ""
    Write-ColoredOutput "Would update:" $Colors.Cyan $Emojis.Info
    Write-Host "  • package.json version to $newVersion"
    Write-Host "  • .env file with new version"
    Write-Host "  • Create Git tag: $newTag"
    Write-Host "  • Push changes and tag to origin"
    exit 0
}

# Bestätigung
Write-ColoredOutput "This will:" $Colors.Yellow $Emojis.Info
Write-Host "  • Update package.json version to $newVersion"
Write-Host "  • Update .env file with new version"
Write-Host "  • Commit changes with message: 'Release $newVersion'"
Write-Host "  • Create Git tag: $newTag"
Write-Host "  • Push changes and tag to origin"
Write-Host ""
if (-not $Force) {
    $continue = Read-Host "Continue? (y/N)"
    if ($continue -notmatch "^[Yy]$") {
        Write-ColoredOutput "Aborted by user" $Colors.Red $Emojis.Error
        exit 1
    }
}

# 1. Package.json aktualisieren
Write-ColoredOutput "Updating package.json..." $Colors.Blue $Emojis.Gear
if (Set-PackageVersion $PackageJson $newVersion) {
    Write-ColoredOutput "Updated package.json version to $newVersion" $Colors.Green $Emojis.Success
} else {
    Write-ColoredOutput "Failed to update package.json" $Colors.Red $Emojis.Error
    exit 1
}

# 2. .env Datei aktualisieren
Write-ColoredOutput "Updating .env file..." $Colors.Blue $Emojis.Gear
if (Update-EnvFile $EnvFile $newVersion) {
    if (Test-Path $EnvFile) {
        Write-ColoredOutput "Updated .env file with VERSION=$newVersion" $Colors.Green $Emojis.Success
    } else {
        Write-ColoredOutput "Created new .env file with VERSION=$newVersion" $Colors.Green $Emojis.Success
    }
} else {
    Write-ColoredOutput "Failed to update .env file" $Colors.Red $Emojis.Error
    exit 1
}

# 3. Release package.json aktualisieren (falls vorhanden)
$releasePackageJson = Join-Path $AppDir "release\app\package.json"
if (Test-Path $releasePackageJson) {
    Write-ColoredOutput "Updating release/app/package.json..." $Colors.Blue $Emojis.Gear
    if (Set-PackageVersion $releasePackageJson $newVersion) {
        Write-ColoredOutput "Updated release/app/package.json version to $newVersion" $Colors.Green $Emojis.Success
    }
}

# 4. Git Changes committen
Write-ColoredOutput "Committing changes..." $Colors.Blue $Emojis.Gear
git add $PackageJson $EnvFile
if (Test-Path $releasePackageJson) {
    git add $releasePackageJson
}

$commitMessage = @"
Release $newVersion

- Updated package.json version to $newVersion
- Updated .env file with new version
- Prepared for release build

[skip ci]
"@

git commit -m $commitMessage
Write-ColoredOutput "Committed changes" $Colors.Green $Emojis.Success

# 5. Git Tag erstellen
Write-ColoredOutput "Creating Git tag..." $Colors.Blue $Emojis.Gear
$tagMessage = @"
Release $newVersion

MthBdeIotClient Raspberry Pi Release v$newVersion

Features:
- Electron App für Raspberry Pi 3+ (ARMv7l)
- Debian Package (.deb) für einfache Installation
- Automatische Pipeline mit Azure DevOps
- GitHub Release Integration

Installation:
wget https://github.com/mthitservice/MTHBDEIOTClient/releases/latest/download/mthbdeiotclient_$($newVersion)_armhf.deb
sudo dpkg -i mthbdeiotclient_$($newVersion)_armhf.deb
sudo apt-get install -f
"@

git tag -a $newTag -m $tagMessage
Write-ColoredOutput "Created tag $newTag" $Colors.Green $Emojis.Success

# 6. Push zu origin
Write-ColoredOutput "Pushing changes and tag to origin..." $Colors.Blue $Emojis.Gear
git push origin HEAD
git push origin $newTag
Write-ColoredOutput "Pushed changes and tag to origin" $Colors.Green $Emojis.Success

# 7. Zusammenfassung
Write-Host ""
Write-ColoredOutput "==========================================" $Colors.Cyan
Write-ColoredOutput "VERSION RELEASE COMPLETED" $Colors.Cyan $Emojis.Success
Write-ColoredOutput "==========================================" $Colors.Cyan
Write-Host ""
Write-ColoredOutput "Summary:" $Colors.Green $Emojis.Info
Write-Host "  • Version: $newVersion" -ForegroundColor Magenta
Write-Host "  • Tag: $newTag" -ForegroundColor Magenta
Write-Host "  • Commit: $(git rev-parse --short HEAD)"
Write-Host "  • Branch: $(git branch --show-current)"
Write-Host ""
Write-ColoredOutput "Next steps:" $Colors.Green $Emojis.Rocket
Write-Host "  1. Azure DevOps Pipeline will start automatically"
Write-Host "  2. .deb package will be built for Raspberry Pi"
Write-Host "  3. GitHub Release will be created automatically"
Write-Host "  4. Package will be available as 'latest' release"
Write-Host ""
Write-ColoredOutput "Useful links:" $Colors.Blue $Emojis.Info
Write-Host "  • Azure DevOps: https://dev.azure.com/mth-it-service/MthBdeIotClient/_build"
Write-Host "  • GitHub Repository: https://github.com/mth-it-service/MTHBDEIOTClient"
Write-Host "  • Latest Release: https://github.com/mth-it-service/MTHBDEIOTClient/tree/master/releases/latest"
Write-Host "  • Install on Raspberry Pi: https://raw.githubusercontent.com/mth-it-service/MTHBDEIOTClient/master/releases/latest/mthbdeiotclient_$($newVersion)_armhf.deb"
Write-Host ""
Write-ColoredOutput "Version $newVersion released successfully!" $Colors.Green $Emojis.Success
