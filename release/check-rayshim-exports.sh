#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAYLIB_DIR="${IMMORTAL_COIL_CLAYLIB_DIR:-${HOME}/quicklisp/local-projects/claylib}"
SOURCE="${1:-${ROOT}/release/rayshim.c}"

EXPECTED="$(mktemp)"
WINDOWS_EXPECTED="$(mktemp)"
ACTUAL="$(mktemp)"
trap 'rm -f "$EXPECTED" "$WINDOWS_EXPECTED" "$ACTUAL"' EXIT

extract_binding_shims() {
  local binding="$1"
  perl -ne 'while (/\("([^"]*__claw[^"]*)"/g) { print "$1\n" }' "$binding" \
    | sort -u
}

extract_source_exports() {
  local source="$1"
  perl -ne 'while (/SHIM_EXPORT[^{;]*\s(__claw[_A-Za-z0-9]*)\s*\(/g) { print "$1\n" }' "$source" \
    | sort -u
}

extract_binding_shims "${CLAYLIB_DIR}/wrap/bindings/x86_64-pc-linux-gnu.lisp" > "$EXPECTED"
extract_binding_shims "${CLAYLIB_DIR}/wrap/bindings/x86_64-pc-windows-msvc.lisp" > "$WINDOWS_EXPECTED"
extract_source_exports "$SOURCE" > "$ACTUAL"

if ! cmp -s "$EXPECTED" "$WINDOWS_EXPECTED"; then
  echo "Linux and Windows x86-64 Claylib shim binding sets differ." >&2
  comm -3 "$EXPECTED" "$WINDOWS_EXPECTED" >&2
  exit 1
fi

if ! cmp -s "$EXPECTED" "$ACTUAL"; then
  echo "release/rayshim.c does not match Claylib's expected shim exports." >&2
  echo
  echo "Missing exports:"
  comm -23 "$EXPECTED" "$ACTUAL" || true
  echo
  echo "Unexpected exports:"
  comm -13 "$EXPECTED" "$ACTUAL" || true
  exit 1
fi

echo "rayshim exports match Claylib x86-64 bindings ($(wc -l < "$EXPECTED") symbols)."
