#!/data/data/com.termux/files/usr/bin/bash

# ============================================
#    YT-DLP TOOL v2.2 - Advanced Edition
#    Complete Video Download Manager for Termux
# ============================================

# ------------------------------
# Global Variables & Colors
# ------------------------------
VERSION="2.2.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$HOME/.config/yt-dlp-tool/config.conf"
DOWNLOAD_HISTORY="$HOME/.config/yt-dlp-tool/history.log"
COOKIES_FILE="$HOME/.config/yt-dlp-tool/cookies.txt"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# Default configuration values
DOWNLOAD_DIR="$HOME/storage/downloads/yt-dlp"
EMBED_THUMBNAILS=true
EMBED_METADATA=true
EMBED_SUBTITLES=false
AUTO_SUBTITLES=false
SUBTITLE_LANGS="en,id,zh-Hans"
AUDIO_FORMAT="mp3"
AUDIO_QUALITY="0"
DEFAULT_QUALITY="best"
KEEP_FILES=false
RESTRICT_FILENAMES=true
USE_COOKIES=false
COOKIES_BROWSER="chrome"
CONCURRENT_DOWNLOADS=1
LIMIT_RATE=""
RETRIES=10
FRAGMENT_RETRIES=10
SLEEP_INTERVAL=0
MAX_SLEEP_INTERVAL=0
CREATE_PLAYLIST_FOLDER=true
PREFER_AV1=false

# ------------------------------
# Core Functions
# ------------------------------

# Initialize configuration
init_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    mkdir -p "$(dirname "$DOWNLOAD_HISTORY")"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        create_default_config
    else
        load_config
    fi
}

# Create default configuration
create_default_config() {
    cat > "$CONFIG_FILE" << EOF
# YT-DLP Tool Configuration File
# Generated: $(date)

# Download Directory
DOWNLOAD_DIR="$DOWNLOAD_DIR"

# Video/Audio Settings
EMBED_THUMBNAILS=true
EMBED_METADATA=true
EMBED_SUBTITLES=false
AUTO_SUBTITLES=false
SUBTITLE_LANGS="en,id,zh-Hans"
AUDIO_FORMAT="mp3"
AUDIO_QUALITY="0"
DEFAULT_QUALITY="best"
KEEP_FILES=false
RESTRICT_FILENAMES=true
PREFER_AV1=false

# Cookie Settings
USE_COOKIES=false
COOKIES_BROWSER="chrome"

# Download Optimization
CONCURRENT_DOWNLOADS=1
LIMIT_RATE=""
RETRIES=10
FRAGMENT_RETRIES=10
SLEEP_INTERVAL=0
MAX_SLEEP_INTERVAL=0

# Playlist Settings
CREATE_PLAYLIST_FOLDER=true
EOF
    echo -e "${GREEN}[✓] Default configuration created${NC}"
}

# Save configuration
save_config() {
    cat > "$CONFIG_FILE" << EOF
# YT-DLP Tool Configuration File
# Last Updated: $(date)

# Download Directory
DOWNLOAD_DIR="$DOWNLOAD_DIR"

# Video/Audio Settings
EMBED_THUMBNAILS=$EMBED_THUMBNAILS
EMBED_METADATA=$EMBED_METADATA
EMBED_SUBTITLES=$EMBED_SUBTITLES
AUTO_SUBTITLES=$AUTO_SUBTITLES
SUBTITLE_LANGS="$SUBTITLE_LANGS"
AUDIO_FORMAT="$AUDIO_FORMAT"
AUDIO_QUALITY="$AUDIO_QUALITY"
DEFAULT_QUALITY="$DEFAULT_QUALITY"
KEEP_FILES=$KEEP_FILES
RESTRICT_FILENAMES=$RESTRICT_FILENAMES
PREFER_AV1=$PREFER_AV1

# Cookie Settings
USE_COOKIES=$USE_COOKIES
COOKIES_BROWSER="$COOKIES_BROWSER"

# Download Optimization
CONCURRENT_DOWNLOADS=$CONCURRENT_DOWNLOADS
LIMIT_RATE="$LIMIT_RATE"
RETRIES=$RETRIES
FRAGMENT_RETRIES=$FRAGMENT_RETRIES
SLEEP_INTERVAL=$SLEEP_INTERVAL
MAX_SLEEP_INTERVAL=$MAX_SLEEP_INTERVAL

# Playlist Settings
CREATE_PLAYLIST_FOLDER=$CREATE_PLAYLIST_FOLDER
EOF
    echo -e "${GREEN}[✓] Configuration saved${NC}"
}

# Load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        # Source config file safely
        while IFS= read -r line; do
            # Skip comments and empty lines
            [[ "$line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$line" ]] && continue
            # Export the variable
            eval "export $line"
        done < "$CONFIG_FILE"
        echo -e "${GREEN}[✓] Configuration loaded${NC}"
    else
        create_default_config
        load_config
    fi
}

# Get playlist title - FIXED to properly extract from URL
get_playlist_title() {
    local url="$1"
    local title
    
    # Try to get playlist title
    title=$(yt-dlp --flat-playlist --print "%playlist_title" "$url" 2>/dev/null | head -1)
    
    # If that fails, try alternative method
    if [ -z "$title" ] || [ "$title" = "NA" ] || [ "$title" = "n/a" ]; then
        title=$(yt-dlp --flat-playlist --print "%title" "$url" 2>/dev/null | head -1)
    fi
    
    # Sanitize title for folder name
    if [ -n "$title" ] && [ "$title" != "NA" ] && [ "$title" != "n/a" ] && [ "$title" != "null" ]; then
        # Remove invalid characters for folder name
        title=$(echo "$title" | sed 's/[\\/:*?"<>|]/_/g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        # Limit length
        title=$(echo "$title" | cut -c1-100)
        echo "$title"
    else
        echo ""
    fi
}

# Get playlist output directory
get_playlist_output_dir() {
    local playlist_title="$1"
    
    if [ "$CREATE_PLAYLIST_FOLDER" = true ] && [ -n "$playlist_title" ]; then
        echo "$DOWNLOAD_DIR/$playlist_title"
    else
        echo "$DOWNLOAD_DIR"
    fi
}

# Show banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                                                          ║"
    echo "║     ██╗   ██╗████████╗      ██████╗ ██╗██████╗           ║"
    echo "║     ╚██╗ ██╔╝╚══██╔══╝      ██╔══██╗██║██╔══██╗          ║"
    echo "║      ╚████╔╝    ██║         ██║  ██║██║██████╔╝          ║"
    echo "║       ╚██╔╝     ██║         ██║  ██║██║██╔═══╝           ║"
    echo "║        ██║      ██║         ██████╔╝██║██║               ║"
    echo "║        ╚═╝      ╚═╝         ╚═════╝ ╚═╝╚═╝               ║"
    echo "║                                                          ║"
    echo "║           Advanced YouTube Downloader v$VERSION             ║"
    echo "║              Termux Edition - Complete Tool              ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${WHITE}┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│  Download Dir: ${GREEN}$DOWNLOAD_DIR${NC}"
    echo -e "${WHITE}│  Quality: ${YELLOW}$DEFAULT_QUALITY${NC}  │  Audio: ${YELLOW}$AUDIO_FORMAT${NC}  │  Thumbnails: ${YELLOW}$EMBED_THUMBNAILS${NC}"
    echo -e "${WHITE}│  Playlist Folder: ${YELLOW}$CREATE_PLAYLIST_FOLDER${NC}"
    echo -e "${WHITE}└──────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# Log download
log_download() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $1 | $2" >> "$DOWNLOAD_HISTORY"
}

# Media type selection
select_media_type() {
    local media_choice
    echo -e "${YELLOW}[?] What would you like to download?${NC}"
    echo -e "  ${GREEN}1)${NC} 🎬 Video (MP4 format)"
    echo -e "  ${GREEN}2)${NC} 🎵 Audio only (MP3 format)"
    echo -e "  ${GREEN}3)${NC} 🎵 Audio only (Custom format)"
    echo ""
    read -p "$(echo -e ${GREEN}"➜ Choose [1-3]: "${NC})" media_choice
    
    case $media_choice in
        1)
            echo -e "${GREEN}[✓] Video mode selected${NC}"
            return 1
            ;;
        2)
            echo -e "${GREEN}[✓] Audio mode selected (MP3)${NC}"
            return 2
            ;;
        3)
            echo -e "${GREEN}[✓] Audio mode selected (Custom)${NC}"
            return 3
            ;;
        *)
            echo -e "${RED}[!] Invalid choice, defaulting to Video mode${NC}"
            sleep 1
            return 1
            ;;
    esac
}

# Get video format with proper audio-video merging - FIXED
get_video_format() {
    local quality="$1"
    local format_string=""
    
    case $quality in
        "best")
            if [ "$PREFER_AV1" = true ]; then
                format_string="bestvideo[ext=mp4][vcodec^=av01]+bestaudio[ext=m4a]/bestvideo[ext=webm][vcodec^=av01]+bestaudio/best[ext=mp4]/best"
            else
                format_string="bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/bestvideo+bestaudio/best"
            fi
            ;;
        "2160p")
            format_string="bestvideo[height<=2160][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=2160]+bestaudio/best[height<=2160]"
            ;;
        "1440p")
            format_string="bestvideo[height<=1440][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=1440]+bestaudio/best[height<=1440]"
            ;;
        "1080p")
            format_string="bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=1080]+bestaudio/best[height<=1080]"
            ;;
        "720p")
            format_string="bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=720]+bestaudio/best[height<=720]"
            ;;
        "480p")
            format_string="bestvideo[height<=480][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=480]+bestaudio/best[height<=480]"
            ;;
        "360p")
            format_string="bestvideo[height<=360][ext=mp4]+bestaudio[ext=m4a]/bestvideo[height<=360]+bestaudio/best[height<=360]"
            ;;
        *)
            format_string="bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
            ;;
    esac
    
    echo "$format_string"
}

# Handle audio download with format selection
download_audio() {
    local url="$1"
    local format_type="$2"
    local is_playlist="$3"
    local playlist_output_dir="$4"
    local format_choice quality_choice audio_quality audio_format
    
    local audio_format="$AUDIO_FORMAT"
    local audio_quality="$AUDIO_QUALITY"
    
    if [ "$format_type" = "custom" ]; then
        echo -e "\n${YELLOW}[?] Select audio format:${NC}"
        echo -e "  ${GREEN}1)${NC} MP3 (Default)"
        echo -e "  ${GREEN}2)${NC} M4A/AAC"
        echo -e "  ${GREEN}3)${NC} OPUS"
        echo -e "  ${GREEN}4)${NC} FLAC (Lossless)"
        echo -e "  ${GREEN}5)${NC} OGG"
        echo -e "  ${GREEN}6)${NC} WAV (Uncompressed)"
        read -p "Choice [1-6]: " format_choice
        
        case $format_choice in
            1) audio_format="mp3" ;;
            2) audio_format="m4a" ;;
            3) audio_format="opus" ;;
            4) audio_format="flac" ;;
            5) audio_format="ogg" ;;
            6) audio_format="wav" ;;
            *) audio_format="mp3" ;;
        esac
        
        echo -e "\n${YELLOW}[?] Audio quality:${NC}"
        echo -e "  ${GREEN}0${NC}) Best quality"
        echo -e "  ${GREEN}5${NC}) Medium quality"
        echo -e "  ${GREEN}9${NC}) Smallest size"
        echo -e "  ${GREEN}c${NC}) Custom bitrate (e.g., 128k, 192k, 320k)"
        read -p "Choice: " quality_choice
        
        if [[ "$quality_choice" == "c" || "$quality_choice" == "C" ]]; then
            read -p "Enter bitrate (e.g., 192k): " audio_quality
        else
            audio_quality="$quality_choice"
        fi
    fi
    
    # Build audio download command
    local output_template
    if [ "$is_playlist" = true ] && [ -n "$playlist_output_dir" ]; then
        output_template="$playlist_output_dir/%(playlist_index)s - %(title)s.%(ext)s"
        mkdir -p "$playlist_output_dir"
        echo -e "${GREEN}[✓] Playlist folder created: $playlist_output_dir${NC}"
    else
        output_template="$DOWNLOAD_DIR/%(title)s.%(ext)s"
    fi
    
    local cmd_array=("yt-dlp" "-x" "--audio-format" "$audio_format" "--audio-quality" "$audio_quality")
    cmd_array+=("-o" "$output_template")
    
    # Add metadata and thumbnail for audio
    if [ "$EMBED_THUMBNAILS" = true ]; then
        cmd_array+=("--embed-thumbnail")
    fi
    
    if [ "$EMBED_METADATA" = true ]; then
        cmd_array+=("--embed-metadata")
    fi
    
    # Add other options
    [ "$RESTRICT_FILENAMES" = true ] && cmd_array+=("--restrict-filenames")
    cmd_array+=("--retries" "$RETRIES")
    cmd_array+=("$url")
    
    echo -e "\n${GREEN}[*] Downloading audio as $audio_format...${NC}"
    if [ "$is_playlist" = true ]; then
        echo -e "${CYAN}[*] Saving to: $playlist_output_dir${NC}"
    fi
    "${cmd_array[@]}"
    return $?
}

# Build yt-dlp command using array for safety
build_command_array() {
    local mode="$1"
    local url="$2"
    local output_template="$3"
    local cmd_array=("yt-dlp")
    
    # Output directory
    if [ -n "$output_template" ]; then
        cmd_array+=("-o" "$output_template")
    else
        cmd_array+=("-o" "$DOWNLOAD_DIR/%(title)s.%(ext)s")
    fi
    
    # Quality settings - FIXED for better video+audio merging
    if [ "$mode" = "audio" ]; then
        cmd_array+=("-x" "--audio-format" "$AUDIO_FORMAT" "--audio-quality" "$AUDIO_QUALITY")
    else
        local format_string=$(get_video_format "$mode")
        cmd_array+=("-f" "$format_string")
    fi
    
    # Thumbnails
    if [ "$EMBED_THUMBNAILS" = true ]; then
        cmd_array+=("--embed-thumbnail")
    fi
    
    # Metadata
    if [ "$EMBED_METADATA" = true ]; then
        cmd_array+=("--embed-metadata")
    fi
    
    # Subtitles
    if [ "$EMBED_SUBTITLES" = true ]; then
        cmd_array+=("--write-subs" "--sub-lang" "$SUBTITLE_LANGS" "--embed-subs")
    fi
    
    if [ "$AUTO_SUBTITLES" = true ]; then
        cmd_array+=("--write-auto-subs" "--sub-lang" "$SUBTITLE_LANGS")
    fi
    
    # Filename restrictions
    if [ "$RESTRICT_FILENAMES" = true ]; then
        cmd_array+=("--restrict-filenames")
    fi
    
    # Cookies
    if [ "$USE_COOKIES" = true ]; then
        if [ -f "$COOKIES_FILE" ]; then
            cmd_array+=("--cookies" "$COOKIES_FILE")
        elif command -v python3 &>/dev/null; then
            cmd_array+=("--cookies-from-browser" "$COOKIES_BROWSER")
        else
            echo -e "${YELLOW}[!] Warning: Cannot extract cookies without python3${NC}"
        fi
    fi
    
    # Download optimization
    cmd_array+=("--concurrent-fragments" "$CONCURRENT_DOWNLOADS")
    cmd_array+=("--retries" "$RETRIES")
    cmd_array+=("--fragment-retries" "$FRAGMENT_RETRIES")
    
    if [ -n "$LIMIT_RATE" ]; then
        cmd_array+=("--limit-rate" "$LIMIT_RATE")
    fi
    
    if [ $SLEEP_INTERVAL -gt 0 ]; then
        cmd_array+=("--sleep-interval" "$SLEEP_INTERVAL")
    fi
    
    if [ $MAX_SLEEP_INTERVAL -gt 0 ]; then
        cmd_array+=("--max-sleep-interval" "$MAX_SLEEP_INTERVAL")
    fi
    
    # Keep files
    if [ "$KEEP_FILES" = true ]; then
        cmd_array+=("--keep-fragments")
    fi
    
    # Add URL
    cmd_array+=("$url")
    
    # Store in global array
    COMMAND_ARRAY=("${cmd_array[@]}")
}

# Execute yt-dlp command safely
execute_ytdlp() {
    local mode="$1"
    local url="$2"
    local custom_format="$3"
    local output_template="$4"
    
    if [ -n "$custom_format" ]; then
        local cmd_array=("yt-dlp" "-f" "$custom_format")
        if [ -n "$output_template" ]; then
            cmd_array+=("-o" "$output_template")
        else
            cmd_array+=("-o" "$DOWNLOAD_DIR/%(title)s.%(ext)s")
        fi
        [ "$EMBED_THUMBNAILS" = true ] && cmd_array+=("--embed-thumbnail")
        [ "$EMBED_METADATA" = true ] && cmd_array+=("--embed-metadata")
        [ "$RESTRICT_FILENAMES" = true ] && cmd_array+=("--restrict-filenames")
        cmd_array+=("$url")
        "${cmd_array[@]}"
        return $?
    else
        build_command_array "$mode" "$url" "$output_template"
        "${COMMAND_ARRAY[@]}"
        return $?
    fi
}

# ------------------------------
# Main Features
# ------------------------------

# Setup Wizard (First Run)
setup_wizard() {
    local dir_choice quality_choice folder_choice thumb_choice meta_choice cookie_choice browser_choice
    
    clear
    echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║           FIRST TIME SETUP WIZARD                       ║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${YELLOW}[?] Where should downloads be saved?${NC}"
    echo -e "    ${GREEN}1)${NC} Default (Downloads/yt-dlp)"
    echo -e "    ${GREEN}2)${NC} Custom location"
    read -p "Choice [1-2]: " dir_choice
    
    if [ "$dir_choice" = "2" ]; then
        echo -e "${GREEN}[+] Enter custom path (e.g., /sdcard/Videos):${NC}"
        read -p "> " DOWNLOAD_DIR
    fi
    
    echo -e "\n${YELLOW}[?] Create separate folder for each playlist?${NC}"
    echo -e "    ${GREEN}y)${NC} Yes (recommended)"
    echo -e "    ${RED}n)${NC} No (all files in one folder)"
    read -p "Choice [y/n]: " folder_choice
    [[ "$folder_choice" = "y" || "$folder_choice" = "Y" ]] && CREATE_PLAYLIST_FOLDER=true || CREATE_PLAYLIST_FOLDER=false
    
    echo -e "\n${YELLOW}[?] Default video quality?${NC}"
    echo -e "    ${GREEN}1)${NC} Best (4K/8K if available)"
    echo -e "    ${GREEN}2)${NC} 1080p"
    echo -e "    ${GREEN}3)${NC} 720p"
    echo -e "    ${GREEN}4)${NC} 480p"
    echo -e "    ${GREEN}5)${NC} Audio only"
    read -p "Choice [1-5]: " quality_choice
    
    case $quality_choice in
        1) DEFAULT_QUALITY="best" ;;
        2) DEFAULT_QUALITY="1080p" ;;
        3) DEFAULT_QUALITY="720p" ;;
        4) DEFAULT_QUALITY="480p" ;;
        5) DEFAULT_QUALITY="audio" ;;
        *) DEFAULT_QUALITY="best" ;;
    esac
    
    echo -e "\n${YELLOW}[?] Embed thumbnails in files?${NC}"
    echo -e "    ${GREEN}y)${NC} Yes (recommended)"
    echo -e "    ${RED}n)${NC} No"
    read -p "Choice [y/n]: " thumb_choice
    [[ "$thumb_choice" = "y" || "$thumb_choice" = "Y" ]] && EMBED_THUMBNAILS=true || EMBED_THUMBNAILS=false
    
    echo -e "\n${YELLOW}[?] Embed video metadata (title, uploader, etc.)?${NC}"
    echo -e "    ${GREEN}y)${NC} Yes"
    echo -e "    ${RED}n)${NC} No"
    read -p "Choice [y/n]: " meta_choice
    [[ "$meta_choice" = "y" || "$meta_choice" = "Y" ]] && EMBED_METADATA=true || EMBED_METADATA=false
    
    echo -e "\n${YELLOW}[?] Use cookies from browser (for age-restricted videos)?${NC}"
    echo -e "    ${GREEN}y)${NC} Yes"
    echo -e "    ${RED}n)${NC} No"
    read -p "Choice [y/n]: " cookie_choice
    
    if [[ "$cookie_choice" = "y" || "$cookie_choice" = "Y" ]]; then
        USE_COOKIES=true
        echo -e "\n${YELLOW}[?] Which browser?${NC}"
        echo -e "    ${GREEN}1)${NC} Chrome"
        echo -e "    ${GREEN}2)${NC} Firefox"
        echo -e "    ${GREEN}3)${NC} Brave"
        echo -e "    ${GREEN}4)${NC} Edge"
        read -p "Choice [1-4]: " browser_choice
        case $browser_choice in
            1) COOKIES_BROWSER="chrome" ;;
            2) COOKIES_BROWSER="firefox" ;;
            3) COOKIES_BROWSER="brave" ;;
            4) COOKIES_BROWSER="edge" ;;
            *) COOKIES_BROWSER="chrome" ;;
        esac
    fi
    
    save_config
    echo -e "\n${GREEN}✓ Setup complete! Configuration saved.${NC}"
    sleep 2
}

# Configuration Menu
config_menu() {
    local config_opt
    
    while true; do
        clear
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║                 CONFIGURATION MENU                       ║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${WHITE}┌─────────────── DOWNLOAD SETTINGS ───────────────┐${NC}"
        echo -e "${GREEN} 1)${NC} Download Directory: ${YELLOW}$DOWNLOAD_DIR${NC}"
        echo -e "${GREEN} 2)${NC} Default Quality: ${YELLOW}$DEFAULT_QUALITY${NC}"
        echo -e "${GREEN} 3)${NC} Audio Format: ${YELLOW}$AUDIO_FORMAT${NC}"
        echo -e "${GREEN} 4)${NC} Audio Quality: ${YELLOW}$AUDIO_QUALITY (0=best, 9=worst)${NC}"
        echo ""
        echo -e "${WHITE}┌─────────────── METADATA SETTINGS ───────────────┐${NC}"
        echo -e "${GREEN} 5)${NC} Embed Thumbnails: ${YELLOW}$EMBED_THUMBNAILS${NC}"
        echo -e "${GREEN} 6)${NC} Embed Metadata: ${YELLOW}$EMBED_METADATA${NC}"
        echo ""
        echo -e "${WHITE}┌─────────────── SUBTITLE SETTINGS ───────────────┐${NC}"
        echo -e "${GREEN} 7)${NC} Embed Subtitles: ${YELLOW}$EMBED_SUBTITLES${NC}"
        echo -e "${GREEN} 8)${NC} Auto-Subtitles: ${YELLOW}$AUTO_SUBTITLES${NC}"
        echo -e "${GREEN} 9)${NC} Subtitle Languages: ${YELLOW}$SUBTITLE_LANGS${NC}"
        echo ""
        echo -e "${WHITE}┌─────────────── COOKIE SETTINGS ─────────────────┐${NC}"
        echo -e "${GREEN}10)${NC} Use Cookies: ${YELLOW}$USE_COOKIES${NC}"
        echo -e "${GREEN}11)${NC} Cookies Browser: ${YELLOW}$COOKIES_BROWSER${NC}"
        echo ""
        echo -e "${WHITE}┌─────────────── ADVANCED SETTINGS ───────────────┐${NC}"
        echo -e "${GREEN}12)${NC} Concurrent Downloads: ${YELLOW}$CONCURRENT_DOWNLOADS${NC}"
        echo -e "${GREEN}13)${NC} Rate Limit: ${YELLOW}${LIMIT_RATE:-None}${NC}"
        echo -e "${GREEN}14)${NC} Retry Count: ${YELLOW}$RETRIES${NC}"
        echo -e "${GREEN}15)${NC} Sleep Interval: ${YELLOW}${SLEEP_INTERVAL}s${NC}"
        echo -e "${GREEN}16)${NC} Restrict Filenames: ${YELLOW}$RESTRICT_FILENAMES${NC}"
        echo -e "${GREEN}17)${NC} Keep Fragments: ${YELLOW}$KEEP_FILES${NC}"
        echo -e "${GREEN}18)${NC} Create Playlist Folder: ${YELLOW}$CREATE_PLAYLIST_FOLDER${NC}"
        echo -e "${GREEN}19)${NC} Prefer AV1 Codec: ${YELLOW}$PREFER_AV1${NC}"
        echo ""
        echo -e "${RED} 0)${NC} Back to Main Menu"
        echo -e "${YELLOW} s)${NC} Save and Exit"
        echo ""
        read -p "Choose option: " config_opt
        
        case $config_opt in
            1) echo -e "${GREEN}[+] New download path:${NC}"; read -p "> " DOWNLOAD_DIR ;;
            2) echo -e "${GREEN}[+] Quality (best/2160p/1440p/1080p/720p/480p/360p/audio):${NC}"; read -p "> " DEFAULT_QUALITY ;;
            3) echo -e "${GREEN}[+] Audio format (mp3/m4a/opus/flac/wav):${NC}"; read -p "> " AUDIO_FORMAT ;;
            4) echo -e "${GREEN}[+] Audio quality (0-9, 0=best):${NC}"; read -p "> " AUDIO_QUALITY ;;
            5) [ "$EMBED_THUMBNAILS" = true ] && EMBED_THUMBNAILS=false || EMBED_THUMBNAILS=true ;;
            6) [ "$EMBED_METADATA" = true ] && EMBED_METADATA=false || EMBED_METADATA=true ;;
            7) [ "$EMBED_SUBTITLES" = true ] && EMBED_SUBTITLES=false || EMBED_SUBTITLES=true ;;
            8) [ "$AUTO_SUBTITLES" = true ] && AUTO_SUBTITLES=false || AUTO_SUBTITLES=true ;;
            9) echo -e "${GREEN}[+] Subtitle languages (comma-separated, e.g., en,id,zh-Hans):${NC}"; read -p "> " SUBTITLE_LANGS ;;
            10) [ "$USE_COOKIES" = true ] && USE_COOKIES=false || USE_COOKIES=true ;;
            11) echo -e "${GREEN}[+] Browser (chrome/firefox/brave/edge):${NC}"; read -p "> " COOKIES_BROWSER ;;
            12) echo -e "${GREEN}[+] Number of concurrent downloads (1-10):${NC}"; read -p "> " CONCURRENT_DOWNLOADS ;;
            13) echo -e "${GREEN}[+] Rate limit (e.g., 50K, 4M, 1G, or leave empty):${NC}"; read -p "> " LIMIT_RATE ;;
            14) echo -e "${GREEN}[+] Retry count:${NC}"; read -p "> " RETRIES ;;
            15) echo -e "${GREEN}[+] Sleep interval between downloads (seconds):${NC}"; read -p "> " SLEEP_INTERVAL ;;
            16) [ "$RESTRICT_FILENAMES" = true ] && RESTRICT_FILENAMES=false || RESTRICT_FILENAMES=true ;;
            17) [ "$KEEP_FILES" = true ] && KEEP_FILES=false || KEEP_FILES=true ;;
            18) [ "$CREATE_PLAYLIST_FOLDER" = true ] && CREATE_PLAYLIST_FOLDER=false || CREATE_PLAYLIST_FOLDER=true ;;
            19) [ "$PREFER_AV1" = true ] && PREFER_AV1=false || PREFER_AV1=true ;;
            0) save_config; break ;;
            s|S) save_config; echo -e "${GREEN}✓ Configuration saved!${NC}"; sleep 1; break ;;
            *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
        esac
        save_config
    done
}

# Download video with media type selection
download_video() {
    local url media_type quality_choice quality show_formats custom_format
    
    clear
    show_banner
    echo -e "${CYAN}┌────────────────── DOWNLOAD VIDEO ──────────────────┐${NC}"
    echo ""
    
    select_media_type
    media_type=$?
    
    echo -e "\n${GREEN}[?] Enter URL:${NC}"
    read -p "> " url
    
    if [ -z "$url" ]; then
        echo -e "${RED}[-] URL cannot be empty!${NC}"
        sleep 1
        return
    fi
    
    if [ $media_type -eq 2 ]; then
        download_audio "$url" "default" false ""
        if [ $? -eq 0 ]; then
            echo -e "\n${GREEN}✓ Audio download completed successfully!${NC}"
            log_download "AUDIO" "$url"
        else
            echo -e "\n${RED}✗ Download failed!${NC}"
        fi
        echo -e "\n${YELLOW}[*] Press Enter to continue...${NC}"
        read
        return
    elif [ $media_type -eq 3 ]; then
        download_audio "$url" "custom" false ""
        if [ $? -eq 0 ]; then
            echo -e "\n${GREEN}✓ Audio download completed successfully!${NC}"
            log_download "AUDIO" "$url"
        else
            echo -e "\n${RED}✗ Download failed!${NC}"
        fi
        echo -e "\n${YELLOW}[*] Press Enter to continue...${NC}"
        read
        return
    fi
    
    echo -e "\n${YELLOW}[?] Quality selection:${NC}"
    echo -e "  ${GREEN}1)${NC} Best (Default: $DEFAULT_QUALITY)"
    echo -e "  ${GREEN}2)${NC} 2160p (4K)"
    echo -e "  ${GREEN}3)${NC} 1440p (2K)"
    echo -e "  ${GREEN}4)${NC} 1080p"
    echo -e "  ${GREEN}5)${NC} 720p"
    echo -e "  ${GREEN}6)${NC} 480p"
    echo -e "  ${GREEN}7)${NC} 360p"
    echo -e "  ${GREEN}8)${NC} Audio only"
    echo -e "  ${GREEN}0)${NC} Use default"
    read -p "Choice: " quality_choice
    
    local quality=""
    case $quality_choice in
        1) quality="$DEFAULT_QUALITY" ;;
        2) quality="2160p" ;;
        3) quality="1440p" ;;
        4) quality="1080p" ;;
        5) quality="720p" ;;
        6) quality="480p" ;;
        7) quality="360p" ;;
        8) quality="audio" ;;
        0) quality="$DEFAULT_QUALITY" ;;
        *) quality="$DEFAULT_QUALITY" ;;
    esac
    
    echo -e "\n${YELLOW}[?] Show available formats first? (y/n)${NC}"
    read -p "> " show_formats
    
    local custom_format=""
    if [[ "$show_formats" = "y" || "$show_formats" = "Y" ]]; then
        echo -e "\n${GREEN}[*] Fetching available formats...${NC}"
        yt-dlp -F "$url"
        echo -e "\n${YELLOW}[?] Custom format code? (press Enter to skip)${NC}"
        read -p "> " custom_format
    fi
    
    echo -e "\n${GREEN}[*] Starting download...${NC}"
    echo -e "${YELLOW}[!] Press Ctrl+C to cancel${NC}\n"
    
    if [ -n "$custom_format" ]; then
        execute_ytdlp "" "$url" "$custom_format" ""
    elif [ "$quality" = "audio" ]; then
        execute_ytdlp "audio" "$url" "" ""
    else
        execute_ytdlp "$quality" "$url" "" ""
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✓ Download completed successfully!${NC}"
        log_download "VIDEO" "$url"
    else
        echo -e "\n${RED}✗ Download failed!${NC}"
    fi
    
    echo -e "\n${YELLOW}[*] Press Enter to continue...${NC}"
    read
}

# Download playlist with folder creation - FIXED
download_playlist() {
    local url media_type quality_choice quality range_choice range items reverse playlist_title custom_folder playlist_output_dir playlist_opts output_template cmd_array
    
    clear
    show_banner
    echo -e "${CYAN}┌────────────────── DOWNLOAD PLAYLIST ─────────────────┐${NC}"
    echo ""
    
    select_media_type
    media_type=$?
    
    echo -e "\n${GREEN}[?] Enter playlist URL:${NC}"
    read -p "> " url
    
    if [ -z "$url" ]; then
        echo -e "${RED}[-] URL cannot be empty!${NC}"
        sleep 1
        return
    fi
    
    # Get playlist title for folder creation - FIXED to properly extract
    local playlist_title=""
    if [ "$CREATE_PLAYLIST_FOLDER" = true ]; then
        echo -e "\n${YELLOW}[*] Fetching playlist information...${NC}"
        playlist_title=$(get_playlist_title "$url")
        if [ -n "$playlist_title" ]; then
            echo -e "${GREEN}[✓] Playlist detected: $playlist_title${NC}"
        else
            echo -e "${YELLOW}[!] Could not detect playlist title${NC}"
            echo -e "${YELLOW}[?] Enter custom folder name (press Enter to skip):${NC}"
            read -p "> " custom_folder
            if [ -n "$custom_folder" ]; then
                playlist_title="$custom_folder"
            fi
        fi
    fi
    
    local playlist_output_dir=$(get_playlist_output_dir "$playlist_title")
    
    if [ "$CREATE_PLAYLIST_FOLDER" = true ] && [ -n "$playlist_title" ]; then
        echo -e "\n${GREEN}[✓] Creating playlist folder: $playlist_output_dir${NC}"
        mkdir -p "$playlist_output_dir"
    fi
    
    if [ $media_type -eq 2 ]; then
        echo -e "\n${YELLOW}[?] Download options for audio playlist:${NC}"
        echo -e "  ${GREEN}1)${NC} Entire playlist"
        echo -e "  ${GREEN}2)${NC} Specific range (e.g., 1-10)"
        echo -e "  ${GREEN}3)${NC} Specific items (e.g., 1,3,5,7)"
        read -p "Choice: " range_choice
        
        local playlist_opts=()
        case $range_choice in
            2)
                echo -e "${GREEN}[+] Enter range (e.g., 1-10):${NC}"
                read -p "> " range
                playlist_opts+=("--playlist-items" "$range")
                ;;
            3)
                echo -e "${GREEN}[+] Enter items (e.g., 1,3,5,7):${NC}"
                read -p "> " items
                playlist_opts+=("--playlist-items" "$items")
                ;;
        esac
        
        echo -e "\n${YELLOW}[?] Reverse order? (y/n)${NC}"
        read -p "> " reverse
        [ "$reverse" = "y" ] && playlist_opts+=("--playlist-reverse")
        
        echo -e "\n${GREEN}[*] Downloading audio playlist as MP3...${NC}"
        echo -e "${CYAN}[*] Saving to: $playlist_output_dir${NC}"
        
        local output_template="$playlist_output_dir/%(playlist_index)s - %(title)s.%(ext)s"
        
        local cmd_array=("yt-dlp" "-x" "--audio-format" "mp3" "--audio-quality" "$AUDIO_QUALITY")
        cmd_array+=("${playlist_opts[@]}")
        cmd_array+=("-o" "$output_template")
        
        if [ "$EMBED_THUMBNAILS" = true ]; then
            cmd_array+=("--embed-thumbnail")
        fi
        if [ "$EMBED_METADATA" = true ]; then
            cmd_array+=("--embed-metadata")
        fi
        [ "$RESTRICT_FILENAMES" = true ] && cmd_array+=("--restrict-filenames")
        cmd_array+=("$url")
        
        "${cmd_array[@]}"
        
        if [ $? -eq 0 ]; then
            echo -e "\n${GREEN}✓ Audio playlist downloaded successfully!${NC}"
            log_download "AUDIO_PLAYLIST" "$url"
        else
            echo -e "\n${RED}✗ Download failed!${NC}"
        fi
        
        echo -e "\n${YELLOW}[*] Press Enter to continue...${NC}"
        read
        return
    elif [ $media_type -eq 3 ]; then
        echo -e "\n${YELLOW}[?] Select audio format:${NC}"
        echo -e "  ${GREEN}1)${NC} MP3"
        echo -e "  ${GREEN}2)${NC} M4A/AAC"
        echo -e "  ${GREEN}3)${NC} OPUS"
        echo -e "  ${GREEN}4)${NC} FLAC"
        echo -e "  ${GREEN}5)${NC} OGG"
        read -p "Choice [1-5]: " format_choice
        
        local audio_format="mp3"
        case $format_choice in
            1) audio_format="mp3" ;;
            2) audio_format="m4a" ;;
            3) audio_format="opus" ;;
            4) audio_format="flac" ;;
            5) audio_format="ogg" ;;
            *) audio_format="mp3" ;;
        esac
        
        echo -e "\n${YELLOW}[?] Download options:${NC}"
        echo -e "  ${GREEN}1)${NC} Entire playlist"
        echo -e "  ${GREEN}2)${NC} Specific range (e.g., 1-10)"
        echo -e "  ${GREEN}3)${NC} Specific items (e.g., 1,3,5,7)"
        read -p "Choice: " range_choice
        
        local playlist_opts=()
        case $range_choice in
            2)
                echo -e "${GREEN}[+] Enter range (e.g., 1-10):${NC}"
                read -p "> " range
                playlist_opts+=("--playlist-items" "$range")
                ;;
            3)
                echo -e "${GREEN}[+] Enter items (e.g., 1,3,5,7):${NC}"
                read -p "> " items
                playlist_opts+=("--playlist-items" "$items")
                ;;
        esac
        
        echo -e "\n${GREEN}[*] Downloading audio playlist as $audio_format...${NC}"
        echo -e "${CYAN}[*] Saving to: $playlist_output_dir${NC}"
        
        local output_template="$playlist_output_dir/%(playlist_index)s - %(title)s.%(ext)s"
        
        local cmd_array=("yt-dlp" "-x" "--audio-format" "$audio_format" "--audio-quality" "$AUDIO_QUALITY")
        cmd_array+=("${playlist_opts[@]}")
        cmd_array+=("-o" "$output_template")
        
        if [ "$EMBED_THUMBNAILS" = true ]; then
            cmd_array+=("--embed-thumbnail")
        fi
        if [ "$EMBED_METADATA" = true ]; then
            cmd_array+=("--embed-metadata")
        fi
        [ "$RESTRICT_FILENAMES" = true ] && cmd_array+=("--restrict-filenames")
        cmd_array+=("$url")
        
        "${cmd_array[@]}"
        
        if [ $? -eq 0 ]; then
            echo -e "\n${GREEN}✓ Audio playlist downloaded successfully!${NC}"
            log_download "AUDIO_PLAYLIST" "$url"
        else
            echo -e "\n${RED}✗ Download failed!${NC}"
        fi
        
        echo -e "\n${YELLOW}[*] Press Enter to continue...${NC}"
        read
        return
    fi
    
    echo -e "\n${YELLOW}[?] Quality selection:${NC}"
    echo -e "  ${GREEN}1)${NC} Best (Default: $DEFAULT_QUALITY)"
    echo -e "  ${GREEN}2)${NC} 2160p (4K)"
    echo -e "  ${GREEN}3)${NC} 1440p (2K)"
    echo -e "  ${GREEN}4)${NC} 1080p"
    echo -e "  ${GREEN}5)${NC} 720p"
    echo -e "  ${GREEN}6)${NC} 480p"
    echo -e "  ${GREEN}7)${NC} 360p"
    echo -e "  ${GREEN}8)${NC} Audio only"
    echo -e "  ${GREEN}0)${NC} Use default"
    read -p "Choice: " quality_choice
    
    local quality=""
    case $quality_choice in
        1) quality="$DEFAULT_QUALITY" ;;
        2) quality="2160p" ;;
        3) quality="1440p" ;;
        4) quality="1080p" ;;
        5) quality="720p" ;;
        6) quality="480p" ;;
        7) quality="360p" ;;
        8) quality="audio" ;;
        0) quality="$DEFAULT_QUALITY" ;;
        *) quality="$DEFAULT_QUALITY" ;;
    esac
    
    echo -e "\n${YELLOW}[?] Download options:${NC}"
    echo -e "  ${GREEN}1)${NC} Entire playlist"
    echo -e "  ${GREEN}2)${NC} Specific range (e.g., 1-10)"
    echo -e "  ${GREEN}3)${NC} Specific items (e.g., 1,3,5,7)"
    read -p "Choice: " range_choice
    
    local playlist_opts=()
    case $range_choice in
        2)
            echo -e "${GREEN}[+] Enter range (e.g., 1-10):${NC}"
            read -p "> " range
            playlist_opts+=("--playlist-items" "$range")
            ;;
        3)
            echo -e "${GREEN}[+] Enter items (e.g., 1,3,5,7):${NC}"
            read -p "> " items
            playlist_opts+=("--playlist-items" "$items")
            ;;
    esac
    
    echo -e "\n${YELLOW}[?] Reverse order? (y/n)${NC}"
    read -p "> " reverse
    [ "$reverse" = "y" ] && playlist_opts+=("--playlist-reverse")
    
    echo -e "\n${GREEN}[*] Downloading video playlist...${NC}"
    echo -e "${CYAN}[*] Saving to: $playlist_output_dir${NC}"
    
    local output_template="$playlist_output_dir/%(playlist_index)s - %(title)s.%(ext)s"
    
    local cmd_array=("yt-dlp" "${playlist_opts[@]}" "-o" "$output_template")
    
    if [ "$quality" = "audio" ]; then
        cmd_array+=("-x" "--audio-format" "$AUDIO_FORMAT" "--audio-quality" "$AUDIO_QUALITY")
    else
        local format_string=$(get_video_format "$quality")
        cmd_array+=("-f" "$format_string")
    fi
    
    [ "$EMBED_THUMBNAILS" = true ] && cmd_array+=("--embed-thumbnail")
    [ "$EMBED_METADATA" = true ] && cmd_array+=("--embed-metadata")
    [ "$RESTRICT_FILENAMES" = true ] && cmd_array+=("--restrict-filenames")
    
    # Add retry settings
    cmd_array+=("--retries" "$RETRIES")
    cmd_array+=("--fragment-retries" "$FRAGMENT_RETRIES")
    
    cmd_array+=("$url")
    
    "${cmd_array[@]}"
    
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✓ Playlist downloaded successfully!${NC}"
        log_download "PLAYLIST" "$url"
    else
        echo -e "\n${RED}✗ Download failed!${NC}"
    fi
    
    echo -e "\n${YELLOW}[*] Press Enter to continue...${NC}"
    read
}

# Batch download from file
batch_download() {
    local batch_file media_choice quality_choice quality audio_quality audio_format_custom url
    
    clear
    show_banner
    echo -e "${CYAN}┌────────────────── BATCH DOWNLOAD ──────────────────┐${NC}"
    echo ""
    
    echo -e "${GREEN}[?] Enter path to URL list file (one URL per line):${NC}"
    read -p "> " batch_file
    
    if [ ! -f "$batch_file" ]; then
        echo -e "${RED}[-] File not found!${NC}"
        sleep 2
        return
    fi
    
    echo -e "\n${YELLOW}[?] What to download?${NC}"
    echo -e "  ${GREEN}1)${NC} Video"
    echo -e "  ${GREEN}2)${NC} Audio only"
    read -p "Choice: " media_choice
    
    echo -e "\n${YELLOW}[?] Quality for batch download:${NC}"
    if [ "$media_choice" = "2" ]; then
        echo -e "  ${GREEN}1)${NC} MP3 (Best quality)"
        echo -e "  ${GREEN}2)${NC} MP3 (Medium)"
        echo -e "  ${GREEN}3)${NC} MP3 (Smallest)"
        echo -e "  ${GREEN}4)${NC} Custom format"
    else
        echo -e "  ${GREEN}1)${NC} Best"
        echo -e "  ${GREEN}2)${NC} 1080p"
        echo -e "  ${GREEN}3)${NC} 720p"
        echo -e "  ${GREEN}4)${NC} 480p"
    fi
    read -p "Choice: " quality_choice
    
    local quality="best"
    local audio_quality="0"
    local audio_format_custom="mp3"
    
    if [ "$media_choice" = "2" ]; then
        case $quality_choice in
            1) audio_quality="0" ;;
            2) audio_quality="5" ;;
            3) audio_quality="9" ;;
            4) echo -e "Enter audio format (mp3/m4a/opus/flac):"; read -p "> " audio_format_custom
               echo -e "Enter quality (0-9 or bitrate like 192k):"; read -p "> " audio_quality
               quality="audio_custom"
               ;;
            *) audio_quality="0" ;;
        esac
    else
        case $quality_choice in
            1) quality="best" ;;
            2) quality="1080p" ;;
            3) quality="720p" ;;
            4) quality="480p" ;;
            *) quality="best" ;;
        esac
    fi
    
    echo -e "\n${GREEN}[*] Starting batch download...${NC}"
    
    while IFS= read -r url; do
        if [ -n "$url" ]; then
            echo -e "\n${YELLOW}[*] Downloading: $url${NC}"
            
            if [ "$media_choice" = "2" ]; then
                if [ "$quality" = "audio_custom" ]; then
                    yt-dlp -x --audio-format "$audio_format_custom" --audio-quality "$audio_quality" \
                           -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" "$url"
                else
                    yt-dlp -x --audio-format mp3 --audio-quality "$audio_quality" \
                           -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" "$url"
                fi
                log_download "BATCH_AUDIO" "$url"
            else
                local format_string=$(get_video_format "$quality")
                yt-dlp -f "$format_string" -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" "$url"
                log_download "BATCH_VIDEO" "$url"
            fi
        fi
    done < "$batch_file"
    
    echo -e "\n${GREEN}✓ Batch download completed!${NC}"
    echo -e "\n${YELLOW}[*] Press Enter to continue...${NC}"
    read
}

# Download history
view_history() {
    local clear_hist
    
    clear
    show_banner
    echo -e "${CYAN}┌────────────────── DOWNLOAD HISTORY ──────────────────┐${NC}"
    echo ""
    
    if [ ! -f "$DOWNLOAD_HISTORY" ] || [ ! -s "$DOWNLOAD_HISTORY" ]; then
        echo -e "${YELLOW}[!] No download history found.${NC}"
    else
        echo -e "${GREEN}Recent downloads:${NC}\n"
        tail -50 "$DOWNLOAD_HISTORY" | while IFS= read -r line; do
            echo -e "${WHITE}$line${NC}"
        done
    fi
    
    echo -e "\n${YELLOW}[?] Clear history? (y/n)${NC}"
    read -p "> " clear_hist
    if [[ "$clear_hist" = "y" || "$clear_hist" = "Y" ]]; then
        > "$DOWNLOAD_HISTORY"
        echo -e "${GREEN}✓ History cleared!${NC}"
    fi
    
    echo -e "\n${YELLOW}[*] Press Enter to continue...${NC}"
    read
}

# Extract audio from existing video
extract_audio() {
    local filepath format_choice output_format output
    
    clear
    show_banner
    echo -e "${CYAN}┌────────────────── EXTRACT AUDIO ───────────────────┐${NC}"
    echo ""
    echo -e "${GREEN}[?] Enter video file path:${NC}"
    read -p "> " filepath
    
    if [ ! -f "$filepath" ]; then
        echo -e "${RED}[-] File not found!${NC}"
        sleep 2
        return
    fi
    
    echo -e "\n${YELLOW}[?] Output audio format:${NC}"
    echo -e "  ${GREEN}1)${NC} MP3 (default)"
    echo -e "  ${GREEN}2)${NC} M4A/AAC"
    echo -e "  ${GREEN}3)${NC} OPUS"
    echo -e "  ${GREEN}4)${NC} FLAC"
    read -p "Choice: " format_choice
    
    local output_format="mp3"
    case $format_choice in
        1) output_format="mp3" ;;
        2) output_format="m4a" ;;
        3) output_format="opus" ;;
        4) output_format="flac" ;;
        *) output_format="mp3" ;;
    esac
    
    output="${filepath%.*}.$output_format"
    
    echo -e "\n${GREEN}[*] Extracting audio...${NC}"
    
    case $output_format in
        mp3)
            ffmpeg -i "$filepath" -q:a 0 -map a "$output" 2>/dev/null
            ;;
        m4a|aac)
            ffmpeg -i "$filepath" -c:a aac -b:a 192k -map a "$output" 2>/dev/null
            ;;
        opus)
            ffmpeg -i "$filepath" -c:a libopus -b:a 128k -map a "$output" 2>/dev/null
            ;;
        flac)
            ffmpeg -i "$filepath" -c:a flac -compression_level 8 -map a "$output" 2>/dev/null
            ;;
        *)
            ffmpeg -i "$filepath" -q:a 0 -map a "$output" 2>/dev/null
            ;;
    esac
    
    if [ $? -eq 0 ] && [ -f "$output" ]; then
        echo -e "${GREEN}✓ Audio extracted to: $output${NC}"
    else
        echo -e "${RED}✗ Extraction failed!${NC}"
    fi
    
    echo -e "\n${YELLOW}[*] Press Enter to continue...${NC}"
    read
}

# Update tool
update_tool() {
    clear
    show_banner
    echo -e "${CYAN}┌────────────────── UPDATE TOOL ────────────────────┐${NC}"
    echo ""
    
    echo -e "${YELLOW}[*] Checking for updates...${NC}"
    
    echo -e "${GREEN}[*] Updating yt-dlp...${NC}"
    pip install -U yt-dlp
    
    echo -e "\n${GREEN}✓ Update completed!${NC}"
    echo -e "\n${YELLOW}[*] Press Enter to continue...${NC}"
    read
}

# Show download directory
open_download_dir() {
    local delete_all
    
    clear
    show_banner
    echo -e "${CYAN}┌────────────────── DOWNLOAD DIRECTORY ──────────────┐${NC}"
    echo ""
    
    if [ -d "$DOWNLOAD_DIR" ]; then
        echo -e "${GREEN}Files and folders in $DOWNLOAD_DIR:${NC}\n"
        ls -lh "$DOWNLOAD_DIR" | tail -20
        
        echo -e "\n${YELLOW}[?] Delete all files and folders? (y/n)${NC}"
        read -p "> " delete_all
        if [[ "$delete_all" = "y" || "$delete_all" = "Y" ]]; then
            rm -rf "$DOWNLOAD_DIR"/*
            echo -e "${GREEN}✓ All files and folders deleted!${NC}"
        fi
    else
        echo -e "${RED}[-] Download directory does not exist!${NC}"
    fi
    
    echo -e "\n${YELLOW}[*] Press Enter to continue...${NC}"
    read
}

# Check system
system_check() {
    clear
    show_banner
    echo -e "${CYAN}┌────────────────── SYSTEM CHECK ───────────────────┐${NC}"
    echo ""
    
    echo -e "${WHITE}[*] Checking dependencies...${NC}\n"
    
    if command -v yt-dlp &> /dev/null; then
        echo -e "${GREEN}✓ yt-dlp: $(yt-dlp --version 2>/dev/null)${NC}"
    else
        echo -e "${RED}✗ yt-dlp: Not installed${NC}"
    fi
    
    if command -v ffmpeg &> /dev/null; then
        echo -e "${GREEN}✓ ffmpeg: $(ffmpeg -version 2>/dev/null | head -1 | cut -d' ' -f3)${NC}"
    else
        echo -e "${RED}✗ ffmpeg: Not installed${NC}"
    fi
    
    if command -v python &> /dev/null; then
        echo -e "${GREEN}✓ python: $(python --version 2>&1)${NC}"
    else
        echo -e "${RED}✗ python: Not installed${NC}"
    fi
    
    if [ -d "$HOME/storage" ]; then
        echo -e "${GREEN}✓ Storage access: Granted${NC}"
    else
        echo -e "${RED}✗ Storage access: Not granted (run 'termux-setup-storage')${NC}"
    fi
    
    echo -e "\n${WHITE}[*] Disk space:${NC}"
    df -h "$HOME" 2>/dev/null | tail -1
    
    echo -e "\n${WHITE}[*] Configuration:${NC}"
    echo -e "  Config file: $CONFIG_FILE"
    echo -e "  Download dir: $DOWNLOAD_DIR"
    echo -e "  History log: $DOWNLOAD_HISTORY"
    echo -e "  Playlist folder: $CREATE_PLAYLIST_FOLDER"
    
    echo -e "\n${YELLOW}[*] Press Enter to continue...${NC}"
    read
}

# ------------------------------
# Main Menu
# ------------------------------
main_menu() {
    local option
    
    while true; do
        show_banner
        echo -e "${WHITE}┌───────────────────── MAIN MENU ──────────────────────┐${NC}"
        echo -e "${WHITE}│                                                      │${NC}"
        echo -e "${GREEN}│  📹 ${WHITE}1)${NC} Download Single Video/Audio"
        echo -e "${GREEN}│  📋 ${WHITE}2)${NC} Download Playlist (Video/Audio)"
        echo -e "${GREEN}│  📦 ${WHITE}3)${NC} Batch Download (from file)"
        echo -e "${GREEN}│  🎵 ${WHITE}4)${NC} Extract Audio from Video"
        echo -e "${WHITE}│                                                      │${NC}"
        echo -e "${CYAN}│  ⚙️  ${WHITE}5)${NC} Configuration Menu"
        echo -e "${CYAN}│  🔧 ${WHITE}6)${NC} System Check"
        echo -e "${CYAN}│  📜 ${WHITE}7)${NC} Download History"
        echo -e "${CYAN}│  📁 ${WHITE}8)${NC} Open Download Directory"
        echo -e "${CYAN}│  🔄 ${WHITE}9)${NC} Update Tool"
        echo -e "${WHITE}│                                                      │${NC}"
        echo -e "${RED}│  ❌ ${WHITE}0)${NC} Exit"
        echo -e "${WHITE}│                                                      │${NC}"
        echo -e "${WHITE}└──────────────────────────────────────────────────────┘${NC}"
        echo ""
        read -p "$(echo -e ${GREEN}"➜ Choose option: "${NC})" option
        
        case $option in
            1) download_video ;;
            2) download_playlist ;;
            3) batch_download ;;
            4) extract_audio ;;
            5) config_menu ;;
            6) system_check ;;
            7) view_history ;;
            8) open_download_dir ;;
            9) update_tool ;;
            0) 
                echo -e "\n${GREEN}✓ Thanks for using YT-DLP Tool!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}✗ Invalid option!${NC}"
                sleep 1
                ;;
        esac
    done
}

# ------------------------------
# Initial Setup
# ------------------------------
init() {
    if [ ! -f "$CONFIG_FILE" ]; then
        clear
        echo -e "${BLUE}"
        echo "╔══════════════════════════════════════════════════════════╗"
        echo "║                                                          ║"
        echo "║     WELCOME TO YT-DLP TOOL - ADVANCED EDITION v$VERSION    ║"
        echo "║                                                          ║"
        echo "║     First time setup required                            ║"
        echo "║                                                          ║"
        echo "╚══════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
        sleep 2
        setup_wizard
    else
        load_config
    fi
    
    mkdir -p "$DOWNLOAD_DIR"
    mkdir -p "$(dirname "$CONFIG_FILE")"
    
    main_menu
}

# ------------------------------
# Start Script
# ------------------------------
init