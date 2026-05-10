# Changelog

## v1.1.0

- Add built-in `verify.sh` with `RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS/FAIL` marker.
- Add optional Magisk `action.sh` wrapper for verification.
- Add bounded log rotation with `.1` backup.
- Add state snapshots under `state/before.env`, `state/after_primary.env`, `state/after_delayed.env`, and `state/after_final.env` when needed.
- Use `MODDIR=${0%/*}` consistently.
- Add environment logging for Android SDK, release, manufacturer, device, and model.
- Add structured failure markers:
  - `FAIL settings_provider_timeout`
  - `FAIL settings_put_denied`
  - `FAIL settings_delete_denied`
  - `FAIL unexpected_state_after_apply`
  - `FAIL unexpected_state_after_final`
  - `WARN unsupported_android_sdk`
  - `WARN drift_after_delayed`
- Add optional final reapply only if drift is detected after delayed verification.
- Keep one-shot battery-aware behavior; no permanent daemon, no wakelock, no network.
- Expand README with safety warning, compatibility matrix, verification, rollback, and issue template.

## v1.0.0

- Initial Pixel Android 16 verified Magisk module.
- Boot wait, settings-provider wait, primary apply, delayed reapply.
- Replaced legacy `/data/adb/service.d/99-audio-safe-volume.sh` boot-fix with module-managed service.
