# Azure DevOps Pipeline Variable Setup Script
# Führen Sie dieses Script aus, um alle erforderlichen Pipeline Variables zu konfigurieren

param(
    [Parameter(Mandatory = $true)]
    [string]$OrganizationUrl,
    
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory = $true)]
    [string]$PipelineId,
    
    [Parameter(Mandatory = $false)]
    [string]$PersonalAccessToken
)

# Azure DevOps CLI Installation prüfen
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI ist nicht installiert. Bitte installieren Sie es von https://aka.ms/installazurecliwindows" -ForegroundColor Red
    exit 1
}

# Azure DevOps Extension prüfen
$extensions = az extension list --query "[?name=='azure-devops'].name" -o tsv
if (-not $extensions -contains "azure-devops") {
    Write-Host "Installiere Azure DevOps Extension..." -ForegroundColor Yellow
    az extension add --name azure-devops
}

# Anmeldung
if ($PersonalAccessToken) {
    echo $PersonalAccessToken | az devops login --organization $OrganizationUrl
}
else {
    az devops login --organization $OrganizationUrl
}

# Pipeline Variables konfigurieren
Write-Host "Konfiguriere Pipeline Variables..." -ForegroundColor Green

# GitHub Integration Variables
$githubToken = Read-Host -Prompt "GitHub Personal Access Token" -AsSecureString
$githubTokenPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($githubToken))

az pipelines variable create --organization $OrganizationUrl --project $ProjectName --pipeline-id $PipelineId --name "GITHUB_TOKEN" --value $githubTokenPlain --secret true

$githubRepo = Read-Host -Prompt "GitHub Repository (owner/name) [Standard: mthitservice/MthBdeIotClient]"
if (-not $githubRepo) { $githubRepo = "mthitservice/MthBdeIotClient" }
az pipelines variable create --organization $OrganizationUrl --project $ProjectName --pipeline-id $PipelineId --name "GITHUB_REPOSITORY" --value $githubRepo

# API Configuration
$apiUrl = Read-Host -Prompt "API Endpoint URL [Standard: https://api.mth-it-service.com]"
if (-not $apiUrl) { $apiUrl = "https://api.mth-it-service.com" }
az pipelines variable create --organization $OrganizationUrl --project $ProjectName --pipeline-id $PipelineId --name "API_ENDPOINT_URL" --value $apiUrl

$apiKey = Read-Host -Prompt "Production API Key" -AsSecureString
$apiKeyPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKey))
az pipelines variable create --organization $OrganizationUrl --project $ProjectName --pipeline-id $PipelineId --name "API_KEY_PRODUCTION" --value $apiKeyPlain --secret true

# Code Signing (Optional)
$useCodeSigning = Read-Host -Prompt "Windows Code Signing verwenden? (y/n)"
if ($useCodeSigning -eq "y" -or $useCodeSigning -eq "Y") {
    $certThumbprint = Read-Host -Prompt "Code Signing Zertifikat Thumbprint"
    az pipelines variable create --organization $OrganizationUrl --project $ProjectName --pipeline-id $PipelineId --name "SIGNING_CERT_THUMBPRINT" --value $certThumbprint --secret true
    
    $certPassword = Read-Host -Prompt "Code Signing Zertifikat Passwort" -AsSecureString
    $certPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($certPassword))
    az pipelines variable create --organization $OrganizationUrl --project $ProjectName --pipeline-id $PipelineId --name "SIGNING_CERT_PASSWORD" --value $certPasswordPlain --secret true
}

# Database Configuration
$dbConnectionString = Read-Host -Prompt "Database Connection String (optional)"
if ($dbConnectionString) {
    az pipelines variable create --organization $OrganizationUrl --project $ProjectName --pipeline-id $PipelineId --name "DATABASE_CONNECTION_STRING" --value $dbConnectionString --secret true
}

# License Key
$licenseKey = Read-Host -Prompt "Software License Key (optional)"
if ($licenseKey) {
    az pipelines variable create --organization $OrganizationUrl --project $ProjectName --pipeline-id $PipelineId --name "LICENSE_KEY" --value $licenseKey --secret true
}

# Analytics/Sentry (Optional)
$useSentry = Read-Host -Prompt "Sentry Error Tracking verwenden? (y/n)"
if ($useSentry -eq "y" -or $useSentry -eq "Y") {
    $sentryDsn = Read-Host -Prompt "Sentry DSN"
    az pipelines variable create --organization $OrganizationUrl --project $ProjectName --pipeline-id $PipelineId --name "SENTRY_DSN" --value $sentryDsn --secret true
}

$useAnalytics = Read-Host -Prompt "Analytics verwenden? (y/n)"
if ($useAnalytics -eq "y" -or $useAnalytics -eq "Y") {
    $analyticsKey = Read-Host -Prompt "Analytics API Key"
    az pipelines variable create --organization $OrganizationUrl --project $ProjectName --pipeline-id $PipelineId --name "ANALYTICS_KEY" --value $analyticsKey --secret true
}

# Standard Environment Variables
$standardVars = @{
    "NODE_ENV"               = "production"
    "AUTO_UPDATE_ENABLED"    = "true"
    "ENABLE_ANALYTICS"       = "true"
    "ENABLE_ERROR_REPORTING" = "true"
    "DEBUG_MODE"             = "false"
    "DEFAULT_THEME"          = "light"
    "MAX_CONCURRENT_SCANS"   = "10"
    "CACHE_TIMEOUT"          = "300000"
    "KIOSK_MODE"             = "true"
    "FULLSCREEN_MODE"        = "true"
    "HIDE_CURSOR"            = "true"
    "DISABLE_SCREENSAVER"    = "true"
}

Write-Host "Setze Standard Environment Variables..." -ForegroundColor Yellow
foreach ($var in $standardVars.GetEnumerator()) {
    az pipelines variable create --organization $OrganizationUrl --project $ProjectName --pipeline-id $PipelineId --name $var.Key --value $var.Value
}

Write-Host "Pipeline Variables erfolgreich konfiguriert!" -ForegroundColor Green
Write-Host ""
Write-Host "Überprüfen Sie die Variables in Azure DevOps unter:" -ForegroundColor Cyan
Write-Host "$OrganizationUrl/$ProjectName/_build/definition?definitionId=$PipelineId&_a=variables" -ForegroundColor Cyan
Write-Host ""
Write-Host "Nächste Schritte:" -ForegroundColor Yellow
Write-Host "1. Service Connection für GitHub erstellen" -ForegroundColor White
Write-Host "2. Pipeline ausführen mit einem Tag (z.B. v1.0.1)" -ForegroundColor White
Write-Host "3. Release auf GitHub überprüfen" -ForegroundColor White

# Beispiel für Service Connection erstellen
Write-Host ""
Write-Host "Service Connection für GitHub erstellen:" -ForegroundColor Cyan
Write-Host "az devops service-endpoint github create --organization $OrganizationUrl --project $ProjectName --name 'github-connection' --github-url 'https://github.com' --github-pat '$githubTokenPlain'" -ForegroundColor Gray
