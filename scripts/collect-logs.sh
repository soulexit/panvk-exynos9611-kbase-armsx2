#!/bin/sh
# Collect ARMSX2 + PanVK logs over adb.
set -eu
. "$(dirname -- "$0")/lib.sh"

need adb
stamp=$(date -u +%Y%m%dT%H%M%SZ)
out="$DIST_DIR/logs-$stamp"
mkdir -p "$out"

pkg=$(find_armsx2_package || echo com.armsx2.nightly)
adb shell 'getprop ro.product.model; getprop ro.build.display.id; uname -a' > "$out/device.txt" 2>&1 || true
adb shell 'cat /sys/class/misc/mali0/device/gpuinfo; cat /sys/class/misc/mali0/device/core_mask' > "$out/gpu.txt" 2>&1 || true
adb shell "dumpsys package $pkg | grep -E 'versionName|versionCode'" > "$out/armsx2-version.txt" 2>&1 || true
adb shell 'dmesg | grep -iE "mali|kbase|gpu|fault|mmu"' > "$out/dmesg.txt" 2>&1 || true
adb logcat -d -s 'panvk:*' 'Mesa:*' 'AndroidRuntime:E' > "$out/logcat.txt" 2>&1 || true
adb logcat -d | grep -iE 'armsx2|vulkan|driver' | tail -500 > "$out/armsx2-tail.txt" 2>&1 || true

tar -czf "$out.tar.gz" -C "$DIST_DIR" "$(basename "$out")"
rm -rf "$out"
echo "wrote $out.tar.gz"
