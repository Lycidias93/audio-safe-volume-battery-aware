#!/system/bin/sh
# Optional Magisk action: run module verification.
MODDIR="${0%/*}"
exec /system/bin/sh "$MODDIR/verify.sh"
