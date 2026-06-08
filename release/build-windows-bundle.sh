#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${ROOT}/build/release/windows-x86_64"
BUNDLE="${BUILD_DIR}/immortal-coil-windows-x86_64"
DIST="${ROOT}/dist"
CLAYLIB_DIR="${IMMORTAL_COIL_CLAYLIB_DIR:-${HOME}/quicklisp/local-projects/claylib}"
MINGW_ROOT="${MINGW_PREFIX:-/mingw64}"
LIB_DIR="${BUNDLE}/lib"
RAYLIB_VERSION="${IMMORTAL_COIL_RAYLIB_VERSION:-4.5.0}"
RAYLIB_INSTALL="${IMMORTAL_COIL_RAYLIB_DIR:-${BUILD_DIR}/raylib-install}"

rm -rf "$BUILD_DIR"
mkdir -p "$LIB_DIR" "$DIST"

build_raylib() {
  local src="${BUILD_DIR}/raylib-src"
  local build="${BUILD_DIR}/raylib-build"

  git clone --depth 1 --branch "$RAYLIB_VERSION" \
    https://github.com/raysan5/raylib.git "$src"

  cmake -S "$src" -B "$build" -G Ninja \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_EXAMPLES=OFF \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$RAYLIB_INSTALL"
  cmake --build "$build" --target install
}

find_raylib_dll() {
  find "$RAYLIB_INSTALL" -type f \( -name 'libraylib.dll' -o -name 'raylib.dll' \) \
    | head -n 1
}

find_raylib_import_dir() {
  local import_lib
  import_lib="$(find "$RAYLIB_INSTALL" -type f \( -name 'libraylib.dll.a' -o -name 'libraylib.a' -o -name 'raylib.dll.a' \) | head -n 1)"
  if [ -z "$import_lib" ]; then
    echo "Could not find Raylib import library under $RAYLIB_INSTALL" >&2
    exit 1
  fi
  if [ "$(basename "$import_lib")" = "raylib.dll.a" ]; then
    cp "$import_lib" "$(dirname "$import_lib")/libraylib.dll.a"
  fi
  dirname "$import_lib"
}

if [ ! -d "$RAYLIB_INSTALL" ] || [ -z "$(find_raylib_dll 2>/dev/null)" ]; then
  build_raylib
fi

RAYLIB_DLL="$(find_raylib_dll)"
RAYLIB_LIB_DIR="$(find_raylib_import_dir)"

gcc -shared -DRAYLIB_DLL \
  -o "${LIB_DIR}/libraygui.dll" \
  "${ROOT}/release/raygui-shared.c" \
  -I"${CLAYLIB_DIR}/wrap/lib" \
  -I"${RAYLIB_INSTALL}/include" \
  -L"${RAYLIB_LIB_DIR}" \
  -lraylib -lopengl32 -lgdi32 -lwinmm

gcc -shared -DRAYLIB_DLL \
  -o "${LIB_DIR}/librayshim.dll" \
  "${ROOT}/release/rayshim.c" \
  -I"${CLAYLIB_DIR}/wrap/lib" \
  -I"${RAYLIB_INSTALL}/include" \
  -L"${RAYLIB_LIB_DIR}" \
  -lraylib -lopengl32 -lgdi32 -lwinmm

cp "$RAYLIB_DLL" "${LIB_DIR}/$(basename "$RAYLIB_DLL")"
if [ "$(basename "$RAYLIB_DLL")" != "libraylib.dll" ]; then
  cp "$RAYLIB_DLL" "${LIB_DIR}/libraylib.dll"
fi

export IMMORTAL_COIL_CLAYLIB_DIR="$CLAYLIB_DIR"
export IMMORTAL_COIL_BINARY="${BUNDLE}/immortal-coil.exe"
export CLAYLIB_USE_SYSTEM_RAYLIB_LIBRARIES=1
export PATH="${LIB_DIR}:${MINGW_ROOT}/bin:${PATH}"
export ASDF_OUTPUT_TRANSLATIONS="${ROOT}/:/tmp/immortal-coil-release-fasl/"

sbcl --no-userinit --no-sysinit --non-interactive \
  --load "${HOME}/quicklisp/setup.lisp" \
  --load "${ROOT}/release/build-binary.lisp"

copy_dll_dependency_closure() {
  local queue=("$@")
  local binary dep dest

  while [ "${#queue[@]}" -gt 0 ]; do
    binary="${queue[0]}"
    queue=("${queue[@]:1}")
    while read -r dep; do
      if [ -f "$dep" ]; then
        dest="${LIB_DIR}/$(basename "$dep")"
        if [ ! -f "$dest" ]; then
          cp "$dep" "$dest"
          queue+=("$dest")
        fi
      fi
    done < <(ldd "$binary" | awk '/mingw64|ucrt64|clang64/ { print $3 }')
  done
}

copy_dll_dependency_closure "${BUNDLE}/immortal-coil.exe" "$LIB_DIR"/*.dll

cp -R "${ROOT}/assets" "$BUNDLE/"
rm -rf "${BUNDLE}/assets/audio/backup"
cp -R "${ROOT}/game" "$BUNDLE/"
mkdir -p "$BUNDLE/mods"
cp "${ROOT}/mods/README.md" "$BUNDLE/mods/"
cp "${ROOT}/README.org" "$BUNDLE/"

cat > "${BUNDLE}/bundle-manifest.txt" <<EOF
Immortal Coil bundle
platform: windows-x86_64
git: $(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)
built: $(date -u +%Y-%m-%dT%H:%M:%SZ)
raylib: ${RAYLIB_VERSION}
EOF

{
  echo "immortal-coil.exe"
  ldd "${BUNDLE}/immortal-coil.exe" || true
  for library in "${LIB_DIR}"/*.dll; do
    echo
    echo "$(basename "$library")"
    ldd "$library" || true
  done
} > "${BUNDLE}/dependencies-windows.txt"

cat > "${BUNDLE}/run-immortal-coil.bat" <<'EOF'
@echo off
setlocal
set "HERE=%~dp0"
pushd "%HERE%" >nul
set "IMMORTAL_COIL_ROOT=."
set "IMMORTAL_COIL_LIB_DIR=lib"
if not defined IMMORTAL_COIL_SAVE_DIR set "IMMORTAL_COIL_SAVE_DIR=save"
if not exist "save" mkdir "save"
set "PATH=lib;%PATH%"
.\immortal-coil.exe %*
set "IMMORTAL_COIL_STATUS=%ERRORLEVEL%"
popd >nul
exit /b %IMMORTAL_COIL_STATUS%
EOF

rm -f "${DIST}/immortal-coil-windows-x86_64.zip"
(cd "$BUILD_DIR" && zip -qr "${DIST}/immortal-coil-windows-x86_64.zip" "immortal-coil-windows-x86_64")
