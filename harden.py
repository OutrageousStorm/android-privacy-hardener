#!/usr/bin/env python3
"""
harden.py -- Comprehensive Android privacy hardening via ADB
Revokes tracking permissions, disables telemetry, hardens settings.
Usage: python3 harden.py [--dry-run] [--level 1|2|3]
"""
import subprocess, sys, argparse

TRACKING_PERMISSIONS = [
    "android.permission.ACCESS_FINE_LOCATION",
    "android.permission.ACCESS_COARSE_LOCATION",
    "android.permission.ACCESS_BACKGROUND_LOCATION",
    "android.permission.READ_CONTACTS",
    "android.permission.GET_ACCOUNTS",
    "android.permission.RECORD_AUDIO",
    "android.permission.READ_CALL_LOG",
    "android.permission.READ_SMS",
    "android.permission.RECEIVE_SMS",
]

TRACKING_PACKAGES = [
    "com.facebook.katana", "com.facebook.orca", "com.facebook.appmanager",
    "com.facebook.services", "com.facebook.system",
    "com.google.android.gms.analytics",
]

LEVEL1_SETTINGS = [
    ("global", "limit_ad_tracking", "1"),
    ("global", "advertising_id_limit_ad_tracking", "1"),
    ("secure", "location_mode", "0"),
    ("global", "network_access_timeout_ms", "5000"),
]

LEVEL2_SETTINGS = [
    ("global", "wifi_scan_always_enabled", "0"),
    ("global", "ble_scan_always_enabled", "0"),
    ("secure", "send_action_app_error", "0"),
    ("global", "dropbox:dumpsys:procstats", "disabled"),
    ("global", "dropbox:dumpsys:meminfo", "disabled"),
    ("global", "dropbox:SYSTEM_TOMBSTONE", "disabled"),
    ("global", "dropbox:system_app_crash", "disabled"),
]

LEVEL3_APPOPS = [
    "READ_CLIPBOARD",
    "MONITOR_LOCATION",
    "RECORD_AUDIO",
]

def adb(cmd, dry_run=False):
    full = f"adb shell {cmd}"
    if dry_run:
        print(f"  [DRY] {full}")
        return ""
    r = subprocess.run(full, shell=True, capture_output=True, text=True)
    return r.stdout.strip()

def get_packages():
    out = subprocess.run("adb shell pm list packages", shell=True, capture_output=True, text=True).stdout
    return [l.split(":")[1] for l in out.splitlines() if l.startswith("package:")]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true", help="Print commands without running")
    parser.add_argument("--level", type=int, default=2, choices=[1, 2, 3],
                        help="Hardening level: 1=basic, 2=intermediate, 3=aggressive")
    args = parser.parse_args()

    print(f"\n🔏 Android Privacy Hardener (Level {args.level})")
    if args.dry_run:
        print("  [DRY RUN MODE]")
    print("=" * 50)

    # Check device
    if not args.dry_run:
        devices = subprocess.run("adb devices", shell=True, capture_output=True, text=True).stdout
        if "device" not in devices.split("List")[1]:
            print("❌ No device connected.")
            sys.exit(1)

    packages = get_packages() if not args.dry_run else []

    # Level 1: Basic settings
    print("\n[Level 1] Applying privacy settings...")
    for namespace, key, val in LEVEL1_SETTINGS:
        adb(f"settings put {namespace} {key} {val}", args.dry_run)
        print(f"  ✓ {namespace}/{key} = {val}")

    # Level 1: Revoke tracking perms from social apps
    print("\n[Level 1] Revoking location/contact perms from social apps...")
    for pkg in TRACKING_PACKAGES:
        if args.dry_run or pkg in packages:
            for perm in [
                "android.permission.ACCESS_FINE_LOCATION",
                "android.permission.READ_CONTACTS",
                "android.permission.GET_ACCOUNTS",
            ]:
                result = adb(f"pm revoke {pkg} {perm}", args.dry_run)
                if "Success" in result or args.dry_run:
                    print(f"  ✓ revoked {perm.split('.')[-1]} from {pkg.split('.')[-1]}")

    if args.level >= 2:
        print("\n[Level 2] Disabling scan-always, telemetry drop boxes...")
        for namespace, key, val in LEVEL2_SETTINGS:
            adb(f"settings put {namespace} {key} {val}", args.dry_run)
            print(f"  ✓ {namespace}/{key} = {val}")

        # Restrict background data for known analytics packages
        print("\n[Level 2] Restricting background data for trackers...")
        for pkg in TRACKING_PACKAGES:
            if args.dry_run or pkg in packages:
                adb(f"cmd netpolicy set restrict-background {pkg} true", args.dry_run)
                print(f"  ✓ background data restricted: {pkg.split('.')[-1]}")

    if args.level >= 3:
        print("\n[Level 3] Applying AppOps restrictions globally...")
        for op in LEVEL3_APPOPS:
            adb(f"appops set --all {op} deny", args.dry_run)
            print(f"  ✓ denied AppOp: {op}")

    print("\n" + "=" * 50)
    print("✅ Hardening complete!")
    print("\nRecommended next steps:")
    print("  1. Install NetGuard (F-Droid) for per-app firewall")
    print("  2. Set private DNS: Settings → Network → Private DNS → dns.quad9.net")
    print("  3. Review app permissions in Settings → Privacy → Permission Manager")

if __name__ == "__main__":
    main()
