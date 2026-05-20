#!/usr/bin/env python3
"""Granular permission presets for different privacy levels"""
import json
PRESETS = {
    'minimal': {
        'revoke': ['LOCATION', 'CONTACTS', 'CAMERA', 'MICROPHONE', 'PHONE_STATE'],
        'desc': 'Remove location, contacts, camera, mic, and phone state'
    },
    'balanced': {
        'revoke': ['ACCESS_BACKGROUND_LOCATION', 'READ_CALL_LOG', 'READ_SMS', 'RECORD_AUDIO'],
        'desc': 'Keep basic functionality, remove background tracking'
    },
    'paranoid': {
        'revoke': ['LOCATION', 'CONTACTS', 'CAMERA', 'MICROPHONE', 'PHONE_STATE', 'BODY_SENSORS', 'ACTIVITY_RECOGNITION'],
        'desc': 'Remove everything possible'
    }
}
if __name__ == '__main__':
    import sys, subprocess
    preset = sys.argv[1] if len(sys.argv) > 1 else 'balanced'
    perms = PRESETS.get(preset, {}).get('revoke', [])
    print(f"Applying {preset} preset: {PRESETS[preset]['desc']}")
    for perm in perms:
        subprocess.run(['adb', 'shell', 'pm', 'revoke', '--all', f'android.permission.{perm}'], capture_output=True)
        print(f"  ✓ revoked {perm}")
