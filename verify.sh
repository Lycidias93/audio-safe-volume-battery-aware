#!/system/bin/sh
# Verify Audio Safe Volume Disabler module status.
set -u

MODE="full"
case "${1:-}" in
  --compact) MODE="compact" ;;
  --xda) MODE="xda" ;;
  --xda-short) MODE="xda-short" ;;
  --json) MODE="json" ;;
  --compat) MODE="compat" ;;
  --compat-xda) MODE="compat-xda" ;;
  --lint-config) MODE="lint-config" ;;
  --support-bundle) MODE="support-bundle" ;;
  --help|-h)
    echo "Usage: verify.sh [--xda|--compact|--xda-short|--json|--compat|--compat-xda|--lint-config|--support-bundle]"
      echo "Recommended: full verify (no args), XDA full report (--xda), or compatibility report (--compat-xda)."
    exit 0
    ;;
esac

MODDIR="${0%/*}"
LOG="$MODDIR/service.log"
STATE_DIR="$MODDIR/state"
CONF="/data/adb/audio-safe-volume-battery-aware.conf"
XDA_THREAD="https://xdaforums.com/t/module-audio-safe-volume-disabler-v1-1-2-pixel-android-16-verified.4788291/"
ASVD_SHARED_DIR="/data/adb/asvd"
BT_HELPER_PKG="org.asvd.bttypehelper"
BT_HELPER_STATE="$ASVD_SHARED_DIR/bt-helper.env"
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
COMPANION_STATE_STALE_SECONDS="86400"

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

find_magisk_bin() {
  for p in     "$(command -v magisk 2>/dev/null || true)"     /sbin/magisk     /debug_ramdisk/magisk     /data/adb/magisk/magisk     /cache/magisk/magisk
  do
    [ -n "$p" ] || continue
    [ -x "$p" ] || continue
    echo "$p"
    return 0
  done
  return 1
}

magisk_version() {
  if [ -n "${MAGISK_VER:-}" ]; then
    echo "$MAGISK_VER"
    return 0
  fi
  bin="$(find_magisk_bin 2>/dev/null || true)"
  [ -n "$bin" ] && "$bin" -v 2>/dev/null && return 0
  echo unknown
}

magisk_version_code() {
  if [ -n "${MAGISK_VER_CODE:-}" ]; then
    echo "$MAGISK_VER_CODE"
    return 0
  fi
  bin="$(find_magisk_bin 2>/dev/null || true)"
  [ -n "$bin" ] && "$bin" -V 2>/dev/null && return 0
  echo unknown
}

json_escape() {
  echo "$1" | /system/bin/sed 's/\/\\/g; s/"/\"/g'
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

package_status() {
  pkg="$1"
  if /system/bin/pm path "$pkg" >/dev/null 2>&1; then
    echo present
  else
    echo absent
  fi
}

package_version_name() {
  pkg="$1"
  /system/bin/dumpsys package "$pkg" 2>/dev/null     | /system/bin/grep -m 1 'versionName=' 2>/dev/null     | /system/bin/sed 's/.*versionName=//' 2>/dev/null || true
}

package_version_code() {
  pkg="$1"
  /system/bin/dumpsys package "$pkg" 2>/dev/null     | /system/bin/grep -m 1 'versionCode=' 2>/dev/null     | /system/bin/sed 's/.*versionCode=//; s/[[:space:]].*//' 2>/dev/null || true
}

state_file_status() {
  if [ -r "$BT_HELPER_STATE" ]; then
    echo present
  else
    echo absent
  fi
}

state_value() {
  key="$1"
  [ -r "$BT_HELPER_STATE" ] || return 0
  /system/bin/grep -m 1 "^$key=" "$BT_HELPER_STATE" 2>/dev/null     | /system/bin/sed "s/^$key=//" 2>/dev/null || true
}

now_epoch() {
  /system/bin/date +%s 2>/dev/null || date +%s 2>/dev/null || echo 0
}

file_mtime_epoch() {
  f="$1"
  [ -r "$f" ] || { echo 0; return 0; }
  /system/bin/stat -c %Y "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null || echo 0
}

safe_int() {
  v="$1"
  case "$v" in ''|*[!0-9]*) echo 0 ;; *) echo "$v" ;; esac
}

state_age_seconds() {
  f="$1"
  [ -r "$f" ] || { echo unknown; return 0; }
  now="$(safe_int "$(now_epoch)")"
  mt="$(safe_int "$(file_mtime_epoch "$f")")"
  if [ "$now" -gt 0 ] && [ "$mt" -gt 0 ] && [ "$now" -ge "$mt" ]; then
    echo $((now - mt))
  else
    echo unknown
  fi
}

state_stale_status() {
  age="$1"
  threshold="$(safe_int "$COMPANION_STATE_STALE_SECONDS")"
  [ "$threshold" -gt 0 ] || threshold=86400
  case "$age" in ''|unknown|*[!0-9]*) echo unknown ;; *) [ "$age" -gt "$threshold" ] && echo yes || echo no ;; esac
}

settings_key_status() {
  ns="$1"
  key="$2"
  v="$(/system/bin/settings get "$ns" "$key" 2>/dev/null || echo __ERROR__)"
  if [ "$v" = "__ERROR__" ]; then
    echo error
  elif [ "$v" = "null" ]; then
    echo absent
  else
    echo present
  fi
}

settings_search() {
  ns="$1"
  /system/bin/settings list "$ns" 2>/dev/null \
    | /system/bin/grep -Ei 'audio_safe|safe_media|sound.*dose|volume.*safe|hearing|csd' 2>/dev/null \
    | /system/bin/sed -n '1,80p' || true
}

root_stack() {
  out=""
  if [ "$magisk_v" != "unknown" ] || [ "$magisk_bin" != "unknown" ]; then out="${out}Magisk"; fi
  for p in /data/adb/ksu/bin/su /data/adb/ksud /debug_ramdisk/ksu/bin/su; do
    [ -e "$p" ] && out="${out}${out:+,}KernelSU"
  done
  for p in /data/adb/ap/bin/su /data/adb/apd /debug_ramdisk/ap/bin/su; do
    [ -e "$p" ] && out="${out}${out:+,}APatch"
  done
  [ -n "$out" ] || out="unknown"
  echo "$out"
}

compat_result() {
  n="$(settings_key_status global audio_safe_csd_next_warning)"
  e="$(settings_key_status global safe_media_volume_enabled)"
  s="$(settings_key_status global audio_safe_volume_state)"
  c="$(settings_key_status global audio_safe_csd_current_value)"
  r="$(settings_key_status global audio_safe_csd_dose_records)"
  if [ "$n" = "present" ] && [ "$e" = "present" ] && [ "$s" = "present" ]; then
    echo probably-compatible
  elif [ "$n" = "absent" ] && [ "$e" = "absent" ] && [ "$s" = "absent" ] && [ "$c" = "absent" ] && [ "$r" = "absent" ]; then
    echo unknown-no-keys-present
  elif [ "$n" = "error" ] || [ "$e" = "error" ] || [ "$s" = "error" ]; then
    echo unknown-settings-error
  else
    echo partial-unknown
  fi
}

config_lint() {
  lint_ok=0
  echo "== config lint =="
  echo "config_file=$config_file"
  if [ ! -r "$CONF" ]; then
    echo "config_lint=PASS reason=absent_using_defaults"
    echo "RESULT: ASVD_CONFIG_LINT_PASS"
    return 0
  fi
  allowed='^(DELAYED_REAPPLY_SECONDS|LOW_POWER_REAPPLY_SECONDS|FINAL_REAPPLY_SECONDS|LOW_BATTERY_THRESHOLD|TARGET_SAFE_MEDIA_VOLUME_ENABLED|TARGET_AUDIO_SAFE_VOLUME_STATE|TARGET_AUDIO_SAFE_CSD_NEXT_WARNING|TARGET_AUDIO_SAFE_CSD_CURRENT_VALUE|DELETE_AUDIO_SAFE_CSD_DOSE_RECORDS|LOG_MAX_BYTES|ACTIVE_GUARD_PASSES|ACTIVE_GUARD_SLEEP_SECONDS|ACTIVE_GUARD_MAX_PASSES|ACTIVE_GUARD_MAX_SLEEP_SECONDS|APPLY_NOW_PASSES|APPLY_NOW_SLEEP_SECONDS|COMPANION_STATE_STALE_SECONDS)='
  /system/bin/grep -n '^[A-Za-z_][A-Za-z0-9_]*=' "$CONF" 2>/dev/null | while IFS= read -r line; do
    body="${line#*:}"
    echo "$body" | /system/bin/grep -Eq "$allowed" || echo "WARN unknown_config_key line=$line"
  done
  for kv in \
    "DELAYED_REAPPLY_SECONDS=$DELAYED_REAPPLY_SECONDS" \
    "LOW_POWER_REAPPLY_SECONDS=$LOW_POWER_REAPPLY_SECONDS" \
    "FINAL_REAPPLY_SECONDS=$FINAL_REAPPLY_SECONDS" \
    "LOW_BATTERY_THRESHOLD=$LOW_BATTERY_THRESHOLD" \
    "LOG_MAX_BYTES=$LOG_MAX_BYTES" \
    "COMPANION_STATE_STALE_SECONDS=$COMPANION_STATE_STALE_SECONDS"
  do
    key="${kv%%=*}"
    val="${kv#*=}"
    case "$val" in ''|*[!0-9]*) echo "FAIL numeric_config key=$key value=$val"; lint_ok=1 ;; *) echo "PASS numeric_config key=$key value=$val" ;; esac
  done
  case "$TARGET_SAFE_MEDIA_VOLUME_ENABLED" in 0|1) echo "PASS target_safe_media_volume_enabled=$TARGET_SAFE_MEDIA_VOLUME_ENABLED" ;; *) echo "FAIL target_safe_media_volume_enabled=$TARGET_SAFE_MEDIA_VOLUME_ENABLED"; lint_ok=1 ;; esac
  case "$DELETE_AUDIO_SAFE_CSD_DOSE_RECORDS" in 0|1) echo "PASS delete_audio_safe_csd_dose_records=$DELETE_AUDIO_SAFE_CSD_DOSE_RECORDS" ;; *) echo "FAIL delete_audio_safe_csd_dose_records=$DELETE_AUDIO_SAFE_CSD_DOSE_RECORDS"; lint_ok=1 ;; esac
  if [ "$lint_ok" -eq 0 ]; then
    echo "RESULT: ASVD_CONFIG_LINT_PASS"
    return 0
  fi
  echo "RESULT: ASVD_CONFIG_LINT_FAIL"
  return 1
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
magisk_bin="$(find_magisk_bin 2>/dev/null || echo unknown)"
config_file="$(config_status)"
service_log="$(log_status)"
bt_helper_status="$(package_status "$BT_HELPER_PKG")"
bt_helper_version="$(package_version_name "$BT_HELPER_PKG")"
bt_helper_version_code="$(package_version_code "$BT_HELPER_PKG")"
[ -n "$bt_helper_version" ] || bt_helper_version="unknown"
[ -n "$bt_helper_version_code" ] || bt_helper_version_code="unknown"
bt_helper_state_file="$(state_file_status)"
bt_helper_state_package="$(state_value package)"
bt_helper_state_version="$(state_value helper_version)"
bt_helper_target_name="$(state_value target_name)"
bt_helper_requested_type="$(state_value requested_type)"
bt_helper_last_result="$(state_value last_result)"
bt_helper_last_run="$(state_value last_run)"
[ -n "$bt_helper_state_package" ] || bt_helper_state_package="unknown"
[ -n "$bt_helper_state_version" ] || bt_helper_state_version="unknown"
[ -n "$bt_helper_target_name" ] || bt_helper_target_name="unknown"
[ -n "$bt_helper_requested_type" ] || bt_helper_requested_type="unknown"
[ -n "$bt_helper_last_result" ] || bt_helper_last_result="unknown"
[ -n "$bt_helper_last_run" ] || bt_helper_last_run="unknown"
bt_helper_state_age_seconds="$(state_age_seconds "$BT_HELPER_STATE")"
bt_helper_state_stale="$(state_stale_status "$bt_helper_state_age_seconds")"
root_stack_value="$(root_stack)"
compat_probe_result="$(compat_result)"

v_next="$(settings_get audio_safe_csd_next_warning)"
v_enabled="$(settings_get safe_media_volume_enabled)"
v_state="$(settings_get audio_safe_volume_state)"
v_current="$(settings_get audio_safe_csd_current_value)"
v_records="$(settings_get audio_safe_csd_dose_records)"

ok=0
check_file_quiet "$module_prop" || ok=1
check_file_quiet "$service_sh" || ok=1
check_file_quiet "$MODDIR/verify.sh" || ok=1
[ -x "$service_sh" ] || ok=1
values_status || ok=1

if [ "$MODE" = "lint-config" ]; then
  config_lint
  exit $?
fi

if [ "$MODE" = "compat" ] || [ "$MODE" = "compat-xda" ]; then
  [ "$MODE" = "compat-xda" ] && echo "[CODE]"
  echo "== compatibility probe =="
  echo "module=$module_name $version ($version_code)"
  echo "android_release=$android_release"
  echo "android_sdk=$android_sdk"
  echo "manufacturer=$manufacturer"
  echo "device=$device"
  echo "model=$model"
  echo "root_stack=$root_stack_value"
  echo "magisk=$magisk_v ($magisk_vc)"
  echo "settings_provider_ready=$([ "$(settings_key_status global safe_media_volume_enabled)" != "error" ] && echo yes || echo no)"
  echo "write_test_performed=no"
  echo "global.audio_safe_csd_next_warning=$(settings_key_status global audio_safe_csd_next_warning)"
  echo "global.safe_media_volume_enabled=$(settings_key_status global safe_media_volume_enabled)"
  echo "global.audio_safe_volume_state=$(settings_key_status global audio_safe_volume_state)"
  echo "global.audio_safe_csd_current_value=$(settings_key_status global audio_safe_csd_current_value)"
  echo "global.audio_safe_csd_dose_records=$(settings_key_status global audio_safe_csd_dose_records)"
  echo "compat_result=$compat_probe_result"
  echo
  echo "== discovered related settings: global =="
  settings_search global
  echo
  echo "== discovered related settings: secure =="
  settings_search secure
  echo
  echo "== discovered related settings: system =="
  settings_search system
  echo
  if [ "$MODE" = "compat-xda" ]; then
    echo "RESULT: ASVD_COMPAT_REPORT_DONE"
    echo "[/CODE]"
  else
    echo "RESULT: ASVD_COMPAT_PROBE_DONE"
  fi
  exit 0
fi

if [ "$MODE" = "support-bundle" ]; then
  out="/storage/emulated/0/Download/ASVD-support-report-$(/system/bin/date +%Y%m%d-%H%M%S 2>/dev/null || date +%Y%m%d-%H%M%S).txt"
  {
    echo "# ASVD support bundle"
    echo "generated=$(/system/bin/date '+%Y-%m-%dT%H:%M:%S%z' 2>/dev/null || date)"
    echo
    echo "## full verify"
    /system/bin/sh "$0" || true
    echo
    echo "## xda report"
    /system/bin/sh "$0" --xda || true
    echo
    echo "## compatibility probe"
    /system/bin/sh "$0" --compat || true
    echo
    echo "## config lint"
    /system/bin/sh "$0" --lint-config || true
    echo
    echo "## companion state"
    if [ -r "$BT_HELPER_STATE" ]; then
      /system/bin/sed -E 's/([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}/<BT_MAC>/g' "$BT_HELPER_STATE" 2>/dev/null || true
    else
      echo "bt_helper_state_file=absent"
    fi
  } > "$out" 2>&1
  /system/bin/chmod 0644 "$out" 2>/dev/null || true
  echo "support_bundle=$out"
  echo "RESULT: ASVD_SUPPORT_BUNDLE_DONE"
  exit 0
fi

if [ "$MODE" = "compact" ]; then
  echo "ASVD $version"
  echo "device=$model"
  echo "android=$android_release sdk=$android_sdk"
  echo "magisk=$magisk_v ($magisk_vc)"
  echo "bt_helper=$bt_helper_status version=$bt_helper_version state=$bt_helper_state_file stale=$bt_helper_state_stale"
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

if [ "$MODE" = "xda-short" ]; then
  echo "[CODE]"
  echo "Module: $module_name $version ($version_code)"
  echo "Device: $manufacturer $model ($device)"
  echo "Android: $android_release / SDK $android_sdk"
  echo "Magisk: $magisk_v ($magisk_vc)"
  echo "Companion: ASVD BT Type Helper $bt_helper_status version=$bt_helper_version state=$bt_helper_state_file"
  echo "Config: $config_file"
  if values_status; then echo "Values: PASS"; else echo "Values: FAIL"; fi
  echo "Service log: $service_log"
  if [ "$ok" -eq 0 ]; then
    echo "RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS"
  else
    echo "RESULT: AUDIO_SAFE_VOLUME_VERIFY_FAIL"
  fi
  echo "[/CODE]"
  [ "$ok" -eq 0 ] && exit 0 || exit 1
fi

if [ "$MODE" = "json" ]; then
  if values_status; then values_result="PASS"; else values_result="FAIL"; fi
  if [ "$ok" -eq 0 ]; then result="AUDIO_SAFE_VOLUME_VERIFY_PASS"; else result="AUDIO_SAFE_VOLUME_VERIFY_FAIL"; fi
  cat <<EOF
{
  "module_id": "$(json_escape "$module_id")",
  "module_name": "$(json_escape "$module_name")",
  "version": "$(json_escape "$version")",
  "versionCode": "$(json_escape "$version_code")",
  "manufacturer": "$(json_escape "$manufacturer")",
  "device": "$(json_escape "$device")",
  "model": "$(json_escape "$model")",
  "android_release": "$(json_escape "$android_release")",
  "android_sdk": "$(json_escape "$android_sdk")",
  "magisk_version": "$(json_escape "$magisk_v")",
  "magisk_versionCode": "$(json_escape "$magisk_vc")",
  "config_file": "$(json_escape "$config_file")",
  "values": "$(json_escape "$values_result")",
  "service_log": "$(json_escape "$service_log")",
  "bt_helper_status": "$(json_escape "$bt_helper_status")",
  "bt_helper_package": "$(json_escape "$BT_HELPER_PKG")",
  "bt_helper_version": "$(json_escape "$bt_helper_version")",
  "bt_helper_versionCode": "$(json_escape "$bt_helper_version_code")",
  "bt_helper_state_file": "$(json_escape "$bt_helper_state_file")",
  "bt_helper_target_name": "$(json_escape "$bt_helper_target_name")",
  "bt_helper_requested_type": "$(json_escape "$bt_helper_requested_type")",
  "bt_helper_last_result": "$(json_escape "$bt_helper_last_result")",
  "bt_helper_last_run": "$(json_escape "$bt_helper_last_run")",
  "bt_helper_state_age_seconds": "$(json_escape "$bt_helper_state_age_seconds")",
  "bt_helper_state_stale": "$(json_escape "$bt_helper_state_stale")",
  "root_stack": "$(json_escape "$root_stack_value")",
  "compat_result": "$(json_escape "$compat_probe_result")",
  "result": "$(json_escape "$result")"
}
EOF
  [ "$ok" -eq 0 ] && exit 0 || exit 1
fi

if [ "$MODE" = "xda" ]; then
  echo "[CODE]"
  echo "Module: $module_name $version ($version_code)"
  echo "Module ID: $module_id"
  echo "Thread: $XDA_THREAD"
  echo "Device: $manufacturer $model ($device)"
  echo "Android: $android_release / SDK $android_sdk"
  echo "Magisk: $magisk_v ($magisk_vc)"
  echo "Boot completed: $boot_completed"
  echo "Battery: level=$battery_level status=$battery_status low_power=$low_power"
  echo "Config: $config_file ($CONF)"
  echo "Companion:"
  echo "  ASVD BT Type Helper: $bt_helper_status"
  echo "  Package: $BT_HELPER_PKG"
  echo "  Package version: $bt_helper_version ($bt_helper_version_code)"
  echo "  State file: $bt_helper_state_file ($BT_HELPER_STATE)"
  echo "  State target: $bt_helper_target_name"
  echo "  Requested type: $bt_helper_requested_type"
  echo "  Last result: $bt_helper_last_result"
  echo "  Last run: $bt_helper_last_run"
  echo "  State age seconds: $bt_helper_state_age_seconds"
  echo "  State stale: $bt_helper_state_stale"
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
printf 'magisk_bin = %s
' "$magisk_bin"
printf 'boot_completed = %s
' "$boot_completed"
printf 'battery_level = %s
' "$battery_level"
printf 'battery_status = %s
' "$battery_status"
printf 'low_power = %s
' "$low_power"

echo
echo "== companion =="
printf 'bt_helper_status = %s
' "$bt_helper_status"
printf 'bt_helper_package = %s
' "$BT_HELPER_PKG"
printf 'bt_helper_version = %s
' "$bt_helper_version"
printf 'bt_helper_versionCode = %s
' "$bt_helper_version_code"
printf 'bt_helper_state_file = %s
' "$bt_helper_state_file"
printf 'bt_helper_state_path = %s
' "$BT_HELPER_STATE"
printf 'bt_helper_state_package = %s
' "$bt_helper_state_package"
printf 'bt_helper_state_version = %s
' "$bt_helper_state_version"
printf 'bt_helper_target_name = %s
' "$bt_helper_target_name"
printf 'bt_helper_requested_type = %s
' "$bt_helper_requested_type"
printf 'bt_helper_last_result = %s
' "$bt_helper_last_result"
printf 'bt_helper_last_run = %s
' "$bt_helper_last_run"
printf 'bt_helper_state_age_seconds = %s
' "$bt_helper_state_age_seconds"
printf 'bt_helper_state_stale = %s
' "$bt_helper_state_stale"
printf 'compat_result = %s
' "$compat_probe_result"

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
echo "== recommended commands =="
printf 'full_verify_command = %s
' "tsu /system/bin/sh $MODDIR/verify.sh"
printf 'xda_report_command = %s
' "tsu /system/bin/sh $MODDIR/verify.sh --xda"

echo
if [ "$ok" -eq 0 ]; then
  echo "RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS"
  exit 0
fi

echo "RESULT: AUDIO_SAFE_VOLUME_VERIFY_FAIL"
exit 1
