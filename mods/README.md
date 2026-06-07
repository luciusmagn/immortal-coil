# Mods

Local development and player mods live here.

Preferred layout:

- `mods/<mod-id>/manifest.lisp`
- `mods/<mod-id>/assets/`

Example manifest:

```lisp
(:id "example-mod"
 :name "Example Mod"
 :scripts ("story.lisp")
 :assets "assets/")
```

Legacy loader support remains:

- `mods/*.lisp`
- `mods/<mod-id>/mod.lisp`

Mod bundles are loaded after the bundled game manifest, sorted by path. Local
mod files are ignored by Git by default; keep examples or docs elsewhere unless
they are meant to ship with the base game.
