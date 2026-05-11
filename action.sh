#!/system/bin/sh
# Optional Magisk action: run compact Audio Safe Volume Disabler verification.
MODDIR="${0%/*}"
exec /system/bin/sh "$MODDIR/verify.sh" --compact
