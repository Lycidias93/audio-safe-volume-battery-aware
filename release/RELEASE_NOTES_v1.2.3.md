Audio Safe Volume Disabler v1.2.3

Support-flow cleanup release.

## Changes

- Simplified public support flow: full verify and XDA full report are now the recommended commands.
- Kept `verify.sh --compact`, `verify.sh --xda-short`, and `verify.sh --json` as advanced/debug modes only.
- Added the XDA thread link to full XDA report output.
- Simplified `README.md`, `SUPPORT.md`, `COMPATIBILITY.md`, and GitHub issue template around the XDA full report.
- Runtime audio behavior unchanged from v1.2.2.

## Runtime mode

- Magisk `late_start service`
- One-shot boot apply
- Bounded delayed reapply
- Final reapply only if drift is detected
- No resident daemon
- No network
- No wakelock

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
