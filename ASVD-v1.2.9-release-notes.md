# Audio Safe Volume Disabler v1.2.9

Hotfix release. Runtime audio behavior is unchanged from v1.2.8.

## What changed

- Fixed stale Magisk installer text that still printed `Audio Safe Volume Disabler v1.2.7`.
- Installer UI now prints `Audio Safe Volume Disabler v1.2.9`.
- Fixed the local release-publish preflight workflow to verify SHA files from the asset directory instead of the repository directory.
- Kept the v1.2.8 Android 17 verified / output-hardening behavior unchanged.

## Runtime

No runtime audio behavior changes.

## Verify after install

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --markers
```

Expected final result:

```text
RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS
```
