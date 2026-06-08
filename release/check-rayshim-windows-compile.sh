#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAYLIB_DIR="${IMMORTAL_COIL_CLAYLIB_DIR:-${HOME}/quicklisp/local-projects/claylib}"
SOURCE="${1:-${ROOT}/release/rayshim.c}"
DEFAULT_CC="x86_64-w64-mingw32-gcc"

if [ -n "${MINGW_PREFIX:-}" ]; then
  DEFAULT_CC="gcc"
fi

CC="${MINGW_CC:-${CC:-${DEFAULT_CC}}}"
OBJECT="$(mktemp --suffix=.o)"
API_SYMBOLS="$(mktemp)"
UNDEFINED_SYMBOLS="$(mktemp)"
STUB_SYMBOLS="$(mktemp)"
STUB_SOURCE="$(mktemp --suffix=.c)"
STUB_OBJECT="$(mktemp --suffix=.o)"
PROBE_DLL="$(mktemp --suffix=.dll)"
trap 'rm -f "$OBJECT" "$API_SYMBOLS" "$UNDEFINED_SYMBOLS" "$STUB_SYMBOLS" "$STUB_SOURCE" "$STUB_OBJECT" "$PROBE_DLL"' EXIT

if ! command -v "$CC" >/dev/null 2>&1; then
  echo "Could not find MinGW compiler '$CC'." >&2
  echo "Set MINGW_CC or run from an MSYS2 MinGW shell." >&2
  exit 1
fi

"$CC" -c \
  -DRAYLIB_DLL \
  -Werror=implicit-function-declaration \
  -Werror=incompatible-pointer-types \
  -Werror=int-conversion \
  -Werror=builtin-declaration-mismatch \
  -I"${CLAYLIB_DIR}/wrap/lib" \
  -o "$OBJECT" \
  "$SOURCE"

perl -ne 'while (/\b(?:RLAPI|RAYGUIAPI|RMAPI)\b[^;{()]*?\b([A-Za-z_][A-Za-z0-9_]*)\s*\(/g) { print "$1\n" }' \
  "${CLAYLIB_DIR}/wrap/lib/raylib.h" \
  "${CLAYLIB_DIR}/wrap/lib/raygui.h" \
  "${CLAYLIB_DIR}/wrap/lib/raymath.h" \
  "${CLAYLIB_DIR}/wrap/lib/rcamera.h" \
  | sort -u > "$API_SYMBOLS"

nm -u "$OBJECT" \
  | awk '{ print $NF }' \
  | sort -u > "$UNDEFINED_SYMBOLS"

comm -12 "$API_SYMBOLS" "$UNDEFINED_SYMBOLS" > "$STUB_SYMBOLS"

awk 'BEGIN { print "/* Generated temporary Claylib API stubs for rayshim PE link probing. */" }
     { printf "void %s(void) {}\n", $1 }' \
  "$STUB_SYMBOLS" > "$STUB_SOURCE"

"$CC" -c \
  -o "$STUB_OBJECT" \
  "$STUB_SOURCE"

# MINGW_LDFLAGS is intentionally word-split so local Nix cross compilers can
# supply extra runtime library search paths without affecting MSYS2 CI.
# shellcheck disable=SC2086
"$CC" -shared \
  -o "$PROBE_DLL" \
  "$OBJECT" \
  "$STUB_OBJECT" \
  ${MINGW_LDFLAGS:-}

"${ROOT}/release/check-rayshim-library-exports.sh" "$PROBE_DLL"
"${ROOT}/release/check-rayshim-imports.sh" "$PROBE_DLL"

echo "$(basename "$SOURCE") compiles and links as a Windows MinGW probe DLL."
