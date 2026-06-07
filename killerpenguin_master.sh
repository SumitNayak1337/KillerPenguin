#!/bin/bash

# ╔═══════════════════════════════════════════════════════════════════╗
# ║            KILLERPENGUIN MASTER — v2.0                           ║
# ║     Bug Bounty Recon + Linux Utility Toolkit                     ║
# ║     Author: Sumit | github.com/SumitNayak1337                    ║
# ╚═══════════════════════════════════════════════════════════════════╝

# ========================== CONFIGURATION ===========================
VT_API_KEY="add_your_api_key"       # VirusTotal API Key

# ========================== COLORS ==================================
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ========================== HELPERS =================================
banner() {
    local art
    art=$(cat <<'EOF'

  ██╗  ██╗██╗██╗     ██╗     ███████╗██████╗ 
  ██║ ██╔╝██║██║     ██║     ██╔════╝██╔══██╗
  █████╔╝ ██║██║     ██║     █████╗  ██████╔╝
  ██╔═██╗ ██║██║     ██║     ██╔══╝  ██╔══██╗
  ██║  ██╗██║███████╗███████╗███████╗██║  ██║
  ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
  ██████╗ ███████╗███╗   ██╗ ██████╗ ██╗   ██╗██╗███╗   ██╗
  ██╔══██╗██╔════╝████╗  ██║██╔════╝ ██║   ██║██║████╗  ██║
  ██████╔╝█████╗  ██╔██╗ ██║██║  ███╗██║   ██║██║██╔██╗ ██║
  ██╔═══╝ ██╔══╝  ██║╚██╗██║██║   ██║██║   ██║██║██║╚██╗██║
  ██║     ███████╗██║ ╚████║╚██████╔╝╚██████╔╝██║██║ ╚████║
  ╚═╝     ╚══════╝╚═╝  ╚═══╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝
         .---.
        /     \        ╔══════════════════════════════════╗
       | o _ o |       ║  Bug Bounty Recon + Linux Tools  ║
       |  \_/  |       ║         MASTER TOOLKIT v2.0      ║
  .----._____.----.    ║           by  Sumit              ║
 (______I_I_I______)   ╚══════════════════════════════════╝
EOF
)
    if command -v lolcat &> /dev/null; then
        echo "$art" | lolcat
    else
        echo -e "${CYAN}${art}${RESET}"
    fi
    echo ""
}

info()    { echo -e "    ${CYAN}[*]${RESET} $1"; }
success() { echo -e "    ${GREEN}[+]${RESET} $1"; }
warn()    { echo -e "    ${YELLOW}[!]${RESET} $1"; }
error()   { echo -e "    ${RED}[-]${RESET} $1"; }
header()  { echo -e "\n${MAGENTA}${BOLD}══════ $1 ══════${RESET}"; }
divider() { echo -e "${DIM}────────────────────────────────────────────────────${RESET}"; }

# ======================== DEPENDENCY CHECK ==========================
check_dependencies() {
    header "Dependency Check"
    local all_deps=("nmap" "curl" "wget" "subfinder" "assetfinder" "httpx"
                    "gau" "katana" "wafw00f" "speedtest-cli" "lolcat" "yt-dlp")
    local missing=0

    for cmd in "${all_deps[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            success "$cmd — installed"
        else
            warn "$cmd — NOT FOUND (some features may be unavailable)"
            ((missing++))
        fi
    done

    if [ "$missing" -eq 0 ]; then
        echo ""
        success "All dependencies are installed! You're good to go."
    else
        echo ""
        warn "$missing tool(s) missing. Install them for full functionality."
    fi
    echo ""
}

# ======================== CLI USAGE HELP ============================
usage() {
    echo -e "${BOLD}Usage:${RESET} $0 ${CYAN}[MODE]${RESET}"
    echo ""
    echo -e "${BOLD}Bug Bounty Recon Mode (CLI Flags):${RESET}"
    echo -e "  $0 ${GREEN}-d <domain>${RESET} [FLAGS]"
    echo -e "    ${GREEN}-s${RESET}   Subdomains + Live Probing"
    echo -e "    ${GREEN}-w${RESET}   WAF Detection + VirusTotal Lookup"
    echo -e "    ${GREEN}-g${RESET}   URL Gathering (Gau + Katana)"
    echo -e "    ${GREEN}-a${RESET}   Run ALL recon modules"
    echo ""
    echo -e "${BOLD}Interactive Mode:${RESET}"
    echo -e "  $0             Launch the full interactive menu"
    echo ""
    echo -e "${BOLD}Other:${RESET}"
    echo -e "  $0 ${GREEN}--check${RESET}     Check all dependencies"
    echo -e "  $0 ${GREEN}-h${RESET}          Show this help"
    echo ""
    echo -e "${BOLD}Examples:${RESET}"
    echo -e "  $0 -d example.com -s -w"
    echo -e "  $0 -d example.com -a"
    echo -e "  $0"
    exit 1
}

# ════════════════════════════════════════════════════════════════════
#                     BUG BOUNTY RECON MODULES
# ════════════════════════════════════════════════════════════════════

# --- Subdomains & Live Probing ---
run_subs() {
    local target="$1"
    local out_dir="$2"
    header "SUBDOMAIN ENUMERATION — $target"

    # Subfinder
    if command -v subfinder &> /dev/null; then
        info "Running Subfinder..."
        subfinder -d "$target" -silent > "$out_dir/subs_subfinder.txt" 2>/dev/null
        success "Subfinder done — $(wc -l < "$out_dir/subs_subfinder.txt") results"
    else
        warn "subfinder not installed, skipping."
        touch "$out_dir/subs_subfinder.txt"
    fi

    # Assetfinder
    if command -v assetfinder &> /dev/null; then
        info "Running Assetfinder..."
        assetfinder --subs-only "$target" > "$out_dir/subs_assetfinder.txt" 2>/dev/null
        success "Assetfinder done — $(wc -l < "$out_dir/subs_assetfinder.txt") results"
    else
        warn "assetfinder not installed, skipping."
        touch "$out_dir/subs_assetfinder.txt"
    fi

    # Merge & Deduplicate
    cat "$out_dir/subs_subfinder.txt" "$out_dir/subs_assetfinder.txt" 2>/dev/null | sort -u > "$out_dir/all_subdomains.txt"
    local total
    total=$(wc -l < "$out_dir/all_subdomains.txt")
    success "Total unique subdomains: $total"

    # Live Probing with httpx
    if command -v httpx &> /dev/null; then
        info "Probing for live hosts (httpx)..."
        httpx -l "$out_dir/all_subdomains.txt" -sc -title -silent -nc > "$out_dir/live_results.txt"

        # Sort by status codes
        grep "\[20" "$out_dir/live_results.txt" | awk '{print $1}' > "$out_dir/status_200.txt"
        grep "\[30" "$out_dir/live_results.txt" | awk '{print $1}' > "$out_dir/status_300.txt"
        grep "\[40" "$out_dir/live_results.txt" | awk '{print $1}' > "$out_dir/status_400.txt"
        grep "\[50" "$out_dir/live_results.txt" | awk '{print $1}' > "$out_dir/status_500.txt"

        success "Live Probing Complete:"
        echo -e "        ${GREEN}200 OK:${RESET}        $(wc -l < "$out_dir/status_200.txt")"
        echo -e "        ${YELLOW}3xx Redirect:${RESET}  $(wc -l < "$out_dir/status_300.txt")"
        echo -e "        ${RED}4xx Forbidden:${RESET} $(wc -l < "$out_dir/status_400.txt")"
        echo -e "        ${RED}5xx Error:${RESET}     $(wc -l < "$out_dir/status_500.txt")"
    else
        warn "httpx not installed, skipping live probe."
    fi
}

# --- WAF & VirusTotal ---
run_waf() {
    local target="$1"
    local out_dir="$2"
    header "WAF DETECTION & VIRUSTOTAL — $target"

    # WAF Check
    if command -v wafw00f &> /dev/null; then
        info "Detecting WAF with wafw00f..."
        wafw00f "$target" > "$out_dir/waf.txt"
        success "WAF results saved → waf.txt"
    else
        warn "wafw00f not installed, skipping WAF detection."
    fi

    # VirusTotal
    if [ "$VT_API_KEY" != "add_your_api_key" ] && [ -n "$VT_API_KEY" ]; then
        info "Querying VirusTotal API..."
        curl --silent --request GET \
          --url "https://www.virustotal.com/api/v3/domains/$target" \
          --header "x-apikey: $VT_API_KEY" \
          -o "$out_dir/vt_report.json"
        success "VirusTotal report saved → vt_report.json"
    else
        warn "VirusTotal API key not configured. Edit VT_API_KEY in the script."
    fi
}

# --- URL Gathering ---
run_gau() {
    local target="$1"
    local out_dir="$2"
    header "URL GATHERING — $target"

    # Gau
    if command -v gau &> /dev/null; then
        info "Running Gau..."
        gau "$target" > "$out_dir/gau.txt" 2>/dev/null
        success "Gau done — $(wc -l < "$out_dir/gau.txt") URLs"
    else
        warn "gau not installed, skipping."
        touch "$out_dir/gau.txt"
    fi

    # Katana
    if command -v katana &> /dev/null; then
        info "Running Katana (depth 3, JS crawl)..."
        katana -u "https://$target" -d 3 -jc -o "$out_dir/katana.txt" > /dev/null 2>&1
        success "Katana done — $(wc -l < "$out_dir/katana.txt") URLs"
    else
        warn "katana not installed, skipping."
        touch "$out_dir/katana.txt"
    fi

    # Merge & Deduplicate
    cat "$out_dir/gau.txt" "$out_dir/katana.txt" 2>/dev/null | sort -u > "$out_dir/all_urls.txt"
    local count
    count=$(wc -l < "$out_dir/all_urls.txt")
    success "Total unique URLs collected: $count"
}

# --- Recon Wrapper (for interactive menu) ---
run_recon_interactive() {
    read -p "    Enter target domain (e.g. example.com): " recon_target
    if [ -z "$recon_target" ]; then
        error "No domain specified."
        return
    fi
    local date_str
    date_str=$(date +%Y-%m-%d_%H%M)
    local recon_dir="${recon_target}_recon_${date_str}"
    mkdir -p "$recon_dir"
    info "Output directory: $recon_dir"
    "$@" "$recon_target" "$recon_dir"
    divider
    success "Results saved in: ${GREEN}$recon_dir${RESET}"
}

# ════════════════════════════════════════════════════════════════════
#                       LINUX UTILITY MODULES
# ════════════════════════════════════════════════════════════════════

# --- Nmap Scan ---
nmap_scan() {
    header "NMAP NETWORK SCANNER"
    read -p "    Enter IP or domain to scan: " target
    if [ -z "$target" ]; then error "No target specified."; return; fi

    if command -v nmap &> /dev/null; then
        info "Scanning $target ..."
        nmap -v "$target"
        success "Nmap scan complete."
    else
        error "nmap is not installed."
    fi
}

# --- Directory Enumeration ---
dir_enum() {
    header "DIRECTORY ENUMERATION"
    read -p "    Enter website URL (e.g. https://example.com): " url
    read -p "    Enter wordlist file path: " wordlist

    if [ -z "$url" ]; then error "No URL specified."; return; fi
    if [ ! -f "$wordlist" ]; then error "Wordlist file not found: $wordlist"; return; fi

    info "Starting directory brute-force on $url"
    local found=0
    while IFS= read -r dir; do
        code=$(curl -s -o /dev/null -w "%{http_code}" "$url/$dir")
        if [ "$code" == "200" ] || [ "$code" == "301" ] || [ "$code" == "302" ]; then
            success "FOUND: $url/$dir  [Status: $code]"
            ((found++))
        fi
    done < "$wordlist"
    echo ""
    success "Enumeration complete. $found directories found."
}

# --- Browse Web ---
browse_web() {
    header "WEB BROWSER"
    read -p "    Enter URL to open: " url
    if [ -z "$url" ]; then error "No URL specified."; return; fi

    if command -v xdg-open &> /dev/null; then
        xdg-open "$url"
        success "Opened in default browser."
    elif command -v open &> /dev/null; then
        open "$url"
        success "Opened in default browser."
    else
        warn "No graphical browser found."
        read -p "    View page source with curl? (y/n): " choice
        if [ "$choice" == "y" ]; then
            curl -s "$url"
        fi
    fi
}

# --- Get Public IP ---
get_ip() {
    header "PUBLIC IP ADDRESS"
    info "Fetching your public IP..."
    local ip
    ip=$(curl -s ifconfig.me)
    if [ -n "$ip" ]; then
        success "Your Public IP: ${GREEN}$ip${RESET}"
    else
        error "Could not fetch IP. Check your internet connection."
    fi
}

# --- IP Lookup ---
check_ip() {
    header "IP GEOLOCATION LOOKUP"
    read -p "    Enter IP address: " ip
    if [ -z "$ip" ]; then error "No IP specified."; return; fi

    info "Looking up $ip ..."
    local result
    result=$(curl -s "http://ip-api.com/json/$ip")
    if command -v python3 &> /dev/null; then
        echo "$result" | python3 -m json.tool
    else
        echo "$result"
    fi
}

# --- Short URL Checker ---
short_url_info() {
    header "SHORT URL REDIRECT CHECKER"
    read -p "    Enter shortened URL: " url
    if [ -z "$url" ]; then error "No URL specified."; return; fi

    info "Tracing redirects..."
    local location
    location=$(curl -sLI "$url" | grep -i "location:" | cut -d " " -f2-)

    if [ -z "$location" ]; then
        warn "No redirect found. The URL might not be shortened."
    else
        success "Redirect chain:"
        echo "$location" | while IFS= read -r loc; do
            echo -e "        ${CYAN}→${RESET} $loc"
        done
    fi
}

# --- System Monitor ---
system_monitor() {
    header "SYSTEM RESOURCE MONITOR"

    echo -e "\n    ${BOLD}${CYAN}CPU Usage:${RESET}"
    if command -v top &> /dev/null; then
        top -bn1 2>/dev/null | grep "Cpu(s)" | sed 's/^/    /'
    else
        warn "top not available on this system."
    fi

    echo -e "\n    ${BOLD}${CYAN}Memory Usage:${RESET}"
    if command -v free &> /dev/null; then
        free -h 2>/dev/null | sed 's/^/    /'
    else
        warn "free not available on this system."
    fi

    echo -e "\n    ${BOLD}${CYAN}Disk Usage:${RESET}"
    df -h 2>/dev/null | sed 's/^/    /'
}

# --- Internet Speed ---
internet_speed() {
    header "INTERNET SPEED TEST"
    if command -v speedtest-cli &> /dev/null; then
        info "Running speed test (this may take a moment)..."
        speedtest-cli --simple | sed 's/^/    /'
    else
        error "speedtest-cli is not installed."
        echo -e "    Install it: ${CYAN}pip install speedtest-cli${RESET}"
    fi
}

# --- Password Generator ---
password_gen() {
    header "RANDOM PASSWORD GENERATOR"
    read -p "    Password length (default 16): " len
    len=${len:-16}

    # Validate numeric input
    if ! [[ "$len" =~ ^[0-9]+$ ]]; then
        error "Invalid length. Using default (16)."
        len=16
    fi

    local password
    password=$(head /dev/urandom | tr -dc 'A-Za-z0-9!@#$%^&*()_+-=' | head -c "$len")
    echo ""
    success "Generated Password:"
    echo -e "    ${BOLD}${GREEN}$password${RESET}"
    echo ""
    info "Password length: $len characters"
}

# --- Weather Info ---
weather_info() {
    header "WEATHER INFORMATION"
    read -p "    Enter city name (e.g. Puri): " city
    if [ -z "$city" ]; then error "No city specified."; return; fi

    info "Fetching weather for $city..."
    curl -s "https://wttr.in/${city}?format=v2"
}

# --- YouTube Downloader ---
youtube_download() {
    header "YOUTUBE VIDEO DOWNLOADER"
    if ! command -v yt-dlp &> /dev/null; then
        error "yt-dlp is not installed."
        echo -e "    Install it: ${CYAN}pip install yt-dlp${RESET}"
        return
    fi

    read -p "    Enter YouTube URL: " yt_url
    if [ -z "$yt_url" ]; then error "No URL specified."; return; fi

    read -p "    Format — (1) mp4 video  (2) mp3 audio  [1]: " fmt_choice
    fmt_choice=${fmt_choice:-1}

    case $fmt_choice in
        1)
            info "Downloading video (best quality)..."
            yt-dlp -f "bestvideo+bestaudio" "$yt_url"
            ;;
        2)
            info "Downloading audio (mp3)..."
            yt-dlp -x --audio-format mp3 "$yt_url"
            ;;
        *)
            warn "Invalid choice. Downloading default format..."
            yt-dlp "$yt_url"
            ;;
    esac
    success "Download complete!"
}

# ════════════════════════════════════════════════════════════════════
#                       INTERACTIVE MENU
# ════════════════════════════════════════════════════════════════════

show_menu() {
    echo ""
    if command -v lolcat &> /dev/null; then
        echo "+══════════════════════════════════════════════════════+" | lolcat
        echo "│          KILLERPENGUIN MASTER TOOLKIT v2.0          │" | lolcat
        echo "+══════════════════════════════════════════════════════+" | lolcat
    else
        echo -e "${MAGENTA}+══════════════════════════════════════════════════════+${RESET}"
        echo -e "${MAGENTA}│${BOLD}          KILLERPENGUIN MASTER TOOLKIT v2.0          ${RESET}${MAGENTA}│${RESET}"
        echo -e "${MAGENTA}+══════════════════════════════════════════════════════+${RESET}"
    fi
    echo ""
    echo -e "  ${RED}${BOLD}🔥 BUG BOUNTY RECON${RESET}"
    echo -e "  ${WHITE}  1)${RESET} Full Recon (Subs + Live Probe)"
    echo -e "  ${WHITE}  2)${RESET} WAF Detection + VirusTotal"
    echo -e "  ${WHITE}  3)${RESET} URL Gathering (Gau + Katana)"
    echo -e "  ${WHITE}  4)${RESET} Nmap Network Scan"
    echo -e "  ${WHITE}  5)${RESET} Directory Enumeration"
    echo ""
    echo -e "  ${CYAN}${BOLD}🐧 LINUX UTILITIES${RESET}"
    echo -e "  ${WHITE}  6)${RESET} Get My Public IP"
    echo -e "  ${WHITE}  7)${RESET} IP Geolocation Lookup"
    echo -e "  ${WHITE}  8)${RESET} Short URL Checker"
    echo -e "  ${WHITE}  9)${RESET} System Resource Monitor"
    echo -e "  ${WHITE} 10)${RESET} Internet Speed Test"
    echo -e "  ${WHITE} 11)${RESET} Password Generator"
    echo -e "  ${WHITE} 12)${RESET} Weather Info"
    echo -e "  ${WHITE} 13)${RESET} YouTube Video Download"
    echo -e "  ${WHITE} 14)${RESET} Browse Web"
    echo ""
    echo -e "  ${YELLOW}${BOLD}⚙️  SYSTEM${RESET}"
    echo -e "  ${WHITE} 15)${RESET} Check Dependencies"
    echo -e "  ${WHITE} 16)${RESET} Clear Terminal"
    echo -e "  ${WHITE}  0)${RESET} Exit"
    echo ""
}

interactive_mode() {
    banner
    echo -e "  ${DIM}Bug Bounty Recon + Linux Utilities — All in One${RESET}"
    echo -e "  ${DIM}Author: Sumit | Type 0 to exit${RESET}"
    echo ""

    while true; do
        show_menu
        read -p "  ➤ Enter your choice: " choice

        case $choice in
            1)  run_recon_interactive run_subs ;;
            2)  run_recon_interactive run_waf ;;
            3)  run_recon_interactive run_gau ;;
            4)  nmap_scan ;;
            5)  dir_enum ;;
            6)  get_ip ;;
            7)  check_ip ;;
            8)  short_url_info ;;
            9)  system_monitor ;;
            10) internet_speed ;;
            11) password_gen ;;
            12) weather_info ;;
            13) youtube_download ;;
            14) browse_web ;;
            15) check_dependencies ;;
            16) clear && banner ;;
            0)
                echo ""
                if command -v lolcat &> /dev/null; then
                    echo "  Exiting KillerPenguin... Stay dangerous! 🐧" | lolcat
                else
                    echo -e "  ${CYAN}Exiting KillerPenguin... Stay dangerous! 🐧${RESET}"
                fi
                echo ""
                exit 0
                ;;
            *)
                error "Invalid option. Please choose 0-16."
                ;;
        esac

        echo ""
        divider
        read -p "  Press Enter to continue..." _
    done
}

# ════════════════════════════════════════════════════════════════════
#                         MAIN ENTRY POINT
# ════════════════════════════════════════════════════════════════════

# If no arguments → interactive mode
if [ $# -eq 0 ]; then
    interactive_mode
    exit 0
fi

# Handle --check and --help
if [ "$1" == "--check" ]; then
    banner
    check_dependencies
    exit 0
fi

if [ "$1" == "--help" ]; then
    usage
fi

# CLI Flag Mode — Parse arguments
TARGET=""
DO_SUBS=false
DO_WAF=false
DO_GAU=false
DO_ALL=false

while getopts "d:swgah" opt; do
    case $opt in
        d) TARGET="$OPTARG" ;;
        s) DO_SUBS=true ;;
        w) DO_WAF=true ;;
        g) DO_GAU=true ;;
        a) DO_ALL=true ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Validate target
if [ -z "$TARGET" ]; then
    error "No target domain specified. Use -d <domain>"
    usage
fi

# Setup output directory
DATE=$(date +%Y-%m-%d_%H%M)
OUT_DIR="${TARGET}_recon_${DATE}"
mkdir -p "$OUT_DIR"

banner
echo -e "  ${BOLD}Target:${RESET}  ${GREEN}$TARGET${RESET}"
echo -e "  ${BOLD}Output:${RESET}  ${CYAN}$OUT_DIR${RESET}"
divider

# Run selected or all modules
if [ "$DO_ALL" = true ]; then
    DO_SUBS=true
    DO_WAF=true
    DO_GAU=true
fi

if [ "$DO_SUBS" = true ]; then run_subs "$TARGET" "$OUT_DIR"; fi
if [ "$DO_WAF" = true ];  then run_waf "$TARGET" "$OUT_DIR"; fi
if [ "$DO_GAU" = true ];  then run_gau "$TARGET" "$OUT_DIR"; fi

# Final Summary
echo ""
divider
success "Scan complete! All results saved in: ${GREEN}$OUT_DIR${RESET}"
echo ""

# Show file listing
echo -e "  ${BOLD}Output Files:${RESET}"
ls -lh "$OUT_DIR" 2>/dev/null | tail -n +2 | while IFS= read -r line; do
    echo -e "    $line"
done
echo ""
