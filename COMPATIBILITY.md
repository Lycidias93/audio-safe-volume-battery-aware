# Compatibility

A device counts as verified only when `verify.sh --xda` ends with:

```text
RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS
```

| Device | Android | ROM / OEM skin | Root stack | ASVD version | Result | Reporter / notes |
|---|---:|---|---|---|---|---|
| Pixel 10 Pro XL | 16 / SDK 36 | Stock Pixel | Magisk | v1.2.x | PASS | Baseline |
| Other Pixel models | 16 | Stock Pixel | Magisk | unverified | unverified | Needs report |
| Samsung | 16 | OneUI | Magisk | unverified | unverified | OEM Sound Dose behavior may differ |
| Xiaomi | 16 | HyperOS | Magisk | unverified | unverified | OEM Sound Dose behavior may differ |
| LineageOS / custom ROMs | 14+ | custom | Magisk | unverified | unverified | Needs report |
| KernelSU / APatch | 14+ | any | KernelSU/APatch | unverified | unverified | Not a baseline yet |

Recommended report command:

```sh
tsu /system/bin/sh /data/adb/modules/audio-safe-volume-battery-aware/verify.sh --xda
```
