<div align="center">

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
```

### 🐧 Automated Bug Bounty Recon & Linux Toolkit

[![ShellCheck](https://github.com/NotaScripptkiddie/KillerPenguin/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/NotaScripptkiddie/KillerPenguin/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)](#)
[![Platform](https://img.shields.io/badge/platform-Linux-orange.svg)](#requirements)
[![Bash](https://img.shields.io/badge/bash-4%2B-green.svg)](#requirements)

**A focused, command-line reconnaissance toolkit for bug bounty hunters and penetration testers.**<br>
Subdomain enumeration → live probing → WAF detection → URL gathering — all in one pipeline with structured reports.

[Quick Start](#-quick-start) •
[Commands](#-commands) •
[Installation](#-installation) •
[Results](#-scan-results) •
[Configuration](#%EF%B8%8F-configuration)

</div>

---

## ⚡ Quick Start

```bash
# Clone and setup
git clone https://github.com/NotaScripptkiddie/KillerPenguin.git
cd KillerPenguin
chmod +x killerpenguin_master.sh

# Check your environment
./killerpenguin_master.sh doctor

# Run full recon on a target
./killerpenguin_master.sh recon all example.com
```

That's it. Results land in `results/` with a clean summary.

---

## 🎯 What Can It Do?

<table>
<tr>
<td width="50%">

### 🔥 Bug Bounty Recon
| Module | What It Does |
|--------|-------------|
| **Subdomain Discovery** | Finds subdomains using `subfinder` + `assetfinder`, merges & deduplicates |
| **Live Host Probing** | Checks which subdomains are alive using `httpx`, sorts by status code |
| **WAF Detection** | Identifies firewalls with `wafw00f` |
| **VirusTotal Lookup** | Pulls domain intelligence via the VT API |
| **URL Gathering** | Collects known URLs and JS endpoints using `gau` + `katana` |
| **Port Scanning** | Network port scanning with `nmap` |

</td>
<td width="50%">

### 🐧 Linux Utilities
| Tool | What It Does |
|------|-------------|
| **Public IP** | Shows your external IP address |
| **IP Geolocation** | Looks up location, ISP, org for any IP |
| **Redirect Checker** | Traces redirect chains for shortened URLs |
| **Password Generator** | Creates random passwords with configurable length |
| **Weather** | Current weather for any city |

</td>
</tr>
</table>

---

## 🚀 Commands

KillerPenguin uses a clean command-based CLI. No confusing flags to memorize.

### Reconnaissance

```bash
# Full recon pipeline (subdomains + live probe + WAF + URLs)
./killerpenguin_master.sh recon all example.com

# Individual modules
./killerpenguin_master.sh recon subs example.com     # Subdomain enumeration only
./killerpenguin_master.sh recon waf  example.com     # WAF detection + VirusTotal
./killerpenguin_master.sh recon urls example.com     # URL gathering only
```

### Scanning

```bash
# Port scan a host
./killerpenguin_master.sh scan ports example.com
./killerpenguin_master.sh scan ports 192.168.1.1
```

### Reports & Tools

```bash
# View a previous scan summary
./killerpenguin_master.sh report results/example_com_2026-09-18_120000

# Interactive menu (beginner-friendly)
./killerpenguin_master.sh menu

# Check tool dependencies
./killerpenguin_master.sh doctor

# Show help / version
./killerpenguin_master.sh --help
./killerpenguin_master.sh --version
```

### Legacy Flags (Still Supported)

Existing users can keep using the original flag syntax:

```bash
./killerpenguin_master.sh -d example.com -s -w -g    # Individual modules
./killerpenguin_master.sh -d example.com -a           # All recon modules
```

---

## 📦 Installation

### Requirements

| Requirement | Details |
|-------------|---------|
| **OS** | Native Linux only (Kali, Ubuntu, Debian, Arch, Fedora) |
| **Shell** | Bash 4+ |
| **Core** | `curl` (required for network utilities) |

> **Note:** Windows PowerShell, Command Prompt, Git Bash, WSL, and macOS are intentionally unsupported. KillerPenguin is built for native Linux terminals.

### Step 1 — Clone the Repo

```bash
git clone https://github.com/NotaScripptkiddie/KillerPenguin.git
cd KillerPenguin
chmod +x killerpenguin_master.sh
```

### Step 2 — Install Recon Tools

KillerPenguin works even with missing tools — it skips what's unavailable and warns you. But for full power, install these:

#### Go-Based Tools (Recon & Crawling)

Make sure [Go](https://go.dev/dl/) is installed first, then:

```bash
# Subdomain Discovery
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/tomnomnom/assetfinder@latest

# Live Host Probing
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

# URL Gathering
go install -v github.com/lc/gau/v2/cmd/gau@latest
go install -v github.com/projectdiscovery/katana/cmd/katana@latest
```

> Make sure `~/go/bin` is in your `PATH`:
> ```bash
> echo 'export PATH=$PATH:$HOME/go/bin' >> ~/.bashrc && source ~/.bashrc
> ```

#### Python-Based Tools

```bash
pip install wafw00f
```

#### System Packages

```bash
# Debian / Ubuntu / Kali
sudo apt install -y nmap curl

# Arch
sudo pacman -S nmap curl

# Fedora
sudo dnf install -y nmap curl
```

### Step 3 — Verify Installation

```bash
./killerpenguin_master.sh doctor
```

This shows a checklist of all tools — green for installed, yellow for missing:

```
── Environment check ──
  [+] curl available
  [+] nmap available
  [+] subfinder available
  [+] assetfinder available
  [+] httpx available
  [!] gau missing
  [!] katana missing
  [+] wafw00f available

  [!] 2 optional tool(s) are unavailable.
```

---

## 📂 Scan Results

Every scan creates a **timestamped directory** inside `results/` so scans never overwrite each other:

```
results/example_com_2026-09-18_120000/
├── subs_subfinder.txt       # Raw subfinder output
├── subs_assetfinder.txt     # Raw assetfinder output
├── all_subdomains.txt       # Merged & deduplicated subdomains
├── live_results.txt         # httpx live probe results
├── status_200.txt           # Live targets (200 OK)
├── status_300.txt           # Redirects (3xx)
├── status_400.txt           # Client errors (4xx)
├── status_500.txt           # Server errors (5xx)
├── waf.txt                  # WAF detection results
├── vt_report.json           # VirusTotal domain report
├── gau.txt                  # Gau URL results
├── katana.txt               # Katana JS crawl results
├── all_urls.txt             # Merged & deduplicated URLs
├── summary.md               # Human-readable scan report
└── summary.json             # Machine-readable scan data
```

### Reading a Report

```bash
# View a scan summary
./killerpenguin_master.sh report results/example_com_2026-09-18_120000
```

Example `summary.md` output:

```markdown
# KillerPenguin scan summary

- Target: `example.com`
- Mode: `all`
- Completed: 2026-09-18T12:05:30Z
- Unique subdomains: 47
- Live hosts: 23
- Unique URLs: 1,284
```

### Custom Output Directory

```bash
export KILLERPENGUIN_OUTPUT_DIR="/path/to/my/scans"
./killerpenguin_master.sh recon all example.com
```

---

## ⚙️ Configuration

KillerPenguin uses **environment variables** for configuration. No secrets are stored in source code.

| Variable | Purpose | Required |
|----------|---------|----------|
| `VT_API_KEY` | VirusTotal API key for domain reports | Optional |
| `KILLERPENGUIN_OUTPUT_DIR` | Custom output directory for results | Optional |

### Setting Up VirusTotal

1. Get a free API key at [virustotal.com](https://www.virustotal.com/gui/join-us)
2. Export it in your terminal:

```bash
export VT_API_KEY='your_api_key_here'
./killerpenguin_master.sh recon waf example.com
```

> **Security:** Never paste your API key into the script file. Use environment variables or a `.env` file (which is git-ignored). See [`.env.example`](.env.example) for the supported variable names.

---

## 🔒 Security & Legal

> **⚠️ This tool is for authorized security testing only.**

- Always obtain **written permission** before scanning targets you don't own
- Unauthorized scanning is **illegal** under computer fraud laws
- The `--scope` lock ensures scans stay within the target domain
- All API keys are loaded from environment variables, never from source code
- `.env` files and scan results are git-ignored by default

---

## 🧪 Development

### Code Quality Checks

Every push and pull request runs automated checks via GitHub Actions:

```bash
# Run locally before pushing
bash -n killerpenguin_master.sh          # Syntax check
shellcheck killerpenguin_master.sh       # Lint check
```

### Project Structure

```
KillerPenguin/
├── killerpenguin_master.sh    # Main toolkit (v2.1.0)
├── Killerpenguin.sh           # Original v1 script (preserved)
├── .env.example               # Environment variable template
├── .gitignore                 # Ignores .env files and results/
├── .github/
│   └── workflows/
│       └── shellcheck.yml     # CI: syntax + ShellCheck on every push
├── LICENSE                    # MIT License
├── README.md                  # This file
└── results/                   # Scan output (git-ignored)
```

---

## 📋 Dependency Reference

<details>
<summary><strong>Click to expand full dependency table</strong></summary>

| Tool | Type | Install Command | Used By |
|------|------|----------------|---------|
| `curl` | **Required** | `sudo apt install curl` | Network utilities, API calls |
| `nmap` | Optional | `sudo apt install nmap` | Port scanning |
| `subfinder` | Optional | `go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest` | Subdomain discovery |
| `assetfinder` | Optional | `go install github.com/tomnomnom/assetfinder@latest` | Subdomain discovery |
| `httpx` | Optional | `go install github.com/projectdiscovery/httpx/cmd/httpx@latest` | Live host probing |
| `gau` | Optional | `go install github.com/lc/gau/v2/cmd/gau@latest` | URL gathering |
| `katana` | Optional | `go install github.com/projectdiscovery/katana/cmd/katana@latest` | JS-aware crawling |
| `wafw00f` | Optional | `pip install wafw00f` | WAF detection |
| `yt-dlp` | Optional | `pip install yt-dlp` | Media download |
| `speedtest-cli` | Optional | `pip install speedtest-cli` | Speed testing |

</details>

---

## 🗺️ Roadmap

- [ ] **v3.0** — Python framework layer with 50+ modules (forensics, payload encoding, reverse engineering, OSINT)
- [ ] Advanced crawling pipeline (gospider, hakrawler, paramspider, LinkFinder)
- [ ] URL processing pipeline (uro, unfurl, qsreplace, gf)
- [ ] Vulnerability scanning (nuclei, nikto, SSL audit)
- [ ] HTML report generation with dark theme
- [ ] Exploitation modules (SQLi, XSS, CORS)
- [ ] Payload encoder (XOR, AES, Base64 chaining)
- [ ] Reverse shell generator (20+ languages)

---

## 👤 Author

<table>
<tr>
<td>

**Sumit Nayak**

[![GitHub](https://img.shields.io/badge/GitHub-NotaScripptkiddie-181717?style=flat&logo=github)](https://github.com/NotaScripptkiddie)

</td>
</tr>
</table>

---

## 📜 License

MIT License — use it, fork it, break it, fix it. See [LICENSE](LICENSE).

---

<div align="center">

**Made with 🔥 by Sumit | KillerPenguin v2.1.0**

*Stay dangerous.* 🐧

</div>
