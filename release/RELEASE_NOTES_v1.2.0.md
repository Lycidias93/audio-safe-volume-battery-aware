# Audio Safe Volume Disabler v1.2.0

Diagnostics/support release.

## Changes

- Added `verify.sh --compact` for short checks.
- Added `verify.sh --xda` for XDA/GitHub report blocks.
- Added Magisk version/versionCode to verify output when available.
- Added config status and effective config values to verify output.
- Magisk Action button now runs compact read-only verify output.
- Added `SUPPORT.md`, `COMPATIBILITY.md`, and GitHub issue template.
- Runtime behavior unchanged from v1.1.2.

## Runtime mode

- Magisk `late_start service`
- One-shot boot apply
- Bounded delayed reapply
- Final reapply only if drift is detected
- No resident daemon
- No network
- No wakelock

## Verified baseline

- Pixel 10 Pro XL
- Android 16 / SDK 36
- Magisk
- v1.1.2 runtime verify: `RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS`

## Verify after install

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh
```

Compact:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --compact
```

XDA report:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda
```

Expected final line:

```text
RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS
```

## Safety warning

This module can disable or delay loud-volume / Sound Dose warnings. That can increase risk of hearing damage. Use conservative playback levels.
