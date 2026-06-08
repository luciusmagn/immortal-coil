#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUNDLE_INPUT="${1:?usage: check-release-bundle.sh PATH-TO-BUNDLE-DIR-OR-ZIP [EXPECTED-GIT-SHORT]}"
EXPECTED_GIT="${2:-}"

WORK_DIR=""
trap 'if [ -n "$WORK_DIR" ]; then rm -rf "$WORK_DIR"; fi' EXIT

bundle_has_shim() {
  local dir="$1"

  [ -f "$dir/lib/librayshim.dll" ] \
    || [ -f "$dir/lib/librayshim.x86_64-pc-linux-gnu.so" ]
}

find_bundle_root() {
  local root="$1"
  local candidate

  if bundle_has_shim "$root"; then
    printf '%s\n' "$root"
    return 0
  fi

  while IFS= read -r candidate; do
    if bundle_has_shim "$candidate"; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done < <(find "$root" -maxdepth 2 -type d | sort)

  echo "Could not find bundle root containing lib/librayshim under $root." >&2
  exit 1
}

resolve_bundle_root() {
  local input="$1"

  if [ -d "$input" ]; then
    find_bundle_root "$input"
    return 0
  fi

  if [ ! -f "$input" ]; then
    echo "Bundle path does not exist: $input" >&2
    exit 1
  fi

  WORK_DIR="$(mktemp -d)"
  unzip -q "$input" -d "$WORK_DIR"
  find_bundle_root "$WORK_DIR"
}

check_manifest_commit() {
  local bundle="$1"
  local expected="$2"
  local manifest actual

  [ -n "$expected" ] || return 0

  manifest="$bundle/bundle-manifest.txt"
  if [ ! -f "$manifest" ]; then
    echo "Bundle manifest is missing: $manifest" >&2
    exit 1
  fi

  actual="$(awk '/^git:/ { print $2 }' "$manifest")"
  if [ -z "$actual" ]; then
    echo "Bundle manifest does not contain a git field: $manifest" >&2
    exit 1
  fi

  case "$expected" in
    "$actual"*)
      ;;
    *)
      echo "Bundle git mismatch: manifest has $actual, expected $expected." >&2
      exit 1
      ;;
  esac
}

BUNDLE="$(resolve_bundle_root "$BUNDLE_INPUT")"

check_manifest_commit "$BUNDLE" "$EXPECTED_GIT"

if [ -f "$BUNDLE/lib/librayshim.dll" ]; then
  RAYSHIM="$BUNDLE/lib/librayshim.dll"
  RAYLIB="$BUNDLE/lib/libraylib.dll"
  RAYGUI="$BUNDLE/lib/libraygui.dll"
else
  RAYSHIM="$BUNDLE/lib/librayshim.x86_64-pc-linux-gnu.so"
  RAYLIB="$BUNDLE/lib/libraylib.so"
  RAYGUI="$BUNDLE/lib/libraygui.so"
fi

for library in "$RAYSHIM" "$RAYLIB" "$RAYGUI"; do
  if [ ! -f "$library" ]; then
    echo "Bundle library is missing: $library" >&2
    exit 1
  fi
done

"$ROOT/release/check-rayshim-library-exports.sh" "$RAYSHIM"
"$ROOT/release/check-rayshim-imports.sh" "$RAYSHIM"
"$ROOT/release/check-claylib-direct-library-exports.sh" "$RAYLIB" "$RAYGUI"

echo "$(basename "$BUNDLE") release bundle shim checks passed."
