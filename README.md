# 🔒 Android Privacy Hardener

> Harden Android privacy in under 5 minutes via ADB. No root required. 10 targeted steps.

![Platform](https://img.shields.io/badge/platform-Android%2010%2B-brightgreen)
![No Root](https://img.shields.io/badge/root-not%20required-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
[![Stars](https://img.shields.io/github/stars/OutrageousStorm/android-privacy-hardener?style=social)](https://github.com/OutrageousStorm/android-privacy-hardener/stargazers)

## What it does

| Step | Action |
|---|---|
| 1 | Disables crash reporting & analytics upload |
| 2 | Restricts Google location/WiFi/BLE background scanning |
| 3 | Revokes LOCATION, CONTACTS, MICROPHONE from known ad packages |
| 4 | Blocks clipboard access for Facebook & Google Search |
| 5 | Disables background microphone for Google, Bixby, Alexa |
| 6 | Switches NTP to Cloudflare, disables captive portal pings |
| 7 | Hides notifications & content on lockscreen |
| 8 | Cleans up risky developer options |
| 9 | Notes sensor restriction (guides to NetGuard) |
| 10 | Opts out of Google Ad ID tracking |

---

## Quick Start

```bash
# Install ADB
brew install android-platform-tools   # macOS
winget install Google.PlatformTools   # Windows
sudo apt install adb                  # Linux

# Enable USB Debugging on phone
# Settings → Developer Options → USB Debugging

# Clone & run ALL steps
git clone https://github.com/OutrageousStorm/android-privacy-hardener.git
cd android-privacy-hardener
chmod +x harden.sh
./harden.sh --all
```

---

## Run Individual Steps

```bash
./harden.sh --step 3   # Only revoke ad permissions
./harden.sh --step 5   # Only restrict microphone
./harden.sh --help     # List all steps
```

---

## After Hardening

- **Firewall:** Install [NetGuard](https://f-droid.org/packages/eu.faircode.netguard/) (no root, F-Droid) to block internet per-app
- **Private DNS:** Settings → More → Private DNS → `dns.adguard.com`
- **ROM upgrade:** For maximum privacy, consider [GrapheneOS](https://grapheneos.org) (Pixel) or [CalyxOS](https://calyxos.org)
- **Full ROM guide:** [android-rom-guide](https://github.com/OutrageousStorm/android-rom-guide)

---

## Compatibility

| Android Version | Supported |
|---|---|
| Android 10 | ✅ (partial — some appops not available) |
| Android 11 | ✅ |
| Android 12 | ✅ |
| Android 13 | ✅ |
| Android 14/15 | ✅ |

Works on all brands: Pixel, Samsung, Xiaomi, OnePlus, etc.

---

*Built by [Tom](https://github.com/OutrageousStorm) · MIT License*
