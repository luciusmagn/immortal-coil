# Repository Guidelines

## Project Shape

Immortal Coil is a Common Lisp / Claylib narrative-game prototype. The current goal is to keep the first playable loop small: story nodes, typewriter text, choices, sound, shaders, and hot-reload-friendly code. Avoid turning this into a storage or engine architecture project before the narrative loop is proven.

The core idea is an always-branching narrative game. "Dialogue tree" is useful industry shorthand, but the implementation may be a graph when it needs shared nodes, conditions, or mod extension points. Player choice should create the narrative rather than reveal one fixed plot. The tree can diverge into other genres, including minigames or alternate presentation modes, but those shifts should be authored through the same dialogue/mod surface where possible.

Do not introduce LMDB, HAMTs, persistent graph databases, or other heavy storage structures until a concrete proven need appears. Plain Lisp data, script reloads, and focused save data are the right default for now.

## Narrative Direction

- Preserve player blindness. Do not announce time loops, count loops, or explain genre pivots before the player has earned them.
- Detailed built-in path notes live in `docs/narrative.md`. Update that file when changing a path premise, reveal, or major hook point.
- The core narrative tool is that the future shapes the past by supplying context, details, surroundings, names, roles, or relationships that make earlier scenes mean different things on different paths.
- Narrate as if the earlier scene was always what the later path reveals; the player only lacked the perspective or context to understand it.
- Branch transitions must be gentle enough that a player on a single playthrough would not recognize them as transitions. A branch entry should feel like the next ordinary detail in the same situation; only later context or another route should reveal that it carried the story somewhere else.
- Prefer revelation over transformation: when a scene changes meaning, it should feel like it was always that thing, not like the game visibly morphed it for the player's benefit.
- Avoid prose that says reality changes because the player acted: no doors becoming other objects, corridors folding shut, or things waiting to transform on cue. Use newly revealed context instead.
- Prefer plain, concrete prose over deliberately paradoxical or purple mystery language. The situations can be mysterious by themselves; do not lean on stock phrases where rooms, shadows, silence, or objects behave mysteriously just to sound ominous.
- Keep prose and interface sparse. The game can become strange, but it should not explain its own cleverness.
- In the ship-captain path, the player is a stressed captain on a large hard-sci-fi ship, near a breaking point and caught in time loops. From the crew's perspective, the captain is impeccable and almost mythic because every visible decision is correct and the crew is saved from every crisis.
- The truth of the ship-captain path is private: the captain keeps failing, dying, looping, and carrying the pain forward. The loop should feel like hidden labor and trauma, not a power fantasy.
- Crew praise should become painful through context. The crew sees the final polished result; the player remembers the failed attempts that made it possible.
- Hallucinations in the ship path should read as memory intrusions from previous loops, such as seeing a living crew member as they died before. Do not frame these as ghosts, prophecies, or reality changing in front of the player.
- Expand the campaign as a diverging built-in mod, not as privileged engine logic. Current planned path families include the hard-sci-fi ship captain loop, a dark-forest escape/hunted path, a seemingly bog-standard JRPG demon-lord quest, an Alice-in-Wonderland-style dream path, a Rogue-inspired dungeon path, a nation-leader-in-war path, and a containment-researcher path.
- Do not use literal loops as a narrative solution. Even the ship captain "loop" should not feel like the game mechanically looping; it should read as private accumulated death-memory and repeated failure revealed through context.
- The dark-forest path begins as leaving a house in the middle of a black forest and surviving pursuit. The later reveal is that the player was kidnapped and has unwittingly escaped confinement; the pursuer is the kidnapper, possibly supernatural. Do not tell the player this early, and do not frame the house as transforming.
- The JRPG path should initially read as a straight-faced genre branch: inn, village, party, demon lord. Its later value is how that familiar frame can recontextualize the same opening room and inventory without announcing the trick.
- Dream-maze exits are good portals into divergent dream genres. At least one exit should lead toward an Alice-in-Wonderland-style branch, and another toward a Rogue-inspired dungeon branch.
- The refuse-all path through door counting and hall sounds should become a nation-leader-in-war path. The room may later read as a bunker, command residence, cabinet room, or emergency office. Emphasize abstract command, propaganda, incomplete information, and decisions made from behind doors and reports.
- The dream right-exit and maze-lost path should become a containment-researcher path. Use institutional language, procedures, logs, classifications, access levels, observation rooms, and facility corridors to recontextualize earlier weirdness. A sparse black-and-white demake-style flash of an SCP-Foundation-like circular logo may be used as a brief visual institutional mark, but do not import or explain external canon in prose.
- New path transitions should never be abrupt title-card reveals. Let ordinary details, forms of address, room details, props, sounds, and procedures accumulate until the player understands the new context.
- The shared dialog store exists so scripts and mods can remember facts such as names, choices, inventory, age, or hidden flags. Conditions may read this store or evaluate explicit lambdas.
- Text substitution is part of the authoring model. Later nodes should be able to refer to values collected earlier.

## Visual Identity

- The game should read as pure black and white. Phosphor tint from CRT/bloom shaders is acceptable, but do not introduce normal color palettes without an explicit reason.
- The visual baseline is the original `mags_game` beginning: stark text, CRT treatment, bloom, typewriter pacing, and a haunted terminal-like feel.
- CRT effects should be strong enough to be felt but should not distort central text into unreadability. Curvature, bloom, and antialiasing need manual visual checks after changes.
- Rising particles are small, identical white squares that drift upward slowly and wobble side to side like sparks or gas in a falling-sand simulation. They should usually cross beyond the viewport instead of fading out halfway.
- Star particles represent the spaceship path. They should be tiny white glints, mostly 1px, with occasional brighter/bigger shimmer. Keep them subtle and slow.
- The title screen menu is part of the fiction: particles rise from below like a trunk, orbit the current menu option, and leave upward like branches. Menu arrows are filled white triangles outside the orbit circle, with bloom, press response, and small oscillation.

## Audio Direction

- Dialogue text should type with alternating typewriter or Model M-like key sounds. Avoid one repeated click sample.
- Menu confirmation sounds should feel substantial, especially starting or continuing a game.
- The title music should be a long, drawn-out, beatless drone. Avoid obvious drums, snare, jingle-bell rhythm, or loop stitching that calls attention to itself.
- Raylib music streams are fed from the main loop with `update-music-stream`. Avoid expensive frame work during music playback, because stalls can cause small skips.
- Prefer loaded WAV sound effects for short UI sounds. For music, test whether MP3 streaming is stable enough before assuming skips are acceptable.

## Dialogue And Mods

- Dialogue scripts under `game/` should use the same public surface that mods will use. Do not hide special core-only powers unless there is a real engine boundary reason.
- The bundled game dialogue is just the built-in dialog script set. It should load through the same script source/eval path as player mods; only provenance and deterministic load order should differ.
- The bundled game title logo and story root should be declared in `game/manifest.lisp` through the same manifest metadata available to mods. Mods can use `:title-logo` and `:start` for total conversions; deterministic latest-wins load order decides which one is active.
- Mods are expected to append choices and nodes to base story nodes and to nodes from other mods.
- Namespaced node IDs such as `some-mod/opening` are preferred. Intentional replacement should be rare.
- Do not add pure branch/router node kinds. Nodes should be authored experiences such as dialogue, input, choices, conversations, or minigames. Conditional traversal belongs on outgoing choices, node targets, or explicit target delegates.
- Current conflict policy is deterministic latest-wins with conflicts recorded and surfaced in the menu. Future "negotiation" should build on that record rather than making conflicts silent.
- A mod manager screen can grow later, but keep the first official mod support simple and visible from the menu.
- No sandboxing is currently required. Treat that as a conscious prototype tradeoff, not as a forgotten security design.
- Helper macros for common patterns are welcome when they make authoring dialogue easier: linear paths, choices with generated child IDs, common branches, and test-only dev save overrides.
- The visual editor should avoid forcing authors to write full Common Lisp into tiny fields. Prefer predefined condition/effect templates with focused fill-in fields, while still allowing escape hatches for Lisp.
- The old Nim web editor was removed after the in-game editor became the supported authoring path. Do not reintroduce a parallel web editor unless there is a concrete reason.

## Gameplay And UI

- `Escape` should open a pause menu, not close the game.
- Fullscreen controls should not fire while a text or number input is active.
- Start-game transitions should be deliberate: confirmation feedback, slow fade out, slow fade in, and delayed typing. Avoid abrupt cuts into the first dialogue node.
- Main-menu navigation uses left/right arrows to cycle a single central option. Do not add redundant underlines or extra chrome unless it improves usability.
- When there are too many vertical choices, show a scrollbar or equivalent overflow indicator.
- Minigames need clear controls and enough readability that failure feels like play, not confusion.
- Any minigame or interaction that supports WASD movement must also support arrow keys and say so in its control text.

## Common Lisp Style

- Prefer clear, boring, established Common Lisp over clever low-level tricks.
- Keep functions small and purpose-named, even when a helper is only used once.
- Use CLOS where it naturally models the domain, but do not add abstractions before they remove real complexity.
- TODO: move repeated node-kind dispatch toward CLOS methods when it reduces complexity. Good candidates are node write/persist behavior, editor panels, draw/update behavior, and current `editor-write-...` or `case`-based node handling. Do this deliberately, not as a broad rewrite.
- Prefer `first` and `rest` over `car` and `cdr` in application-level code.
- Use `kebab-case` for functions and variables, `+snake-case+` for constants, and `*snake-case*` for special variables.
- Use entity-prefixed function names when a domain concept exists, such as `node-find`, `scene-load`, or `renderer-register`.
- For functions with four or more parameters, prefer keyword arguments over long positional lambda lists.
- In `format` strings, literal percent signs are plain `%`; do not write `%%`.
- Prefer specific `:import-from` package imports as files mature. It is fine for the small initial prototype to `:use` `#:cl` and `#:claylib`, but tighten package imports once the code starts splitting into modules.
- Use Serapeum `->` signatures and concrete `deftype` vocabulary for engine/domain code where it clarifies contracts. Keep dialogue graph scripts under `game/` lightweight and do not pollute author-facing story data with type ceremony.

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
- Repeated filename prefixes under `source/` should become directories instead of remaining flat files. For example, use module directories such as `audio/`, `dialog/`, `graph/`, `minigame/`, `mod/`, `menu/`, `particles/`, `pause/`, `play-state/`, `save/`, and `title/`. Nested prefixes should become nested directories, such as `dialog/bundle/` or `particles/field/`. Apply the same rule recursively inside `game/` and tool source trees when several files in one directory start with the same domain word.
- Split by coherent workflow or domain concept, not generic `misc` or `helpers` files.
- Do not split so mechanically that every tiny model, store, or hook gets its own file. If a group is tightly coupled and small, prefer one sectioned file inside the right module directory.
- After a folder reorganization, check for remaining same-prefix collisions in the touched directories before committing. Either nest them, rename them to their actual concept, or intentionally leave a short note when the collision is meaningful.
- Preserve public entry points when splitting files so hot reload and REPL workflows stay simple.
- Keep rendering code separate from story/domain data once the renderer becomes more than the initial prototype.
- The project owner dislikes large source files. Split when a file starts mixing domains or becomes hard to reason about, but keep each split tied to an actual workflow.
- Concrete main-game content, including main-game minigames such as wire-flight, belongs under `game/` and should load through the bundled game manifest instead of living as special engine code under `source/` or ASDF. The bundled game is the first dogfood mod, not a privileged engine extension.

## Runtime And Hot Reload

- Use Common Lisp reloadability as a development advantage: prefer rebuilding in-memory story state from data over mutating complicated global structures in place.
- For incompatible class/struct changes, expect that a clean restart may be needed even if normal function reloads work.
- GPU/audio resources are external resources; reload paths must explicitly unload or replace them when needed.
- Prefer robust runtime warnings and safe fallbacks over dropping into the debugger during normal play. Narrative scripts, mods, saves, audio, and rendering paths should be defensive.
- Graph and mod reloads should be explicit enough that developers can test a node quickly, including with a top-level dev save override form that can be moved around during development.

## Claylib Notes

- Claylib is installed in `~/quicklisp/local-projects/claylib`.
- Check Claylib source before assuming a wrapper exists. Some exported low-level names may not have live function definitions in this local checkout.
- For sound playback in this project, call `claylib/ll:play-sound` directly instead of the high-level `play` generic until Claylib's `play-sound-multi` mismatch is fixed upstream or locally.

## Assets

- Keep asset provenance next to assets in a credits or license file.
- Prefer CC0/public-domain assets for early prototypes to avoid attribution friction.
- Do not embed unlicensed or unclear assets.
- Dialogue bundles, including the bundled game, should have a manifest that
  declares script files and an asset root. Resolve bundle-local files through
  `dialog-asset-pathname` instead of hardcoding project-global paths in scripts
  or mods.
- Generated music and sound assets should be documented with model/provider/source details where possible. Do not commit secrets such as OpenRouter keys; keep them in `.env`.

## Release And Packaging

- Nix is the preferred path for reproducible builds.
- Linux binaries should eventually target Steam distribution constraints, not only the local dev machine.
- Windows builds are a future requirement for Steam. Treat cross-platform packaging as important, but do not let it derail the current playable loop.
- TODO: replace Perl-based release shim scanners with Common Lisp tooling. The current checks work, but release verification should eventually be written in the project's own language instead of ad hoc Perl scripts and one-liners.

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
- Push after every commit unless the user explicitly says not to.
