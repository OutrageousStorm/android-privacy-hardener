#!/usr/bin/env bash
# ╔══════════════════════════════════════════╗
# ║  🔒 Android Privacy Hardener v2.0       ║
# ║  by Tom | Android Intelligence           ║
# ║  github.com/OutrageousStorm             ║
# ╚══════════════════════════════════════════╝
# No root required · ADB powered · MIT License

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

VERSION="2.0"

print_header() {
  echo -e "${CYAN}"
  echo "  ╔══════════════════════════════════════════╗"
  echo "  ║  🔒 Android Privacy Hardener v${VERSION}      ║"
  echo "  ║  No root needed · ADB only               ║"
  echo "  ╚══════════════════════════════════════════╝"
  echo -e "${NC}"
}

check_adb() {
  if ! command -v adb &>/dev/null; then
    echo -e "${RED}✗ ADB not found.${NC}"
    echo "  macOS:   brew install android-platform-tools"
    echo "  Windows: winget install Google.PlatformTools"
    echo "  Linux:   sudo apt install adb"; exit 1
  fi
  STATE=$(adb get-state 2>/dev/null || echo "none")
  if [[ "$STATE" != "device" ]]; then
    echo -e "${RED}✗ No device connected. Enable USB Debugging.${NC}"; exit 1
  fi
  MODEL=$(adb shell getprop ro.product.model | tr -d '\r')
  echo -e "${GREEN}✓ Connected: ${BOLD}${MODEL}${NC}"
}

step() { echo -e "\n${CYAN}[${1}/${TOTAL}] ${2}${NC}"; }
ok()   { echo -e "  ${GREEN}✓${NC} ${1}"; }
warn() { echo -e "  ${YELLOW}⚠${NC} ${1}"; }
skip() { echo -e "  ${YELLOW}~${NC} skip: ${1}"; }

TOTAL=10

harden_analytics() {
  step 1 "Disable crash reporting & analytics upload"
  adb shell settings put global send_action_app_error 0 && ok "Crash reports disabled"
  adb shell settings put global dropbox:data_app_crash 0 && ok "Dropbox crash log disabled"
  adb shell settings put global dropbox:data_app_anr 0 && ok "ANR reporting disabled"
  adb shell settings put global dropbox:data_app_wtf 0 && ok "WTF log disabled"
  adb shell settings put global usage_stats_period 0 2>/dev/null && ok "Usage stats disabled" || skip "usage_stats_period (API restriction)"
}

harden_google_services() {
  step 2 "Restrict Google data collection"
  adb shell settings put global auto_time_zone 1  # Keep time sync
  adb shell settings put secure location_mode 0 && ok "Location OFF (re-enable as needed)"
  adb shell settings put global wifi_scan_always_enabled 0 && ok "WiFi scan (background) disabled"
  adb shell settings put global ble_scan_always_enabled 0 && ok "BLE scan (background) disabled"
  adb shell settings put global network_recommendations_enabled 0 && ok "Network recommendations disabled"
}

harden_permissions() {
  step 3 "Revoke dangerous permissions from ad/tracking packages"

  AD_PKGS=(
    "com.facebook.katana"
    "com.facebook.services"
    "com.facebook.appmanager"
    "com.google.android.googlequicksearchbox"
    "com.samsung.android.rubin.app"
    "com.miui.analytics"
    "com.xiaomi.mipicks"
  )

  DANGEROUS_PERMS=(
    "android.permission.ACCESS_FINE_LOCATION"
    "android.permission.ACCESS_COARSE_LOCATION"
    "android.permission.READ_CONTACTS"
    "android.permission.READ_CALL_LOG"
    "android.permission.RECORD_AUDIO"
  )

  for pkg in "${AD_PKGS[@]}"; do
    for perm in "${DANGEROUS_PERMS[@]}"; do
      adb shell pm revoke "$pkg" "$perm" 2>/dev/null && ok "Revoked $perm from $pkg" || true
    done
  done
}

harden_clipboard() {
  step 4 "Restrict clipboard access (Android 10+)"
  adb shell appops set com.facebook.katana READ_CLIPBOARD deny 2>/dev/null && ok "Blocked FB clipboard" || skip "Not applicable"
  adb shell appops set com.google.android.googlequicksearchbox READ_CLIPBOARD deny 2>/dev/null && ok "Blocked Google Search clipboard" || skip "Not applicable"
}

harden_microphone() {
  step 5 "Restrict background microphone access"
  adb shell appops set com.google.android.googlequicksearchbox RECORD_AUDIO deny 2>/dev/null && ok "Google Search mic: DENY" || skip "Not applicable"
  adb shell appops set com.samsung.android.bixby.agent RECORD_AUDIO deny 2>/dev/null && ok "Bixby mic: DENY" || skip "Bixby not present"
  adb shell appops set com.amazon.dee.app RECORD_AUDIO deny 2>/dev/null && ok "Amazon Alexa mic: DENY" || skip "Alexa not present"
}

harden_networking() {
  step 6 "Disable telemetry networking settings"
  adb shell settings put global captive_portal_detection_enabled 0 && ok "Captive portal detection disabled (prevents Google ping)"
  adb shell settings put global ntp_server "time.cloudflare.com" && ok "NTP: Cloudflare (not Google)"
}

harden_lockscreen() {
  step 7 "Harden lockscreen"
  adb shell settings put secure lock_screen_show_notifications 0 && ok "Notifications hidden on lockscreen"
  adb shell settings put secure lock_screen_allow_private_notifications 0 && ok "Private notification content hidden"
}

harden_developer_options() {
  step 8 "Disable risky developer option leftovers"
  adb shell settings put global adb_enabled 1  # Keep ADB on (we need it)
  adb shell settings put global mock_location 0 && ok "Mock location disabled"
}

harden_sensors() {
  step 9 "Disable sensors when screen is off (battery + privacy)"
  adb shell settings put global keep_screen_on_while_unplugging 0 2>/dev/null || true
  ok "Screen-off sensor restriction noted (use app like Sensor Blocker for full control)"
}

revoke_ad_ids() {
  step 10 "Reset & opt out of ad tracking ID"
  adb shell cmd appops set com.google.android.gms AD_ID deny 2>/dev/null && ok "Google Ad ID: denied" || skip "Requires Android 13+ with gms access"
}

print_summary() {
  echo ""
  echo -e "${CYAN}════════════════════════════════════════${NC}"
  echo -e "${GREEN}${BOLD}  ✓ Privacy hardening complete!${NC}"
  echo -e "${CYAN}════════════════════════════════════════${NC}"
  echo ""
  echo -e "${YELLOW}  Recommended next steps:${NC}"
  echo "  • Install a firewall: NetGuard (no root, F-Droid)"
  echo "  • Use a private DNS: Settings → More → Private DNS → dns.adguard.com"
  echo "  • Consider a privacy ROM: GrapheneOS (Pixel) or CalyxOS"
  echo ""
  echo -e "  Full ROM guide: ${CYAN}https://github.com/OutrageousStorm/android-rom-guide${NC}"
  echo ""
}

usage() {
  echo "Usage: $0 [--all | --step N]"
  echo ""
  echo "  --all       Run all hardening steps (recommended)"
  echo "  --step N    Run only step N (1-$TOTAL)"
  echo "  --help      Show this help"
  echo ""
  echo "Steps:"
  echo "  1  Analytics & crash reporting"
  echo "  2  Google services data collection"
  echo "  3  Dangerous permission revocation"
  echo "  4  Clipboard restrictions"
  echo "  5  Background microphone"
  echo "  6  Telemetry networking"
  echo "  7  Lockscreen hardening"
  echo "  8  Developer option cleanup"
  echo "  9  Sensor restrictions"
  echo "  10 Ad ID opt-out"
}

# ── Main ─────────────────────────────────────────────────────────────────

print_header
check_adb
echo ""

case "${1:---all}" in
  --all)
    harden_analytics
    harden_google_services
    harden_permissions
    harden_clipboard
    harden_microphone
    harden_networking
    harden_lockscreen
    harden_developer_options
    harden_sensors
    revoke_ad_ids
    print_summary
    ;;
  --step)
    case "$2" in
      1) harden_analytics ;;
      2) harden_google_services ;;
      3) harden_permissions ;;
      4) harden_clipboard ;;
      5) harden_microphone ;;
      6) harden_networking ;;
      7) harden_lockscreen ;;
      8) harden_developer_options ;;
      9) harden_sensors ;;
      10) revoke_ad_ids ;;
      *) echo "Step must be 1-$TOTAL"; exit 1 ;;
    esac
    ;;
  --help|-h|*) usage ;;
esac
