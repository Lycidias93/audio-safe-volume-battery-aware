#!/system/bin/sh
# Optional Magisk action: apply target values once, then verify.
# Manual action only. No daemon, no network, no wakelock.
MODDIR="${0%/*}"
exec /system/bin/sh "$MODDIR/apply-now.sh"
