# ARMSX2 test results

## Environment

| | |
|---|---|
| Device | Samsung Galaxy A51 4G (SM-A515F) |
| SoC / GPU | Exynos 9611 / Mali-G72 MP3 r0p1 (`0x6221`) |
| Android / kernel | 16 (API 36) / 4.14.364-openela |
| Kbase | DDK r38p1-01bet0 |
| ARMSX2 | 2.8.4-nightly.20261020 (`com.armsx2.nightly`, `c66d053fe5`) |
| RAM | 6 GB |
| Driver | v0.01 binary (`ba9368cd…948bf`), packaged here as v0.02 |

## Results

| Package | Date | Driver listed | Driver selectable | Vulkan renderer | Game boot | Gameplay | Notes |
|---|---|---|---|---|---|---|---|
| v0.02 (driver v0.01) | 2026-10-21 | yes | yes | yes | yes | yes | Kingdom Hearts (USA), native and 2x, no visible corruption |

## Run 1 — native resolution, uncapped

| | |
|---|---|
| Game | Kingdom Hearts (USA), `SLUS-20370`, CRC `0F6B6315` |
| Renderer | Vulkan |
| GPU driver | PanVK Exynos 9611 (Mali-G72 MP3), active |
| Internal resolution | Native (OSD `512x447 NTSC Interlaced`) |
| Frame limit | Unlocked (`T: Max`) |
| Scene | Destiny Islands, beach/shack view |

Observed on the ARMSX2 OSD while rotating the camera with L2/R2:

- `33.0 FPS / 113%` facing the shack and rocks.
- `43.7 FPS / 146%` facing the ocean.
- `45.0 FPS / 152%` facing the waterfall and trees.
- EE 88–100%, GS 46–84%, VU 16–45%.
- GPU timing stayed at `0.0% / 0.00 ms`; PanVK does not report ARMSX2's GPU timing query on this
  driver, so the OSD cannot show GPU utilization.

The 30-second `PerfLog` samples after loading the save state were:

```text
PerfLog: 64.7 fps | EE 100% GS 67% VU 38% GPU 0% | frame 10543
PerfLog: 74.1 fps | EE 100% GS 71% VU 38% GPU 0% | frame 12769
PerfLog: 75.7 fps | EE 100% GS 67% VU 38% GPU 0% | frame 15047
PerfLog: 88.0 fps | EE 100% GS 85% VU 39% GPU 0% | frame 36063
```

## Run 2 — 2x upscale, 30 FPS cap

| | |
|---|---|
| Game | Same save state and scene |
| Internal resolution | 2x (OSD `1024x894 NTSC Interlaced`) |
| Frame limit | 30 FPS (`T: 100%`) |
| GS multi-threading | Off |

Observed after loading the same state:

- `29.97 FPS / 98–100% speed`, i.e. the emulator held its 30 FPS target at 2x.
- EE 79–89%, GS 62–70%, VU 28–32%.
- Textures, shadows, HUD, and character models rendered correctly at 2x; no missing geometry,
  colour corruption, or driver reset was observed.
- The run was stopped manually; it did not crash.

## Driver identification

The relevant ARMSX2 log lines were:

```text
VK: GPU profile override='auto' resolved='Mali' driver='Mesa PanVK' version=26.2.99
VK: Mali-G72 MC3 is a Mali GPU not running malisx2
    (driverName "panvk", driverInfo "Mesa 26.3.0-devel (git-fb3b49d016)")
VK: GPU 'Mali-G72 MC3' vendor=0x13B5 driver='panvk'
    (Mesa 26.3.0-devel (git-fb3b49d016))
```

## Import path

The package was imported entirely through the ARMSX2 UI:

1. **Settings → Renderer → Graphics API → Vulkan**.
2. **GPU Driver → Import**, then selected `panvk-exynos9611-armsx2-v0.01.zip` from Download.
3. ARMSX2 listed **PanVK Exynos 9611 (Mali-G72 MP3)** with `Mesa 26.3.0-devel / PanVK kbase JM`
   and marked it **Active**.
4. The game was started with the Vulkan renderer; no root copy or environment variables were used.

This confirms that ARMSX2's AdrenoTools-style importer accepts the package layout
(`meta.json` + `libvulkan_freedreno.so` at the zip root) and that the Mali ICD is selectable on a
non-Adreno device.

## Known issues / caveats

- **GPU timing is unavailable.** ARMSX2 shows `GPU 0.0% / 0.00 ms` with PanVK; use FPS and
  speed as the performance signal.
- **2x was tested with the 30 FPS limit.** The native run was uncapped, but restarting the app
  reset the frame limit to 30 FPS before the 2x run. A 2x uncapped run still needs to be recorded.
- **Only one game and one scene were tested.** Kingdom Hearts is not a worst-case PS2 title.
  Results from other games, especially ones with heavy alpha, shadows, or EE/GS load, are needed.
- **The driver is still experimental.** Keep the system Vulkan driver installed as the fallback.

## Known-good control

**System Vulkan driver** is the control. If the game fails with both the vendor driver and PanVK,
the problem is not this package. If it works with the vendor driver and fails with PanVK, the
emulator/driver log is the useful artifact.
