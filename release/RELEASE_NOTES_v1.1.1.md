# Audio Safe Volume Battery Aware v1.1.1

Hotfix release focused on Magisk update support and release hygiene.

## Changes

- Added `updateJson` to `module.prop`.
- Added `update.json` for Magisk in-app update metadata.
- Fixed release publishing workflow so SHA256 files use local relative filenames, not sandbox paths.
- Kept runtime behavior unchanged from v1.1.0.

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
- v1.1.0 runtime verify: `RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS`

## Safety warning

This module can disable or delay loud-volume / Sound Dose warnings. That can increase risk of hearing damage. Use conservative playback levels.

## Verify after install

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh
```

Expected final line:

```text
RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS
```
