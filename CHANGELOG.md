# Changelog

## v1.2.1

- Privacy metadata cleanup: public project metadata now uses `Lycidias93` only.
- Removed old public releases/tags before publishing this release.
- Kept internal Magisk module ID unchanged for update compatibility.
- Runtime behavior unchanged from v1.2.0.

## v1.2.0

- Add `verify.sh --compact` for short support checks.
- Add `verify.sh --xda` for copy-ready XDA report blocks.
- Add Magisk version and versionCode to verify output when available.
- Add config status and effective config values to verify output.
- Make Magisk Action button run compact read-only verify output.
- Add `SUPPORT.md`, `COMPATIBILITY.md`, and GitHub issue template.
- Keep runtime behavior unchanged from v1.1.2.

## v1.1.2

- Rename visible project/module name to **Audio Safe Volume Disabler**.
- Keep Magisk module ID `audio-safe-volume-battery-aware` unchanged for update compatibility.
- Keep GitHub repo slug and updateJson path unchanged.
- Update release asset naming to the shorter `ASVD-v1.1.2.zip`.
- Keep runtime behavior unchanged from v1.1.1.

## v1.1.1

- Add `updateJson` to `module.prop` for Magisk in-app update metadata.
- Add repository `update.json` pointing to the GitHub release asset.
- Fix release publishing hygiene so SHA256 files use local relative filenames instead of sandbox paths.
- Keep runtime behavior unchanged from v1.1.0: one-shot late_start service, bounded delayed reapply, no resident daemon.

## v1.1.0

- Add built-in `verify.sh` with `RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS/FAIL` marker.
- Add optional Magisk `action.sh` wrapper for verification.
- Add bounded log rotation with `.1` backup.
- Add state snapshots under `state/before.env`, `state/after_primary.env`, `state/after_delayed.env`, and `state/after_final.env` when needed.
- Use `MODDIR=${0%/*}` consistently.
- Add environment logging for Android SDK, release, manufacturer, device, and model.
- Add structured failure markers.
- Add optional final reapply only if drift is detected after delayed verification.
- Keep one-shot battery-aware behavior; no permanent daemon, no wakelock, no network.
- Expand README with safety warning, compatibility matrix, verification, rollback, and issue template.

## v1.0.0

- Initial Pixel Android 16 verified Magisk module.
- Boot wait, settings-provider wait, primary apply, delayed reapply.
- Replaced legacy `/data/adb/service.d/99-audio-safe-volume.sh` boot-fix with module-managed service.
