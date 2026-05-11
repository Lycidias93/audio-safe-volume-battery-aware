# Support

Please include a verify report when opening an issue or replying on XDA.

## Recommended report

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda
```

## Also useful

For local troubleshooting, run the full verify:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh
```

If values drift during active Bluetooth playback, run:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/apply-now.sh
```

For a bounded active playback session guard, run:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/active-guard-once.sh
```

## Include

- Device model
- Android version and SDK
- Root stack and version
- ROM / OEM skin
- Module version
- Full verify/report output
- Playback context: speaker, Bluetooth headphones, car receiver, Android Auto
- Whether the warning returned after reboot, Bluetooth reconnect, Android Auto use, or media playback
- Whether volume was actually reduced

## Known H222 / car receiver case

The tested H222 Skoda BT2MP3 receiver is classified as headphones by Pixel Android 16 and the device type picker is greyed out. During active playback, Android can repopulate Sound Dose values. `active-guard-once.sh` is the current safe manual workaround.

ASVD does not currently modify Bluetooth device classification. Do not edit `/data/misc/bluedroid/bt_config.conf` manually.

## Do not include

- Private keys
- Tokens
- Full unrelated logs
- Personal account data
- Unsanitized Bluetooth MAC addresses

## Known scope

Pixel Android 16 with Magisk is verified. Other devices are experimental until verified.
