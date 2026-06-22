#!/usr/bin/env python3
"""Extract the base64 audio from an OpenRouter Lyria SSE stream into a file.

Usage: extract-lyria.py <stream-file> <out.mp3>

OpenRouter's google/lyria-3-clip-preview returns a streamed chat completion
whose delta carries a base64-encoded MP3 (the clip). This pulls it out and
writes the decoded bytes. No API key is involved here — see gen-lyria-music.sh.
"""
import sys, json, base64, re


def find_audio(infile):
    audio = None
    with open(infile) as f:
        for line in f:
            line = line.strip()
            if not line.startswith("data:"):
                continue
            payload = line[5:].strip()
            if payload == "[DONE]":
                continue
            try:
                obj = json.loads(payload)
            except Exception:
                continue
            for ch in obj.get("choices", []):
                delta = ch.get("delta", {}) or {}
                aud = delta.get("audio")
                if isinstance(aud, dict) and aud.get("data"):
                    audio = aud["data"]
                cont = delta.get("content")
                if isinstance(cont, list):
                    for part in cont:
                        if (isinstance(part, dict)
                                and part.get("type", "").startswith("audio")
                                and "data" in part):
                            audio = part["data"]
    if audio:
        return audio
    # Fallback: longest base64 token that decodes to a known audio header.
    txt = open(infile).read()
    for tok in sorted(re.findall(r'[A-Za-z0-9+/=]{2000,}', txt),
                      key=len, reverse=True):
        try:
            raw = base64.b64decode(tok)
        except Exception:
            continue
        if raw[:3] == b'ID3' or raw[:4] in (b'RIFF', b'OggS') or raw[:2] == b'\xff\xfb':
            return tok
    return None


def main():
    if len(sys.argv) != 3:
        print("usage: extract-lyria.py <stream-file> <out.mp3>")
        sys.exit(2)
    audio = find_audio(sys.argv[1])
    if not audio:
        print("NO AUDIO FOUND in stream")
        sys.exit(1)
    raw = base64.b64decode(audio)
    with open(sys.argv[2], "wb") as f:
        f.write(raw)
    print(f"decoded {len(raw)} bytes -> {sys.argv[2]} (magic={raw[:4]!r})")


if __name__ == "__main__":
    main()
