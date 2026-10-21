#!/bin/sh
# Shared helpers. Source this file, do not execute it.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
VERSION=$(cat "$ROOT/VERSION")
DIST_DIR=${DIST_DIR:-$ROOT/dist}
BUILD_ROOT=${BUILD_ROOT:-$ROOT/build}
SOURCE_REPO=${SOURCE_REPO:-https://github.com/soulexit/panvk-exynos9611-kbase-termux.git}
SOURCE_TAG=${SOURCE_TAG:-v$VERSION}
RELEASE_URL=${RELEASE_URL:-https://github.com/soulexit/panvk-exynos9611-kbase-termux/releases/download/$SOURCE_TAG}
PACKAGE_NAME=panvk-exynos9611-armsx2-v$VERSION
DRIVER_LIB=libvulkan_freedreno.so
ARMSX2_PACKAGES="com.armsx2.nightly com.armsx2"

log() { printf '==> %s\n' "$*" >&2; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "$1 not found in PATH"; }

# Print the first installed ARMSX2 package name.
find_armsx2_package() {
    for pkg in $ARMSX2_PACKAGES; do
        if adb shell pm list packages 2>/dev/null | grep -qx "package:$pkg"; then
            printf '%s\n' "$pkg"
            return 0
        fi
    done
    return 1
}
