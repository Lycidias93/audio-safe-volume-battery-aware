# Audio Safe Volume Disabler v1.2.8

Android 17 verified / output-hardening release.

## What changed

- Pixel 10 Pro XL / Android 17 / SDK 37 is now documented as verified.
- Added bounded marker-only verify mode:
  ```sh
  tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --markers
  ```
- Hardened `verify.sh --compat` and `verify.sh --compat-xda` so huge Android settings values are omitted with length/hash/preview instead of flooding Termux/XDA.
- Compatibility discovery now filters by setting key name, not by matching noisy values.
- XDA service-log tails are shorter by default.
- BT Helper reporting now separates `current_type` from last requested type.
- Support bundle generation falls back to `/data/local/tmp` if Download is not writable.

## Runtime

Runtime audio behavior is unchanged from v1.2.7:

- no resident daemon
- no default polling loop
- no wakelock
- no network access
- no Play Services manipulation
- no Bluetooth config patching

## Verify after install

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --markers
```

Expected:

```text
RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS
```
