```markdown
# 🎬 Social Downloader

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Kali%20Linux%20%7C%20Termux-blue)](https://www.kali.org/)
[![Version](https://img.shields.io/badge/version-1.0-green)](https://github.com/JS-TOOLS-LAB/social-downloader)
[![Python](https://img.shields.io/badge/python-3.x-blue)](https://www.python.org/)
[![yt-dlp](https://img.shields.io/badge/yt--dlp-supported-brightgreen)](https://github.com/yt-dlp/yt-dlp)

> A powerful terminal-based downloader for social media videos and audio. Built for Kali Linux and Termux/Android.

## ✨ Features

- 🎵 **MP3 Extraction** - Extract audio from any video
- 🎬 **MP4 Download** - Download videos with quality selection
- 📱 **Termux Support** - Works perfectly on Android devices
- 🌐 **12+ Platforms** - Support for all major social media
- 🍪 **Cookie Management** - Access protected content
- 💾 **Flexible Storage** - Choose between internal and external storage
- 🔄 **Auto Quality Detection** - Lists all available resolutions
- 🚀 **Fast Downloads** - Powered by yt-dlp

## 📱 Supported Platforms

| Platform | Status | Cookies Required |
|----------|--------|------------------|
| Facebook | ✅ | Private videos only |
| TikTok | ✅ | Rarely needed |
| YouTube | ✅ | No |
| Instagram | ✅ | Sometimes |
| Twitter/X | ✅ | Age-restricted |
| Reddit | ✅ | No |
| Twitch | ✅ | No |
| Vimeo | ✅ | No |
| Dailymotion | ✅ | No |
| Bilibili | ✅ | No |
| Likee | ✅ | No |
| Snapchat | ✅ | Sometimes |

## 📋 Requirements

- Python 3.x
- yt-dlp
- ffmpeg

## 🔧 Installation

### Kali Linux

```bash
# Clone repository
git clone https://github.com/JS-TOOLS-LAB/social-downloader.git
cd social-downloader

# Make executable
chmod +x install.sh

# Run installation (requires sudo)
sudo ./install.sh
```

Termux/Android

```bash
# Update packages
pkg update && pkg upgrade

# Install dependencies
pkg install git ffmpeg python

# Install yt-dlp
pip install yt-dlp

# Clone repository
git clone https://github.com/JS-TOOLS-LAB/social-downloader.git
cd social-downloader

# Make executable
chmod +x smd
```

Manual Installation

```bash
# Install dependencies
pip install yt-dlp
sudo apt install ffmpeg -y  # Kali Linux
# OR
pkg install ffmpeg -y       # Termux

# Download script
wget https://raw.githubusercontent.com/JS-TOOLS-LAB/social-downloader/main/smd
chmod +x smd
sudo mv smd /usr/local/bin/  # Kali Linux
# OR
mv smd $PATH                # Termux
```

🚀 Usage

Simply run the command:

```bash
smd
```

Menu Options

```
===================================
   Social Downloader v1.0
===================================

[1] Download Music (MP3)
[2] Download Video (MP4)
[3] Cookie Settings
[4] About
[5] Exit
```

Download Flow

MP3 Download

1. Select option 1
2. Paste video URL
3. Choose storage location
4. Wait for extraction

MP4 Download

1. Select option 2
2. Paste video URL
3. Choose quality from list
4. Select storage location
5. Wait for download

Quality Selection Example

```
===================================
     Available Video Qualities
===================================

[1] 360x640   (Low - Small file)
[2] 480x852   (Medium)
[3] 720x1280  (HD - Recommended)
[4] 1080x1920 (Full HD - Large file)

[0] Best quality (auto)

Choose quality [0-4]: 
```

Storage Options

Option Path Best For
1 /sdcard/JS-TOOLS-LAB Termux/Android
2 $HOME/JS-TOOLS-LAB Kali Linux

🍪 Cookie Management

When to Use Cookies

· TikTok private videos
· Instagram protected content
· Twitter/X age-restricted videos
· Facebook private videos

Setup Cookies

1. Select option 3 from main menu
2. Choose y to enable cookies
3. Select your browser:
   · Firefox
   · Chrome
   · Chromium
   · Brave
   · Edge
   · Opera
   · Vivaldi
   · Safari
   · File (cookies.txt)

Termux Cookie Method

```bash
# Export cookies from Android browser
1. Install Cookie-Editor extension
2. Log into website
3. Export as Netscape format
4. Save as $HOME/cookies.txt
5. Select "File" option in Cookie Settings
```

📁 Project Structure

```
social-downloader/
├── smd              # Main executable script
├── install.sh       # Installation script
├── README.md        # Documentation
├── LICENSE          # MIT License
└── .gitignore       # Git ignore rules
```

🛠️ Manual Commands

Basic yt-dlp Commands

```bash
# Download best quality video
yt-dlp --merge-output-format mp4 --remux-video mp4 -S "vcodec:h264,res,acodec:aac" "URL"

# Extract MP3 audio
yt-dlp -x --audio-format mp3 --audio-quality 0 "URL"

# List available formats
yt-dlp -F "URL"

# Use browser cookies
yt-dlp --cookies-from-browser firefox "URL"

# Use cookie file
yt-dlp --cookies cookies.txt "URL"
```

Advanced Options

```bash
# Download specific quality
yt-dlp -f "best[height<=720]" "URL"

# Download with custom name
yt-dlp -o "%(title)s.%(ext)s" "URL"

# Download playlist
yt-dlp --yes-playlist "PLAYLIST_URL"

# Limit download speed
yt-dlp --limit-rate 2M "URL"
```

🔍 Troubleshooting

Common Issues

Issue Solution
command not found: smd Run chmod +x smd and add to PATH
yt-dlp: command not found Install: pip install yt-dlp
ffmpeg: command not found Install: sudo apt install ffmpeg (Kali) or pkg install ffmpeg (Termux)
TikTok download fails Update yt-dlp: pip install -U yt-dlp
No video formats URL may be invalid or platform changed API
Permission denied (Termux) Grant storage permission: termux-setup-storage

Debug Mode

```bash
# Run with verbose output
bash -x smd

# Test yt-dlp directly
yt-dlp -v "URL"
```

📊 Performance

Quality Resolution File Size (1 min) Best For
Low 360p ~3 MB Slow connections
Medium 480p ~5 MB Balanced
HD 720p ~10 MB Most users
Full HD 1080p ~20 MB High quality

🔄 Updates

```bash
# Update script
cd social-downloader
git pull

# Update yt-dlp
pip install -U yt-dlp

# Update ffmpeg
sudo apt update && sudo apt upgrade ffmpeg  # Kali
pkg update && pkg upgrade ffmpeg            # Termux
```

🗑️ Uninstall

Kali Linux

```bash
sudo rm /usr/local/bin/smd
rm -rf ~/JS-TOOLS-LAB
rm -rf social-downloader
```

Termux

```bash
rm $PREFIX/bin/smd
rm -rf ~/JS-TOOLS-LAB
rm -rf ~/social-downloader
rm -rf /sdcard/JS-TOOLS-LAB
```

📝 License

MIT License

Copyright (c) 2026 Mr JV Sibanyoni (JS-TOOLS-LAB)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

👤 Author

Mr JV Sibanyoni

· GitHub: @JS-TOOLS-LAB
· Location: South Africa

🌟 Support

· ⭐ Star this repository
· 🐛 Report issues
· 🔧 Submit pull requests
· 📧 Contact for questions

🙏 Acknowledgments

· yt-dlp - The core download engine
· ffmpeg - Media processing
· All contributors and users

---

<div align="center">
Made with ❤️ by JS-TOOLS-LAB
</div>
```
