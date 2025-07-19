# PowerShell Script für lokale DEB-Paket-Validierung
# validate-deb-package.ps1

param(
    [Parameter(Mandatory=$false)]
    [string]$DebPackagePath = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$BuildFirst = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Verbose = $false
)

function Write-Status {
    param([string]$Message, [string]$Type = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    switch ($Type) {
        "SUCCESS" { Write-Host "[$timestamp] ✓ $Message" -ForegroundColor Green }
        "ERROR"   { Write-Host "[$timestamp] ✗ $Message" -ForegroundColor Red }
        "WARNING" { Write-Host "[$timestamp] ⚠ $Message" -ForegroundColor Yellow }
        default   { Write-Host "[$timestamp] ℹ $Message" -ForegroundColor Cyan }
    }
}

function Test-WSLAvailable {
    try {
        $wslOutput = wsl --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Status "WSL is available" "SUCCESS"
            return $true
        }
    } catch {
        Write-Status "WSL is not available" "WARNING"
        return $false
    }
    return $false
}

function Validate-DebPackage {
    param([string]$PackagePath)
    
    Write-Status "Starting DEB package validation: $PackagePath"
    
    if (-not (Test-Path $PackagePath)) {
        Write-Status "DEB package not found: $PackagePath" "ERROR"
        return $false
    }
    
    $fileSize = (Get-Item $PackagePath).Length
    Write-Status "Package size: $fileSize bytes"
    
    if ($fileSize -lt 10000) {
        Write-Status "Package too small ($fileSize bytes)" "ERROR"
        return $false
    }
    
    # Check if WSL is available for Linux tools
    if (Test-WSLAvailable) {
        Write-Status "Using WSL for validation..."
        
        # Convert Windows path to WSL path
        $wslPath = $PackagePath -replace "\\", "/" -replace "^([A-Za-z]):", "/mnt/`$1"
        $wslPath = $wslPath.ToLower()
        
        # Run validation in WSL
        $validationScript = @"
#!/bin/bash
set -e

debfile='$wslPath'
echo "Validating: `$debfile"

# Check file type
file_type=`$(file "`$debfile")
echo "File type: `$file_type"

# Check if it's a valid AR archive
if ! ar t "`$debfile" >/dev/null 2>&1; then
    echo "ERROR: Not a valid AR archive!"
    exit 1
fi

# List AR archive contents
echo "AR archive contents:"
ar t "`$debfile"

# Check for required AR members
ar_contents=`$(ar t "`$debfile")
if ! echo "`$ar_contents" | grep -q "debian-binary"; then
    echo "ERROR: Missing debian-binary file!"
    exit 1
fi

if ! echo "`$ar_contents" | grep -q "control\.tar"; then
    echo "ERROR: Missing control.tar file!"
    exit 1
fi

if ! echo "`$ar_contents" | grep -q "data\.tar"; then
    echo "ERROR: Missing data.tar file!"
    exit 1
fi

# Check debian-binary version
if ar p "`$debfile" debian-binary | grep -q "2.0"; then
    echo "✓ Debian binary format version: 2.0"
else
    echo "ERROR: Invalid debian-binary version!"
    exit 1
fi

# Use dpkg-deb if available
if command -v dpkg-deb >/dev/null 2>&1; then
    echo "Running dpkg-deb validation..."
    
    if dpkg-deb --info "`$debfile" >/dev/null 2>&1; then
        echo "✓ dpkg-deb validation passed"
        
        echo "Package info:"
        dpkg-deb --info "`$debfile"
        
        echo "Package contents (first 20 lines):"
        dpkg-deb --contents "`$debfile" | head -20
        
    else
        echo "ERROR: dpkg-deb validation failed!"
        exit 1
    fi
else
    echo "WARNING: dpkg-deb not available"
fi

echo "✓ DEB package validation completed successfully"
"@
        
        # Write validation script to temporary file
        $tempScript = [System.IO.Path]::GetTempFileName() + ".sh"
        $validationScript | Out-File -FilePath $tempScript -Encoding UTF8
        
        # Execute in WSL
        $wslTempScript = $tempScript -replace "\\", "/" -replace "^([A-Za-z]):", "/mnt/`$1"
        $wslTempScript = $wslTempScript.ToLower()
        
        try {
            wsl bash $wslTempScript
            $validationResult = $LASTEXITCODE -eq 0
        } finally {
            Remove-Item $tempScript -Force -ErrorAction SilentlyContinue
        }
        
        if ($validationResult) {
            Write-Status "DEB package validation passed" "SUCCESS"
            return $true
        } else {
            Write-Status "DEB package validation failed" "ERROR"
            return $false
        }
    } else {
        Write-Status "WSL not available, performing basic validation..." "WARNING"
        
        # Basic validation without Linux tools
        $fileInfo = Get-Item $PackagePath
        Write-Status "File name: $($fileInfo.Name)"
        Write-Status "File size: $($fileInfo.Length) bytes"
        Write-Status "Last modified: $($fileInfo.LastWriteTime)"
        
        # Check file extension
        if ($fileInfo.Extension -ne ".deb") {
            Write-Status "Invalid file extension: $($fileInfo.Extension)" "ERROR"
            return $false
        }
        
        Write-Status "Basic validation passed (limited without WSL)" "WARNING"
        return $true
    }
}

function Build-DebPackage {
    Write-Status "Building DEB package..."
    
    $appPath = Join-Path $PSScriptRoot "App"
    
    if (-not (Test-Path $appPath)) {
        Write-Status "App directory not found: $appPath" "ERROR"
        return $false
    }
    
    Push-Location $appPath
    
    try {
        Write-Status "Installing dependencies..."
        npm ci
        
        if ($LASTEXITCODE -ne 0) {
            Write-Status "npm ci failed" "ERROR"
            return $false
        }
        
        Write-Status "Building application..."
        npm run build
        
        if ($LASTEXITCODE -ne 0) {
            Write-Status "Build failed" "ERROR"
            return $false
        }
        
        Write-Status "Creating DEB package..."
        npm run package:raspberry-deb
        
        if ($LASTEXITCODE -ne 0) {
            Write-Status "DEB package creation failed" "ERROR"
            return $false
        }
        
        Write-Status "DEB package built successfully" "SUCCESS"
        return $true
    } finally {
        Pop-Location
    }
}

function Find-DebPackages {
    $appPath = Join-Path $PSScriptRoot "App"
    $debFiles = Get-ChildItem -Path $appPath -Filter "*.deb" -Recurse
    
    if ($debFiles.Count -eq 0) {
        Write-Status "No DEB files found in $appPath" "WARNING"
        return @()
    }
    
    Write-Status "Found $($debFiles.Count) DEB file(s):"
    foreach ($file in $debFiles) {
        Write-Status "  - $($file.FullName)"
    }
    
    return $debFiles
}

# Main execution
Write-Status "=== DEB Package Validation Script ==="
Write-Status "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-Status "Script Path: $PSScriptRoot"

try {
    # Build first if requested
    if ($BuildFirst) {
        if (-not (Build-DebPackage)) {
            Write-Status "Build failed, exiting" "ERROR"
            exit 1
        }
    }
    
    # Find DEB packages
    if ([string]::IsNullOrEmpty($DebPackagePath)) {
        $debFiles = Find-DebPackages
        
        if ($debFiles.Count -eq 0) {
            Write-Status "No DEB packages found. Use -BuildFirst to build first." "ERROR"
            exit 1
        }
        
        # Validate all found packages
        $allValid = $true
        foreach ($debFile in $debFiles) {
            if (-not (Validate-DebPackage $debFile.FullName)) {
                $allValid = $false
            }
        }
        
        if ($allValid) {
            Write-Status "All DEB packages are valid" "SUCCESS"
            exit 0
        } else {
            Write-Status "Some DEB packages failed validation" "ERROR"
            exit 1
        }
    } else {
        # Validate specific package
        if (Validate-DebPackage $DebPackagePath) {
            Write-Status "DEB package is valid" "SUCCESS"
            exit 0
        } else {
            Write-Status "DEB package validation failed" "ERROR"
            exit 1
        }
    }
    
} catch {
    Write-Status "Script failed with error: $($_.Exception.Message)" "ERROR"
    if ($Verbose) {
        Write-Status "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    }
    exit 1
}

Write-Status "Script completed successfully" "SUCCESS"
