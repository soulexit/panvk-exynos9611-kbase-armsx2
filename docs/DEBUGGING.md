# Debugging the ARMSX2 package

## Driver is not listed after import

- Confirm the zip root: `unzip -l panvk-exynos9611-armsx2-v0.02.zip` must show `meta.json` and
  `libvulkan_freedreno.so` with no leading directory.
- `meta.json` must be valid JSON and `libraryName` must be `libvulkan_freedreno.so`.
- Re-download the zip; a truncated archive can fail silently.
- Force-stop ARMSX2 and reopen Settings → GPU driver.

## Driver is listed but cannot be selected

ARMSX2's custom-driver manager is Adreno-oriented. It may check the GPU vendor or a driver
identifier before offering the entry. Capture:

```sh
adb logcat -d | grep -iE 'armsx2|adrenotools|vulkan|driver' | tail -300
```

A line naming the rejected driver/reason is more useful than a screenshot.

## Vulkan renderer fails to initialize

This is the expected hard gate. Look for:

- `panvk`/`Mesa`: `Unknown gpu_id`, `VK_ERROR_INCOMPATIBLE_DRIVER`, missing extension;
- ARMSX2: a message naming the required `VkPhysicalDeviceFeatures` or extension;
- kbase: `JOB_CONFIG_FAULT`, `EINVAL`, `fault`.

The emulator may require features that Bifrost/PanVK does not expose. Record the exact name; it
becomes the next patch target.

## Game crashes or the GPU hangs

```sh
adb shell 'dmesg | grep -iE "mali|kbase|fault|mmu|job"' | tail -100
```

- Atom stride / `JOB_CONFIG_FAULT`: a driver/kbase ABI mismatch. The base driver uses a 64-byte
  `base_jd_atom`; this needs a source patch, not an app setting.
- `VK_ERROR_DEVICE_LOST`: GPU fault. Force-stop ARMSX2; reboot if kbase is wedged.
- Memory: PS2 emulation + PanVK on 6 GB can hit the limit. Close background apps, disable upscaling.

## Black screen, emulator alive

- Check whether the emulator log says frames are being rendered.
- Try native resolution and a different game.
- Disable frame generation/upscaling; those paths add their own Vulkan work.
- This may be the Android 16 gralloc/swapchain path rather than the 3D pipeline.

## Environment switches

ARMSX2 may not pass environment variables to the ICD. If it has a debug/environment field, these
are useful:

| Variable | Effect |
|---|---|
| `PANVK_DEBUG=startup` | Device-creation diagnostics |
| `PANVK_DEBUG=trace` | Verbose tracing |
| `PANVK_FORCE_IDVS=1` | Re-enable index-driven vertex shading |
| `MESA_LOG=stderr` | Mesa logs to stderr |

Otherwise rely on logcat; Mesa logs to logcat on Android by default.

## Collect a report

```sh
./scripts/collect-logs.sh
```

Attach the tarball, the driver SHA-256, the emulator settings and the exact game/scene. Do not
attach BIOS files, ISOs or save states.
