#!/bin/bash

clear
echo "==================================="
echo "  Social Downloader v1.0 Setup"
echo "==================================="
echo ""

# Check dependencies
echo "[*] Checking dependencies..."

if ! command -v yt-dlp &> /dev/null; then
    echo "[!] yt-dlp not found. Installing..."
    pip install yt-dlp
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "[!] ffmpeg not found. Installing..."
    sudo apt update && sudo apt install ffmpeg -y
fi

echo "[✓] Dependencies OK"
echo ""

# Install script
cp smd-jsil /usr/local/bin/smd-jsil
chmod +x /usr/local/bin/smd-jsil

echo "[✓] Installed to /usr/local/bin/smd-jsil"
echo ""
echo "Usage: Just type 'smd-jsil' in terminal"
echo ""
read -p "Press Enter to exit..."
