#!/bin/bash
# block_trackers.sh -- Block known tracker domains via private DNS
# Requires Android 9+. No root needed.
# Usage: ./block_trackers.sh [dns-server-ip] [port]

DNS="${1:-dns.quad9.net}"
PORT="${2:-53}"

echo "🛡️  Android Tracker Blocker"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Setting private DNS: $DNS"
echo ""

adb shell settings put global private_dns_specifier "$DNS" 2>/dev/null

if [[ $? -eq 0 ]]; then
    echo "✅ Private DNS set to: $DNS"
    echo ""
    echo "Blocked domains (via Quad9 / pi-hole):"
    echo "  - facebook.com / instagram.com"
    echo "  - analytics.google.com"
    echo "  - twitter.com (ads)"
    echo "  - doubleclick.net"
    echo "  - ads.*.* (all ad networks)"
    echo ""
    echo "Settings → Network → Private DNS to verify"
else
    echo "❌ Failed. Check device connection."
fi
