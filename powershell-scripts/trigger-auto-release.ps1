# Automatic release trigger for Azure DevOps pipeline

param(
    [switch]$Force = $false
)

Write-Host "Automatic release trigger for MTH BDE IoT Client" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green

if (-not (Test-Path "App\package.json")) {
    Write-Host "Error: App\package.json not found. Run this script from repository root." -ForegroundColor Red
    exit 1
}

try {
    $packageJson = Get-Content "App\package.json" | ConvertFrom-Json
    $currentVersion = $packageJson.version
    Write-Host "Current package version: $currentVersion" -ForegroundColor Cyan
}
catch {
    Write-Host "Failed to read App\package.json: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$gitStatus = git status --porcelain
if ($gitStatus -and -not $Force) {
    Write-Host "There are uncommitted changes:" -ForegroundColor Yellow
    git status --short
    $response = Read-Host "Continue? (y/N)"
    if ($response -notmatch "^[Yy]$") {
        Write-Host "Aborted." -ForegroundColor Red
        exit 1
    }
}

$currentBranch = git branch --show-current
Write-Host "Current branch: $currentBranch" -ForegroundColor Cyan

if ($currentBranch -ne "master" -and -not $Force) {
    $response = Read-Host "You are not on master. Continue? (y/N)"
    if ($response -notmatch "^[Yy]$") {
        Write-Host "Aborted." -ForegroundColor Red
        exit 1
    }
}

if ($gitStatus) {
    Write-Host "Committing pending changes..." -ForegroundColor Yellow
    git add .

    $commitMessage = "Pre-release commit for version $currentVersion`n`n[automated-release]"
    git commit -m $commitMessage

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Commit failed." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Pushing to Azure DevOps remote..." -ForegroundColor Yellow
git push origin $currentBranch
if ($LASTEXITCODE -ne 0) {
    Write-Host "Push to origin failed." -ForegroundColor Red
    exit 1
}
Write-Host "Push to origin successful." -ForegroundColor Green

Write-Host ""
Write-Host "Release trigger completed." -ForegroundColor Green
Write-Host "Azure DevOps build: https://dev.azure.com/mth-it-service/MthBdeIotClient/_build" -ForegroundColor Blue
Write-Host "Expected GitHub release: https://github.com/mthitservice/MTHBDEIOTClient/releases" -ForegroundColor Blue

if (-not $Force) {
    $response = Read-Host "Open Azure DevOps build page now? (y/N)"
    if ($response -match "^[Yy]$") {
        Start-Process "https://dev.azure.com/mth-it-service/MthBdeIotClient/_build"
    }
}
