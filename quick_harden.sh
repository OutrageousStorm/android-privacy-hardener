#!/bin/bash
# Quick privacy hardening in one command
adb shell settings put global limit_ad_tracking 1
adb shell settings put secure location_mode 0
adb shell settings put global wifi_scan_always_enabled 0
adb shell cmd appops set --all READ_CLIPBOARD deny
echo "✓ Quick hardening applied"
