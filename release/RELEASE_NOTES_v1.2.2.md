# Audio Safe Volume Disabler v1.2.2

Diagnostics polish release.

## Changes

- Dynamic service log version/name from `module.prop`.
- Better Magisk version detection from Termux/root contexts.
- Hardened state/log permissions; snapshots are no longer world-writable.
- Added `verify.sh --xda-short` for compact XDA compatibility reports.
- Added `verify.sh --json` for machine-readable diagnostics.
- Runtime audio behavior unchanged from v1.2.1.

## Runtime mode

- Magisk `late_start service`
- One-shot boot apply
- Bounded delayed reapply
- Final reapply only if drift is detected
- No resident daemon
- No network
- No wakelock

## Verify after install

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh
```

Compact:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --compact
```

XDA short:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda-short
```

XDA full:

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

## Safety warning

This module can disable or delay loud-volume / Sound Dose warnings. That can increase risk of hearing damage. Use conservative playback levels.
