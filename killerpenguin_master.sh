#!/usr/bin/env bash
# KillerPenguin — lightweight reconnaissance and Linux utility toolkit
# https://github.com/SumitNayak1337/KillerPenguin

set -o pipefail

readonly APP_NAME="KillerPenguin"
readonly VERSION="2.1.0"
if [[ "${BASH_SOURCE[0]}" == */* ]]; then
    SCRIPT_DIR="$(cd -- "${BASH_SOURCE[0]%/*}" && pwd)"
else
    SCRIPT_DIR="$PWD"
fi
readonly SCRIPT_DIR
readonly OUTPUT_ROOT="${KILLERPENGUIN_OUTPUT_DIR:-$SCRIPT_DIR/results}"
readonly CURL_COMMON=(--fail --silent --show-error --location --connect-timeout 10 --max-time 45)

RED='\033[1;31m'; GREEN='\033[1;32m'; YELLOW='\033[1;33m'; CYAN='\033[1;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { printf '  %b[*]%b %s\n' "$CYAN" "$RESET" "$*"; }
success() { printf '  %b[+]%b %s\n' "$GREEN" "$RESET" "$*"; }
warn()    { printf '  %b[!]%b %s\n' "$YELLOW" "$RESET" "$*" >&2; }
error()   { printf '  %b[-]%b %s\n' "$RED" "$RESET" "$*" >&2; }
header()  { printf '\n%b%s%b\n' "$BOLD$CYAN" "── $* ──" "$RESET"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

require_linux() {
    if [[ "$(uname -s)" != "Linux" ]]; then
        error "$APP_NAME supports native Linux environments only."
        error "Run it from a Linux terminal, not PowerShell, Command Prompt, Git Bash, or macOS."
        return 1
    fi
}

banner() {
    cat <<'EOF'
  _  ___ _ _           ___                 _
 | |/ (_) | | ___ _ __| _ \___ _ _  __ _ _ _(_)_ _
 | ' <| | | |/ -_) '_ \  _/ -_) ' \/ _` | '_| | ' \
 |_|\_\_|_|_|\___|_| |_|_| \___|_||_\__, |_| |_|_||_|
                                      |___/
EOF
    printf '  %b%s v%s%b — recon and Linux utilities\n\n' "$BOLD$CYAN" "$APP_NAME" "$VERSION" "$RESET"
}

usage() {
    cat <<EOF
${APP_NAME} v${VERSION}

Usage:
  $0 menu
  $0 doctor
  $0 recon <subs|waf|urls|all> <domain>
  $0 scan ports <host>
  $0 report <result-directory>
  $0 --version

Examples:
  $0 recon all example.com
  $0 recon subs example.com
  $0 scan ports 192.0.2.10
  $0 report results/example.com_2026-09-18_120000

Legacy flags are still supported:
  $0 -d example.com -s -w -g
  $0 -d example.com -a

Configuration:
  VT_API_KEY                 Optional VirusTotal API key for the waf module
  KILLERPENGUIN_OUTPUT_DIR   Directory for scan results (default: ./results)
EOF
}

validate_domain() {
    local target=${1,,}
    [[ "$target" =~ ^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$ ]]
}

validate_host() {
    local target=$1
    validate_domain "$target" || [[ "$target" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
}

safe_result_name() { printf '%s' "$1" | tr -cd 'A-Za-z0-9.-' | tr '.' '_'; }

create_scan_directory() {
    local target=$1 name timestamp dir
    name=$(safe_result_name "$target")
    timestamp=$(date '+%Y-%m-%d_%H%M%S')
    dir="$OUTPUT_ROOT/${name}_${timestamp}"
    mkdir -p -- "$dir" || return 1
    printf '%s' "$dir"
}

line_count() { [[ -f "$1" ]] && wc -l < "$1" | tr -d ' ' || printf '0'; }

write_summary() {
    local target=$1 scan_dir=$2 mode=$3 now subs urls live
    now=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    subs=$(line_count "$scan_dir/all_subdomains.txt")
    urls=$(line_count "$scan_dir/all_urls.txt")
    live=$(line_count "$scan_dir/live_results.txt")
    cat > "$scan_dir/summary.md" <<EOF
# KillerPenguin scan summary

- Target: \`$target\`
- Mode: \`$mode\`
- Completed: $now
- Unique subdomains: $subs
- Live hosts: $live
- Unique URLs: $urls

See the individual result files in this directory for raw tool output.
EOF
    printf '{\n  "tool": "KillerPenguin",\n  "version": "%s",\n  "target": "%s",\n  "mode": "%s",\n  "completed_at": "%s",\n  "subdomains": %s,\n  "live_hosts": %s,\n  "urls": %s\n}\n' \
        "$VERSION" "$target" "$mode" "$now" "$subs" "$live" "$urls" > "$scan_dir/summary.json"
}

check_dependencies() {
    local dependencies=(curl nmap subfinder assetfinder httpx gau katana wafw00f yt-dlp speedtest-cli)
    local missing=0 cmd
    header "Environment check"
    for cmd in "${dependencies[@]}"; do
        if command_exists "$cmd"; then success "$cmd available"; else warn "$cmd missing"; ((missing++)); fi
    done
    printf '\n'
    if (( missing == 0 )); then success "All optional tools are available."; else warn "$missing optional tool(s) are unavailable."; fi
    info "Results directory: $OUTPUT_ROOT"
}

run_subs() {
    local target=$1 out_dir=$2
    header "Subdomain discovery — $target"
    : > "$out_dir/subs_subfinder.txt"; : > "$out_dir/subs_assetfinder.txt"; : > "$out_dir/live_results.txt"
    if command_exists subfinder; then
        info "Running subfinder..."
        subfinder -d "$target" -silent > "$out_dir/subs_subfinder.txt" 2>"$out_dir/subfinder.stderr" || warn "subfinder did not complete; see subfinder.stderr"
    else warn "subfinder is not installed; skipping."; fi
    if command_exists assetfinder; then
        info "Running assetfinder..."
        assetfinder --subs-only "$target" > "$out_dir/subs_assetfinder.txt" 2>"$out_dir/assetfinder.stderr" || warn "assetfinder did not complete; see assetfinder.stderr"
    else warn "assetfinder is not installed; skipping."; fi
    cat "$out_dir/subs_subfinder.txt" "$out_dir/subs_assetfinder.txt" | sed '/^$/d' | sort -u > "$out_dir/all_subdomains.txt"
    success "$(line_count "$out_dir/all_subdomains.txt") unique subdomains found"
    if command_exists httpx && [[ -s "$out_dir/all_subdomains.txt" ]]; then
        info "Probing discovered hosts with httpx..."
        httpx -l "$out_dir/all_subdomains.txt" -sc -title -silent -nc > "$out_dir/live_results.txt" 2>"$out_dir/httpx.stderr" || warn "httpx did not complete; see httpx.stderr"
        grep -E '\[20[0-9]\]' "$out_dir/live_results.txt" | awk '{print $1}' > "$out_dir/status_200.txt" || true
        grep -E '\[30[0-9]\]' "$out_dir/live_results.txt" | awk '{print $1}' > "$out_dir/status_300.txt" || true
        grep -E '\[40[0-9]\]' "$out_dir/live_results.txt" | awk '{print $1}' > "$out_dir/status_400.txt" || true
        grep -E '\[50[0-9]\]' "$out_dir/live_results.txt" | awk '{print $1}' > "$out_dir/status_500.txt" || true
        success "$(line_count "$out_dir/live_results.txt") live hosts recorded"
    elif ! command_exists httpx; then warn "httpx is not installed; skipping host probing."; fi
}

run_waf() {
    local target=$1 out_dir=$2
    header "WAF and VirusTotal — $target"
    if command_exists wafw00f; then
        info "Running wafw00f..."
        wafw00f "$target" > "$out_dir/waf.txt" 2>"$out_dir/wafw00f.stderr" || warn "wafw00f did not complete; see wafw00f.stderr"
        success "WAF output saved to waf.txt"
    else warn "wafw00f is not installed; skipping WAF detection."; fi
    if [[ -n "${VT_API_KEY:-}" ]]; then
        info "Requesting VirusTotal domain report..."
        if curl "${CURL_COMMON[@]}" --request GET --url "https://www.virustotal.com/api/v3/domains/$target" --header "x-apikey: $VT_API_KEY" --output "$out_dir/vt_report.json"; then
            success "VirusTotal report saved to vt_report.json"
        else
            rm -f -- "$out_dir/vt_report.json"
            warn "VirusTotal request failed; check VT_API_KEY and connectivity."
        fi
    else warn "VT_API_KEY is not set; skipping VirusTotal lookup."; fi
}

run_urls() {
    local target=$1 out_dir=$2
    header "URL gathering — $target"
    : > "$out_dir/gau.txt"; : > "$out_dir/katana.txt"
    if command_exists gau; then
        info "Running gau..."
        gau "$target" > "$out_dir/gau.txt" 2>"$out_dir/gau.stderr" || warn "gau did not complete; see gau.stderr"
    else warn "gau is not installed; skipping."; fi
    if command_exists katana; then
        info "Running katana..."
        katana -u "https://$target" -d 3 -jc -silent -o "$out_dir/katana.txt" > /dev/null 2>"$out_dir/katana.stderr" || warn "katana did not complete; see katana.stderr"
    else warn "katana is not installed; skipping."; fi
    cat "$out_dir/gau.txt" "$out_dir/katana.txt" | sed '/^$/d' | sort -u > "$out_dir/all_urls.txt"
    success "$(line_count "$out_dir/all_urls.txt") unique URLs collected"
}

run_recon() {
    local mode=$1 target=${2,,} scan_dir
    if ! validate_domain "$target"; then error "Use a valid domain such as example.com."; return 2; fi
    case "$mode" in subs|waf|urls|all) ;; *) error "Unknown recon module: $mode"; return 2 ;; esac
    scan_dir=$(create_scan_directory "$target") || { error "Could not create results directory."; return 1; }
    banner; info "Target: $target"; info "Output: $scan_dir"
    case "$mode" in
        subs) run_subs "$target" "$scan_dir" ;;
        waf)  run_waf "$target" "$scan_dir" ;;
        urls) run_urls "$target" "$scan_dir" ;;
        all)  run_subs "$target" "$scan_dir"; run_waf "$target" "$scan_dir"; run_urls "$target" "$scan_dir" ;;
    esac
    write_summary "$target" "$scan_dir" "$mode"
    success "Scan complete. Summary: $scan_dir/summary.md"
}

port_scan() {
    local target=$1
    if ! validate_host "$target"; then error "Use a valid domain or IPv4 address."; return 2; fi
    if ! command_exists nmap; then error "nmap is not installed. Run '$0 doctor' for requirements."; return 1; fi
    header "Port scan — $target"; nmap -v "$target"
}

show_report() {
    local dir=$1
    if [[ ! -d "$dir" || ! -f "$dir/summary.md" ]]; then error "No KillerPenguin result directory found: $dir"; return 2; fi
    cat "$dir/summary.md"
}

get_public_ip() { header "Public IP"; curl "${CURL_COMMON[@]}" https://api.ipify.org && printf '\n'; }
ip_lookup() {
    local ip; read -r -p '  IP address: ' ip
    [[ -n "$ip" ]] || { error "No IP supplied."; return; }
    header "IP lookup — $ip"; curl "${CURL_COMMON[@]}" "https://ipwho.is/$ip" || error "IP lookup failed."; printf '\n'
}
short_url_info() {
    local url; read -r -p '  Short URL (http/https): ' url
    [[ "$url" =~ ^https?:// ]] || { error "Enter an http(s) URL."; return; }
    header "Redirect chain"
    curl "${CURL_COMMON[@]}" -I "$url" | awk 'BEGIN{IGNORECASE=1} /^location:/{print "  -> " $0}' || error "Could not inspect URL."
}
password_gen() {
    local length; read -r -p '  Password length [16]: ' length; length=${length:-16}
    [[ "$length" =~ ^[1-9][0-9]{0,2}$ ]] || { error "Choose a length from 1 to 999."; return; }
    header "Generated password"; LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*()_+-=' < /dev/urandom | head -c "$length"; printf '\n'
}
weather_info() {
    local city; read -r -p '  City: ' city; [[ -n "$city" ]] || { error "No city supplied."; return; }
    header "Weather — $city"; curl "${CURL_COMMON[@]}" "https://wttr.in/${city// /+}?format=v2" || error "Weather lookup failed."
}

interactive_mode() {
    local choice target
    banner
    while true; do
        cat <<'EOF'
  1) Recon: all modules       6) Public IP
  2) Recon: subdomains        7) IP lookup
  3) Recon: WAF/VT            8) Redirect checker
  4) Recon: URLs              9) Password generator
  5) Port scan               10) Weather
 11) Environment check       12) Show help
  0) Exit
EOF
        read -r -p '  Select an option: ' choice
        case "$choice" in
            1|2|3|4)
                read -r -p '  Domain: ' target
                case "$choice" in 1) run_recon all "$target";; 2) run_recon subs "$target";; 3) run_recon waf "$target";; 4) run_recon urls "$target";; esac ;;
            5) read -r -p '  Host: ' target; port_scan "$target" ;;
            6) get_public_ip ;; 7) ip_lookup ;; 8) short_url_info ;; 9) password_gen ;; 10) weather_info ;;
            11) check_dependencies ;; 12) usage ;; 0) printf 'Bye.\n'; return 0 ;;
            *) error "Choose an option from the menu." ;;
        esac
        printf '\n'; read -r -p '  Press Enter to continue...' _
    done
}

legacy_mode() {
    local target='' do_subs=false do_waf=false do_urls=false do_all=false
    OPTIND=1
    while getopts ':d:swgah' opt; do
        case "$opt" in
            d) target=$OPTARG ;; s) do_subs=true ;; w) do_waf=true ;; g) do_urls=true ;; a) do_all=true ;; h) usage; return 0 ;;
            :) error "Option -$OPTARG needs a value."; return 2 ;;
            *) usage; return 2 ;;
        esac
    done
    [[ -n "$target" ]] || { error "Use -d <domain>."; return 2; }
    if "$do_all"; then run_recon all "$target"; return; fi
    if "$do_subs"; then run_recon subs "$target"; fi
    if "$do_waf"; then run_recon waf "$target"; fi
    if "$do_urls"; then run_recon urls "$target"; fi
    if ! "$do_subs" && ! "$do_waf" && ! "$do_urls"; then error "Choose -s, -w, -g, or -a."; return 2; fi
}

main() {
    require_linux || return 1
    case "${1:-menu}" in
        menu) interactive_mode ;;
        doctor|--check) check_dependencies ;;
        --version|-V) printf '%s %s\n' "$APP_NAME" "$VERSION" ;;
        --help|-h|help) usage ;;
        recon) [[ $# -eq 3 ]] || { usage; return 2; }; run_recon "$2" "$3" ;;
        scan) [[ "${2:-}" == ports && $# -eq 3 ]] || { usage; return 2; }; port_scan "$3" ;;
        report) [[ $# -eq 2 ]] || { usage; return 2; }; show_report "$2" ;;
        -*) legacy_mode "$@" ;;
        *) error "Unknown command: $1"; usage; return 2 ;;
    esac
}

main "$@"
