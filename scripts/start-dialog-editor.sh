#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: immortal-coil-editor [--host HOST] [--port PORT] [--root PATH]

Serves the repository root so the dialog editor can fetch game/opening.lisp and
shared assets.

Environment:
  IMMORTAL_COIL_EDITOR_HOST  Bind address, default 127.0.0.1
  IMMORTAL_COIL_EDITOR_PORT  Port, default 8080
  IMMORTAL_COIL_EDITOR_ROOT  Repository root override
EOF
}

find_editor_root() {
  if [[ -n "${IMMORTAL_COIL_EDITOR_ROOT:-}" ]]; then
    printf '%s\n' "$IMMORTAL_COIL_EDITOR_ROOT"
    return
  fi

  local dir
  dir="$PWD"

  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/tools/dialog-editor/index.html" && -f "$dir/game/opening.lisp" ]]; then
      printf '%s\n' "$dir"
      return
    fi

    dir="$(dirname "$dir")"
  done

  printf 'Could not find Immortal Coil repository root. Run from the repo or pass --root.\n' >&2
  exit 1
}

host="${IMMORTAL_COIL_EDITOR_HOST:-127.0.0.1}"
port="${IMMORTAL_COIL_EDITOR_PORT:-8080}"
root=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --host)
      host="${2:?Missing host for --host.}"
      shift 2
      ;;
    --port)
      port="${2:?Missing port for --port.}"
      shift 2
      ;;
    --root)
      root="${2:?Missing path for --root.}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$root" ]]; then
  root="$(find_editor_root)"
fi

if [[ ! -f "$root/tools/dialog-editor/index.html" ]]; then
  printf 'Editor not found under %s/tools/dialog-editor.\n' "$root" >&2
  exit 1
fi

if [[ ! -f "$root/game/opening.lisp" ]]; then
  printf 'Opening script not found under %s/game/opening.lisp.\n' "$root" >&2
  exit 1
fi

printf 'Serving Immortal Coil dialog editor from %s\n' "$root"
printf 'Open http://%s:%s/tools/dialog-editor/\n' "$host" "$port"

exec python3 -m http.server "$port" --bind "$host" --directory "$root"
