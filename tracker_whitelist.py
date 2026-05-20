#!/usr/bin/env python3
"""Build a granular permission whitelist for specific apps"""
import json, argparse

PRESETS = {
    'minimal': {
        'com.google.android.gms': ['android.permission.ACCESS_FINE_LOCATION'],
        'com.google.android.apps.maps': ['android.permission.ACCESS_FINE_LOCATION'],
    },
    'normal': {
        'com.google.android.apps.messaging': ['android.permission.READ_SMS'],
        'com.google.android.dialer': ['android.permission.READ_CALL_LOG'],
    },
}

def gen_whitelist(preset):
    return json.dumps(PRESETS.get(preset, {}), indent=2)

parser = argparse.ArgumentParser()
parser.add_argument('--preset', default='minimal', choices=PRESETS.keys())
args = parser.parse_args()
print(gen_whitelist(args.preset))
