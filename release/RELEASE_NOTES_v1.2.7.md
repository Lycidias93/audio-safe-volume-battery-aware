Audio Safe Volume Disabler v1.2.7

Compatibility/support diagnostics release.

## Changes

- Added read-only compatibility probe:

    tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --compat

- Added copy-ready XDA/GitHub compatibility report:

    tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --compat-xda

- Added sanitized support bundle generation:

    tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --support-bundle

- Added config lint mode:

    tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --lint-config

- Added companion shared-state age/stale reporting for:

    /data/adb/asvd/bt-helper.env

- Added ASVD helper shared state written by apply-now.sh and active-guard-once.sh:

    /data/adb/asvd/asvd.env

- Improved README, SUPPORT.md, COMPATIBILITY.md and GitHub issue template for non-Pixel compatibility reports.
- Runtime audio behavior unchanged from v1.2.6.

## Runtime mode

- Magisk late_start service
- One-shot boot apply
- Bounded delayed reapply
- Final reapply only if drift is detected
- No resident daemon
- No network
- No wakelock

## Verify after install

Full verify:

    tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh

XDA/GitHub report:

    tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda

Compatibility report for non-Pixel devices:

    tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --compat-xda

Expected final line:

    RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS

## Safety warning

This module can disable or delay loud-volume / Sound Dose warnings. That can increase risk of hearing damage. Use conservative playback levels.
