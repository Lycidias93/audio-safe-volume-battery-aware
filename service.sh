#!/system/bin/sh
# Audio Safe Volume Battery Aware Magisk service
# Runs once per boot in late_start service. No persistent daemon, no network, no wakelock.

MODDIR="${0%/*}"
MODID="audio-safe-volume-battery-aware"
VERSION="v1.1.0"
LOG="$MODDIR/service.log"
STATE_DIR="$MODDIR/state"
CONF="/data/adb/audio-safe-volume-battery-aware.conf"

# Defaults can be overridden in /data/adb/audio-safe-volume-battery-aware.conf
TARGET_SAFE_MEDIA_VOLUME_ENABLED="0"
TARGET_AUDIO_SAFE_VOLUME_STATE="1"
TARGET_AUDIO_SAFE_CSD_NEXT_WARNING="999999.0"
TARGET_AUDIO_SAFE_CSD_CURRENT_VALUE="0.0"
DELETE_AUDIO_SAFE_CSD_DOSE_RECORDS="1"
BOOT_WAIT_MAX_SECONDS="120"
SETTINGS_WAIT_MAX_SECONDS="60"
DELAYED_REAPPLY_SECONDS="45"
LOW_POWER_REAPPLY_SECONDS="15"
FINAL_REAPPLY_SECONDS="120"
LOW_BATTERY_THRESHOLD="15"
CRITICAL_BATTERY_THRESHOLD="5"
LOG_MAX_BYTES="65536"
LOG_ROTATE_KEEP_BYTES="32768"
MIN_WARN_ANDROID_SDK="31"

# shellcheck disable=SC1090
[ -r "$CONF" ] && . "$CONF"

mkdir_safe() {
  /system/bin/mkdir -p "$1" 2>/dev/null || true
}

now() {
  /system/bin/date '+%Y-%m-%dT%H:%M:%S%z' 2>/dev/null || /system/bin/date 2>/dev/null || echo unknown-time
}

log() {
  mkdir_safe "$MODDIR"
  echo "$(now) $*" >> "$LOG" 2>/dev/null || true
}

normalize_number() {
  v="$1"
  case "$v" in *[!0-9]*|'') echo 0 ;; *) echo "$v" ;; esac
}

rotate_log() {
  [ -f "$LOG" ] || return 0
  size="$(/system/bin/wc -c < "$LOG" 2>/dev/null || echo 0)"
  size="$(normalize_number "$size")"
  max="$(normalize_number "$LOG_MAX_BYTES")"
  keep="$(normalize_number "$LOG_ROTATE_KEEP_BYTES")"
  [ "$max" -gt 0 ] || max=65536
  [ "$keep" -gt 0 ] || keep=32768
  if [ "$size" -gt "$max" ]; then
    /system/bin/cp -af "$LOG" "$LOG.1" 2>/dev/null || true
    /system/bin/tail -c "$keep" "$LOG.1" > "$LOG.tmp" 2>/dev/null && /system/bin/mv "$LOG.tmp" "$LOG" 2>/dev/null || true
    log "LOG_ROTATED old_bytes=$size keep_bytes=$keep previous=$LOG.1"
  fi
}

settings_get() {
  /system/bin/settings get global "$1" 2>/dev/null || echo "__ERROR__"
}

prop_get() {
  /system/bin/getprop "$1" 2>/dev/null || true
}

snapshot_values() {
  phase="$1"
  mkdir_safe "$STATE_DIR"
  file="$STATE_DIR/${phase}.env"
  {
    echo "timestamp=$(now)"
    echo "phase=$phase"
    echo "android_sdk=$(prop_get ro.build.version.sdk)"
    echo "android_release=$(prop_get ro.build.version.release)"
    echo "device=$(prop_get ro.product.device)"
    echo "model=$(prop_get ro.product.model)"
    echo "manufacturer=$(prop_get ro.product.manufacturer)"
    echo "sys_boot_completed=$(prop_get sys.boot_completed)"
    echo "safe_media_volume_enabled=$(settings_get safe_media_volume_enabled)"
    echo "audio_safe_volume_state=$(settings_get audio_safe_volume_state)"
    echo "audio_safe_csd_next_warning=$(settings_get audio_safe_csd_next_warning)"
    echo "audio_safe_csd_current_value=$(settings_get audio_safe_csd_current_value)"
    echo "audio_safe_csd_dose_records=$(settings_get audio_safe_csd_dose_records)"
  } > "$file" 2>/dev/null || true
}

settings_put_if_needed() {
  key="$1"
  want="$2"
  phase="$3"
  cur="$(settings_get "$key")"
  if [ "$cur" = "$want" ]; then
    log "OK phase=$phase key=$key unchanged=$want"
    return 0
  fi
  if /system/bin/settings put global "$key" "$want" 2>/dev/null; then
    new="$(settings_get "$key")"
    if [ "$new" = "$want" ]; then
      log "SET phase=$phase key=$key old=$cur new=$want result=confirmed"
      return 0
    fi
    log "FAIL unexpected_state_after_apply phase=$phase key=$key old=$cur want=$want got=$new"
    return 1
  fi
  log "FAIL settings_put_denied phase=$phase key=$key old=$cur want=$want"
  return 1
}

settings_delete_if_present() {
  key="$1"
  phase="$2"
  cur="$(settings_get "$key")"
  if [ "$cur" = "null" ] || [ "$cur" = "__ERROR__" ]; then
    log "OK phase=$phase key=$key delete_not_needed current=$cur"
    return 0
  fi
  if /system/bin/settings delete global "$key" >/dev/null 2>&1; then
    new="$(settings_get "$key")"
    if [ "$new" = "null" ] || [ "$new" = "__ERROR__" ]; then
      log "DELETE phase=$phase key=$key old_present=yes result=confirmed"
      return 0
    fi
    log "FAIL unexpected_state_after_delete phase=$phase key=$key old=$cur got=$new"
    return 1
  fi
  log "FAIL settings_delete_denied phase=$phase key=$key old_present=yes"
  return 1
}

wait_for_boot_completed() {
  waited=0
  while [ "$waited" -lt "$BOOT_WAIT_MAX_SECONDS" ]; do
    [ "$(prop_get sys.boot_completed)" = "1" ] && return 0
    /system/bin/sleep 2
    waited=$((waited + 2))
  done
  return 1
}

wait_for_settings_provider() {
  waited=0
  while [ "$waited" -lt "$SETTINGS_WAIT_MAX_SECONDS" ]; do
    /system/bin/settings get global safe_media_volume_enabled >/dev/null 2>&1 && return 0
    /system/bin/sleep 2
    waited=$((waited + 2))
  done
  return 1
}

battery_level() {
  out="$(/system/bin/cmd battery get level 2>/dev/null || true)"
  echo "$out" | /system/bin/tr -cd '0-9'
}

battery_status() {
  out="$(/system/bin/cmd battery get status 2>/dev/null || true)"
  echo "$out" | /system/bin/tr -cd '0-9'
}

is_charging_or_full() {
  case "$1" in
    2|5) return 0 ;;
    *) return 1 ;;
  esac
}

low_power_state() {
  val="$(settings_get low_power)"
  [ "$val" = "1" ] && echo 1 || echo 0
}

choose_reapply_delay() {
  level="$1"
  status="$2"
  low_power="$3"
  delay="$DELAYED_REAPPLY_SECONDS"
  level="$(normalize_number "$level")"
  low="$(normalize_number "$LOW_BATTERY_THRESHOLD")"
  critical="$(normalize_number "$CRITICAL_BATTERY_THRESHOLD")"
  if [ "$low_power" = "1" ]; then
    delay="$LOW_POWER_REAPPLY_SECONDS"
  elif [ "$level" -le "$critical" ] && ! is_charging_or_full "$status"; then
    delay="$LOW_POWER_REAPPLY_SECONDS"
  elif [ "$level" -le "$low" ] && ! is_charging_or_full "$status"; then
    delay="$LOW_POWER_REAPPLY_SECONDS"
  fi
  echo "$(normalize_number "$delay")"
}

apply_profile() {
  phase="$1"
  ok=0
  settings_put_if_needed safe_media_volume_enabled "$TARGET_SAFE_MEDIA_VOLUME_ENABLED" "$phase" || ok=1
  settings_put_if_needed audio_safe_volume_state "$TARGET_AUDIO_SAFE_VOLUME_STATE" "$phase" || ok=1
  settings_put_if_needed audio_safe_csd_next_warning "$TARGET_AUDIO_SAFE_CSD_NEXT_WARNING" "$phase" || ok=1
  settings_put_if_needed audio_safe_csd_current_value "$TARGET_AUDIO_SAFE_CSD_CURRENT_VALUE" "$phase" || ok=1
  if [ "$DELETE_AUDIO_SAFE_CSD_DOSE_RECORDS" = "1" ]; then
    settings_delete_if_present audio_safe_csd_dose_records "$phase" || ok=1
  fi
  return "$ok"
}

profile_matches() {
  [ "$(settings_get safe_media_volume_enabled)" = "$TARGET_SAFE_MEDIA_VOLUME_ENABLED" ] || return 1
  [ "$(settings_get audio_safe_volume_state)" = "$TARGET_AUDIO_SAFE_VOLUME_STATE" ] || return 1
  [ "$(settings_get audio_safe_csd_next_warning)" = "$TARGET_AUDIO_SAFE_CSD_NEXT_WARNING" ] || return 1
  [ "$(settings_get audio_safe_csd_current_value)" = "$TARGET_AUDIO_SAFE_CSD_CURRENT_VALUE" ] || return 1
  if [ "$DELETE_AUDIO_SAFE_CSD_DOSE_RECORDS" = "1" ]; then
    dose="$(settings_get audio_safe_csd_dose_records)"
    [ "$dose" = "null" ] || [ "$dose" = "__ERROR__" ] || return 1
  fi
  return 0
}

warn_environment() {
  sdk="$(prop_get ro.build.version.sdk)"
  release="$(prop_get ro.build.version.release)"
  device="$(prop_get ro.product.device)"
  model="$(prop_get ro.product.model)"
  manufacturer="$(prop_get ro.product.manufacturer)"
  min_sdk="$(normalize_number "$MIN_WARN_ANDROID_SDK")"
  sdk_num="$(normalize_number "$sdk")"
  log "ENV android_sdk=$sdk android_release=$release manufacturer=$manufacturer device=$device model=$model"
  if [ "$sdk_num" -gt 0 ] && [ "$sdk_num" -lt "$min_sdk" ]; then
    log "WARN unsupported_android_sdk sdk=$sdk min_warn_sdk=$min_sdk action=continue"
  fi
}

main() {
  mkdir_safe "$STATE_DIR"
  rotate_log
  log "START module=$MODID version=$VERSION mode=one-shot battery-aware"
  warn_environment

  if wait_for_boot_completed; then
    log "BOOT_COMPLETED yes"
  else
    log "WARN boot_completed_timeout timeout_after=${BOOT_WAIT_MAX_SECONDS}s action=continue"
  fi

  if wait_for_settings_provider; then
    log "SETTINGS_PROVIDER ready"
  else
    log "FAIL settings_provider_timeout timeout_after=${SETTINGS_WAIT_MAX_SECONDS}s action=continue"
  fi

  snapshot_values "before"

  level="$(battery_level)"
  status="$(battery_status)"
  low_power="$(low_power_state)"
  [ -n "$level" ] || level="unknown"
  [ -n "$status" ] || status="unknown"
  log "BATTERY level=$level status=$status low_power=$low_power"

  apply_profile "primary" || true
  snapshot_values "after_primary"

  delay="$(choose_reapply_delay "$level" "$status" "$low_power")"
  log "REAPPLY delay_seconds=$delay reason=battery_aware_bounded_single_shot"
  if [ "$delay" -gt 0 ]; then
    /system/bin/sleep "$delay"
    apply_profile "delayed" || true
    snapshot_values "after_delayed"
  fi

  if profile_matches; then
    log "VERIFY phase=delayed result=pass"
  else
    final_delay="$(normalize_number "$FINAL_REAPPLY_SECONDS")"
    log "WARN drift_after_delayed final_reapply_seconds=$final_delay"
    if [ "$final_delay" -gt 0 ]; then
      /system/bin/sleep "$final_delay"
    fi
    apply_profile "final" || true
    snapshot_values "after_final"
    if profile_matches; then
      log "VERIFY phase=final result=pass"
    else
      log "FAIL unexpected_state_after_final result=fail"
    fi
  fi

  log "DONE module=$MODID version=$VERSION"
}

main
exit 0
