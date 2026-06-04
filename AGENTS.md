# Repository Guidelines

## Project Shape

Immortal Coil is a Common Lisp / Claylib narrative-game prototype. The current goal is to keep the first playable loop small: story nodes, typewriter text, choices, sound, shaders, and hot-reload-friendly code. Avoid turning this into a storage or engine architecture project before the narrative loop is proven.

## Common Lisp Style

- Prefer clear, boring, established Common Lisp over clever low-level tricks.
- Keep functions small and purpose-named, even when a helper is only used once.
- Use CLOS where it naturally models the domain, but do not add abstractions before they remove real complexity.
- Prefer `first` and `rest` over `car` and `cdr` in application-level code.
- Use `kebab-case` for functions and variables, `+snake-case+` for constants, and `*snake-case*` for special variables.
- Use entity-prefixed function names when a domain concept exists, such as `node-find`, `scene-load`, or `renderer-register`.
- For functions with four or more parameters, prefer keyword arguments over long positional lambda lists.
- In `format` strings, literal percent signs are plain `%`; do not write `%%`.
- Prefer specific `:import-from` package imports as files mature. It is fine for the small initial prototype to `:use` `#:cl` and `#:claylib`, but tighten package imports once the code starts splitting into modules.

## Formatting

- Align related slot definitions, let bindings, and keyword arguments when it improves readability.
- Leave one blank line between function definitions.
- Leave two blank lines between major sections if a file grows enough to need sections.
- Put conditional branch bodies on their own line when the branch does nontrivial work.
- Avoid trailing whitespace.

Example:

```lisp
(let* ((current-node (game-current-node game))
       (choices      (node-choices current-node))
       (selected     (game-selected-index game)))
  ...)
```

## Code Organization

- Keep boot code as boot code. `source/main.lisp` may wire startup and the tiny prototype, but split story data, rendering, audio, and graph/mod logic into focused files as they grow.
- Prefer module trees over monoliths once a file mixes unrelated concerns.
- Split by coherent workflow or domain concept, not generic `misc` or `helpers` files.
- Preserve public entry points when splitting files so hot reload and REPL workflows stay simple.
- Keep rendering code separate from story/domain data once the renderer becomes more than the initial prototype.

## Runtime And Hot Reload

- Use Common Lisp reloadability as a development advantage: prefer rebuilding in-memory story state from data over mutating complicated global structures in place.
- For incompatible class/struct changes, expect that a clean restart may be needed even if normal function reloads work.
- GPU/audio resources are external resources; reload paths must explicitly unload or replace them when needed.

## Claylib Notes

- Claylib is installed in `~/quicklisp/local-projects/claylib`.
- Check Claylib source before assuming a wrapper exists. Some exported low-level names may not have live function definitions in this local checkout.
- For sound playback in this project, call `claylib/ll:play-sound` directly instead of the high-level `play` generic until Claylib's `play-sound-multi` mismatch is fixed upstream or locally.

## Assets

- Keep asset provenance next to assets in a credits or license file.
- Prefer CC0/public-domain assets for early prototypes to avoid attribution friction.
- Do not embed unlicensed or unclear assets.

## Verification

- After code changes, at least load the system:

```bash
ASDF_OUTPUT_TRANSLATIONS=/root/common-lisp/immortal-coil/:/tmp/immortal-coil-fasl/ \
  sbcl --noinform --non-interactive \
    --eval '(require :asdf)' \
    --eval '(asdf:load-system :immortal-coil)'
```

- When the change touches rendering, shaders, input, or audio, also run the game manually if a display/audio device is available.

## Commit Preferences

- Keep commits tiny, granular, and single-purpose.
- Prefer one commit per feature slice or regression fix.
- Use primitive title-only commit messages under 72 characters.
- Prefer rebase over merge; avoid merge commits.
- Do not bundle unrelated refactors with feature work just because the files are nearby.
