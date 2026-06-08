#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${ROOT}/build/release/linux-x86_64"
BUNDLE="${BUILD_DIR}/immortal-coil-linux-x86_64"
DIST="${ROOT}/dist"
CLAYLIB_DIR="${IMMORTAL_COIL_CLAYLIB_DIR:-${HOME}/quicklisp/local-projects/claylib}"
LIB_DIR="${BUNDLE}/lib"

rm -rf "$BUILD_DIR"
mkdir -p "$LIB_DIR" "$DIST"

"${ROOT}/release/check-rayshim-exports.sh"

copy-linux-library-maybe() {
  local soname="$1"
  local path=""

  if command -v ldconfig >/dev/null 2>&1; then
    path="$(ldconfig -p 2>/dev/null | awk -v soname="$soname" '$1 == soname { print $NF; exit }' || true)"
  fi

  if [ -n "$path" ] && [ -f "$path" ]; then
    cp "$path" "$LIB_DIR/"
  else
    echo "Warning: could not find $soname to include in the bundle" >&2
  fi
}

gcc -shared -fPIC \
  -o "${LIB_DIR}/librayshim.x86_64-pc-linux-gnu.so" \
  "${ROOT}/release/rayshim.c" \
  -I"${CLAYLIB_DIR}/wrap/lib" \
  -L"${CLAYLIB_DIR}/wrap/lib" \
  -lraylib

"${ROOT}/release/check-rayshim-library-exports.sh" \
  "${LIB_DIR}/librayshim.x86_64-pc-linux-gnu.so"
"${ROOT}/release/check-rayshim-imports.sh" \
  "${LIB_DIR}/librayshim.x86_64-pc-linux-gnu.so"

cp "${CLAYLIB_DIR}/wrap/lib/libraylib.so" "$LIB_DIR/"
cp "${CLAYLIB_DIR}/wrap/lib/libraylib.so" "${LIB_DIR}/libraylib.so.420"
cp "${CLAYLIB_DIR}/wrap/lib/libraygui.so" "$LIB_DIR/"
"${ROOT}/release/check-claylib-direct-library-exports.sh" \
  "${LIB_DIR}/libraylib.so" \
  "${LIB_DIR}/libraygui.so"
copy-linux-library-maybe "libglfw.so.3"

export IMMORTAL_COIL_CLAYLIB_DIR="$CLAYLIB_DIR"
export IMMORTAL_COIL_BINARY="${BUNDLE}/immortal-coil"
export CLAYLIB_USE_SYSTEM_RAYLIB_LIBRARIES=1
export LD_LIBRARY_PATH="${LIB_DIR}:${CLAYLIB_DIR}/wrap/lib:${LD_LIBRARY_PATH:-}"
export ASDF_OUTPUT_TRANSLATIONS="${ROOT}/:/tmp/immortal-coil-release-fasl/"

sbcl --no-userinit --no-sysinit --non-interactive \
  --load "${HOME}/quicklisp/setup.lisp" \
  --load "${ROOT}/release/build-binary.lisp"

cp -R "${ROOT}/assets" "$BUNDLE/"
rm -rf "${BUNDLE}/assets/audio/backup"
cp -R "${ROOT}/game" "$BUNDLE/"
mkdir -p "$BUNDLE/mods"
cp "${ROOT}/mods/README.md" "$BUNDLE/mods/"
cp "${ROOT}/README.org" "$BUNDLE/"

cat > "${BUNDLE}/bundle-manifest.txt" <<EOF
Immortal Coil bundle
platform: linux-x86_64
git: $(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)
built: $(date -u +%Y-%m-%dT%H:%M:%SZ)
raylib: claylib bundled library
EOF

{
  echo "immortal-coil"
  ldd "${BUNDLE}/immortal-coil" || true
  for library in "${LIB_DIR}"/*.so*; do
    echo
    echo "$(basename "$library")"
    ldd "$library" || true
  done
} > "${BUNDLE}/dependencies-linux.txt"

cat > "${BUNDLE}/run-immortal-coil.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
export IMMORTAL_COIL_ROOT="$HERE"
export IMMORTAL_COIL_LIB_DIR="$HERE/lib"
export IMMORTAL_COIL_SHARED_OBJECTS="libraylib.so;libraygui.so;librayshim.x86_64-pc-linux-gnu.so"
export LD_LIBRARY_PATH="$HERE/lib:${LD_LIBRARY_PATH:-}"
if [ -z "${IMMORTAL_COIL_SAVE_DIR:-}" ]; then
  export IMMORTAL_COIL_SAVE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/immortal-coil"
fi

exec "$HERE/immortal-coil" "$@"
EOF
chmod +x "${BUNDLE}/run-immortal-coil.sh" "${BUNDLE}/immortal-coil"

rm -f "${DIST}/immortal-coil-linux-x86_64.zip"
(cd "$BUILD_DIR" && zip -qr "${DIST}/immortal-coil-linux-x86_64.zip" "immortal-coil-linux-x86_64")

EXPECTED_GIT="$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || true)"
"${ROOT}/release/check-release-bundle.sh" "$BUNDLE" "$EXPECTED_GIT"
"${ROOT}/release/check-release-bundle.sh" \
  "${DIST}/immortal-coil-linux-x86_64.zip" \
  "$EXPECTED_GIT"
