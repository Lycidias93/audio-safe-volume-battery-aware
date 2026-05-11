# Changelog

## v1.2.4

- Add `apply-now.sh` for manual immediate reapply + verify.
- Add `active-guard-once.sh` for bounded active Bluetooth sessions where Sound Dose values drift during playback.
- Change Magisk Action button to run `apply-now.sh`.
- Document H222 / Skoda BT2MP3 receiver behavior: classified as headphones, transient warning can appear, volume was not reduced, CSD values can repopulate during active playback.
- Document verified active Bluetooth playback recovery with bounded active guard.
- Clarify that ASVD does not currently modify Bluetooth device classification.
- Keep boot runtime behavior unchanged from v1.2.3.

## v1.2.3

- Simplify public support flow: full verify and XDA full report are now the recommended commands.
- Keep compact, XDA-short, and JSON verify modes as advanced/debug modes.
- Add XDA thread link to full XDA report output.
- Simplify README, SUPPORT.md, and GitHub issue template around the XDA full report.
- Runtime audio behavior unchanged from v1.2.2.

## v1.2.2

- Read module name, ID, version and versionCode dynamically from `module.prop` in `service.sh`.
- Fix service log version drift after metadata-only releases.
- Improve Magisk version detection from Termux/root contexts.
- Harden state/log permissions to avoid world-writable snapshots.
- Add `verify.sh --xda-short` for compact XDA compatibility reports.
- Add `verify.sh --json` for machine-readable diagnostics.
- Keep runtime audio behavior unchanged from v1.2.1.

## v1.2.1

- Privacy metadata cleanup.
- Public project metadata now uses `Lycidias93` only.
- Removed old public releases/tags before publishing this release.
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

- Add Magisk `updateJson` support.
- Add `update.json`.
- Fix release publishing workflow so SHA256 files use local relative filenames instead of sandbox paths.
- Runtime behavior unchanged from v1.1.0.

## v1.1.0

- Add built-in `verify.sh`.
- Add log rotation.
- Add state snapshots.
- Add structured service logs.
- Add final delayed reapply only if drift is detected.
- Add Magisk Action button support.
- Battery-aware one-shot behavior retained.
- Runtime behavior based on the verified Pixel Android 16 boot-fix logic.

## v1.0.0

- Initial Magisk module release.
- Add boot-time safe-volume / Sound Dose target reapply.
- Add primary apply after boot completion.
- Add bounded delayed reapply.
- Add battery-aware behavior.
- No resident daemon, no network, no wakelock.
- Replaced earlier manual `service.d` boot-fix approach.
