# Changelog

## v1.2.3

- Simplify public support flow: full verify and XDA full report are now the recommended commands.
- Keep compact, XDA-short, and JSON verify modes as advanced/debug modes.
- Add XDA thread link to full XDA report output.
- Simplify README, SUPPORT.md, and GitHub issue template around the XDA full report.
- Runtime audio behavior unchanged from v1.2.2.

## v1.2.3

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
