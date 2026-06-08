#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAYLIB_DIR="${IMMORTAL_COIL_CLAYLIB_DIR:-${HOME}/quicklisp/local-projects/claylib}"
LIBRARY="${1:?usage: check-rayshim-imports.sh PATH-TO-LIBRAYSHIM}"

API_SYMBOLS="$(mktemp)"
IMPORTS="$(mktemp)"
UNEXPECTED="$(mktemp)"
RAW="$(mktemp)"
trap 'rm -f "$API_SYMBOLS" "$IMPORTS" "$UNEXPECTED" "$RAW"' EXIT

extract_api_symbols() {
  perl -ne 'while (/\b(?:RLAPI|RAYGUIAPI|RMAPI)\b[^;{()]*?\b([A-Za-z_][A-Za-z0-9_]*)\s*\(/g) { print "$1\n" }' \
    "${CLAYLIB_DIR}/wrap/lib/raylib.h" \
    "${CLAYLIB_DIR}/wrap/lib/raygui.h" \
    "${CLAYLIB_DIR}/wrap/lib/raymath.h" \
    "${CLAYLIB_DIR}/wrap/lib/rcamera.h" \
    | sort -u
}

is_runtime_symbol() {
  case "$1" in
    _ITM_*|__*)
      return 0
      ;;
    abort|calloc|ceilf|fclose|feof|fgets|floorf|fopen|fprintf|fread|free|fseek|ftell|malloc|memcpy|memset|printf|realloc|roundf|snprintf|sprintf|strlen|strncmp|vfprintf)
      return 0
      ;;
    acoshl|acosl|asinhl|asinl|atan2l|atanhl|atanl|cbrtl|ceill|copysignl|coshl|cosl|dreml|erfcl|erfl|exp2l|expl|expm1l|fabsl|fdiml|finitel|floorl|fmal|fmaxl|fminl|fmodl|frexpl|gammal|hypotl|ilogbl|isinfl|isnanl|j0l|j1l|jnl|ldexpl|lgammal|lgammal_r|llrintl|llroundl|log10l|log1pl|log2l|logbl|logl|lrintl|lroundl|modfl|nanl|nearbyintl|nextafterl|nexttoward|nexttowardf|nexttowardl|powl|qecvt|qfcvt|qgcvt|remainderl|remquol|rintl|roundl|scalbl|scalblnl|scalbnl|significandl|sinhl|sinl|sqrtl|strtold|tanhl|tanl|tgammal|truncl|y0l|y1l|ynl)
      return 0
      ;;
  esac

  return 1
}

is_runtime_dll() {
  local dll
  dll="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"

  case "$dll" in
    api-ms-win-*|advapi32.dll|combase.dll|gdi32.dll|imm32.dll|kernel32.dll|kernelbase.dll|libgcc_s*.dll|libstdc++*.dll|libwinpthread*.dll|msvcrt.dll|ntdll.dll|rpcrt4.dll|shell32.dll|ucrtbase.dll|user32.dll|vcruntime*.dll|winmm.dll|ws2_32.dll)
      return 0
      ;;
  esac

  return 1
}

extract_elf_imports() {
  if nm -D -u "$LIBRARY" > "$RAW" 2>/dev/null; then
    awk '{ print $NF }' "$RAW" | sed 's/@.*//' | sort -u
    return 0
  fi

  return 1
}

extract_pe_imports() {
  objdump -p "$LIBRARY" > "$RAW" 2>/dev/null || return 1
  awk '
    /DLL Name:/ {
      dll = $3
      next
    }
    dll && /^[[:space:]]+[0-9a-fA-F]+[[:space:]]+<none>[[:space:]]+[0-9a-fA-F]+[[:space:]]+[A-Za-z_][A-Za-z0-9_@?]*/ {
      print dll ":" $4
    }
  ' "$RAW" | sort -u
}

check_elf_imports() {
  local symbol

  while read -r symbol; do
    [ -n "$symbol" ] || continue
    if grep -Fxq "$symbol" "$API_SYMBOLS"; then
      continue
    fi
    if is_runtime_symbol "$symbol"; then
      continue
    fi
    echo "$symbol" >> "$UNEXPECTED"
  done < "$IMPORTS"
}

check_pe_imports() {
  local entry dll symbol dll_lower

  while IFS=: read -r dll symbol; do
    [ -n "$dll" ] || continue
    dll_lower="$(printf '%s' "$dll" | tr '[:upper:]' '[:lower:]')"

    case "$dll_lower" in
      *raylib*.dll|*raygui*.dll)
        if ! grep -Fxq "$symbol" "$API_SYMBOLS"; then
          echo "$dll:$symbol" >> "$UNEXPECTED"
        fi
        ;;
      *)
        if ! is_runtime_dll "$dll" && ! is_runtime_symbol "$symbol"; then
          echo "$dll:$symbol" >> "$UNEXPECTED"
        fi
        ;;
    esac
  done < "$IMPORTS"
}

extract_api_symbols > "$API_SYMBOLS"

if extract_pe_imports > "$IMPORTS" && [ -s "$IMPORTS" ] && grep -q ':' "$IMPORTS"; then
  check_pe_imports
else
  extract_elf_imports > "$IMPORTS"
  check_elf_imports
fi

if [ -s "$UNEXPECTED" ]; then
  echo "$LIBRARY imports unexpected non-Claylib/non-runtime symbols." >&2
  echo
  cat "$UNEXPECTED" >&2
  exit 1
fi

echo "$(basename "$LIBRARY") imports only Claylib API and runtime symbols ($(wc -l < "$IMPORTS") imports)."
