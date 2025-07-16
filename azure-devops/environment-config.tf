# Environment Configuration für Azure DevOps Pipeline
# Diese Datei definiert alle benötigten Environment Variables

# =============================================================================
# AZURE DEVOPS PIPELINE VARIABLES
# Diese Variablen müssen in Azure DevOps als Pipeline Variables konfiguriert werden
# =============================================================================

# GitHub Integration
variable "github.token" {
  description = "GitHub Personal Access Token für Releases"
  sensitive   = true
  # Berechtigung: repo, write:packages, read:packages
}

variable "github.repository" {
  description = "GitHub Repository (owner/name)"
  default     = "MthBdeIotClient"
}

# Code Signing (Optional für Windows)
variable "signing.certificate.thumbprint" {
  description = "Windows Code Signing Zertifikat Thumbprint"
  sensitive   = true
}

variable "signing.certificate.password" {
  description = "Windows Code Signing Zertifikat Passwort"
  sensitive   = true
}

# Apple Code Signing (Optional für macOS)
variable "apple.developer.id" {
  description = "Apple Developer ID für Code Signing"
  sensitive   = true
}

variable "apple.app.password" {
  description = "Apple App-specific Password für Notarization"
  sensitive   = true
}

# Application API Keys
variable "api.endpoint.url" {
  description = "Haupt-API Endpoint URL"
  default     = "https://api.mth-it-service.com"
}

variable "api.key.production" {
  description = "Produktions-API Schlüssel"
  sensitive   = true
}

variable "api.key.staging" {
  description = "Staging-API Schlüssel"
  sensitive   = true
}

# Database Configuration
variable "database.connection.string" {
  description = "Datenbank Verbindungsstring (falls externe DB)"
  sensitive   = true
}

# License/Update Server
variable "update.server.url" {
  description = "Electron Update Server URL"
  default     = "https://github.com/mthitservice/MthBdeIotClient"
}

variable "license.key" {
  description = "Software Lizenz Schlüssel"
  sensitive   = true
}

# Analytics/Telemetry (Optional)
variable "analytics.key" {
  description = "Analytics Service API Key"
  sensitive   = true
}

variable "sentry.dsn" {
  description = "Sentry DSN für Error Tracking"
  sensitive   = true
}

# =============================================================================
# ENVIRONMENT VARIABLE MAPPINGS
# Diese Variablen werden zur Laufzeit der Anwendung verfügbar gemacht
# =============================================================================

locals {
  environment_variables = {
    # Application Metadata
    "NODE_ENV"                = "production"
    "APP_VERSION"            = var.app_version
    "REACT_APP_VERSION"      = var.app_version
    "BUILD_DATE"             = timestamp()
    "BUILD_NUMBER"           = var.build_number
    
    # API Configuration
    "REACT_APP_API_URL"      = var.api.endpoint.url
    "REACT_APP_API_KEY"      = var.api.key.production
    "API_ENDPOINT"           = var.api.endpoint.url
    
    # Update Configuration
    "ELECTRON_UPDATE_URL"    = var.update.server.url
    "AUTO_UPDATE_ENABLED"    = "true"
    
    # Database
    "DATABASE_URL"           = var.database.connection.string
    "SQLITE_PATH"           = "./public/database/bde.sqlite"
    
    # Security
    "LICENSE_KEY"            = var.license.key
    "ENCRYPTION_KEY"         = random_password.encryption_key.result
    
    # Feature Flags
    "ENABLE_ANALYTICS"       = "true"
    "ENABLE_ERROR_REPORTING" = "true"
    "DEBUG_MODE"            = "false"
    
    # Analytics
    "ANALYTICS_KEY"          = var.analytics.key
    "SENTRY_DSN"            = var.sentry.dsn
    
    # Application Specific
    "DEFAULT_THEME"          = "light"
    "MAX_CONCURRENT_SCANS"   = "10"
    "CACHE_TIMEOUT"         = "300000"
    
    # Raspberry Pi Specific
    "KIOSK_MODE"            = "true"
    "FULLSCREEN_MODE"       = "true"
    "HIDE_CURSOR"           = "true"
    "DISABLE_SCREENSAVER"   = "true"
  }
}

# Random Encryption Key Generation
resource "random_password" "encryption_key" {
  length  = 32
  special = true
}
