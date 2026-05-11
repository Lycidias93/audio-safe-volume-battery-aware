# Audio Safe Volume Disabler v1.2.5

Docs/support safety release.

## Changes

- Added docs/support warning about Google Play Billing account-context side effects observed during experimental GMS-disable/offline-ui helper tests.
- Explicitly marked the GMS-disable/offline-ui Bluetooth type helper path as rejected and not shipped.
- Documented failed H222 UI-unlock attempts:
  - soft mode failed
  - hard mode failed
  - offline-ui + Bluetooth reload failed
- Clarified future BT Device Type Helper direction:
  - optional Bluetooth metadata/API research only
  - no GMS-disable/offline-ui mode
  - no direct `bt_config.conf` patching
  - no boot automation for Bluetooth type changes
- Fixed Magisk install text quoting in `customize.sh`.
- Runtime audio behavior unchanged from v1.2.4.

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
