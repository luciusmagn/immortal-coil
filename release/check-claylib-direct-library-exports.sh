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
RAYGUI_HELPERS="$(mktemp)"
FOREIGN_GLOBALS="$(mktemp)"
RUNTIME_GLOBALS="$(mktemp)"
CLASSIFIED="$(mktemp)"
UNCLASSIFIED="$(mktemp)"
UNCLASSIFIED_GLOBALS="$(mktemp)"
ACTUAL="$(mktemp)"
MISSING="$(mktemp)"
RAW_NM="$(mktemp)"
CANDIDATE="$(mktemp)"
trap 'rm -f "$DIRECT_CFFI" "$RAYLIB_API" "$RAYGUI_API" "$RAYLIB_EXPECTED" "$RAYGUI_EXPECTED" "$RAYGUI_HELPERS" "$FOREIGN_GLOBALS" "$RUNTIME_GLOBALS" "$CLASSIFIED" "$UNCLASSIFIED" "$UNCLASSIFIED_GLOBALS" "$ACTUAL" "$MISSING" "$RAW_NM" "$CANDIDATE"' EXIT

extract_direct_cffi_symbols() {
  perl -ne 'while (/\(cffi:defcfun\s+\("([^"]+)"/g) { print "$1\n" }' "$@" \
    | grep -v '__claw' \
    | sort -u
}

extract_foreign_global_symbols() {
  perl -ne 'while (/foreign-symbol-pointer\s+"([^"]+)"/g) { print "$1\n" }' "$@" \
    | sort -u
}

extract_header_api_symbols() {
  local api_macro="$1"
  shift

  perl -ne 'while (/\b'"$api_macro"'\b[^;()]*?\b([A-Za-z_][A-Za-z0-9_]*)\s*\(/g) { print "$1\n" }' "$@" \
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

write_checked_raygui_helpers() {
  {
    echo "GetTextLines"
  } | sort -u
}

write_runtime_direct_symbols() {
  awk '/^_Exit$/ || /^[a-z_][A-Za-z0-9_]*$/ { print }' "$DIRECT_CFFI" \
    | sort -u
}

write_runtime_foreign_globals() {
  {
    echo "signgam"
    echo "stderr"
    echo "stdin"
    echo "stdout"
  } | sort -u
}

check_direct_symbol_classification() {
  {
    cat "$RAYLIB_EXPECTED"
    cat "$RAYGUI_EXPECTED"
    cat "$RAYGUI_HELPERS"
    write_runtime_direct_symbols
  } | sort -u > "$CLASSIFIED"

  comm -23 "$DIRECT_CFFI" "$CLASSIFIED" > "$UNCLASSIFIED"

  if [ -s "$UNCLASSIFIED" ]; then
    echo "Claylib has direct CFFI symbols with no checked library/runtime classification." >&2
    echo
    cat "$UNCLASSIFIED" >&2
    exit 1
  fi
}

check_foreign_global_classification() {
  comm -23 "$FOREIGN_GLOBALS" "$RUNTIME_GLOBALS" > "$UNCLASSIFIED_GLOBALS"

  if [ -s "$UNCLASSIFIED_GLOBALS" ]; then
    echo "Claylib has foreign-symbol-pointer globals with no checked runtime classification." >&2
    echo
    cat "$UNCLASSIFIED_GLOBALS" >&2
    exit 1
  fi
}

extract_direct_cffi_symbols "${CLAYLIB_DIR}/wrap/bindings/"*.lisp > "$DIRECT_CFFI"
extract_foreign_global_symbols "${CLAYLIB_DIR}/wrap/bindings/"*.lisp > "$FOREIGN_GLOBALS"
extract_header_api_symbols RLAPI \
  "${CLAYLIB_DIR}/wrap/lib/raylib.h" \
  "${CLAYLIB_DIR}/wrap/lib/rcamera.h" > "$RAYLIB_API"
extract_header_api_symbols RAYGUIAPI "${CLAYLIB_DIR}/wrap/lib/raygui.h" > "$RAYGUI_API"
write_checked_raygui_helpers > "$RAYGUI_HELPERS"
write_runtime_foreign_globals > "$RUNTIME_GLOBALS"

comm -12 "$DIRECT_CFFI" "$RAYLIB_API" > "$RAYLIB_EXPECTED"
{
  comm -12 "$DIRECT_CFFI" "$RAYGUI_API"
  comm -12 "$DIRECT_CFFI" "$RAYGUI_HELPERS"
} | sort -u > "$RAYGUI_EXPECTED"

check_direct_symbol_classification
check_foreign_global_classification
check_library_exports raylib "$RAYLIB_LIBRARY" "$RAYLIB_EXPECTED"
check_library_exports raygui "$RAYGUI_LIBRARY" "$RAYGUI_EXPECTED"
