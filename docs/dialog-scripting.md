# Dialog Scripting Helpers

The primitive graph forms still exist:

```lisp
(dialog-text "base/awake" "you awake..." :next "base/feel")
(dialog-pick "base/choice"
             "which way?"
             (dialog-option "left" "base/left"))
```

For common prose-heavy branches, use the pattern helpers.

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
choice node plus short child paths. Branch IDs default to
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

Use `:id` when the label is long or likely to change. Use `:target` on a branch
with no text to point directly to an existing node. If a branch has text,
`:target` is treated as the path's final `:next`.

Conditions work like normal choices:

```lisp
("hinges"
 :when #'(lambda ()
           (>= (dialog-value "door-count" 0) 5))
 "the hinges count themselves out loud.")
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
