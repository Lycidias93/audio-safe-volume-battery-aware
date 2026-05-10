#!/system/bin/sh
# Runs when Magisk removes the module.
LOG="/data/adb/audio-safe-volume-battery-aware-uninstall.log"
echo "$(date '+%Y-%m-%dT%H:%M:%S%z' 2>/dev/null || date) uninstall module=audio-safe-volume-battery-aware note='settings left unchanged intentionally'" >> "$LOG" 2>/dev/null || true
exit 0
