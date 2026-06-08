#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAYLIB_DIR="${IMMORTAL_COIL_CLAYLIB_DIR:-${HOME}/quicklisp/local-projects/claylib}"
RAYLIB_LIBRARY="${1:?usage: check-claylib-direct-library-exports.sh PATH-TO-RAYLIB PATH-TO-RAYGUI}"
RAYGUI_LIBRARY="${2:?usage: check-claylib-direct-library-exports.sh PATH-TO-RAYLIB PATH-TO-RAYGUI}"

DIRECT_CFFI="$(mktemp)"
RAYLIB_API="$(mktemp)"
RAYGUI_API="$(mktemp)"
RAYLIB_EXPECTED="$(mktemp)"
RAYGUI_EXPECTED="$(mktemp)"
ACTUAL="$(mktemp)"
MISSING="$(mktemp)"
RAW_NM="$(mktemp)"
CANDIDATE="$(mktemp)"
trap 'rm -f "$DIRECT_CFFI" "$RAYLIB_API" "$RAYGUI_API" "$RAYLIB_EXPECTED" "$RAYGUI_EXPECTED" "$ACTUAL" "$MISSING" "$RAW_NM" "$CANDIDATE"' EXIT

extract_direct_cffi_symbols() {
  perl -ne 'while (/\(cffi:defcfun\s+\("([^"]+)"/g) { print "$1\n" }' "$@" \
    | grep -v '__claw' \
    | sort -u
}

extract_header_api_symbols() {
  local api_macro="$1"
  local header="$2"

  perl -ne 'while (/\b'"$api_macro"'\b[^;()]*?\b([A-Za-z_][A-Za-z0-9_]*)\s*\(/g) { print "$1\n" }' "$header" \
    | sort -u
}

extract_library_exports() {
  local library="$1"
  local mode

  for mode in dynamic global llvm; do
    case "$mode" in
      dynamic)
        nm -D --defined-only "$library" > "$RAW_NM" 2>/dev/null || continue
        ;;
      global)
        nm -g --defined-only "$library" > "$RAW_NM" 2>/dev/null || continue
        ;;
      llvm)
        command -v llvm-nm >/dev/null 2>&1 || continue
        llvm-nm --defined-only "$library" > "$RAW_NM" 2>/dev/null || continue
        ;;
    esac

    awk '{
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^[A-Za-z_][A-Za-z0-9_]*$/) {
          print $i
        }
      }
    }' "$RAW_NM" | sort -u > "$CANDIDATE"

    if [ -s "$CANDIDATE" ]; then
      cat "$CANDIDATE"
      return 0
    fi
  done

  echo "Could not inspect exported symbols for $library" >&2
  exit 1
}

check_library_exports() {
  local label="$1"
  local library="$2"
  local expected="$3"

  extract_library_exports "$library" > "$ACTUAL"
  comm -23 "$expected" "$ACTUAL" > "$MISSING"

  if [ ! -s "$MISSING" ]; then
    echo "$(basename "$library") exports all Claylib direct $label symbols ($(wc -l < "$expected") symbols)."
    return 0
  fi

  echo "$library does not export Claylib's expected direct $label symbols." >&2
  echo
  echo "Missing exports:"
  cat "$MISSING"
  exit 1
}

extract_direct_cffi_symbols "${CLAYLIB_DIR}/wrap/bindings/"*.lisp > "$DIRECT_CFFI"
extract_header_api_symbols RLAPI "${CLAYLIB_DIR}/wrap/lib/raylib.h" > "$RAYLIB_API"
extract_header_api_symbols RAYGUIAPI "${CLAYLIB_DIR}/wrap/lib/raygui.h" > "$RAYGUI_API"

comm -12 "$DIRECT_CFFI" "$RAYLIB_API" > "$RAYLIB_EXPECTED"
comm -12 "$DIRECT_CFFI" "$RAYGUI_API" > "$RAYGUI_EXPECTED"

check_library_exports raylib "$RAYLIB_LIBRARY" "$RAYLIB_EXPECTED"
check_library_exports raygui "$RAYGUI_LIBRARY" "$RAYGUI_EXPECTED"
