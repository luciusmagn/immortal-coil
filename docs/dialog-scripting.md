# Dialog Scripting Helpers

The primitive graph forms still exist:

```lisp
(dialog-text "base/awake" "you awake..." :next "base/feel")
(dialog-pick "base/choice"
             "which way?"
             (dialog-option "left" "base/left"))
```

For common prose-heavy choice paths, use the pattern helpers.

## Paths

`dialog-path` defines a linear run of text nodes. The first node uses the ID
you give it. Later nodes use predictable child IDs:

```lisp
(dialog-path "base/walk"
  "you find the hallway."
  "it finds you back."
  (:next "base/door"))
```

This creates:

- `base/walk`
- `base/walk/2`

The last node points to `base/door`.

## Choice Paths

`dialog-choice-path`, `dialog-pick-path`, and `dialog-list-path` define a
choice node plus short child paths. Option IDs default to
`parent/sanitized-label`.

```lisp
(dialog-pick-path "base/night-stand"
                  "what do you take?"
                  ("glass of water"
                   :id "glass"
                   "the glass is cold."
                   (:next "ship/wake"))
                  ("nothing"
                   "your hand returns empty."))
```

This creates option targets:

- `base/night-stand/glass`
- `base/night-stand/nothing`

Use `:id` when the label is long or likely to change. Use `:target` on an
option with no text to point directly to an existing node. If an option has text,
`:target` is treated as the path's final `:next`.

Conditions work like normal choices:

```lisp
("hinges"
 :when #'(lambda ()
           (>= (dialog-value "door-count" 0) 5))
 "the hinges count themselves out loud.")
```

`:when` and `:unless` hide a choice option. Use `:enabled-when` or
`:enabled-unless` to keep it visible but locked until the predicate passes:

```lisp
("service hatch"
 :enabled-when '(dialog-value "has-crowbar")
 "the hatch opens with a sound like a bad tooth.")
```

The visual editor expands these helpers into ordinary graph nodes when reading a
script. Export still writes primitive `dialog-*` forms.

## Dev Save Override

For development, a script can contain one top-level save override. Move it near
the node you want to test and use New Game. Continue also prefers the override
after the graph has been loaded.

```lisp
(dialog-dev-save "ship/flight"
                 :store '(("player-name" . "dev")
                          ("door-count" . 5))
                 :particle-mode :stars
                 :visible :all)
```

When placed directly after a node, this shorter form targets the last node that
was defined:

```lisp
(dialog-dev-save-here
 :store '(("player-name" . "dev"))
 :visible :all)
```

Disable active overrides without editing the script by setting:

```bash
IMMORTAL_COIL_DISABLE_DEV_SAVE=1
```

## Bundle Assets

Each script runs inside a dialog bundle. The bundled game and player mods use
the same manifest format, so scripts should resolve local files through the
current bundle:

```lisp
(dialog-asset-pathname "audio/click.wav")
```

The path is resolved under the bundle's manifest `:assets` directory.

## Minigames

Minigames are registered by scripts too:

```lisp
(dialog-minigame-kind :wire-flight
                      :update #'update-flight-minigame-node
                      :draw #'draw-flight-minigame)
```

Nodes then reference the registered kind:

```lisp
(dialog-minigame "ship/flight"
                 "keep the ship inside the gates."
                 :game :wire-flight
                 :success "ship/threaded"
                 :failure "ship/crash-return")
```
