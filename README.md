# Audio Safe Volume Disabler

Small Magisk module that disables/delays Android safe-volume / Sound Dose warning behavior after boot.

The internal Magisk module ID intentionally remains `audio-safe-volume-battery-aware` for update compatibility.

## Status

- Version: `v1.2.4`
- Verified baseline: Pixel 10 Pro XL on Android 16 / SDK 36
- Additional verified scenario: active Bluetooth music playback on H222 car receiver after bounded active guard
- Other Android/OEM ROMs: experimental until verified
- Runtime mode: Magisk `late_start service`, one-shot + bounded delayed reapply
- Battery behavior: no default loop, no wakelock, no network
- Magisk in-app updates: supported via `updateJson`

## Safety warning

This module can disable or delay loud-volume / Sound Dose warnings. That can increase risk of hearing damage. Use conservative playback levels and do not treat this as a safety feature.

## Target values

```text
audio_safe_csd_next_warning = 999999.0
safe_media_volume_enabled   = 0
audio_safe_volume_state     = 1
audio_safe_csd_current_value = 0.0
audio_safe_csd_dose_records = null
```

## What the boot service does

1. Waits for boot completion.
2. Waits for Android Settings Provider readiness.
3. Captures a `before` state snapshot.
4. Applies target values only when current values differ.
5. Captures `after_primary` state.
6. Performs one bounded delayed reapply.
7. Verifies the final state.
8. Performs one final delayed reapply only if drift is detected.
9. Writes structured logs and exits.

## Manual helpers

### Apply now

Use this after a transient warning or after values drift during active playback:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/apply-now.sh
```

### Active guard once

Use this for active Bluetooth sessions where Android repopulates CSD values during playback. It is bounded and exits after the configured passes. It is not a daemon.

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/active-guard-once.sh
```

Default: 12 passes, 15 seconds apart. Optional custom run:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/active-guard-once.sh 12 15
```

## H222 / car Bluetooth receiver note

On the tested Pixel, the H222 Skoda BT2MP3 receiver is shown as `Headphones` and the Android audio device type picker is greyed out. During active loud Bluetooth playback, Android can repopulate Sound Dose values even after the boot-time ASVD service has passed.

Observed behavior:

- transient high-volume warning can still briefly appear
- volume was not reduced
- CSD values can repopulate during active playback
- `active-guard-once.sh` restored the target state and final verify passed

ASVD does not currently modify Bluetooth device classification. A future optional BT Device Type Helper may be developed separately.

## Install

Install the ZIP in Magisk:

```text
Magisk → Modules → Install from storage → ASVD-v1.2.4.zip → Reboot
```

## Verify after reboot

Recommended full verify:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh
```

Recommended XDA/GitHub report:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda
```

Expected final line:

```text
RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS
```

Advanced/debug modes still exist but are not the primary support path: `--compact`, `--xda-short`, `--json`.

## XDA thread

https://xdaforums.com/t/module-audio-safe-volume-disabler-v1-1-2-pixel-android-16-verified.4788291/

## Optional config

Create `/data/adb/audio-safe-volume-battery-aware.conf` to override defaults:

```sh
DELAYED_REAPPLY_SECONDS="45"
LOW_POWER_REAPPLY_SECONDS="15"
FINAL_REAPPLY_SECONDS="120"
LOW_BATTERY_THRESHOLD="15"
TARGET_AUDIO_SAFE_VOLUME_STATE="1"
LOG_MAX_BYTES="65536"
ACTIVE_GUARD_PASSES="12"
ACTIVE_GUARD_SLEEP_SECONDS="15"
ACTIVE_GUARD_MAX_PASSES="24"
ACTIVE_GUARD_MAX_SLEEP_SECONDS="60"
APPLY_NOW_PASSES="2"
APPLY_NOW_SLEEP_SECONDS="2"
```

## Compatibility matrix

See [`COMPATIBILITY.md`](COMPATIBILITY.md).

## Support

See [`SUPPORT.md`](SUPPORT.md).

## Rollback

Disable/remove the module in Magisk and reboot.

The uninstall script intentionally does not blindly restore old Android audio safety values, because old values may be region/OEM/runtime-dependent.

Manual reset, if desired:

```sh
tsu /system/bin/sh -c 'settings delete global audio_safe_csd_next_warning; settings delete global safe_media_volume_enabled; settings delete global audio_safe_volume_state; settings delete global audio_safe_csd_current_value; settings delete global audio_safe_csd_dose_records'
```

## Release notes

See `CHANGELOG.md`.
