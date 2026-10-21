# Install in ARMSX2

Tested with **ARMSX2 `com.armsx2.nightly` 2.8.4-nightly.20261020** on Android 16.

## 1. Install ARMSX2

Use a current nightly from <https://github.com/ARMSX2/ARMSX2/releases> (the Android arm64 APK).
The stable package, if installed, uses `com.armsx2`; the scripts detect either.

## 2. Download the driver

Take `panvk-exynos9611-armsx2-v0.02.zip` from this repository's **Releases** page.

Do **not** use the Winlator package here: ARMSX2's importer requires the library to be named
`libvulkan_freedreno.so`, while Winlator expects `libvulkan_panfrost.so`. The two zips contain the
same driver under different names.

Verify:

```sh
sha256sum -c panvk-exynos9611-armsx2-v0.02.zip.sha256
```

## 3. Import

1. Open ARMSX2.
2. Open **Settings → Renderer**.
3. Set **Graphics API** to **Vulkan**. The **GPU Driver** section appears below it.
4. Open **GPU Driver → Import**.
5. Pick the zip from Downloads.
6. The driver should appear as **PanVK Exynos 9611 (Mali-G72 MP3)** with
   `Mesa 26.3.0-devel / PanVK kbase JM` and be marked **Active**.
7. Start a game with the Vulkan renderer.

On the tested nightly, the **GPU Driver** row is hidden while Graphics API is set to **Auto**.
Select **Vulkan** first, then import.

ARMSX2's import error messages usually say what is wrong:

| Message | Meaning |
|---|---|
| "needs to be an AdrenoToolsDrivers-style .zip with meta.json + libvulkan_freedreno.so" | The zip root is wrong, the file is missing, or the download is truncated |
| "unreachable" / network error | The app tried its online driver catalog; use the local zip import instead |
| Driver listed but greyed out | The emulator did not accept the driver for this GPU; check the log |

## 4. Select it for a game

1. Open the game's per-game settings.
2. Set **Renderer** to **Vulkan**.
3. Set **GPU driver** to **PanVK Exynos 9611**.
4. Disable upscaling and frame generation for the first run.
5. Use native resolution and a light game.

If the game crashes before the menu, switch back to **System Vulkan driver** and keep the log.

## 5. Revert

- Set **GPU driver** back to **System Vulkan driver**.
- Remove the imported entry from **Settings → GPU driver**.
- Direct/root install: remove the directory you passed to `install-adb.sh --dest`.

Nothing under `/vendor` or `/system` is modified.

## Install with adb

```sh
./scripts/install-adb.sh          # push the zip to /sdcard/Download
```

Then import it from the app. A root install is possible but not recommended because ARMSX2's
private driver directory changes between builds:

```sh
./scripts/install-adb.sh --root --dest /data/data/com.armsx2.nightly/files/<driver-dir> --yes
```

Find `<driver-dir>` only after importing a driver once (then inspect the app's data directory) or in
the app's documentation. The in-app importer is the supported path.

## Notes

- ARMSX2's custom-driver feature is built around **Adreno/Turnip**. A Mali ICD may be accepted by the
  importer but rejected later by the Vulkan renderer. That is a valid test result; attach the log.
- The emulator's **ANGLE** option is a different path (GLES-on-Vulkan with a bundled driver). It is
  not this driver. Test one path at a time.
- Keep the system Vulkan driver available; the vendor blob is the control.
