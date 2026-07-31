#!/usr/bin/env bash
#
# Build an iOS-ready copy of the Dramatic Shape voxel mod.
#
# The mod's published release does not pin the DPI scale on its own render
# targets, so on an iPhone or iPad 3D mode switches on and draws an empty
# frame -- no error, just nothing.  The fix is open upstream as PR #40 and is
# not merged yet, so this applies it locally.
#
# The mod itself is downloaded from its author's own GitHub release; only the
# lines added by PR #40 (patches/pr40-highdpi.patch) come from this
# repository.  Nothing of the author's work is redistributed here.
#
# Output: DRAMATIC_SHAPE-ios.zip -- import it with the app's Import Mod button.
#
# Once PR #40 is merged this script is obsolete: install the mod normally.

set -euo pipefail

REPO="DramaticShape/DramaticShapeVoxelMod"
PATCH="$(cd "$(dirname "$0")" && pwd)/patches/pr40-highdpi.patch"
OUT="$(pwd)/DRAMATIC_SHAPE-ios.zip"

die() { printf '\033[1;31merror:\033[0m %s\n' "$1" >&2; exit 1; }
say() { printf '\033[1;32m==>\033[0m %s\n' "$1"; }

for tool in curl unzip zip patch python3; do
  command -v "$tool" >/dev/null 2>&1 || die "missing required tool: $tool"
done
[ -f "$PATCH" ] || die "patch not found: $PATCH"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# Resolve the latest release's zip through the public API, so this keeps
# working when the mod is updated rather than pinning a version that rots.
say "looking up the latest $REPO release"
url="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
  | python3 -c 'import json,sys
d = json.load(sys.stdin)
z = [a["browser_download_url"] for a in d.get("assets", [])
     if a["name"].endswith(".zip")]
if not z:
    sys.exit("no .zip asset on the latest release")
print(z[0])')" || die "could not resolve the release asset"

say "downloading $(basename "$url")"
curl -fsSL "$url" -o "$work/mod.zip" || die "download failed"

say "unpacking"
unzip -q "$work/mod.zip" -d "$work/src"

# Releases are zipped from the repo, so everything sits under one top folder.
root="$(find "$work/src" -maxdepth 2 -name manifest.json -print -quit)"
[ -n "$root" ] || die "no manifest.json in the downloaded zip"
root="$(dirname "$root")"

if [ -f "$root/lib/PixelCanvas.lua" ]; then
  say "this release already contains the fix -- PR #40 has landed."
  say "install the mod normally; this script is no longer needed."
  exit 0
fi

say "applying the high-DPI fix (PR #40)"
( cd "$root" && patch -p1 --silent < "$PATCH" ) \
  || die "patch did not apply -- the mod has changed since this patch was
written. Check whether PR #40 has merged:
https://github.com/$REPO/pull/40"

[ -f "$root/lib/PixelCanvas.lua" ] || die "patch applied but PixelCanvas.lua is
missing -- refusing to ship a mod that would fail at load"

say "repacking"
rm -f "$OUT"
( cd "$root" && zip -q -9 -r "$OUT" . -x '*.DS_Store' -x '*/.git/*' )

printf '\n\033[1;32mdone:\033[0m %s\n\n' "$OUT"
cat <<'EOF'
Next:
  1. Move that zip to your device (AirDrop, iCloud Drive, or the Files app).
  2. In VoxelTrail, tap Import Mod and select it.
  3. Force-quit and reopen the app -- a picked file is not noticed until
     restart (see the Known issues section of the README).
  4. START -> OPTION -> 3D WORLD to choose an angle.
EOF
