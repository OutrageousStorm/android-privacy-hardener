# Contributing to Android Privacy Hardener

Thanks for wanting to help. Here's how.

## Ways to contribute

### 1. Add device profiles
The most valuable contribution. If you have a device (Samsung, Pixel, Xiaomi, OnePlus, etc.) and can verify which packages are safe to disable, open a PR adding a new profile to `profiles/`.

**Profile format:**
```bash
# profiles/samsung-galaxy-s24.sh
# Samsung Galaxy S24 — Android 14 / One UI 6
# Verified: 2026-03-xx by @yourusername

disable_if_present "com.samsung.android.app.tips" "Samsung Tips"
disable_if_present "com.samsung.android.bixby.agent" "Bixby"
revoke_permission "com.samsung.android.app.smartcapture" "android.permission.ACCESS_FINE_LOCATION" "Smart Select"
```

### 2. Report false positives
If a command breaks something on your device, open an issue with:
- Device model + Android version
- The exact package name that caused issues
- What broke

### 3. Add new permission revocations
Found a tracker permission we missed? PR the relevant permission line with the package and permission name. Verify it doesn't break the app's core function.

### 4. Improve docs
Fix typos, clarify steps, translate to other languages.

## Standards
- All commands must be **reversible** (no permanent changes)
- No root required — ADB only
- Test on a real device before PRing
- One profile per PR

## Running tests
```bash
# Dry-run mode (won't actually execute commands)
DRY_RUN=1 ./harden.sh
```

## Code style
- Bash: 2-space indent, `set -e` at top, functions for reuse
- Comments explain *why*, not just what
- Use `revoke_permission` and `disable_if_present` helper functions — don't raw-call `pm` directly

## License
By contributing, you agree your code is released under MIT.
