#!/system/bin/sh
# Verify Audio Safe Volume Disabler module status.
set -u

MODE="full"
case "${1:-}" in
  --compact) MODE="compact" ;;
  --xda) MODE="xda" ;;
  --help|-h)
    echo "Usage: verify.sh [--compact|--xda]"
    exit 0
    ;;
esac

MODDIR="${0%/*}"
LOG="$MODDIR/service.log"
STATE_DIR="$MODDIR/state"
CONF="/data/adb/audio-safe-volume-battery-aware.conf"
TARGET_SAFE_MEDIA_VOLUME_ENABLED="0"
TARGET_AUDIO_SAFE_VOLUME_STATE="1"
TARGET_AUDIO_SAFE_CSD_NEXT_WARNING="999999.0"
TARGET_AUDIO_SAFE_CSD_CURRENT_VALUE="0.0"
DELETE_AUDIO_SAFE_CSD_DOSE_RECORDS="1"
DELAYED_REAPPLY_SECONDS="45"
LOW_POWER_REAPPLY_SECONDS="15"
FINAL_REAPPLY_SECONDS="120"
LOW_BATTERY_THRESHOLD="15"
LOG_MAX_BYTES="65536"

# shellcheck disable=SC1090
[ -r "$CONF" ] && . "$CONF"

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

magisk_version() {
  if command -v magisk >/dev/null 2>&1; then
    magisk -v 2>/dev/null || echo unknown
  elif [ -x /sbin/magisk ]; then
    /sbin/magisk -v 2>/dev/null || echo unknown
  else
    echo unknown
  fi
}

magisk_version_code() {
  if command -v magisk >/dev/null 2>&1; then
    magisk -V 2>/dev/null || echo unknown
  elif [ -x /sbin/magisk ]; then
    /sbin/magisk -V 2>/dev/null || echo unknown
  else
    echo unknown
  fi
}

check_file_quiet() {
  [ -s "$1" ] || return 1
  return 0
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

config_status() {
  if [ -r "$CONF" ]; then
    echo present
  else
    echo absent
  fi
}

log_status() {
  if [ -r "$LOG" ] && /system/bin/grep -q "DONE module=audio-safe-volume-battery-aware" "$LOG" 2>/dev/null; then
    echo PASS
  elif [ -r "$LOG" ]; then
    echo WARN_NO_DONE_MARKER
  else
    echo WARN_MISSING
  fi
}

values_status() {
  [ "$v_next" = "$TARGET_AUDIO_SAFE_CSD_NEXT_WARNING" ] || return 1
  [ "$v_enabled" = "$TARGET_SAFE_MEDIA_VOLUME_ENABLED" ] || return 1
  [ "$v_state" = "$TARGET_AUDIO_SAFE_VOLUME_STATE" ] || return 1
  [ "$v_current" = "$TARGET_AUDIO_SAFE_CSD_CURRENT_VALUE" ] || return 1
  if [ "$DELETE_AUDIO_SAFE_CSD_DOSE_RECORDS" = "1" ]; then
    [ "$v_records" = "null" ] || [ "$v_records" = "__ERROR__" ] || return 1
  fi
  return 0
}

module_prop="$MODDIR/module.prop"
service_sh="$MODDIR/service.sh"
version="$(read_prop_file version "$module_prop")"
version_code="$(read_prop_file versionCode "$module_prop")"
module_id="$(read_prop_file id "$module_prop")"
module_name="$(read_prop_file name "$module_prop")"
android_sdk="$(prop_get ro.build.version.sdk)"
android_release="$(prop_get ro.build.version.release)"
manufacturer="$(prop_get ro.product.manufacturer)"
device="$(prop_get ro.product.device)"
model="$(prop_get ro.product.model)"
boot_completed="$(prop_get sys.boot_completed)"
battery_level="$(/system/bin/cmd battery get level 2>/dev/null || echo unknown)"
battery_status="$(/system/bin/cmd battery get status 2>/dev/null || echo unknown)"
low_power="$(settings_get low_power)"
magisk_v="$(magisk_version)"
magisk_vc="$(magisk_version_code)"
config_file="$(config_status)"
service_log="$(log_status)"

v_next="$(settings_get audio_safe_csd_next_warning)"
v_enabled="$(settings_get safe_media_volume_enabled)"
v_state="$(settings_get audio_safe_volume_state)"
v_current="$(settings_get audio_safe_csd_current_value)"
v_records="$(settings_get audio_safe_csd_dose_records)"

ok=0
check_file_quiet "$module_prop" || ok=1
check_file_quiet "$service_sh" || ok=1
[ -x "$service_sh" ] || ok=1
values_status || ok=1

if [ "$MODE" = "compact" ]; then
  echo "ASVD $version"
  echo "device=$model"
  echo "android=$android_release sdk=$android_sdk"
  echo "magisk=$magisk_v ($magisk_vc)"
  echo "config=$config_file"
  if values_status; then echo "values=PASS"; else echo "values=FAIL"; fi
  echo "service_log=$service_log"
  if [ "$ok" -eq 0 ]; then
    echo "RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS"
    exit 0
  fi
  echo "RESULT: AUDIO_SAFE_VOLUME_VERIFY_FAIL"
  exit 1
fi

if [ "$MODE" = "xda" ]; then
  echo "[CODE]"
  echo "Module: $module_name $version ($version_code)"
  echo "Module ID: $module_id"
  echo "Device: $manufacturer $model ($device)"
  echo "Android: $android_release / SDK $android_sdk"
  echo "Magisk: $magisk_v ($magisk_vc)"
  echo "Boot completed: $boot_completed"
  echo "Battery: level=$battery_level status=$battery_status low_power=$low_power"
  echo "Config: $config_file ($CONF)"
  echo "Values:"
  echo "  audio_safe_csd_next_warning = $v_next"
  echo "  safe_media_volume_enabled   = $v_enabled"
  echo "  audio_safe_volume_state     = $v_state"
  echo "  audio_safe_csd_current_value = $v_current"
  echo "  audio_safe_csd_dose_records = $v_records"
  echo "Service log: $service_log"
  if [ -r "$LOG" ]; then
    echo "Log tail:"
    /system/bin/tail -n 30 "$LOG" 2>/dev/null || true
  fi
  if [ "$ok" -eq 0 ]; then
    echo "RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS"
  else
    echo "RESULT: AUDIO_SAFE_VOLUME_VERIFY_FAIL"
  fi
  echo "[/CODE]"
  [ "$ok" -eq 0 ] && exit 0 || exit 1
fi

printf 'module_id = %s
' "$module_id"
printf 'module_name = %s
' "$module_name"
printf 'version = %s
' "$version"
printf 'versionCode = %s
' "$version_code"
printf 'android_sdk = %s
' "$android_sdk"
printf 'android_release = %s
' "$android_release"
printf 'manufacturer = %s
' "$manufacturer"
printf 'device = %s
' "$device"
printf 'model = %s
' "$model"
printf 'magisk_version = %s
' "$magisk_v"
printf 'magisk_versionCode = %s
' "$magisk_vc"
printf 'boot_completed = %s
' "$boot_completed"
printf 'battery_level = %s
' "$battery_level"
printf 'battery_status = %s
' "$battery_status"
printf 'low_power = %s
' "$low_power"

echo
check_file module.prop "$module_prop" || ok=1
check_file service.sh "$service_sh" || ok=1
check_file verify.sh "$MODDIR/verify.sh" || ok=1

if [ -x "$service_sh" ]; then
  echo "PASS service_executable=yes"
else
  echo "FAIL service_executable=no"
  ok=1
fi

echo
echo "== config =="
printf 'config_file = %s
' "$config_file"
printf 'config_path = %s
' "$CONF"
printf 'target_safe_media_volume_enabled = %s
' "$TARGET_SAFE_MEDIA_VOLUME_ENABLED"
printf 'target_audio_safe_volume_state = %s
' "$TARGET_AUDIO_SAFE_VOLUME_STATE"
printf 'target_audio_safe_csd_next_warning = %s
' "$TARGET_AUDIO_SAFE_CSD_NEXT_WARNING"
printf 'target_audio_safe_csd_current_value = %s
' "$TARGET_AUDIO_SAFE_CSD_CURRENT_VALUE"
printf 'delete_audio_safe_csd_dose_records = %s
' "$DELETE_AUDIO_SAFE_CSD_DOSE_RECORDS"
printf 'delayed_reapply_seconds = %s
' "$DELAYED_REAPPLY_SECONDS"
printf 'low_power_reapply_seconds = %s
' "$LOW_POWER_REAPPLY_SECONDS"
printf 'final_reapply_seconds = %s
' "$FINAL_REAPPLY_SECONDS"
printf 'low_battery_threshold = %s
' "$LOW_BATTERY_THRESHOLD"
printf 'log_max_bytes = %s
' "$LOG_MAX_BYTES"

echo
echo "== values =="
printf 'audio_safe_csd_next_warning = %s
' "$v_next"
printf 'safe_media_volume_enabled   = %s
' "$v_enabled"
printf 'audio_safe_volume_state     = %s
' "$v_state"
printf 'audio_safe_csd_current_value = %s
' "$v_current"
printf 'audio_safe_csd_dose_records = %s
' "$v_records"

[ "$v_next" = "$TARGET_AUDIO_SAFE_CSD_NEXT_WARNING" ] || { echo "FAIL key=audio_safe_csd_next_warning want=$TARGET_AUDIO_SAFE_CSD_NEXT_WARNING got=$v_next"; ok=1; }
[ "$v_enabled" = "$TARGET_SAFE_MEDIA_VOLUME_ENABLED" ] || { echo "FAIL key=safe_media_volume_enabled want=$TARGET_SAFE_MEDIA_VOLUME_ENABLED got=$v_enabled"; ok=1; }
[ "$v_state" = "$TARGET_AUDIO_SAFE_VOLUME_STATE" ] || { echo "FAIL key=audio_safe_volume_state want=$TARGET_AUDIO_SAFE_VOLUME_STATE got=$v_state"; ok=1; }
[ "$v_current" = "$TARGET_AUDIO_SAFE_CSD_CURRENT_VALUE" ] || { echo "FAIL key=audio_safe_csd_current_value want=$TARGET_AUDIO_SAFE_CSD_CURRENT_VALUE got=$v_current"; ok=1; }
if [ "$DELETE_AUDIO_SAFE_CSD_DOSE_RECORDS" = "1" ]; then
  [ "$v_records" = "null" ] || [ "$v_records" = "__ERROR__" ] || { echo "FAIL key=audio_safe_csd_dose_records want=null got=present"; ok=1; }
fi

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
printf 'compact_command = %s
' "tsu /system/bin/sh $MODDIR/verify.sh --compact"
printf 'xda_report_command = %s
' "tsu /system/bin/sh $MODDIR/verify.sh --xda"

echo
if [ "$ok" -eq 0 ]; then
  echo "RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS"
  exit 0
fi

echo "RESULT: AUDIO_SAFE_VOLUME_VERIFY_FAIL"
exit 1
