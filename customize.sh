#!/system/bin/sh
# Magisk installation customizer

ui_print "- Audio Safe Volume Disabler v1.2.9"
ui_print "- Module ID remains audio-safe-volume-battery-aware for update compatibility"
ui_print "- Mode: late_start one-shot, no resident daemon"
ui_print "- Battery aware: idempotent writes, bounded delayed reapply"
ui_print "- Changed: compatibility probe, support bundle, config lint and companion state stale detection; boot runtime unchanged"
ui_print "- Rejected helper path: no GMS-disable/offline-ui mode is shipped"
ui_print "- Future BT helper direction: metadata/API research only"
ui_print "- Companion detection: org.asvd.bttypehelper status shown in verify/XDA reports"
ui_print "- Shared optional companion state path: /data/adb/asvd/bt-helper.env"
ui_print "- Manual helpers remain: apply-now.sh and active-guard-once.sh"
ui_print "- No default daemon, no network, no wakelock"

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
set_perm "$MODPATH/apply-now.sh" 0 0 0755
set_perm "$MODPATH/active-guard-once.sh" 0 0 0755
set_perm "$MODPATH/action.sh" 0 0 0755
set_perm "$MODPATH/uninstall.sh" 0 0 0755
set_perm "$MODPATH/module.prop" 0 0 0644
set_perm "$MODPATH/update.json" 0 0 0644
[ -f "$MODPATH/README.md" ] && set_perm "$MODPATH/README.md" 0 0 0644
[ -f "$MODPATH/CHANGELOG.md" ] && set_perm "$MODPATH/CHANGELOG.md" 0 0 0644
[ -f "$MODPATH/LICENSE" ] && set_perm "$MODPATH/LICENSE" 0 0 0644
[ -f "$MODPATH/SUPPORT.md" ] && set_perm "$MODPATH/SUPPORT.md" 0 0 0644
[ -f "$MODPATH/COMPATIBILITY.md" ] && set_perm "$MODPATH/COMPATIBILITY.md" 0 0 0644

ui_print "- Installed. Reboot required for Magisk service run."
ui_print "- Full verify: tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh"
ui_print "- XDA report: tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda"
ui_print "- Compat report: tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --compat-xda"
ui_print "- Support bundle: tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --support-bundle"
ui_print "- Config lint: tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --lint-config"
ui_print "- Apply now: tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/apply-now.sh"
ui_print "- Active guard: tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/active-guard-once.sh"
