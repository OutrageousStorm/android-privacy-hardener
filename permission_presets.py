#!/usr/bin/env python3
"""Pre-built permission presets: minimal, balanced, paranoid"""
import subprocess, json

PRESETS = {
    'minimal': {
        'allow': ['INTERNET', 'ACCESS_NETWORK_STATE'],
        'revoke': ['LOCATION', 'CONTACTS', 'CAMERA', 'MICROPHONE', 'SMS', 'CALL_LOG'],
    },
    'balanced': {
        'allow': ['INTERNET', 'LOCATION', 'CAMERA', 'MICROPHONE'],
        'revoke': ['CONTACTS', 'READ_SMS', 'CALL_LOG', 'ACCESS_FINE_LOCATION'],
    },
    'paranoid': {
        'allow': [],  # Revoke everything
        'revoke': ['ALL'],
    },
}

def apply_preset(app, preset_name):
    preset = PRESETS.get(preset_name, {})
    for perm in preset.get('revoke', []):
        subprocess.run(['adb', 'shell', 'pm', 'revoke', app, f'android.permission.{perm}'])

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 3:
        print("Usage: permission_presets.py <app_pkg> <minimal|balanced|paranoid>")
        sys.exit(1)
    apply_preset(sys.argv[1], sys.argv[2])
