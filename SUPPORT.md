# Support

Please include a verify report when opening an issue or replying on XDA.

## Preferred short report

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda-short
```

## Full report

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda
```

## Include

- Device model
- Android version and SDK
- Root stack and version
- ROM / OEM skin
- Module version
- Verify output
- Whether the warning returned after reboot, Bluetooth reconnect, or media playback

## Do not include

- Private keys
- Tokens
- Full unrelated logs
- Personal account data

## Known scope

Pixel Android 16 with Magisk is verified. Other devices are experimental until verified.
