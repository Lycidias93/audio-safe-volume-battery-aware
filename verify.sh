#!/system/bin/sh
# Verify Audio Safe Volume Battery Aware module status.
set -u

MODDIR="${0%/*}"
LOG="$MODDIR/service.log"
STATE_DIR="$MODDIR/state"
TARGET_SAFE_MEDIA_VOLUME_ENABLED="0"
TARGET_AUDIO_SAFE_VOLUME_STATE="1"
TARGET_AUDIO_SAFE_CSD_NEXT_WARNING="999999.0"
TARGET_AUDIO_SAFE_CSD_CURRENT_VALUE="0.0"

settings_get() {
  /system/bin/settings get global "$1" 2>/dev/null || echo "__ERROR__"
}

prop_get() {
  /system/bin/getprop "$1" 2>/dev/null || true
}

read_prop_file() {
  key="$1"
  file="$2"
  [ -r "$file" ] || return 0
  /system/bin/grep -m 1 "^$key=" "$file" 2>/dev/null | /system/bin/sed "s/^$key=//" 2>/dev/null || true
}

check_file() {
  label="$1"
  path="$2"
  if [ -s "$path" ]; then
    echo "PASS file=$label path=$path size_gt_0=yes"
    return 0
  fi
  echo "FAIL file=$label path=$path missing_or_empty=yes"
  return 1
}

ok=0
module_prop="$MODDIR/module.prop"
service_sh="$MODDIR/service.sh"
version="$(read_prop_file version "$module_prop")"
version_code="$(read_prop_file versionCode "$module_prop")"

printf 'module_id = '; read_prop_file id "$module_prop"
printf 'version = '; echo "$version"
printf 'versionCode = '; echo "$version_code"
printf 'android_sdk = '; prop_get ro.build.version.sdk
printf 'android_release = '; prop_get ro.build.version.release
printf 'manufacturer = '; prop_get ro.product.manufacturer
printf 'device = '; prop_get ro.product.device
printf 'model = '; prop_get ro.product.model
printf 'boot_completed = '; prop_get sys.boot_completed
printf 'battery_level = '; /system/bin/cmd battery get level 2>/dev/null || echo unknown
printf 'battery_status = '; /system/bin/cmd battery get status 2>/dev/null || echo unknown
printf 'low_power = '; settings_get low_power

echo
check_file module.prop "$module_prop" || ok=1
check_file service.sh "$service_sh" || ok=1

if [ -x "$service_sh" ]; then
  echo "PASS service_executable=yes"
else
  echo "FAIL service_executable=no"
  ok=1
fi

echo
v_next="$(settings_get audio_safe_csd_next_warning)"
v_enabled="$(settings_get safe_media_volume_enabled)"
v_state="$(settings_get audio_safe_volume_state)"
v_current="$(settings_get audio_safe_csd_current_value)"
v_records="$(settings_get audio_safe_csd_dose_records)"

printf 'audio_safe_csd_next_warning = %s\n' "$v_next"
printf 'safe_media_volume_enabled   = %s\n' "$v_enabled"
printf 'audio_safe_volume_state     = %s\n' "$v_state"
printf 'audio_safe_csd_current_value = %s\n' "$v_current"
printf 'audio_safe_csd_dose_records = %s\n' "$v_records"

[ "$v_next" = "$TARGET_AUDIO_SAFE_CSD_NEXT_WARNING" ] || { echo "FAIL key=audio_safe_csd_next_warning want=$TARGET_AUDIO_SAFE_CSD_NEXT_WARNING got=$v_next"; ok=1; }
[ "$v_enabled" = "$TARGET_SAFE_MEDIA_VOLUME_ENABLED" ] || { echo "FAIL key=safe_media_volume_enabled want=$TARGET_SAFE_MEDIA_VOLUME_ENABLED got=$v_enabled"; ok=1; }
[ "$v_state" = "$TARGET_AUDIO_SAFE_VOLUME_STATE" ] || { echo "FAIL key=audio_safe_volume_state want=$TARGET_AUDIO_SAFE_VOLUME_STATE got=$v_state"; ok=1; }
[ "$v_current" = "$TARGET_AUDIO_SAFE_CSD_CURRENT_VALUE" ] || { echo "FAIL key=audio_safe_csd_current_value want=$TARGET_AUDIO_SAFE_CSD_CURRENT_VALUE got=$v_current"; ok=1; }
[ "$v_records" = "null" ] || [ "$v_records" = "__ERROR__" ] || { echo "FAIL key=audio_safe_csd_dose_records want=null got=present"; ok=1; }

echo
if [ -d "$STATE_DIR" ]; then
  echo "== state snapshots =="
  /system/bin/ls -l "$STATE_DIR" 2>/dev/null || true
else
  echo "WARN state_snapshots=missing"
fi

echo
if [ -r "$LOG" ]; then
  echo "== log tail =="
  /system/bin/tail -n 80 "$LOG" 2>/dev/null || true
else
  echo "WARN service_log=missing"
fi

echo
if [ "$ok" -eq 0 ]; then
  echo "RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS"
  exit 0
fi

echo "RESULT: AUDIO_SAFE_VOLUME_VERIFY_FAIL"
exit 1
