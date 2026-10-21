# PanVK for ARMSX2 — Exynos 9611 / Mali-G72 MP3

**Custom Vulkan driver packages for [ARMSX2](https://github.com/ARMSX2/ARMSX2)** on the
**Samsung Galaxy A51 (SM-A515F)** and other **Exynos 9611 + Mali-G72 MP3** phones.

The driver is Mesa **PanVK** talking to the stock **Arm `mali_kbase`** kernel interface
(`/dev/mali0`). No custom kernel, no `/dev/dri`, no root required.

| | |
|---|---|
| **Device** | Samsung Galaxy A51 4G (SM-A515F, `a51`) |
| **SoC / GPU** | Exynos 9611 / Mali-G72 MP3 r0p1 (`0x6221`, Mesa arch **v6**) |
| **Android** | 16 / API 36 |
| **Kernel / kbase** | Linux 4.14.364 / Arm DDK `r38p1-01bet0` |
| **ARMSX2 tested** | `com.armsx2.nightly` **2.8.4-nightly.20261020** |
| **Driver base** | [`JimVulkan/mali-panvk`](https://github.com/JimVulkan/mali-panvk) `fb3b49d`, Mesa 26.3.0-devel |
| **Current build** | **v0.01 — debug, expect crashes** |

> [!WARNING]
> Experimental driver. A bad GPU job can hang the emulator or the phone's GPU. Keep the system
> Vulkan driver selected as the fallback, and do not test with save states you cannot lose.

## What this repository contains

ARMSX2 imports custom drivers using the AdrenoTools layout, but it expects the library at the zip
root under the name **`libvulkan_freedreno.so`** (the Adreno/Turnip convention), together with
`meta.json`. This repository repackages the driver from the sister Termux repository into exactly
that layout:

```text
panvk-exynos9611-armsx2-v0.01.zip
├── meta.json
├── libvulkan_freedreno.so     # PanVK binary, renamed for ARMSX2's importer
├── NOTICE.txt
└── BUILD-INFO.txt
```

No source code is duplicated here. The driver is built and tested in
[`panvk-exynos9611-kbase-termux`](https://github.com/soulexit/panvk-exynos9611-kbase-termux).

## Goal

Give ARMSX2 a **working Vulkan renderer on Mali-G72** through kbase, so PS2 games can use the
Vulkan backend instead of the vendor GLES/Vulkan blob. Vulkan is required for several ARMSX2
features (GPU pipeline stats, some upscalers, frame generation) and is the path where PanVK's
DXVK-oriented feature work can be reused.

This is a harder target than Winlator:

- ARMSX2's custom-driver UI is designed around **Adreno/Turnip**; a Mali ICD may be listed but not
  selected, or selected but rejected by the emulator's feature checks.
- ARMSX2's Vulkan renderer expects features that go beyond DXVK D3D9; not all of them exist on
  Bifrost.
- The G72 is slow. The realistic target is **native-resolution PS2 games with the Vulkan renderer**,
  not upscaling.

A negative result is still useful: a clean log showing which feature check fails tells the next
build what to fix.

## Status

| Build | Date | ARMSX2 version | Driver listed | Driver selected | Game boot | In-game | Notes |
|---|---|---|---|---|---|---|---|
| v0.01 | 2026-10-21 | 2.8.4-nightly.20261020 | pending | pending | pending | pending | first package |

See [`docs/TEST-RESULTS.md`](docs/TEST-RESULTS.md).

## Requirements

### Phone

- Galaxy A51 / Exynos 9611 / Mali-G72 MP3 (other G72 devices may work; report them).
- Android 12+ (driver built for API 31; tested on API 36).
- arm64-v8a, 4 GB RAM minimum (6 GB recommended).
- `/dev/mali0` accessible to the app (`0666` on the A51).
- ARMSX2 installed. Nightly builds are at
  <https://github.com/ARMSX2/ARMSX2/releases>.

### Build host

Same as the sister repository: Linux x86_64 (or proot Ubuntu on the phone), Android NDK r29+,
Meson, Ninja, Python 3, glslang, LLVM 20. See
[`docs/BUILD.md`](https://github.com/soulexit/panvk-exynos9611-kbase-termux/blob/main/docs/BUILD.md).

## Install

### Option A — import in ARMSX2 (no root, recommended)

1. Download `panvk-exynos9611-armsx2-v0.01.zip` from **Releases**.
2. Copy it to the phone.
3. Open **ARMSX2 → Settings → GPU driver**.
4. Tap **Import** (or the add button) and choose the zip.
5. Select **PanVK Exynos 9611 (Mali-G72 MP3)**.
6. In the game settings, set the renderer to **Vulkan**, then start the game.
7. On first failure, switch back to **System Vulkan driver** and collect the logs.

The importer requires `meta.json` and `libvulkan_freedreno.so` at the **zip root**. If you get
"it needs to be an AdrenoToolsDrivers-style .zip", the archive layout is wrong or the download is
truncated.

### Option B — adb push, then import

```sh
./scripts/install-adb.sh
```

The zip is copied to `/sdcard/Download/`; import it from the app. No root needed.

### Option C — direct install (root, advanced)

```sh
./scripts/install-adb.sh --root --yes
```

Copies the unpacked driver into ARMSX2's private storage. The exact directory differs between
nightly and stable packages; the script detects the installed package and prints what it did.
Force-stop ARMSX2 afterwards. Prefer the in-app importer.

## Uninstall / revert

- Select **System Vulkan driver** in ARMSX2's GPU driver settings.
- Remove the imported driver from the same screen.
- Root install: remove the directory printed by the installer, then restart ARMSX2.

The vendor Vulkan driver is untouched.

## Build the package

### From the released driver

```sh
git clone https://github.com/soulexit/panvk-exynos9611-kbase-armsx2.git
cd panvk-exynos9611-kbase-armsx2
./scripts/fetch-prebuilt.sh
./scripts/package.sh
```

`fetch-prebuilt.sh` downloads the pinned Termux release and verifies its `SHA256SUMS`.

### From source

```sh
./scripts/build-from-source.sh /path/to/android-ndk
```

Clones the sister repository at the tag in `VERSION`, builds the driver, renames the library for
ARMSX2 and packages it.

### Package only

```sh
./scripts/package.sh --so /path/to/libvulkan_panfrost.so
```

Output: `dist/panvk-exynos9611-armsx2-v0.01.zip` and `.sha256`.

## Testing

1. Start with a light PS2 game at native resolution (no upscaling, no widescreen patches).
2. Use the **Vulkan** renderer.
3. If it boots, reach gameplay before recording a result.
4. Capture:
   - ARMSX2 version and settings (renderer, resolution, upscaler, frame limit);
   - `adb logcat -d -s panvk:* Mesa:* AndroidRuntime:E > logcat.txt`;
   - `adb shell dmesg | grep -iE 'mali|kbase|gpu|fault' > dmesg.txt`;
   - a screenshot of the emulator log overlay if it shows a Vulkan feature error.
5. Fill in [`docs/TEST-RESULTS.md`](docs/TEST-RESULTS.md).

```sh
./scripts/collect-logs.sh
```

## Known limitations

- **Mali-G72 v6 is the least-tested Bifrost path.** The base tree validated G72 on a Galaxy Tab S6
  Lite; the A51's Android 16 + kbase r38 is new.
- **ARMSX2 custom drivers are Adreno-oriented.** Listing/selecting a Mali ICD is not guaranteed by
  the app. Treat this repository as an experiment with a clear log trail.
- **No native BCn, no D3D12/vkd3d-proton.** PS2 texture formats are mostly handled by the emulator;
  BCn is not the blocker here.
- **GS/tessellation/XFB are compute-emulated** and slow on three G72 cores.
- **Shared RAM.** PS2 emulation plus a Vulkan driver on a 6 GB phone leaves little headroom.
- **Android 16 gralloc** can break presentation while offscreen rendering works.

## Debugging

| Switch | Effect |
|---|---|
| `PANVK_DEBUG=startup` | Device-creation diagnostics |
| `PANVK_DEBUG=trace` | Verbose tracing |
| `PANVK_FORCE_IDVS=1` | Re-enable index-driven vertex shading |

ARMSX2 may not expose environment variables to the driver. Use logcat first:

```sh
adb logcat -d -s 'panvk:*' 'Mesa:*' 'AndroidRuntime:E'
adb shell 'dmesg | grep -iE "mali|kbase|gpu|fault|mmu"'
```

See [`docs/DEBUGGING.md`](docs/DEBUGGING.md) for the app-specific checks and the generic kbase
failure classes.

## Versioning and releases

`v0.01`, `v0.02`, … follow the source driver. Each release contains:

- `panvk-exynos9611-armsx2-v0.0x.zip`
- `.sha256`
- `BUILD-INFO.txt` (source tag, driver SHA-256, package date, target ARMSX2 version)

Releases are immutable. Test results and the exact ARMSX2 version go in the release notes.

## Repository layout

```text
README.md
VERSION
NOTICE.md
scripts/
  fetch-prebuilt.sh     download + verify the pinned Termux release
  build-from-source.sh  build the sister repo, then package
  package.sh            wrapper around package.py
  package.py            create the ARMSX2 zip + meta.json
  install-adb.sh        push to Download, optional root install
  collect-logs.sh       adb logcat + dmesg bundle
docs/
  INSTALL.md
  TESTING.md
  DEBUGGING.md
  TEST-RESULTS.md
  REPORT-TEMPLATE.md
```

## Credits and license

Driver: Mesa PanVK + [`JimVulkan/mali-panvk`](https://github.com/JimVulkan/mali-panvk) (MIT).
Packaging and documentation: MIT. See [`NOTICE.md`](NOTICE.md).

Not affiliated with ARMSX2, Arm, Samsung, Mesa or the Panfrost project. Arm and Mali are trademarks
of Arm Limited; Samsung, Galaxy and Exynos are trademarks of Samsung Electronics.
