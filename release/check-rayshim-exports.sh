#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAYLIB_DIR="${IMMORTAL_COIL_CLAYLIB_DIR:-${HOME}/quicklisp/local-projects/claylib}"
SOURCE="${1:-${ROOT}/release/rayshim.c}"

EXPECTED="$(mktemp)"
ACTUAL="$(mktemp)"
trap 'rm -f "$EXPECTED" "$ACTUAL"' EXIT

extract_binding_shims() {
  perl -ne 'while (/\("([^"]*__claw[^"]*)"/g) { print "$1\n" }' "$@" \
    | sort -u
}

extract_source_exports() {
  local source="$1"
  perl -ne 'while (/SHIM_EXPORT[^{;]*\s(__claw[_A-Za-z0-9]*)\s*\(/g) { print "$1\n" }' "$source" \
    | sort -u
}

extract_binding_shims "${CLAYLIB_DIR}/wrap/bindings/"*.lisp > "$EXPECTED"
extract_source_exports "$SOURCE" > "$ACTUAL"

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

echo "rayshim exports match all Claylib bindings ($(wc -l < "$EXPECTED") symbols)."
"${ROOT}/release/check-rayshim-signatures.pl" "$SOURCE"
