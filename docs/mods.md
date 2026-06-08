# Mod Support

Immortal Coil now has a small official mod loading surface. The bundled game
uses the same manifest shape as player mods.

See [`mod-api.md`](mod-api.md) for the current public prototype API exposed to
mod scripts.

## Layout

Preferred mod layout:

```text
mods/<mod-id>/manifest.lisp
mods/<mod-id>/story.lisp
mods/<mod-id>/assets/
```

`manifest.lisp` is data, not code:

```lisp
(:id "example-mod"
 :name "Example Mod"
 :version "0.1.0"
 :depends-on ("immortal-coil/base")
 :scripts ("story.lisp")
 :assets "assets/")
```

Script paths and asset paths are relative to the manifest directory.
`:depends-on` names bundle IDs that should load first. The bundled game is a
bundle too, with ID `immortal-coil/base`.

Total conversions or test bundles can also set:

```lisp
(:title-logo "logo/title-logo.png"
 :start "example-mod/start")
```

`:title-logo` is relative to the manifest's asset root. `:start` changes the
root story node. Later-loaded bundles win.

Legacy single-file mods are still read from:

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

## Assets

Inside a script, use `dialog-asset-pathname` for files bundled with that mod:

```lisp
(dialog-asset-pathname "audio/click.wav")
```

For the example layout above, this resolves to:

```text
mods/example-mod/assets/audio/click.wav
```

## Loading

The base story manifest loads first. Mod manifests and legacy mod scripts load
after it. Manifests with dependency IDs are ordered so dependencies load before
dependents; ties use deterministic path order. That means mods can append to
base nodes and to nodes from earlier mods:

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
