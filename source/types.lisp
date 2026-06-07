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

  (deftype menu-action ()
    "Top-level title menu command."
    '(member :new-game :continue :mods :exit))

  (deftype menu-direction ()
    "Horizontal menu movement direction."
    '(member -1 1))

  (deftype dialog-id ()
    "Canonical node and response-key identifier used by dialog scripts."
    'string)

  (deftype dialog-source ()
    "A script/mod source marker for conflict reports."
    '(or pathname string symbol))

  (deftype node-kind ()
    "Dialog node behavior handled by the runtime."
    '(member :text :choice :number :string :minigame :branch))

  (deftype choice-layout ()
    "Choice presentation style."
    '(member :horizontal :vertical :list))

  (deftype dialog-conflict-resolution ()
    "Recorded policy for one dialog graph conflict."
    '(member :latest-wins))

  (deftype dialog-store-key ()
    "A key in the shared dialog/mod state store."
    '(or string symbol))

  (deftype dialog-script-origin ()
    "Where a dialog script source came from."
    '(member :bundled :mod))

  (deftype particle-field-mode ()
    "A named full-screen particle field managed by the engine."
    '(member :rising :stars :title-menu)))
