# Audio Safe Volume Battery Aware v1.1.0

Battery-aware Magisk module that reapplies Android safe-media-volume / CSD target values after boot without a resident daemon.

## Verified scope

- Pixel Android 16: verified
- Other Android/OEM devices: experimental until verified

## Safety warning

This module can disable or delay loud-volume / Sound Dose warnings. That can increase risk of hearing damage. Use conservative playback levels.

## Changes since v1.0.0

- Built-in `verify.sh` with `RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS/FAIL`
- Optional Magisk `action.sh` verify entrypoint
- Bounded log rotation
- State snapshots for before/after diagnostics
- Structured failure markers
- Environment logging
- Optional final reapply only if drift is detected
- Expanded README with compatibility matrix, rollback, and issue template
- Still one-shot only: no resident daemon, no wakelock, no network

## Verify after reboot

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh
```

Expected:

```text
RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS
```
