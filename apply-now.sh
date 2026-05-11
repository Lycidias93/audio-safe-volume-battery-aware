#!/system/bin/sh
# Audio Safe Volume Disabler manual apply-now helper.
# Applies target safe-volume / Sound Dose values immediately, then verifies.
set -eu

umask 022
MODDIR="${0%/*}"
MODULE_PROP="$MODDIR/module.prop"
CONF="/data/adb/audio-safe-volume-battery-aware.conf"
LOG="$MODDIR/apply-now.log"

read_module_prop() {
  key="$1"
  [ -r "$MODULE_PROP" ] || return 0
  /system/bin/grep -m 1 "^$key=" "$MODULE_PROP" 2>/dev/null | /system/bin/sed "s/^$key=//" 2>/dev/null || true
}

MODID="$(read_module_prop id)"
MODNAME="$(read_module_prop name)"
VERSION="$(read_module_prop version)"
VERSION_CODE="$(read_module_prop versionCode)"
[ -n "$MODID" ] || MODID="audio-safe-volume-battery-aware"
[ -n "$MODNAME" ] || MODNAME="Audio Safe Volume Disabler"
[ -n "$VERSION" ] || VERSION="unknown"
[ -n "$VERSION_CODE" ] || VERSION_CODE="unknown"

TARGET_SAFE_MEDIA_VOLUME_ENABLED="0"
TARGET_AUDIO_SAFE_VOLUME_STATE="1"
TARGET_AUDIO_SAFE_CSD_NEXT_WARNING="999999.0"
TARGET_AUDIO_SAFE_CSD_CURRENT_VALUE="0.0"
DELETE_AUDIO_SAFE_CSD_DOSE_RECORDS="1"
APPLY_NOW_PASSES="2"
APPLY_NOW_SLEEP_SECONDS="2"
LOG_MAX_BYTES="65536"
LOG_ROTATE_KEEP_BYTES="32768"

# shellcheck disable=SC1090
[ -r "$CONF" ] && . "$CONF"

now() {
  /system/bin/date '+%Y-%m-%dT%H:%M:%S%z' 2>/dev/null || /system/bin/date 2>/dev/null || echo unknown-time
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
  fi
}

log() {
  rotate_log
  echo "$(now) $*" >> "$LOG" 2>/dev/null || true
  [ -f "$LOG" ] && /system/bin/chmod 0644 "$LOG" 2>/dev/null || true
}

settings_get() {
  /system/bin/settings get global "$1" 2>/dev/null || echo "__ERROR__"
}

apply_once() {
  phase="$1"
  /system/bin/settings put global safe_media_volume_enabled "$TARGET_SAFE_MEDIA_VOLUME_ENABLED"
  /system/bin/settings put global audio_safe_volume_state "$TARGET_AUDIO_SAFE_VOLUME_STATE"
  /system/bin/settings put global audio_safe_csd_next_warning "$TARGET_AUDIO_SAFE_CSD_NEXT_WARNING"
  /system/bin/settings put global audio_safe_csd_current_value "$TARGET_AUDIO_SAFE_CSD_CURRENT_VALUE"
  if [ "$DELETE_AUDIO_SAFE_CSD_DOSE_RECORDS" = "1" ]; then
    /system/bin/settings delete global audio_safe_csd_dose_records >/dev/null 2>&1 || true
  fi
  log "APPLY_NOW phase=$phase safe_media_volume_enabled=$(settings_get safe_media_volume_enabled) audio_safe_volume_state=$(settings_get audio_safe_volume_state) audio_safe_csd_next_warning=$(settings_get audio_safe_csd_next_warning) audio_safe_csd_current_value=$(settings_get audio_safe_csd_current_value) dose_records=$(settings_get audio_safe_csd_dose_records)"
}

passes="$(normalize_number "${1:-$APPLY_NOW_PASSES}")"
sleep_s="$(normalize_number "${2:-$APPLY_NOW_SLEEP_SECONDS}")"
[ "$passes" -gt 0 ] || passes=2
[ "$passes" -le 10 ] || passes=10
[ "$sleep_s" -le 30 ] || sleep_s=30

log "START apply-now module=$MODID name=$MODNAME version=$VERSION versionCode=$VERSION_CODE passes=$passes sleep_seconds=$sleep_s"

echo "== ASVD apply-now =="
echo "module=$MODID"
echo "name=$MODNAME"
echo "version=$VERSION"
echo "versionCode=$VERSION_CODE"
echo "passes=$passes sleep_seconds=$sleep_s"

i=1
while [ "$i" -le "$passes" ]; do
  echo
  echo "== apply pass $i/$passes =="
  apply_once "pass_$i"
  printf "audio_safe_csd_next_warning = "; settings_get audio_safe_csd_next_warning
  printf "safe_media_volume_enabled   = "; settings_get safe_media_volume_enabled
  printf "audio_safe_volume_state     = "; settings_get audio_safe_volume_state
  printf "audio_safe_csd_current_value = "; settings_get audio_safe_csd_current_value
  printf "audio_safe_csd_dose_records = "; settings_get audio_safe_csd_dose_records || true
  if [ "$i" -lt "$passes" ]; then
    /system/bin/sleep "$sleep_s"
  fi
  i=$((i + 1))
done

echo
if [ -x "$MODDIR/verify.sh" ]; then
  /system/bin/sh "$MODDIR/verify.sh" | /system/bin/tail -n 60
else
  echo "WARN verify_missing=$MODDIR/verify.sh"
fi

log "DONE apply-now module=$MODID name=$MODNAME version=$VERSION versionCode=$VERSION_CODE"
echo
echo "RESULT: ASVD_APPLY_NOW_DONE"
