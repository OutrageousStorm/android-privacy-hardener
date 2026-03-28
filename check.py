#!/usr/bin/env python3
"""
check.py -- Audit current Android privacy status
Shows: ad tracking, location, dangerous permissions, background data, known trackers
Usage: python3 check.py
"""
import subprocess, re

def adb(cmd):
    return subprocess.run(f"adb shell {cmd}", shell=True, capture_output=True, text=True).stdout.strip()

def check(label, cmd, good_val, invert=False):
    val = adb(cmd)
    ok = (val == good_val) if not invert else (val != good_val)
    icon = "✅" if ok else "⚠️ "
    print(f"  {icon}  {label:<40} [{val or 'null'}]")
    return ok

def main():
    print("\n🔍 Android Privacy Check")
    print("=" * 55)
    score = 0; total = 0

    checks = [
        ("Ad tracking disabled",     "settings get global limit_ad_tracking",        "1"),
        ("Location off",             "settings get secure location_mode",             "0"),
        ("WiFi scan always off",     "settings get global wifi_scan_always_enabled",  "0"),
        ("BLE scan always off",      "settings get global ble_scan_always_enabled",   "0"),
        ("ADB enabled",              "settings get global adb_enabled",               "0"),  # 0 = not exposed
        ("Nearby device scan off",   "settings get global ble_scan_always_enabled",   "0"),
    ]

    for label, cmd, good in checks:
        total += 1
        val = adb(cmd)
        ok = val == good
        score += int(ok)
        icon = "✅" if ok else "⚠️ "
        print(f"  {icon}  {label:<42} [{val or 'null'}]")

    # Check for installed trackers
    print("\n  Installed tracker packages:")
    TRACKERS = ["com.facebook.katana","com.facebook.appmanager","com.facebook.services",
                "com.facebook.system","com.instagram.android","com.twitter.android"]
    installed_trackers = []
    pkgs = adb("pm list packages")
    for t in TRACKERS:
        if f"package:{t}" in pkgs:
            installed_trackers.append(t)
            print(f"  ⚠️   {t}")
            total += 1
        else:
            score += 1
            total += 1

    if not installed_trackers:
        print("  ✅  None found")

    # Check dangerous perms on suspicious apps
    print("\n  Location granted to social apps:")
    found_loc = False
    for pkg in installed_trackers:
        perms = adb(f"dumpsys package {pkg} | grep 'ACCESS_FINE_LOCATION'")
        if "granted=true" in perms:
            print(f"  ⚠️   {pkg.split('.')[-1]} has FINE_LOCATION")
            found_loc = True
            total += 1
    if not found_loc:
        score += 1
        total += 1
        print("  ✅  None")

    print(f"\n{'─'*55}")
    pct = int((score / total) * 100) if total else 0
    bar = "█" * (pct // 10) + "░" * (10 - pct // 10)
    print(f"  Privacy Score: {bar} {pct}% ({score}/{total} checks passed)")
    print()
    if pct < 50:
        print("  Run: python3 harden.py --level 2")
    elif pct < 80:
        print("  Run: python3 harden.py --level 3")
    else:
        print("  Looking good! Consider a privacy ROM for maximum protection.")
    print()

if __name__ == "__main__":
    main()
