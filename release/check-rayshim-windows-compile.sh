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
trap 'rm -f "$OBJECT"' EXIT

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

echo "$(basename "$SOURCE") compiles as a Windows MinGW object."
