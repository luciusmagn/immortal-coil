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

  (deftype seconds ()
    "A duration in seconds."
    'real)

  (deftype scalar ()
    "A numeric scalar used for screen coordinates, interpolation, and opacity."
    'real)

  (deftype command-action ()
    "A keyword command selected by a small engine UI model."
    'keyword)

  (deftype particle-field-mode ()
    "A named full-screen particle field managed by the engine."
    '(member :rising :stars :title-menu)))
