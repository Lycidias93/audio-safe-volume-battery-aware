# Audio Safe Volume Disabler

Small Magisk module that disables/delays Android safe-volume / Sound Dose warning behavior after boot.

The internal Magisk module ID intentionally remains `audio-safe-volume-battery-aware` for update compatibility.

## Status

- Version: `v1.2.2`
- Verified baseline: Pixel 10 Pro XL on Android 16 / SDK 36
- Other Android/OEM ROMs: experimental until verified
- Runtime mode: Magisk `late_start service`, one-shot + bounded delayed reapply
- Battery behavior: no loop, no wakelock, no network, idempotent writes only when values drift
- Magisk in-app updates: supported via `updateJson`

## Safety warning

This module can disable or delay loud-volume / Sound Dose warnings. That can increase risk of hearing damage. Use conservative playback levels and do not treat this as a safety feature.

## Target values

```text
audio_safe_csd_next_warning = 999999.0
safe_media_volume_enabled   = 0
audio_safe_volume_state     = 1
audio_safe_csd_current_value = 0.0
audio_safe_csd_dose_records = null
```

## What it does

1. Waits for boot completion.
2. Waits for Android Settings Provider readiness.
3. Captures a `before` state snapshot.
4. Applies target values only when current values differ.
5. Captures `after_primary` state.
6. Performs one bounded delayed reapply.
7. Verifies the final state.
8. Performs one final delayed reapply only if drift is detected.
9. Writes structured logs and exits.

## Install

Install the ZIP in Magisk:

```text
Magisk → Modules → Install from storage → ASVD-v1.2.2.zip → Reboot
```

## Verify after reboot

Full verify:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh
```

Compact verify:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --compact
```

XDA short:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda-short
```

XDA report block:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda
```

JSON:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --json
```

Expected final line:

```text
RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS
```

## Optional config

Create `/data/adb/audio-safe-volume-battery-aware.conf` to override defaults:

```sh
DELAYED_REAPPLY_SECONDS="45"
LOW_POWER_REAPPLY_SECONDS="15"
FINAL_REAPPLY_SECONDS="120"
LOW_BATTERY_THRESHOLD="15"
TARGET_AUDIO_SAFE_VOLUME_STATE="1"
LOG_MAX_BYTES="65536"
```

## Compatibility matrix

See [`COMPATIBILITY.md`](COMPATIBILITY.md).

## Support

See [`SUPPORT.md`](SUPPORT.md).

## Rollback

Disable/remove the module in Magisk and reboot.

The uninstall script intentionally does not blindly restore old Android audio safety values, because old values may be region/OEM/runtime-dependent.

Manual reset, if desired:

```sh
tsu /system/bin/sh -c 'settings delete global audio_safe_csd_next_warning; settings delete global safe_media_volume_enabled; settings delete global audio_safe_volume_state; settings delete global audio_safe_csd_current_value; settings delete global audio_safe_csd_dose_records'
```

## Release notes

See `CHANGELOG.md`.
