# MTH BDE IoT Client - Update System Tools
# Wrapper-Script für einfachen Zugriff auf Update-System Tools

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("test", "upload", "azure")]
    [string]$Action,
    
    [Parameter(Mandatory = $false)]
    [string]$Version,
    
    [Parameter(Mandatory = $false)]
    [string]$GitHubToken = $env:GITHUB_TOKEN
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

switch ($Action) {
    "test" {
        Write-Host "🧪 Starte Update-System Test..." -ForegroundColor Cyan
        $testScript = Join-Path $scriptDir "scripts\testing\test-update-system.ps1"
        & $testScript
    }
    
    "upload" {
        if (-not $Version) {
            Write-Error "Version ist erforderlich für Upload. Verwendung: .\update-tools.ps1 upload -Version 1.0.111"
            exit 1
        }
        
        Write-Host "📤 Starte GitHub Upload für Version $Version..." -ForegroundColor Cyan
        $uploadScript = Join-Path $scriptDir "scripts\update-system\upload-version-json.ps1"
        & $uploadScript -Version $Version -GitHubToken $GitHubToken
    }
    
    "azure" {
        if (-not $Version) {
            Write-Error "Version ist erforderlich für Azure Upload. Verwendung: .\update-tools.ps1 azure -Version 1.0.111"
            exit 1
        }
        
        if (-not $GitHubToken) {
            Write-Error "GitHub Token ist erforderlich für Azure Upload. Setzen Sie GITHUB_TOKEN oder übergeben Sie -GitHubToken"
            exit 1
        }
        
        Write-Host "🚀 Starte Azure Pipeline Upload für Version $Version..." -ForegroundColor Cyan
        $azureScript = Join-Path $scriptDir "scripts\azure-devops\azure-upload-version-json.ps1"
        & $azureScript -Version $Version -GitHubToken $GitHubToken
    }
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Script fehlgeschlagen mit Exit-Code: $LASTEXITCODE"
    exit $LASTEXITCODE
}
