#!/usr/bin/env bash
# Generate ambient music for the King in Yellow path via OpenRouter's Google
# Lyria clip model, into assets/audio/. The API key is read from .env
# (OPENROUTER_API_KEY=...) and is NEVER written into this script or committed.
#
#   ./scripts/gen-lyria-music.sh            # generate the default track set
#   ./scripts/gen-lyria-music.sh name "prompt"   # generate one named track
#
# Lyria is experimental and "can be weird": prompts ask for instrumental beds,
# but it may add voices. Re-run to reroll a track.
set -uo pipefail
cd "$(dirname "$0")/.."

KEY=$(grep -E '^OPENROUTER_API_KEY=' .env 2>/dev/null | cut -d= -f2-)
if [ -z "${KEY:-}" ]; then
  echo "No OPENROUTER_API_KEY in .env — put it there (gitignored) and retry."
  exit 1
fi

MODEL="google/lyria-3-clip-preview"

gen_one() {
  local name="$1" prompt="$2" tmp
  tmp=$(mktemp)
  echo ">> $name"
  # prompts are plain ASCII with no double quotes, so inlining is safe
  curl -s -N --max-time 240 https://openrouter.ai/api/v1/chat/completions \
    -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"$prompt\"}],\"modalities\":[\"audio\"],\"stream\":true}" \
    > "$tmp"
  python3 scripts/extract-lyria.py "$tmp" "assets/audio/$name.mp3" \
    || echo "!! $name failed (kept stream at $tmp)"
  rm -f "$tmp" 2>/dev/null || true
}

if [ "$#" -eq 2 ]; then
  gen_one "$1" "$2"
  exit 0
fi

gen_one jrpg-carcosa   "a vast detuned ambient drone beneath two suns that never finish setting, slow, dread, instrumental, no percussion"
gen_one jrpg-city-night "an uneasy gaslit nocturne, sparse low piano and distant strings, faint wrongness, instrumental"
gen_one jrpg-court     "a lone church organ playing a solemn tune that keeps dying in its third line, wrong meter, instrumental"
gen_one jrpg-dys       "a sweet medieval falconry idyll on lute and viol that slowly curdles into grief, instrumental"
echo "done"
