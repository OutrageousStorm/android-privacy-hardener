#!/usr/bin/env bash
# android-privacy-hardener — harden.sh
# https://github.com/OutrageousStorm/android-privacy-hardener
# MIT License

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║  🔒 Android Privacy Hardener v1.0    ║${NC}"
  echo -e "${CYAN}║  by Tom | Android Intelligence        ║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
  echo ""
}

check_adb() {
  if ! command -v adb &>/dev/null; then
    echo -e "${RED}✗ ADB not found.${NC}"
    echo "  Install: brew install android-platform-tools (macOS)"
    echo "           winget install Google.PlatformTools (Windows)"
    echo "           sudo apt install adb (Linux)"
    exit 1
  fi

  DEVICES=$(adb devices | grep -v "List" | grep -v "^$" | wc -l)
  if [[ "$DEVICES" -eq 0 ]]; then
    echo -e "${RED}✗ No device connected.${NC}"
    echo "  Connect via USB or run: adb connect IP:PORT"
    exit 1
  fi
  echo -e "${GREEN}✓ Device connected${NC}"
  MODEL=$(adb shell getprop ro.product.model 2>/dev/null)
  ANDROID=$(adb shell getprop ro.build.version.release 2>/dev/null)
  echo -e "  Model: ${CYAN}$MODEL${NC} | Android ${CYAN}$ANDROID${NC}"
}

revoke_permission() {
  local pkg=$1
  local perm=$2
  local label=$3
  if adb shell pm revoke "$pkg" "$perm" 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Revoked $perm from $label"
  fi
}

disable_package() {
  local pkg=$1
  local label=$2
  if adb shell pm disable-user --user 0 "$pkg" 2>/dev/null | grep -q "disabled"; then
    echo -e "  ${GREEN}✓${NC} Disabled: $label ($pkg)"
  fi
}

harden_permissions() {
  echo -e "\n${BLUE}▶ Revoking tracking permissions...${NC}"

  # Facebook / Meta
  revoke_permission "com.facebook.katana" "android.permission.ACCESS_FINE_LOCATION" "Facebook"
  revoke_permission "com.facebook.katana" "android.permission.ACCESS_COARSE_LOCATION" "Facebook"
  revoke_permission "com.facebook.katana" "android.permission.RECORD_AUDIO" "Facebook"

  # Instagram
  revoke_permission "com.instagram.android" "android.permission.ACCESS_FINE_LOCATION" "Instagram"
  revoke_permission "com.instagram.android" "android.permission.ACCESS_COARSE_LOCATION" "Instagram"

  # TikTok
  revoke_permission "com.zhiliaoapp.musically" "android.permission.ACCESS_FINE_LOCATION" "TikTok"
  revoke_permission "com.zhiliaoapp.musically" "android.permission.RECORD_AUDIO" "TikTok"
  revoke_permission "com.ss.android.ugc.trill" "android.permission.ACCESS_FINE_LOCATION" "TikTok (alt)"

  # LinkedIn
  revoke_permission "com.linkedin.android" "android.permission.ACCESS_FINE_LOCATION" "LinkedIn"
  revoke_permission "com.linkedin.android" "android.permission.READ_CONTACTS" "LinkedIn"

  # Twitter/X
  revoke_permission "com.twitter.android" "android.permission.ACCESS_FINE_LOCATION" "Twitter/X"

  # Snapchat (location only — breaks some features intentionally)
  revoke_permission "com.snapchat.android" "android.permission.ACCESS_FINE_LOCATION" "Snapchat"
}

harden_settings() {
  echo -e "\n${BLUE}▶ Applying privacy settings...${NC}"

  adb shell settings put global limit_ad_tracking 1 2>/dev/null && \
    echo -e "  ${GREEN}✓${NC} Ad tracking limited"

  adb shell settings put global send_action_app_error 0 2>/dev/null && \
    echo -e "  ${GREEN}✓${NC} App error reporting disabled"

  adb shell settings put global dropbox:data_app_crash 0 2>/dev/null && \
    echo -e "  ${GREEN}✓${NC} Crash data sharing disabled"

  adb shell settings put global dropbox:data_app_anr 0 2>/dev/null && \
    echo -e "  ${GREEN}✓${NC} ANR data sharing disabled"
}

harden_samsung() {
  echo -e "\n${BLUE}▶ Applying Samsung-specific hardening...${NC}"
  PACKAGES=(
    "com.samsung.android.bixby.agent:Bixby Agent"
    "com.samsung.android.bixbyvision.framework:Bixby Vision"
    "com.samsung.android.bixby.wakeup:Bixby Wake"
    "com.hiya.star:Caller ID (Hiya)"
    "com.samsung.android.app.tips:Samsung Tips"
    "com.samsung.android.game.gametools:Game Tools"
    "com.samsung.android.game.gamehome:Game Launcher"
    "com.samsung.android.aremoji:AR Emoji"
    "com.samsung.android.arzone:AR Zone"
    "com.samsung.android.samsungpay.gear:Samsung Pay (Gear)"
    "com.samsung.android.app.galaxyfinder:Galaxy Find"
    "com.samsung.storyservice:Story Service"
    "com.samsung.android.app.routines:Routines (Bixby)"
  )
  for entry in "${PACKAGES[@]}"; do
    pkg="${entry%%:*}"
    label="${entry##*:}"
    disable_package "$pkg" "$label"
  done
}

harden_pixel() {
  echo -e "\n${BLUE}▶ Applying Pixel-specific hardening...${NC}"
  PACKAGES=(
    "com.google.android.as.oss:Private Compute Services"
    "com.google.android.odad:Device Personalization"
    "com.google.android.apps.subscriptions.red:Google One promo"
    "com.google.android.apps.wellbeing:Digital Wellbeing"
    "com.google.android.hotspot2:Passpoint"
  )
  for entry in "${PACKAGES[@]}"; do
    pkg="${entry%%:*}"
    label="${entry##*:}"
    disable_package "$pkg" "$label"
  done
}

print_menu() {
  echo -e "${YELLOW}Select device profile:${NC}"
  echo "  1) Samsung One UI"
  echo "  2) Google Pixel"
  echo "  3) Generic (permissions + settings only)"
  echo "  4) Exit"
  echo ""
  read -rp "Choice [1-4]: " CHOICE
}

main() {
  print_header
  check_adb

  print_menu

  case $CHOICE in
    1)
      harden_permissions
      harden_settings
      harden_samsung
      ;;
    2)
      harden_permissions
      harden_settings
      harden_pixel
      ;;
    3)
      harden_permissions
      harden_settings
      ;;
    4)
      echo "Exiting."
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid choice.${NC}"
      exit 1
      ;;
  esac

  echo ""
  echo -e "${GREEN}✅ Hardening complete!${NC}"
  echo ""
  echo "To reverse any change, run: ./restore.sh"
  echo "Audit your permissions: https://github.com/OutrageousStorm/android-permission-auditor"
}

main
