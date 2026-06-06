# Mods

Local development and player mods live here.

The loader scans:

- `mods/*.lisp`
- `mods/<mod-id>/mod.lisp`

Scripts are loaded after `game/opening.lisp`, sorted by path. Local mod files
are ignored by Git by default; keep examples or docs elsewhere unless they are
meant to ship with the base game.
