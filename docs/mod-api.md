# Mod API

This is the public prototype API for Immortal Coil dialog bundles and mods.

The API is not package-exported yet. Scripts are currently read and evaluated
with `*package*` bound to `IMMORTAL-COIL`, so mod scripts normally call these
forms by bare name. Treat only the forms documented here as supported. Other
engine functions, accessors, globals, and structs/classes are internal unless
they are promoted into this document.

There is no sandboxing in the prototype. Mod scripts are Lisp code.

## Bundle Manifest

Preferred mod layout:

```text
mods/<mod-id>/manifest.lisp
mods/<mod-id>/story.lisp
mods/<mod-id>/assets/
```

Manifest form:

```lisp
(:id "example-mod"
 :name "Example Mod"
 :version "0.1.0"
 :description "Optional short description."
 :author "Optional author."
 :depends-on ("immortal-coil/base")
 :scripts ("story.lisp")
 :assets "assets/"
 :title-logo "logo/title-logo.png"
 :start "example-mod/start")
```

Fields:

- `:id`: stable bundle ID. Prefer reverse-domain or namespaced IDs for larger mods.
- `:name`: display name.
- `:version`: optional version string.
- `:description`: optional description string.
- `:author`: optional author string.
- `:depends-on`: bundle IDs that should load before this bundle.
- `:scripts`: script path or list of script paths, relative to the manifest.
- `:assets`: asset root path, relative to the manifest.
- `:title-logo`: optional title-screen logo path, relative to the asset root.
- `:start`: optional story start node. `:start-node` and `:root-node` are aliases.

The bundled game is also a bundle. Its ID is `immortal-coil/base`.

## Loading And Conflicts

Load order is deterministic:

- bundled game manifests load first
- player mods load after bundled manifests
- `:depends-on` orders a bundle after its dependencies
- remaining ties use deterministic path order

If a later script defines an existing node ID, the conflict is recorded and the
later node wins. Prefer appending choices or creating new namespaced nodes.

Use namespaced node IDs:

```text
my-mod/opening
my-mod/forest/look-up
```

## Basic Nodes

Set the story start node:

```lisp
(dialog-start "base/awake")
```

Manifests may also set the story start node:

```lisp
(:start "my-mod/start")
```

Ordinary additive mods should usually not call `dialog-start`. Use it for the
bundled game, total conversions, or test bundles that intentionally replace the
entry point. If several bundles set a start node, the latest loaded bundle wins.

Plain text node:

```lisp
(dialog-text "my-mod/start"
             "the room is smaller than you remember."
             :next "my-mod/next")
```

Spoken text node:

```lisp
(dialog-say "my-mod/crewman"
            "crewman"
            "captain {player-name}, we are ready."
            :next "my-mod/next")
```

Patch a node's next link:

```lisp
(dialog-set-next "base/listen" "my-mod/interruption")
```

Use `dialog-set-next` sparingly. Prefer adding choices or writing new nodes
unless the mod intentionally changes an existing path.

## Choices

Horizontal yes/no style choice:

```lisp
(dialog-choice "my-mod/choice"
               "exit bed?"
               (dialog-option "yes" "my-mod/yes")
               (dialog-option "no" "my-mod/no"))
```

Vertical pick:

```lisp
(dialog-pick "my-mod/night-stand"
             "what do you take?"
             (dialog-option "glass of water" "ship/wake")
             (dialog-option "nothing" "my-mod/nothing"))
```

Scrollable list:

```lisp
(dialog-list "my-mod/door"
             "choose a door."
             (dialog-option "north" "my-mod/north")
             (dialog-option "east" "my-mod/east")
             (dialog-option "west" "my-mod/west"))
```

Append a choice to an existing choice node:

```lisp
(dialog-add-choice "base/exit-bed"
                   "look under the bed"
                   "my-mod/under-bed")
```

Conditional options:

```lisp
(dialog-option "use the brass key"
               "my-mod/unlock"
               :when '(dialog-value "has-brass-key"))

(dialog-option "pretend not to know"
               "my-mod/lie"
               :unless '(dialog-value "was-seen"))
```

## Branches

Branch nodes immediately jump to the first matching case:

```lisp
(dialog-branch "my-mod/door-count"
               (dialog-case '(>= (dialog-value "door-count" 0) 5)
                            "my-mod/too-many")
               (dialog-default "my-mod/normal"))
```

Conditions may be:

- `t` or `nil`
- a function object
- a lambda form
- a function form
- a Lisp form to evaluate
- a symbol naming a function or bound variable

Failures are caught and treated as false with a runtime warning.

## Input And Store

Ask for a number:

```lisp
(dialog-number "my-mod/age"
               "what age does the file list?"
               :response-key "player-age"
               :min 0
               :max 130
               :target "my-mod/after-age")
```

Ask for a string:

```lisp
(dialog-string "my-mod/name"
               "what does the room call you?"
               :response-key "player-name"
               :max-length 24
               :target "my-mod/after-name")
```

Read and write the shared dialog store:

```lisp
(dialog-value "player-name" "unknown")

(setf (dialog-value "has-brass-key") t)
```

Remove or inspect store keys:

```lisp
(dialog-store-bound-p "has-brass-key")
(dialog-store-remove "has-brass-key")
```

Text and choice labels substitute store values with `{store-key}`:

```lisp
(dialog-text "my-mod/report"
             "captain {player-name}, the crew is waiting.")
```

If the key is absent, the original `{store-key}` text remains visible.

## Path Helpers

Linear text path:

```lisp
(dialog-path "my-mod/hall"
  "the hallway is too narrow."
  "it has learned your shoulders."
  (:next "my-mod/door"))
```

This creates:

- `my-mod/hall`
- `my-mod/hall/2`

Choice paths:

```lisp
(dialog-pick-path "my-mod/table"
                  "what do you take?"
                  ("glass of water"
                   :id "water"
                   "the glass is cold."
                   (:next "ship/wake"))
                  ("nothing"
                   "your hand returns empty."
                   (:next "my-mod/empty")))
```

Branch options support:

- `:id`: child ID suffix when the label is unstable or too long.
- `:target`: direct target for a branch with no text.
- `:next`: final target after generated text nodes.
- `:when`: option condition.
- `:unless`: inverted option condition.

Available helper macros:

- `dialog-path`
- `dialog-choice-path`
- `dialog-pick-path`
- `dialog-list-path`

## Node Effects

Attach raw enter effects:

```lisp
(dialog-on-enter "my-mod/key"
                 '(setf (dialog-value "has-brass-key") t))
```

Multiple effects may be attached to the same node. Effects run when the node is
entered. If the node does not exist yet, the effects are saved and applied when
the node is later defined.

## Particles

Switch particle field on node entry:

```lisp
(dialog-particles "ship/wake" :stars :fade-seconds 6.5)
(dialog-particles "base/awake" :rising :immediate t)
```

Built-in particle fields:

- `:rising`
- `:stars`
- `:title-menu`

Mods may register a new particle field:

```lisp
(dialog-particle-field-kind :my-mod/wind
                            :reset #'reset-my-wind
                            :ensure #'ensure-my-wind
                            :update #'update-my-wind
                            :draw #'draw-my-wind)
```

Handlers:

- `:reset`: no arguments.
- `:ensure`: no arguments, should make sure backing particles exist.
- `:update`: one argument, frame delta in seconds.
- `:draw`: one argument, alpha scale.

The engine catches handler errors and emits runtime warnings.

## Music And Assets

Resolve an asset path relative to the current bundle:

```lisp
(dialog-asset-pathname "audio/click.wav")
```

Start bundle-local story music on node entry:

```lisp
(dialog-music "forest/threshold"
              "audio/forest-lyria-drone.mp3"
              :volume 0.28)
```

Stop story music on node entry:

```lisp
(dialog-stop-music "base/awake")
```

Keep asset provenance next to committed assets. Do not commit API keys or other
secrets.

## Minigames

Register a minigame kind:

```lisp
(dialog-minigame-kind :my-mod/flight
                      :update #'update-my-flight-node
                      :draw #'draw-my-flight)
```

Reference it from a node:

```lisp
(dialog-minigame "my-mod/flight"
                 "use wasd or arrow keys. keep the ship inside the gates."
                 :game :my-mod/flight
                 :success "my-mod/success"
                 :failure "my-mod/failure")
```

Handlers:

- update handler receives the dialog node and frame delta in seconds.
- draw handler receives the dialog node and a white Claylib color object.

The update handler is responsible for calling `jump-to-node` when the minigame
ends. Use the node's success or failure targets:

```lisp
(jump-to-node (node-success-target node))
(jump-to-node (node-failure-target node))
```

`node-success-target`, `node-failure-target`, and `jump-to-node` are currently
part of the practical minigame API. They should be wrapped in cleaner helpers
later.

## CLOS Extension Points

The engine has CLOS protocols under the function-backed registration forms:

- `minigame-update`
- `minigame-draw`
- `particle-field-reset`
- `particle-field-ensure`
- `particle-field-update`
- `particle-field-draw`

These are provisional advanced extension points. Prefer the function-backed
forms above unless a class-based minigame or particle field removes real
complexity.

## Dev Save Helpers

Set a development save override:

```lisp
(dialog-dev-save "ship/flight"
                 :store '(("player-name" . "dev")
                          ("door-count" . 5))
                 :particle-mode :stars
                 :visible :all)
```

Target the last defined node:

```lisp
(dialog-dev-save-here
 :store '(("player-name" . "dev"))
 :visible :all)
```

Clear an override:

```lisp
(dialog-clear-dev-save)
```

Disable active overrides without editing scripts:

```bash
IMMORTAL_COIL_DISABLE_DEV_SAVE=1
```

Development save overrides are not intended for released mods.

## Environment Variables

- `IMMORTAL_COIL_MOD_DIR`: additional colon-separated mod directories.
- `IMMORTAL_COIL_DISABLE_MODS`: disable mod loading when set to `1`, `true`,
  `yes`, or `on`.
- `IMMORTAL_COIL_SAVE_DIR`: override save directory.
- `IMMORTAL_COIL_DISABLE_DEV_SAVE`: disable dev save overrides when set to `1`,
  `true`, `yes`, or `on`.

## Not Public Yet

These are engine internals for now:

- graph hash tables and node storage globals
- renderer internals
- menu and pause internals
- save serialization details beyond documented dev save helpers
- audio resource caches
- title particle internals
- Claylib low-level calls outside minigame or particle implementations
- ASDF/system layout

If a mod needs one of these, promote a small explicit helper instead of relying
on incidental access.
