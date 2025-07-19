# PowerShell Debug script for DEB package generation

Write-Host "=== MTH BDE IoT Client - DEB Package Debug ===" -ForegroundColor Green
Write-Host "Date: $(Get-Date)"
Write-Host "Node Version: $(node --version)"
Write-Host "NPM Version: $(npm --version)"
Write-Host ""

# Check if we're in the right directory
if (!(Test-Path "package.json")) {
    Write-Error "package.json not found. Please run this script from the App directory."
    exit 1
}

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
Remove-Item -Path "release/build" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "dist" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "node_modules/.cache" -Recurse -Force -ErrorAction SilentlyContinue

# Install dependencies
Write-Host "Installing dependencies..." -ForegroundColor Yellow
npm ci

# Build the application
Write-Host "Building application..." -ForegroundColor Yellow
npm run build

# Check if build was successful
if (!(Test-Path "dist")) {
    Write-Error "Build failed - dist directory not found"
    exit 1
}

Write-Host "Build successful - dist directory created" -ForegroundColor Green

# Create the DEB package with verbose output
Write-Host "Creating DEB package..." -ForegroundColor Yellow
$env:DEBUG = "electron-builder"
npm run package:raspberry-deb

# Check if DEB files were created
$debDir = "release/build"
if (!(Test-Path $debDir)) {
    Write-Error "Build directory not found: $debDir"
    exit 1
}

# Find and validate DEB files
Write-Host "Checking generated DEB files..." -ForegroundColor Yellow
$debFiles = Get-ChildItem -Path $debDir -Filter "*.deb" -Recurse

if ($debFiles.Count -eq 0) {
    Write-Error "No DEB files found in build directory"
    exit 1
}

foreach ($debFile in $debFiles) {
    Write-Host "Found DEB file: $($debFile.Name)" -ForegroundColor Cyan

    # Check file size
    $size = $debFile.Length
    $sizeMB = [math]::Round($size / 1MB, 2)
    Write-Host "File size: $size bytes ($sizeMB MB)"

    # Check if file size is reasonable
    if ($size -lt 30MB) {
        Write-Warning "DEB file seems unusually small for an Electron app"
    }

    # Check file header (first few bytes)
    $header = Get-Content $debFile.FullName -Encoding Byte -TotalCount 100
    $headerHex = ($header | ForEach-Object { "{0:X2}" -f $_ }) -join " "
    Write-Host "File header (hex): $($headerHex.Substring(0, [Math]::Min($headerHex.Length, 60)))..."

    # Check for Debian package signature
    $headerString = [System.Text.Encoding]::ASCII.GetString($header)
    if ($headerString -match "debian") {
        Write-Host "✓ Debian signature found in file header" -ForegroundColor Green
    } else {
        Write-Warning "✗ Debian signature not found in file header"
    }

    # Try to extract with 7zip if available
    if (Get-Command "7z" -ErrorAction SilentlyContinue) {
        Write-Host "Testing archive extraction with 7zip..."
        try {
            $result = & 7z t $debFile.FullName 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✓ Archive structure validated with 7zip" -ForegroundColor Green
            } else {
                Write-Warning "✗ Archive structure validation failed with 7zip"
                Write-Host "7zip output: $result"
            }
        } catch {
            Write-Warning "Failed to test with 7zip: $($_.Exception.Message)"
        }
    }

    Write-Host "----------------------------------------"
}

Write-Host "=== Debug completed ===" -ForegroundColor Green

# Additional suggestions
Write-Host ""
Write-Host "Troubleshooting suggestions:" -ForegroundColor Yellow
Write-Host "1. If DEB files are corrupted, try updating electron-builder:"
Write-Host "   npm update electron-builder"
Write-Host ""
Write-Host "2. Clear npm cache and rebuild:"
Write-Host "   npm cache clean --force"
Write-Host "   npm run rebuild"
Write-Host ""
Write-Host "3. Check Node.js version compatibility with electron-builder"
Write-Host "   Current Node.js: $(node --version)"
Write-Host ""
Write-Host "4. Try building on Linux/WSL for better DEB package compatibility"
