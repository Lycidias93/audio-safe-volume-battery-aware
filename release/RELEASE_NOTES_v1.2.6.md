Audio Safe Volume Disabler v1.2.6

Companion detection release.

## Changes

• Added optional ASVD BT Type Helper companion detection to verify output and XDA/GitHub reports.
• Reports companion package `org.asvd.bttypehelper`, package version and optional shared state when available.
• Added shared optional state path documentation: `/data/adb/asvd/bt-helper.env`.
• Kept ASVD and BT Helper loosely coupled: no hard dependency, no boot automation, no GMS-disable/offline-ui mode and no direct `bt_config.conf` patching.
• Runtime audio behavior unchanged from v1.2.5.

## Runtime mode

• Magisk `late_start service`
• One-shot boot apply
• Bounded delayed reapply
• Final reapply only if drift is detected
• No resident daemon
• No network
• No wakelock

## Verify after install

Full verify:

    tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh

XDA/GitHub report:

    tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda

Expected final line:

    RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS

## Companion note

If the optional ASVD BT Type Helper is installed, ASVD verify output will show its package/version and any state available from `/data/adb/asvd/bt-helper.env`.

## Safety warning

This module can disable or delay loud-volume / Sound Dose warnings. That can increase risk of hearing damage. Use conservative playback levels.
