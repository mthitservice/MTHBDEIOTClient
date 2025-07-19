#!/bin/bash
# Debug script for DEB package generation

echo "=== MTH BDE IoT Client - DEB Package Debug ==="
echo "Date: $(date)"
echo "Node Version: $(node --version)"
echo "NPM Version: $(npm --version)"
echo

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "Error: package.json not found. Please run this script from the App directory."
    exit 1
fi

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf release/build
rm -rf dist
rm -rf node_modules/.cache

# Install dependencies
echo "Installing dependencies..."
npm ci

# Build the application
echo "Building application..."
npm run build

# Check if build was successful
if [ ! -d "dist" ]; then
    echo "Error: Build failed - dist directory not found"
    exit 1
fi

echo "Build successful - dist directory created"

# Create the DEB package with verbose output
echo "Creating DEB package..."
export DEBUG=electron-builder
npm run package:raspberry-deb

# Check if DEB files were created
DEB_DIR="release/build"
if [ ! -d "$DEB_DIR" ]; then
    echo "Error: Build directory not found: $DEB_DIR"
    exit 1
fi

# Find and validate DEB files
echo "Checking generated DEB files..."
find "$DEB_DIR" -name "*.deb" | while read debfile; do
    echo "Found DEB file: $debfile"

    # Check file size
    size=$(stat -c%s "$debfile")
    echo "File size: $size bytes ($(echo "scale=2; $size/1024/1024" | bc) MB)"

    # Check file type
    filetype=$(file "$debfile")
    echo "File type: $filetype"

    # Validate DEB package
    if command -v dpkg-deb >/dev/null 2>&1; then
        echo "Validating DEB package structure..."
        if dpkg-deb --info "$debfile" >/dev/null 2>&1; then
            echo "✓ DEB package validation successful"
            echo "Package info:"
            dpkg-deb --info "$debfile"
        else
            echo "✗ DEB package validation failed"
            echo "Attempting to extract control information..."
            dpkg-deb --extract "$debfile" /tmp/deb_extract_test 2>&1 || echo "Extraction failed"
        fi
    else
        echo "dpkg-deb not available for validation"
    fi

    # Check if file is actually a DEB archive
    if [[ "$filetype" == *"Debian"* ]]; then
        echo "✓ File is recognized as Debian package"
    else
        echo "✗ File is NOT recognized as Debian package"
        echo "This may cause installation issues"
    fi

    echo "----------------------------------------"
done

echo "=== Debug completed ==="
