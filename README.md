<!-- telegram-release-channel:start -->
> Release updates: [@lycidias93](https://t.me/lycidias93)
<!-- telegram-release-channel:end -->

# Audio Safe Volume Disabler

<!-- ASVD_INTRO_START -->
## What it is and why it exists

Audio Safe Volume Disabler / ASVD is a **Magisk module** that disables or delays Android safe-volume / Sound Dose warning behavior after boot.

It started from a manual Android settings workaround and turns it into a bounded boot-time module: wait for boot, apply the target state, verify it, optionally reapply once if Android rewrites values, then exit.

ASVD is intentionally small and conservative:

- no resident daemon
- no polling loop by default
- no wakelock
- no network access
- no Play Services manipulation
- no Bluetooth config patching

The internal Magisk module ID intentionally remains `audio-safe-volume-battery-aware` for update compatibility.
<!-- ASVD_INTRO_END -->

## Current status

| Area | Status |
|---|---|
| Current stable release | `v1.2.7` |
| Version / versionCode | `v1.2.7` / `127` |
| Runtime model | Magisk `late_start service` |
| Boot behavior | one-shot apply + bounded delayed reapply |
| Battery behavior | no default loop, no wakelock, no network |
| Verified phone | Pixel 10 Pro XL / Android 16 / SDK 36 |
| Verified baseline | boot verify PASS |
| Verified Bluetooth scenario | H222 / Skoda BT2MP3 receiver after active guard |
| Optional companion | ASVD BT Type Helper `v0.6.1` / `61` |
| Companion shared state | `/data/adb/asvd/bt-helper.env` |
| Online updates | Enabled via Magisk `updateJson` |
| Other phones / OEM ROMs | Unknown, tester feedback needed |

## Download

All releases:

<https://github.com/Lycidias93/audio-safe-volume-battery-aware/releases>

Latest release:

<https://github.com/Lycidias93/audio-safe-volume-battery-aware/releases/latest>

Download the Magisk ZIP from the newest stable release:

```text
ASVD-vX.X.X.zip
```

Do **not** install this as a normal APK. Flash the ZIP in Magisk.

## Install

1. Flash the ZIP in Magisk.
2. Reboot.
3. Run full verify:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh
```

Expected final line:

```text
RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS
```

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

ASVD itself does not modify Bluetooth device classification. The separate optional ASVD BT Type Helper can change Bluetooth metadata key `17` with explicit user action and can report sanitized companion state back to ASVD.

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

## Optional BT Type Helper companion

ASVD can detect the optional ASVD BT Type Helper companion package:

```text
org.asvd.bttypehelper
```

Current verified companion baseline:

| Area | Status |
|---|---|
| Companion module | ASVD BT Type Helper |
| Current stable release | `v0.6.1` |
| Version / versionCode | `0.6.1` / `61` |
| Package | `org.asvd.bttypehelper` |
| Reference target | `H222` Bluetooth receiver |
| Reference result | `metadata_17=Carkit` |
| Shared state | `/data/adb/asvd/bt-helper.env` |

The split is intentional:

- ASVD handles Android safe-volume / Sound Dose settings.
- ASVD BT Type Helper handles optional Bluetooth device type metadata.
- ASVD only reads sanitized companion state for verify / XDA / support reports.
- ASVD does not depend on the helper and keeps working when the helper is absent.
- The helper does not trigger ASVD `apply-now.sh` unless explicitly requested with its opt-in flag.

Expected shared-state fields from BT Helper v0.6.1+:

```text
helper_present=1
helper_package=org.asvd.bttypehelper
helper_version=0.6.1
helper_versionCode=61
target_name=H222
last_result=PASS
current_type=Carkit
method=metadata_api
asvd_apply_now_triggered=0
```

Optional fields may include `requested_type`, `previous_type`, `last_run`, `last_error`, and sanitized target hints. The shared-state file must not contain a raw Bluetooth MAC address.

Safety boundaries:

- no Google Play Services manipulation
- no GMS-disable / offline-ui mode
- no Bluetooth service reload
- no direct `/data/misc/bluedroid/bt_config.conf` patching
- no background daemon
- no automatic boot-time Bluetooth metadata changes
- no automatic ASVD apply-now trigger by default

Companion repository:

<https://github.com/Lycidias93/asvd-bt-type-helper>


## Optional ASVD shared state

`apply-now.sh` and `active-guard-once.sh` write a small sanitized state file for support diagnostics:

```text
/data/adb/asvd/asvd.env
```

This does not create a daemon and does not change boot behavior.
