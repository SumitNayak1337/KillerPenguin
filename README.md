# 🐧 KillerPenguin Master v2.0

```
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
                Bug Bounty Recon + Linux Toolkit
                        by Sumit
```

An all-in-one bash toolkit for **bug bounty hunters** and **Linux power users**. Combines automated reconnaissance with everyday utility tools in a single, colorized, menu-driven script.

---

## ⚡ Quick Start

```bash
git clone https://github.com/SumitNayak1337/coolasit.git
cd coolasit
chmod +x killerpenguin_master.sh
./killerpenguin_master.sh
```

That's it. The script launches an interactive menu with **16 tools** at your fingertips.

---

## 🎯 What Can It Do?

### Bug Bounty Recon
- **Subdomain Enumeration** — discovers subdomains using `subfinder` + `assetfinder`, merges and deduplicates automatically
- **Live Host Probing** — checks which subdomains are alive using `httpx`, sorts by status code (200/300/400/500)
- **WAF Detection** — identifies firewalls with `wafw00f`
- **VirusTotal Lookup** — pulls domain intelligence reports via the VT API
- **URL Gathering** — collects known URLs and JS endpoints using `gau` + `katana`
- **Nmap Scanning** — full network port scanning
- **Directory Brute-force** — finds hidden directories using a wordlist

### Linux Utilities
- **Public IP** — shows your external IP address
- **IP Geolocation** — looks up location, ISP, and org for any IP
- **Short URL Checker** — traces redirect chains for shortened URLs
- **System Monitor** — CPU, memory, and disk usage at a glance
- **Speed Test** — measures download/upload speeds
- **Password Generator** — creates random passwords with configurable length
- **Weather** — current weather for any city
- **YouTube Downloader** — downloads videos (mp4) or audio (mp3)
- **Web Browser** — opens URLs from the terminal

---

## 🚀 How to Use

### Interactive Menu

Run with no arguments to launch the full menu:

```bash
./killerpenguin_master.sh
```

You'll see a categorized menu — just type a number and press Enter:

```
+══════════════════════════════════════════════════════+
│          KILLERPENGUIN MASTER TOOLKIT v2.0          │
+══════════════════════════════════════════════════════+

  🔥 BUG BOUNTY RECON
    1) Full Recon (Subs + Live Probe)
    2) WAF Detection + VirusTotal
    3) URL Gathering (Gau + Katana)
    4) Nmap Network Scan
    5) Directory Enumeration

  🐧 LINUX UTILITIES
    6) Get My Public IP
    7) IP Geolocation Lookup
    8) Short URL Checker
    9) System Resource Monitor
   10) Internet Speed Test
   11) Password Generator
   12) Weather Info
   13) YouTube Video Download
   14) Browse Web

  ⚙️  SYSTEM
   15) Check Dependencies
   16) Clear Terminal
    0) Exit
```

### CLI Flags (Automated Recon)

For quick, non-interactive recon — perfect for scripting and automation:

```bash
# Run ALL recon modules on a target
./killerpenguin_master.sh -d target.com -a

# Just subdomains + live probing
./killerpenguin_master.sh -d target.com -s

# WAF + VirusTotal only
./killerpenguin_master.sh -d target.com -w

# URL gathering only
./killerpenguin_master.sh -d target.com -g

# Mix and match
./killerpenguin_master.sh -d target.com -s -w -g
```

### Other Commands

```bash
# Check if all tools are installed
./killerpenguin_master.sh --check

# Show help
./killerpenguin_master.sh -h
```

---

## 📂 Output

Recon results are saved in timestamped directories so scans never overwrite each other:

```
target.com_recon_2026-06-07_1430/
├── subs_subfinder.txt       # Subfinder results
├── subs_assetfinder.txt     # Assetfinder results
├── all_subdomains.txt       # Merged & deduplicated subdomains
├── live_results.txt         # httpx live probe output
├── status_200.txt           # Live targets (200 OK)
├── status_300.txt           # Redirects (3xx)
├── status_400.txt           # Client errors (4xx)
├── status_500.txt           # Server errors (5xx)
├── waf.txt                  # WAF detection results
├── vt_report.json           # VirusTotal domain report
├── gau.txt                  # Gau URL results
├── katana.txt               # Katana JS crawl results
└── all_urls.txt             # Merged & deduplicated URLs
```

---

## 🔧 Dependencies

The script works even with missing tools — it skips what's not available and warns you. But for full power, install these:

```bash
# Bug bounty tools (Go-based)
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/tomnomnom/assetfinder@latest
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/lc/gau/v2/cmd/gau@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest

# Python-based tools
pip install wafw00f speedtest-cli yt-dlp

# System packages
sudo apt install nmap curl wget lolcat    # Debian/Ubuntu
sudo pacman -S nmap curl wget lolcat      # Arch
```

Run `./killerpenguin_master.sh --check` to see what's installed and what's missing.

---

## ⚙️ Configuration

Edit the top of `killerpenguin_master.sh` to set your VirusTotal API key:

```bash
VT_API_KEY="your_api_key_here"
```

Get a free API key at [virustotal.com](https://www.virustotal.com/gui/join-us).

---

## 🛡️ Legal

This tool is for **authorized security testing only**. Always get written permission before scanning targets you don't own. Unauthorized scanning is illegal.

---

## 👤 Author

**Sumit** — [@SumitNayak1337](https://github.com/SumitNayak1337)

## 📜 License

MIT License — use it, fork it, break it, fix it.

---

Made with 🔥 by Sumit | KillerPenguin Master v2.0
