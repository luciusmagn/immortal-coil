(in-package #:immortal-coil)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (deftype option (inner-type)
    "Either NIL or a value of INNER-TYPE."
    `(or null ,inner-type))

  (-> plistp (t) boolean)
  (defun plistp (value)
    "Return T when VALUE is an even-length property list with keyword keys."
    (and (listp value)
         (evenp (length value))
         (loop for key in value by #'cddr
               always (keywordp key))))

  (deftype plist ()
    "A keyword property list."
    '(satisfies plistp))

  (deftype list-of (element-type)
    "A proper list whose elements are all of ELEMENT-TYPE."
    `(serapeum:soft-list-of ,element-type))

  (deftype nonnegative-integer ()
    "An integer greater than or equal to zero."
    '(integer 0 *))

  (deftype alpha-channel ()
    "An 8-bit opacity value."
    '(integer 0 255))

  (deftype seconds ()
    "A duration in seconds."
    'real)

  (deftype scalar ()
    "A numeric scalar used for screen coordinates, interpolation, and opacity."
    'real)

  (deftype command-action ()
    "A keyword command selected by a small engine UI model."
    'keyword)

  (deftype navigation-direction ()
    "A discrete one-step UI selection movement."
    '(member -1 1))

  (deftype menu-action ()
    "Top-level title menu command."
    '(member :new-game :continue :mods :exit))

  (deftype menu-direction ()
    "Horizontal menu movement direction."
    'navigation-direction)

  (deftype pause-action ()
    "Pause menu command."
    '(member :resume :menu :quit))

  (deftype pause-direction ()
    "Pause menu movement direction."
    'navigation-direction)

  (deftype dialog-id ()
    "Canonical node and response-key identifier used by dialog scripts."
    'string)

  (deftype dialog-source ()
    "A script/mod source marker for conflict reports."
    '(or pathname string symbol))

  (deftype node-kind ()
    "Dialog node behavior handled by the runtime."
    '(member :text :say :choice :number :string :minigame :branch))

  (deftype minigame-id ()
    "A named minigame implementation selected by dialog nodes."
    'keyword)

  (deftype choice-layout ()
    "Choice presentation style."
    '(member :horizontal :vertical :list))

  (deftype runtime-function ()
    "A live function object."
    '(satisfies functionp))

  (deftype dialog-condition ()
    "Permissive script condition accepted by the dialog runtime."
    '(or null symbol runtime-function cons))

  (deftype dialog-effect ()
    "Script effect evaluated when a node is entered."
    '(or symbol runtime-function cons))

  (deftype dialog-pattern-branch-data ()
    "A parsed choice-branch pattern used by graph authoring macros."
    'plist)

  (deftype dialog-conflict-resolution ()
    "Recorded policy for one dialog graph conflict."
    '(member :latest-wins))

  (deftype dialog-store-key ()
    "A key in the shared dialog/mod state store."
    '(or string symbol))

  (deftype save-data ()
    "Versioned save plist used by disk saves and dev-save overrides."
    'plist)

  (deftype dialog-script-origin ()
    "Where a dialog script source came from."
    '(member :bundled :mod))

  (deftype dialog-bundle-id ()
    "A stable ID for a bundled game script set or player mod."
    'string)

  (deftype dialog-bundle-dependencies ()
    "Stable bundle IDs that should load before a dialog bundle."
    '(list-of dialog-bundle-id))

  (deftype particle-field-mode ()
    "A named full-screen particle field managed by the engine."
    'keyword)

  (deftype particle-field-save-data ()
    "A save plist for the active particle field and transition."
    'plist)

  (deftype flight-gate-index ()
    "A nonnegative wire-flight gate index."
    'nonnegative-integer))
