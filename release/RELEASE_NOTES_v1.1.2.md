# Audio Safe Volume Disabler v1.1.2

Branding hotfix release.

## Changes

- Renamed visible project/module name from **Audio Safe Volume Battery Aware** to **Audio Safe Volume Disabler**.
- Kept Magisk module ID unchanged: `audio-safe-volume-battery-aware`.
- Kept GitHub repo slug and `updateJson` path unchanged for update compatibility.
- Updated release asset naming to the short public asset `ASVD-v1.1.2.zip`.
- Runtime behavior unchanged from v1.1.1.

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
- v1.1.1 runtime verify: `RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS`

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
