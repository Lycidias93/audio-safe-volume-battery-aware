# Support

Please include a verify report when opening an issue or replying on XDA.

## Recommended report

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda
```

## Compatibility report for other devices

For Samsung, Xiaomi, LineageOS, KernelSU/APatch or other non-baseline setups, also include:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --compat-xda
```

For deeper troubleshooting, generate a local support bundle:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --support-bundle
```

Check the generated file before posting it.

## Also useful

For config troubleshooting, run:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --lint-config
```

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

## Rejected helper path

Do not use or request a GMS-disable/offline-ui helper path in public ASVD.

Observed during private H222 helper testing:

- soft UI-unlock mode failed
- hard UI-unlock mode failed
- offline-ui + Bluetooth reload failed
- Google Play Services disable/offline-ui testing caused Google Play Billing account-context side effects
- Wavelet Pro license check used the wrong Google account
- Play Store data reset alone did not fix it
- removing all non-primary Google accounts restored Wavelet Pro in that test

Decision:

- no Google Play Services manipulation as default/helper behavior
- no offline-ui helper shipped
- no direct Bluetooth config patching
- no boot automation for Bluetooth type changes
- future BT helper research must use Bluetooth metadata/API path only

## Do not include

- Private keys
- Tokens
- Full unrelated logs
- Personal account data
- Unsanitized Bluetooth MAC addresses
- Google account identifiers

## Known scope

Pixel Android 16 with Magisk is verified. Other devices are experimental until verified.

## Companion status

ASVD v1.2.6 reports optional ASVD BT Type Helper status in full verify and XDA/GitHub reports.

Please include the companion block when reporting H222 / Bluetooth receiver issues:

```text
Companion:
  ASVD BT Type Helper: present/absent
  Package: org.asvd.bttypehelper
  State file: present/absent
  Requested type: ...
  Last result: ...
```

The companion is optional and remains separate from ASVD core runtime.
