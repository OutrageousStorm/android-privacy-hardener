# 🔒 Android Privacy Hardener

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![No Root](https://img.shields.io/badge/Root-Not%20Required-brightgreen)]()
[![Android](https://img.shields.io/badge/Android-8.0%2B-blue)]()

> Harden your Android phone's privacy in under 5 minutes. No root, no custom ROM, no technical knowledge required. Just ADB.

## What This Does

Runs a series of targeted ADB commands to:
- 🚫 Revoke location access from tracking-heavy apps
- 🎤 Revoke microphone access from apps that don't need it
- 🔴 Disable telemetry and analytics packages
- 🗑️ Disable pre-installed advertising SDKs
- 🔒 Apply recommended Android privacy settings

## Quick Start

```bash
git clone https://github.com/OutrageousStorm/android-privacy-hardener
cd android-privacy-hardener
chmod +x harden.sh
./harden.sh
```

You'll see a menu — choose your device (Samsung, Pixel, stock AOSP, or custom).

## What Gets Changed

### Permissions Revoked (from tracking-heavy apps)
```
Facebook / Meta     → location, microphone, contacts, storage
Instagram          → location, microphone, contacts
TikTok             → location, microphone, contacts
Snapchat           → location (read-only mode still works)
Twitter/X          → location
LinkedIn           → location, contacts
```

### System Settings Applied
```
Disable ad personalization    → settings put global limit_ad_tracking 1  
Disable usage stats sharing   → settings put global send_action_app_error 0
Reduce OEM telemetry          → device-specific (Samsung, Pixel, Xiaomi)
```

### Packages Disabled (OEM telemetry — Samsung example)
```
com.samsung.android.game.gametools     → Game Launcher tracking
com.hiya.star                          → Caller ID data harvesting
com.samsung.android.app.tips           → Promotional content
com.samsung.android.bixby.agent        → Bixby voice data collection
```

## Device Profiles

| Device | Status | Packages Targeted |
|--------|--------|------------------|
| Samsung One UI 6 | ✅ Full support | 24 packages |
| Samsung One UI 7 | ✅ Full support | 26 packages |
| Google Pixel (any) | ✅ Full support | 12 packages |
| Xiaomi HyperOS | 🔧 Beta | 18 packages |
| OnePlus OxygenOS | 🔧 Beta | 14 packages |
| Stock AOSP | ✅ Permissions only | N/A |

## What This Does NOT Do

- Does **not** unlock your bootloader
- Does **not** flash anything
- Does **not** break system apps (disable only, fully reversible)
- Does **not** affect apps you use regularly — only targets tracking

## Reversing Any Change

Everything is reversible:
```bash
# Re-enable a disabled package
adb shell pm enable com.package.name

# Re-grant a permission
adb shell pm grant com.package.name android.permission.ACCESS_FINE_LOCATION

# Full restore script
./restore.sh
```

## Files

```
android-privacy-hardener/
├── harden.sh            # Main script — interactive menu
├── restore.sh           # Undo all changes
├── profiles/
│   ├── samsung.sh       # Samsung One UI hardening
│   ├── pixel.sh         # Google Pixel hardening
│   ├── xiaomi.sh        # Xiaomi HyperOS hardening
│   └── generic.sh       # Permissions-only (any device)
└── README.md
```

## Related Tools

- [android-permission-auditor](https://github.com/OutrageousStorm/android-permission-auditor) — See what you're hardening against
- [android-adb-toolkit](https://github.com/OutrageousStorm/android-adb-toolkit) — Web GUI version
- [shizuku-apps-root-alternative](https://github.com/OutrageousStorm/shizuku-apps-root-alternative) — Do this without a PC
- [AppManager](https://github.com/MuntashirAkon/AppManager) — Per-component blocking on-device

---

*Built by [Tom | Android Intelligence](https://github.com/OutrageousStorm) — Open source, MIT license*
