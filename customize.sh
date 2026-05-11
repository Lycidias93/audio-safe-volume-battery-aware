#!/system/bin/sh
# Magisk installation customizer

ui_print "- Audio Safe Volume Disabler v1.2.2"
ui_print "- Module ID remains audio-safe-volume-battery-aware for update compatibility"
ui_print "- Mode: late_start one-shot, no resident daemon"
ui_print "- Battery aware: idempotent writes, bounded delayed reapply"
ui_print "- Changed: diagnostics polish only; runtime audio behavior unchanged"
ui_print "- Added: dynamic service log version, improved Magisk detection, --xda-short, --json"

legacy="/data/adb/service.d/99-audio-safe-volume.sh"
backup_dir="/data/adb/audio-safe-volume-battery-aware-backup"
if [ -f "$legacy" ]; then
  mkdir -p "$backup_dir" 2>/dev/null || true
  stamp="$(date +%Y%m%d_%H%M%S 2>/dev/null || echo unknown)"
  cp -af "$legacy" "$backup_dir/99-audio-safe-volume.sh.bak.$stamp" 2>/dev/null || true
  rm -f "$legacy" 2>/dev/null || true
  ui_print "- Legacy service.d boot-fix moved to backup"
  ui_print "  $backup_dir/99-audio-safe-volume.sh.bak.$stamp"
fi

set_perm "$MODPATH/service.sh" 0 0 0755
set_perm "$MODPATH/verify.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755
set_perm "$MODPATH/module.prop" 0 0 0644
set_perm "$MODPATH/update.json" 0 0 0644
[ -f "$MODPATH/README.md" ] && set_perm "$MODPATH/README.md" 0 0 0644
[ -f "$MODPATH/CHANGELOG.md" ] && set_perm "$MODPATH/CHANGELOG.md" 0 0 0644
[ -f "$MODPATH/LICENSE" ] && set_perm "$MODPATH/LICENSE" 0 0 0644

ui_print "- Installed. Reboot required for Magisk service run."
ui_print "- Verify: tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh"
ui_print "- Compact: tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --compact"
ui_print "- XDA short: tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda-short"
ui_print "- XDA report: tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda"
ui_print "- JSON: tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --json"
