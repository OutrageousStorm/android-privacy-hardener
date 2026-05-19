#!/usr/bin/env python3
"""whitelist_builder.py -- Build custom app permission whitelist
Define which apps get which permissions, revoke everything else
"""
import json, subprocess, argparse

WHITELIST = {
    "com.google.android.apps.messaging": ["SEND_SMS", "READ_SMS", "READ_CONTACTS"],
    "com.google.android.apps.maps": ["ACCESS_FINE_LOCATION", "CAMERA"],
    "com.spotify.music": ["RECORD_AUDIO", "READ_EXTERNAL_STORAGE"],
    "com.google.android.gms": ["*"],  # Google Play Services: full access
}

def adb(cmd):
    subprocess.run(['adb', 'shell'] + cmd.split(), capture_output=True)

def apply_whitelist():
    print("🔐 Applying permission whitelist...\n")
    
    # Get all packages
    out = subprocess.run(['adb', 'shell', 'pm', 'list', 'packages', '-3'],
                        capture_output=True, text=True).stdout
    packages = [p.replace('package:', '') for p in out.splitlines()]
    
    all_perms = [
        "SEND_SMS", "READ_SMS", "READ_CONTACTS", "ACCESS_FINE_LOCATION",
        "RECORD_AUDIO", "READ_EXTERNAL_STORAGE", "CAMERA",
    ]
    
    for pkg in packages:
        if pkg in WHITELIST:
            allowed = WHITELIST[pkg]
            print(f"✅ {pkg}: {', '.join(allowed)}")
        else:
            # Revoke all dangerous perms
            for perm in all_perms:
                adb(f'pm revoke {pkg} android.permission.{perm}')
            print(f"🔒 {pkg}: revoked all")

if __name__ == '__main__':
    apply_whitelist()
