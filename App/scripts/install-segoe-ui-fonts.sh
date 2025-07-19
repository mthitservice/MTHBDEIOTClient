#!/bin/bash

# Script to install Segoe UI fonts on Raspberry Pi
# Run with: sudo bash install-segoe-ui-fonts.sh

echo "🔤 Installing Segoe UI fonts on Raspberry Pi..."

# Create fonts directory if it doesn't exist
sudo mkdir -p /usr/share/fonts/truetype/segoe-ui

# Download Segoe UI fonts (legal alternatives or system fonts)
echo "📥 Downloading font files..."

# Option 1: Install via apt (alternative fonts that look similar)
sudo apt update
sudo apt install -y fonts-liberation fonts-dejavu-core fonts-noto

# Option 2: Copy from Windows system (if available)
# Note: You need to manually copy these files from a Windows system
# Segoe UI fonts are located at: C:\Windows\Fonts\
# Files needed:
# - segoeui.ttf (Segoe UI Regular)
# - segoeuib.ttf (Segoe UI Bold)
# - segoeuii.ttf (Segoe UI Italic)
# - segoeuiz.ttf (Segoe UI Bold Italic)

echo "⚠️  Manual step required:"
echo "   Copy Segoe UI font files from Windows system:"
echo "   From: C:\\Windows\\Fonts\\"
echo "   Files: segoeui.ttf, segoeuib.ttf, segoeuii.ttf, segoeuiz.ttf"
echo "   To: /usr/share/fonts/truetype/segoe-ui/"
echo ""
echo "   Example command (if files are in current directory):"
echo "   sudo cp segoeui*.ttf /usr/share/fonts/truetype/segoe-ui/"

# Update font cache
echo "🔄 Updating font cache..."
sudo fc-cache -f -v

echo "✅ Font installation completed!"
echo "   Restart the application to use the new fonts."
