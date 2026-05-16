# Audio Safe Volume Disabler

Small Magisk module that disables/delays Android safe-volume / Sound Dose warning behavior after boot.

The internal Magisk module ID intentionally remains `audio-safe-volume-battery-aware` for update compatibility.

## Status

- Version: `v1.2.7`
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

ASVD does not currently modify Bluetooth device classification.

## Rejected experimental helper path

Do **not** use Google Play Services manipulation as a public/helper path for changing Bluetooth audio device type.

Private testing on Pixel Android 16 showed:

- H222 UI-unlock `soft` mode failed
- H222 UI-unlock `hard` mode failed
- H222 `offline-ui` + Bluetooth reload failed
- GMS-disable/offline-ui testing caused Google Play Billing account-context side effects
- Wavelet Pro license check used the wrong Google account
- Play Store data reset alone did not fix that account-context issue
- removing all non-primary Google accounts restored Wavelet Pro in that test

Decision:

- no GMS-disable/offline-ui helper is shipped in public ASVD
- no Play Services manipulation as a default or helper path
- no direct `/data/misc/bluedroid/bt_config.conf` patching
- no boot automation for Bluetooth type changes

Future BT Device Type Helper research, if any, must use a Bluetooth metadata/API path only and remain optional/manual.

## Install

Install the ZIP in Magisk:

```text
Magisk → Modules → Install from storage → ASVD-v1.2.7.zip → Reboot
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


## Compatibility probe

For non-Pixel or unverified devices, run the read-only compatibility probe. It does not change Android settings.

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --compat
```

Copy-ready XDA/GitHub compatibility report:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --compat-xda
```

The probe checks Android/OEM identity, root-stack hints, Settings Provider access and safe-volume / Sound Dose related settings keys.

## Support bundle

For troubleshooting, generate a sanitized local report file in Download:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --support-bundle
```

The bundle includes full verify, XDA report, compatibility probe, config lint and companion state. Do not post it without checking for unrelated private data first.

## Config lint

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --lint-config
```

This checks `/data/adb/audio-safe-volume-battery-aware.conf` for known keys and sane numeric values.

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

## Optional companion detection

ASVD v1.2.6 can detect the optional ASVD BT Type Helper companion package:

```text
org.asvd.bttypehelper
```

The companion is optional. ASVD does not depend on it and does not control it at boot. When present, ASVD verify and `--xda` reports show package/version and optional shared state from:

```text
/data/adb/asvd/bt-helper.env
```

Intended split:

- ASVD: safe-volume / Sound Dose handling
- BT Type Helper: optional Bluetooth device type / Carkit metadata research
- Shared reporting only; no GMS-disable/offline-ui mode, no direct `bt_config.conf` patching, no boot automation for Bluetooth type changes


## Optional ASVD shared state

`apply-now.sh` and `active-guard-once.sh` write a small sanitized state file for support diagnostics:

```text
/data/adb/asvd/asvd.env
```

This does not create a daemon and does not change boot behavior.
