Audio Safe Volume Disabler v1.2.4

Active-session helper release.

## Changes

- Added `apply-now.sh` for manual immediate reapply + verify.
- Added `active-guard-once.sh` for bounded active Bluetooth playback sessions where Android repopulates Sound Dose values.
- Magisk Action button now runs `apply-now.sh`.
- Documented H222 / Skoda BT2MP3 receiver behavior: Android classifies it as headphones, transient warning can appear, and CSD values can repopulate during active playback.
- Documented verified recovery: bounded active guard restored target values and final verify passed.
- Clarified that ASVD does not currently modify Bluetooth device classification.
- Boot runtime behavior unchanged from v1.2.3.

## Runtime mode

- Magisk `late_start service`
- One-shot boot apply
- Bounded delayed reapply
- Final reapply only if drift is detected
- No resident daemon
- No network
- No wakelock

## Manual helpers

Apply now:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/apply-now.sh
```

Bounded active guard:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/active-guard-once.sh
```

Default active guard: 12 passes, 15 seconds apart.

## Verify after install

Full verify:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh
```

XDA/GitHub report:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda
```

Expected final line:

```text
RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS
```

## Safety warning

This module can disable or delay loud-volume / Sound Dose warnings. That can increase risk of hearing damage. Use conservative playback levels.
