# Audio Safe Volume Disabler v1.2.1

Privacy metadata cleanup release.

## Changes

- Public project metadata now uses `Lycidias93` only.
- Old public releases/tags were removed before publishing this release.
- Kept Magisk module ID unchanged: `audio-safe-volume-battery-aware`.
- Kept GitHub repo slug and `updateJson` path unchanged for update compatibility.
- Runtime behavior unchanged from v1.2.0.

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

Expected final line:

```text
RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS
```

## Safety warning

This module can disable or delay loud-volume / Sound Dose warnings. That can increase risk of hearing damage. Use conservative playback levels.
