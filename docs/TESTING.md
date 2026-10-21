# Testing the ARMSX2 package

## Test order

| Step | Check | What it proves |
|---|---|---|
| 1 | Driver appears in **Settings → GPU driver** | Zip layout and `meta.json` are valid |
| 2 | Driver can be selected | ARMSX2 accepts the package |
| 3 | Vulkan renderer initializes | Device creation and required features pass the emulator's checks |
| 4 | Game reaches the menu | Swapchain, shaders and basic draws work |
| 5 | Gameplay for 5+ minutes | Stability and memory |

Step 3 is the hard gate on Mali. If the renderer refuses the driver, capture the exact error from
the emulator log and logcat.

## Settings for the first run

- Renderer: **Vulkan**
- GPU driver: **PanVK Exynos 9611**
- Resolution: native (no upscaling)
- Frame generation / interpolation: off
- Widescreen patches: off
- Texture replacement / custom textures: off
- EE/IOP and VU settings: default
- BIOS: the dump you normally use (do not publish it)

## What to record

- Package version and SHA-256;
- ARMSX2 version (`dumpsys package com.armsx2.nightly | grep versionName`);
- game and scene;
- renderer, resolution, upscaler, frame limit, any speed hacks;
- result: driver listed / selected / renderer initialized / menu / gameplay;
- FPS range;
- visible corruption;
- logs.

## Commands

```sh
adb shell "dumpsys package com.armsx2.nightly | grep -E 'versionName|versionCode'"
adb logcat -c
# ... run the test ...
adb logcat -d -s 'panvk:*' 'Mesa:*' 'AndroidRuntime:E' > logcat.txt
adb shell 'dmesg | grep -iE "mali|kbase|gpu|fault|mmu"' > dmesg.txt
./scripts/collect-logs.sh
```

Some ARMSX2 builds write an emulator log to its app data. If the on-screen log overlay has a
"share/save" button, use it; it contains the renderer feature report.

## Promotion rule

A build is promoted in [`TEST-RESULTS.md`](TEST-RESULTS.md) only when:

1. the driver is listed and selectable;
2. the Vulkan renderer initializes;
3. a named game reaches gameplay and renders correctly;
4. logs are attached to the release notes.

A driver that only imports is "package valid", not "working".

## Reporting

Copy [`REPORT-TEMPLATE.md`](REPORT-TEMPLATE.md). Do not attach BIOS files, game ISOs or save states.
