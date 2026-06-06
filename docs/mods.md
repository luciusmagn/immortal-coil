# Mod Support

Immortal Coil now has a small official mod loading surface.

## Layout

Mods are read from:

```text
mods/*.lisp
mods/<mod-id>/mod.lisp
```

You can add extra mod directories with:

```bash
IMMORTAL_COIL_MOD_DIR=/path/to/mods:/another/path
```

Disable mod loading with:

```bash
IMMORTAL_COIL_DISABLE_MODS=1
```

## Loading

The base story scripts load first. Mod scripts load after them, sorted by path.
That means mods can append to base nodes and to nodes from earlier mods:

```lisp
(dialog-add-choice "base/exit-bed"
                   "look under the bed"
                   "my-mod/under-bed")

(dialog-text "my-mod/under-bed"
             "the dark has been folded into a square.")
```

## Conflicts

If a later script defines a node ID that already exists from an earlier script,
the conflict is recorded and the later definition wins for now. The title menu's
`MODS` item shows how many mods were found or loaded and how many node conflicts
were recorded.

Use stable, namespaced IDs such as `my-mod/opening` to avoid accidental
replacement. Intentional replacement should be rare; prefer `dialog-add-choice`,
`dialog-set-next`, or new namespaced nodes where possible.
