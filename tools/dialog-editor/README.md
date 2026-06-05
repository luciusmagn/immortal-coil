# Dialog Graph Editor

Static browser editor for Immortal Coil dialog scripts.

Run from the repository root when you want `Load Opening` to fetch `game/opening.lisp`:

```bash
python3 -m http.server 8080
```

Then open:

```text
http://localhost:8080/tools/dialog-editor/
```

Use the local server instead of opening `index.html` directly. The editor uses browser module imports, and browsers also block local `fetch` calls from `file://`.
