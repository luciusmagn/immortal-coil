# Dialog Graph Editor

Static browser editor for Immortal Coil dialog scripts.

Run from the repository root:

```bash
nix run .#editor
```

Then open:

```text
http://localhost:8080/tools/dialog-editor/
```

To change the bind address or port:

```bash
nix run .#editor -- --host 0.0.0.0 --port 8081
```

Use the local server instead of opening `index.html` directly. The editor uses browser module imports, and browsers also block local `fetch` calls from `file://`.

String substitutions use `{store-key}` placeholders in dialog text and choice labels. A `dialog-string` or `dialog-number` node can store values into the shared dialog store, and later nodes can refer to them.

Choice and branch conditions use presets for common dialog-store checks. Custom Lisp is still available for cases that need the full language.

Node particle effects can be scripted with forms such as:

```lisp
(dialog-particles "ship/wake" :stars :fade-seconds 6.5)
```
