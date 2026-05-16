# Changelog

## v1.2.7

- Add read-only compatibility probe via `verify.sh --compat`.
- Add copy-ready XDA/GitHub compatibility report via `verify.sh --compat-xda`.
- Add sanitized support bundle generation via `verify.sh --support-bundle`.
- Add config lint mode via `verify.sh --lint-config`.
- Add companion shared-state age/stale reporting for `/data/adb/asvd/bt-helper.env`.
- Add ASVD helper shared state from `apply-now.sh` and `active-guard-once.sh` under `/data/adb/asvd/asvd.env`.
- Improve documentation and issue template for non-Pixel compatibility reports.
- Runtime audio behavior unchanged from v1.2.6.

## v1.2.6

- Add optional ASVD BT Type Helper companion detection in full verify, XDA report, compact mode and JSON mode.
- Report companion package `org.asvd.bttypehelper`, package version, optional shared state file and last helper result when available.
- Document shared optional state path `/data/adb/asvd/bt-helper.env` for loose ASVD ↔ BT Helper integration.
- Keep ASVD and BT Helper separated: no hard dependency, no boot automation, no GMS-disable/offline-ui mode and no direct `bt_config.conf` patching.
- Keep ASVD runtime audio behavior unchanged from v1.2.5.

## v1.2.5

- Add docs/support warning about Google Play Billing account-context side effects observed during experimental GMS-disable/offline-ui helper tests.
- Explicitly mark the GMS-disable/offline-ui Bluetooth type helper path as rejected and not shipped.
- Document failed H222 UI-unlock attempts: soft mode, hard mode, and offline-ui + Bluetooth reload.
- Clarify future BT Device Type Helper direction: optional Bluetooth metadata/API research only.
- Reaffirm no direct `/data/misc/bluedroid/bt_config.conf` patching and no boot automation for BT type changes.
- Fix Magisk install text quoting in `customize.sh`.
- Keep ASVD runtime audio behavior unchanged from v1.2.4.


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
