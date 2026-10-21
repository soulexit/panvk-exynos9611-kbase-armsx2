#!/bin/sh
# Push the ARMSX2 driver zip to the phone.
#
# usage:
#   ./scripts/install-adb.sh [zip]
#   ./scripts/install-adb.sh --root --dest /data/data/<pkg>/files/<driver-dir> --yes [zip]
#
# The in-app importer is the supported path. --root exists for debugging a build when the app's
# file picker is unusable; it requires you to name the destination directory explicitly because
# ARMSX2's private layout differs between nightly and stable builds.
set -eu
. "$(dirname -- "$0")/lib.sh"

root=0
yes=0
dest=""
zip=""
while [ $# -gt 0 ]; do
    case "$1" in
        --root) root=1 ;;
        --yes) yes=1 ;;
        --dest) shift; [ $# -gt 0 ] || die "--dest needs a value"; dest=$1 ;;
        --*) die "unknown option: $1" ;;
        *) zip=$1 ;;
    esac
    shift
done

zip=${zip:-$DIST_DIR/$PACKAGE_NAME.zip}
[ -f "$zip" ] || die "zip not found: $zip (run scripts/package.sh first)"
need adb
adb get-state >/dev/null 2>&1 || die "no adb device; check 'adb devices'"

pkg=$(find_armsx2_package) || die "ARMSX2 is not installed (looked for: $ARMSX2_PACKAGES)"
log "ARMSX2 package: $pkg"

remote="/sdcard/Download/$(basename "$zip")"
log "pushing $(basename "$zip") to $remote"
adb push "$zip" "$remote" >/dev/null

if [ "$root" = 0 ]; then
    echo
    echo "zip is on the phone: $remote"
    echo "In ARMSX2: Settings > GPU driver > Import, then select PanVK Exynos 9611."
    exit 0
fi

[ "$yes" = 1 ] || die "root install writes into the app's private data; pass --yes to confirm"
[ -n "$dest" ] || die "--root needs --dest; find the driver directory first (see docs/INSTALL.md)"
case "$dest" in
    /data/data/"$pkg"/*) ;;
    *) die "--dest must be under /data/data/$pkg" ;;
esac
adb shell su -c true >/dev/null 2>&1 || die "adb shell su is not available; use the in-app import"

local_tmp=$(mktemp -d)
trap 'rm -rf "$local_tmp"' EXIT INT TERM
unzip -q "$zip" -d "$local_tmp"
tmp="/sdcard/Download/.panvk-armsx2-$$"
adb push "$local_tmp" "$tmp" >/dev/null
adb shell su -c "mkdir -p '$dest' && cp -r '$tmp/.' '$dest/' && rm -rf '$tmp'"
uid=$(adb shell su -c "stat -c %u /data/data/$pkg" | tr -d '\r')
adb shell su -c "chown -R $uid:$uid '$dest'"

echo "installed to $dest"
echo "force-stop ARMSX2, reopen it, and select the driver in Settings > GPU driver"
