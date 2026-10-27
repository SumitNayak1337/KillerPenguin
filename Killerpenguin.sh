#!/bin/bash

# KillerPenguin Tool
# Author: Sumit

check_dependencies() {
    # Check for required commands
    commands=("nmap" "curl" "wget" "speedtest-cli" "lolcat" "yt-dlp")
    
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" > /dev/null 2>&1; then
            echo "Warning: $cmd is not installed. Some features may not work."
        fi
    done
}

nmap_scan() {
    echo "Nmap Network Scanner"
    read -rp "Enter IP address or domain to scan: " target
    nmap -v "$target"
}

dir_enum() {
    echo "Directory Enumeration"
    read -rp "Enter website URL: " url
    read -rp "Enter wordlist file path: " wordlist
    
    if [ -f "$wordlist" ]; then
        echo "Starting directory enumeration on $url"
        while IFS= read -r dir; do
            code=$(curl -s -o /dev/null -w '%{http_code}' "$url/$dir")
            if [ "$code" = "200" ] || [ "$code" = "301" ] || [ "$code" = "302" ]; then
                echo "Found: $url/$dir (Status: $code)"
            fi
        done < "$wordlist"
    else
        echo "Wordlist file not found!"
    fi
}

browse_web() {
    echo "Browse Web"
    read -rp "Enter URL: " url
    if command -v xdg-open > /dev/null 2>&1; then
        xdg-open "$url"
    elif command -v open > /dev/null 2>&1; then
        open "$url"
    else
        echo "Cannot open browser. Try using curl to view page content:"
        read -rp "View page content with curl? (y/n): " choice
        if [ "$choice" = "y" ]; then
            curl -s "$url"
        fi
    fi
}

get_ip() {
    echo "Your Public IP Address:"
    curl -s ifconfig.me
    echo ""
}

check_ip() {
    echo "IP Information Lookup"
    read -rp "Enter IP Address: " ip
    curl -s "http://ip-api.com/json/$ip" | python3 -m json.tool
}

short_url_info() {
    echo "URL Redirect Checker"
    read -rp "Enter shortened URL: " url
    
    location=$(curl -sI "$url" | grep -i "location:" | cut -d " " -f2-)
    
    if [ -z "$location" ]; then
        echo "No Redirect found. The URL might not be shortened."
    else
        echo "Original URL(s):"
        echo "$location"
    fi
}

system_monitor() {
    echo "Checking System Resources..."
    echo ""
    echo "CPU Usage:"
    top -bn1 | grep "Cpu(s)"
    echo ""
    echo "Memory Usage:"
    free -h
    echo ""
    echo "Disk Usage:"
    df -h
}

internet_speed() {
    echo "Checking Internet Speed....."
    speedtest-cli --simple
}

password_gen() {
    echo "Generating a Random Password..."
    echo ""
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16
    echo ""
}

weather_info() {
    echo "Fetching Weather Information"
    read -rp "Enter City name (Ex- Puri): " city
    curl -s "https://wttr.in/$city?format=3"
}

youtube_download() {
    echo "YouTube Video Downloader"
    read -rp "Enter YouTube URL: " yt_url
    read -rp "Enter Download Format (e.g., mp4, mp3): " format
    yt-dlp -f "$format" "$yt_url"
    echo "Download complete"
}

# Main execution
check_dependencies

# ASCII Penguin with sharp goggles
cat <<'EOF' | lolcat
                      .---.
                     /     \
                    | o _ o |
                    |  \_/  |
     .----._______.-----.----.
    (___________I_I_I_I_I____)
        /      \     /      \
       /        \___/        \
      /                       \
      |     KillerPenguin     |
      \        UTILITY        /
       \      by Sumit       /
        \___________________/
EOF

echo "Linux use is easy you just need to add this Tool" | lolcat
echo "==========================" | lolcat
echo "Author: Sumit" | lolcat
echo " "

while true; do
    echo ""
    echo "+------------------------------------------------+" | lolcat
    echo "|             KILLERPENGUIN TOOL                 |" | lolcat
    echo "+------------------------------------------------+" | lolcat
    echo "| 1) Nmap scan           | 7) System Monitor     |"
    echo "| 2) Directory enum      | 8) Check Internet Speed|"
    echo "| 3) Browse web          | 9) Password generate  |"
    echo "| 4) Get IP Address      | 10) Weather Info      |"
    echo "| 5) Check IP Address    | 11) YouTube Download  |"
    echo "| 6) Check Short URL Info| 12) Clear Terminal    |"
    echo "|                        | 13) Exit              |"
    echo "+------------------------------------------------+"

    read -rp "Enter your choice (1-13): " choice
    case $choice in
        1) nmap_scan ;;
        2) dir_enum ;;
        3) browse_web ;;
        4) get_ip ;;
        5) check_ip ;;
        6) short_url_info ;;
        7) system_monitor ;;
        8) internet_speed ;;
        9) password_gen ;;
        10) weather_info ;;
        11) youtube_download ;;
        12) clear ;;
        13)
            echo "Exiting... Good Bye!" | lolcat
            exit 0
            ;;
        *)
            echo "Invalid Option. Please try again!" | lolcat
            ;;
    esac
done