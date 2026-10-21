# ARMSX2 test results

## Environment

| | |
|---|---|
| Device | Samsung Galaxy A51 4G (SM-A515F) |
| SoC / GPU | Exynos 9611 / Mali-G72 MP3 r0p1 (`0x6221`) |
| Android / kernel | 16 (API 36) / 4.14.364-openela |
| Kbase | DDK r38p1-01bet0 |
| ARMSX2 | 2.8.4-nightly.20261020 (`com.armsx2.nightly`) |
| RAM | 6 GB |

## Results

| Package | Date | Driver listed | Selectable | Vulkan renderer | Menu | Gameplay | Notes |
|---|---|---|---|---|---|---|---|
| v0.01 | 2026-10-21 | pending | pending | pending | pending | pending | first package |

## Run details

Add one subsection per run:

```text
Date:
Package / SHA-256:
ARMSX2 version:
Game and scene:
Renderer / GPU driver:
Resolution / upscaler / frame limit:
Result:
FPS:
Corruption:
Logs:
```

## Known-good control

**System Vulkan driver** is the control. If the game fails with both the vendor driver and PanVK,
the problem is not this package. If it works with the vendor driver and fails with PanVK, the
emulator/driver log is the useful artifact.
