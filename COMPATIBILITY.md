# Compatibility

| Device / ROM | Android | Root stack | Status | Notes |
|---|---:|---|---|---|
| Pixel 10 Pro XL | 16 / SDK 36 | Magisk | PASS | Original verified baseline |
| Other Pixel models | 16 | Magisk | unverified | Needs `verify.sh --xda-short` report |
| Samsung / OneUI | 16 | Magisk | unverified | OEM Sound Dose behavior may differ |
| Xiaomi / HyperOS | 16 | Magisk | unverified | OEM Sound Dose behavior may differ |
| LineageOS / custom ROMs | 14+ | Magisk | unverified | Needs report |
| KernelSU / APatch | 14+ | KernelSU/APatch | unverified | Not supported as baseline yet |

A report counts as verified only when the verify script ends with:

```text
RESULT: AUDIO_SAFE_VOLUME_VERIFY_PASS
```
