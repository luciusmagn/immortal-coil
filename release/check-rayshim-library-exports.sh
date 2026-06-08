#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAYLIB_DIR="${IMMORTAL_COIL_CLAYLIB_DIR:-${HOME}/quicklisp/local-projects/claylib}"
LIBRARY="${1:?usage: check-rayshim-library-exports.sh PATH-TO-LIBRAYSHIM}"

EXPECTED="$(mktemp)"
ACTUAL="$(mktemp)"
RAW_NM="$(mktemp)"
trap 'rm -f "$EXPECTED" "$ACTUAL" "$RAW_NM"' EXIT

extract_binding_shims() {
  perl -ne 'while (/\("([^"]*__claw[^"]*)"/g) { print "$1\n" }' "$@" \
    | sort -u
}

extract_library_exports() {
  local library="$1"

  if nm -D --defined-only "$library" > "$RAW_NM" 2>/dev/null; then
    :
  elif nm -g --defined-only "$library" > "$RAW_NM" 2>/dev/null; then
    :
  elif command -v llvm-nm >/dev/null 2>&1 && llvm-nm --defined-only "$library" > "$RAW_NM" 2>/dev/null; then
    :
  else
    echo "Could not inspect exported symbols for $library" >&2
    exit 1
  fi

  awk '{
    for (i = 1; i <= NF; i++) {
      if ($i ~ /^__claw[_A-Za-z0-9]*$/) {
        print $i
      }
    }
  }' "$RAW_NM" | sort -u
}

extract_binding_shims "${CLAYLIB_DIR}/wrap/bindings/"*.lisp > "$EXPECTED"
extract_library_exports "$LIBRARY" > "$ACTUAL"

if ! cmp -s "$EXPECTED" "$ACTUAL"; then
  echo "$LIBRARY does not export Claylib's expected shim symbols." >&2
  echo
  echo "Missing exports:"
  comm -23 "$EXPECTED" "$ACTUAL" || true
  echo
  echo "Unexpected exports:"
  comm -13 "$EXPECTED" "$ACTUAL" || true
  exit 1
fi

echo "$(basename "$LIBRARY") exports all Claylib shim symbols ($(wc -l < "$EXPECTED") symbols)."
