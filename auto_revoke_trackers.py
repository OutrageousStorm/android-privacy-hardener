#!/usr/bin/env python3
"""
auto_revoke_trackers.py — Automatically detect and revoke tracking permissions
Inspired by: HN "Auto-identity-remove – Automated data broker opt-out runner"

Scans all installed apps, identifies ones requesting tracking/location/contacts
permissions, and optionally revokes them automatically via ADB.
"""
import subprocess, json, re, argparse
from dataclasses import dataclass, field
from typing import List

TRACKING_PERMS = [
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.ACCESS_COARSE_LOCATION',
    'android.permission.ACCESS_BACKGROUND_LOCATION',
    'android.permission.READ_CONTACTS',
    'android.permission.READ_CALL_LOG',
    'android.permission.READ_SMS',
    'android.permission.RECEIVE_SMS',
    'android.permission.CAMERA',
    'android.permission.RECORD_AUDIO',
    'android.permission.READ_PHONE_STATE',
    'android.permission.PROCESS_OUTGOING_CALLS',
    'com.google.android.gms.permission.AD_ID',
    'android.permission.GET_ACCOUNTS',
    'android.permission.BLUETOOTH_SCAN',
]

SYSTEM_PKG_PREFIXES = ['com.android.', 'com.google.android.', 'android.']

@dataclass
class AppTracker:
    package: str
    label: str
    granted_perms: List[str] = field(default_factory=list)
    risk_score: int = 0

def adb(cmd):
    r = subprocess.run(['adb', 'shell'] + cmd.split(), capture_output=True, text=True)
    return r.stdout.strip()

def get_packages(include_system=False):
    flag = '' if include_system else '-3'
    raw = adb(f'pm list packages {flag}'.strip())
    pkgs = [l.replace('package:', '').strip() for l in raw.splitlines() if l.startswith('package:')]
    return pkgs

def get_granted_tracking_perms(pkg):
    raw = adb(f'dumpsys package {pkg}')
    granted = []
    in_grants = False
    for line in raw.splitlines():
        if 'granted=true' in line:
            for perm in TRACKING_PERMS:
                if perm in line:
                    granted.append(perm)
    return list(set(granted))

def get_app_label(pkg):
    # Try to get app label from aapt or fallback to package name
    try:
        r = subprocess.run(['adb', 'shell', 'pm', 'list', 'packages', '-l', pkg],
                           capture_output=True, text=True)
        return pkg  # Simplified — full label requires APK parsing
    except:
        return pkg

def revoke_permission(pkg, perm):
    r = subprocess.run(['adb', 'shell', 'pm', 'revoke', pkg, perm],
                       capture_output=True, text=True)
    return r.returncode == 0

def score_app(perms):
    score = 0
    weights = {
        'ACCESS_FINE_LOCATION': 30,
        'ACCESS_BACKGROUND_LOCATION': 40,
        'READ_CONTACTS': 20,
        'READ_CALL_LOG': 25,
        'READ_SMS': 25,
        'RECORD_AUDIO': 20,
        'AD_ID': 15,
        'PROCESS_OUTGOING_CALLS': 20,
    }
    for perm in perms:
        for key, w in weights.items():
            if key in perm:
                score += w
    return score

def scan(include_system=False, auto_revoke=False, min_score=30, output_json=None):
    print("🔍 Scanning installed apps for tracking permissions...\n")
    packages = get_packages(include_system)
    print(f"Found {len(packages)} user-installed apps")

    trackers = []
    for pkg in packages:
        perms = get_granted_tracking_perms(pkg)
        if not perms:
            continue
        score = score_app(perms)
        trackers.append(AppTracker(
            package=pkg, label=pkg,
            granted_perms=perms, risk_score=score
        ))

    trackers.sort(key=lambda x: x.risk_score, reverse=True)

    print(f"\n🚨 Found {len(trackers)} apps with tracking permissions:\n")
    for app in trackers:
        flag = '🔴' if app.risk_score >= 50 else '🟡' if app.risk_score >= 30 else '🟢'
        print(f"{flag} [{app.risk_score:3d}] {app.package}")
        for p in app.granted_perms:
            print(f"       • {p.split('.')[-1]}")

        if auto_revoke and app.risk_score >= min_score:
            print(f"  → Revoking {len(app.granted_perms)} permissions...")
            for perm in app.granted_perms:
                ok = revoke_permission(app.package, perm)
                print(f"    {'✅' if ok else '❌'} {perm.split('.')[-1]}")

    if output_json:
        data = [{'package': a.package, 'risk_score': a.risk_score,
                 'permissions': a.granted_perms} for a in trackers]
        with open(output_json, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"\n💾 Saved to {output_json}")

    return trackers

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Auto-detect and revoke Android tracking permissions')
    parser.add_argument('--revoke', action='store_true', help='Automatically revoke high-risk permissions')
    parser.add_argument('--min-score', type=int, default=30, help='Minimum risk score to revoke (default: 30)')
    parser.add_argument('--system', action='store_true', help='Include system apps')
    parser.add_argument('--json', metavar='FILE', help='Save results to JSON file')
    args = parser.parse_args()
    scan(include_system=args.system, auto_revoke=args.revoke,
         min_score=args.min_score, output_json=args.json)
