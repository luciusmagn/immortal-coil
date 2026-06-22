(in-package #:immortal-coil)

(defun clamp01 (value)
  (min 1.0 (max 0.0 value)))

(defun cubic-in (value)
  (let ((x (clamp01 value)))
    (* x x x)))

(defun smoothstep (value)
  (let ((x (clamp01 value)))
    (* x x (- 3.0 (* 2.0 x)))))

(defun random-float (min max)
  (+ min
     (* (- max min)
        (/ (get-random-value 0 10000) 10000.0))))

(defun project-root-pathname ()
  (let ((root (uiop:getenv "IMMORTAL_COIL_ROOT")))
    (if root
        (uiop:ensure-directory-pathname root)
        (asdf:system-source-directory :immortal-coil))))

(defun runtime-warn (control &rest arguments)
  (format *error-output*
          "~&[immortal-coil] ~?~%"
          control
          arguments))

(defgeneric source-designator-name (source)
  (:documentation "Display name for a script or bundle source designator.")
  (:method ((source pathname))
    (namestring source))
  (:method ((source string))
    source)
  (:method ((source symbol))
    (string-downcase (symbol-name source)))
  (:method (source)
    (princ-to-string source)))

(defgeneric project-pathname (path)
  (:documentation "Resolve a path designator against the project root.")
  (:method ((path pathname))
    path)
  (:method ((path string))
    (merge-pathnames path (project-root-pathname)))
  (:method (path)
    (runtime-warn "Expected pathname designator, got: ~s" path)
    (merge-pathnames (princ-to-string path)
                     (project-root-pathname))))

(defgeneric normalize-keyword-designator (value)
  (:documentation "Coerce a keyword designator to a keyword, else nil.")
  (:method ((value symbol))
    (if (keywordp value)
        value
        (intern (string-upcase (symbol-name value)) "KEYWORD")))
  (:method ((value string))
    (intern (string-upcase value) "KEYWORD"))
  (:method (value)
    (declare (ignore value))
    nil))

(defgeneric resolve-function-designator (handler)
  (:documentation "Resolve a function designator to a function, else nil.")
  (:method ((handler function))
    handler)
  (:method ((handler symbol))
    (when (fboundp handler)
      (symbol-function handler)))
  (:method ((handler cons))
    (let ((value (eval handler)))
      (when (functionp value)
        value)))
  (:method (handler)
    (declare (ignore handler))
    nil))

(-> estimated-text-width (string nonnegative-integer) nonnegative-integer)
(defun estimated-text-width (text size)
  (round (* (length text) size 0.58)))

(-> text-width (string nonnegative-integer) nonnegative-integer)
(defun text-width (text size)
  (if (zerop (length text))
      0
      (let ((measured-width (measure-text text size)))
        (if (plusp measured-width)
            measured-width
            (estimated-text-width text size)))))

(defun draw-text-at (text x y size color)
  (claylib/ll:draw-text text
                        (round x)
                        (round y)
                        size
                        (claylib::c-ptr color)))

(defvar *draw-color* (make-color 255 255 255 255))

(-> draw-color-ptr (integer integer integer &optional integer) t)
(defun draw-color-ptr (red green blue &optional (alpha 255))
  (setf (r *draw-color*) red
        (g *draw-color*) green
        (b *draw-color*) blue
        (a *draw-color*) alpha)
  (claylib::c-ptr *draw-color*))

(defun yellow-sign-color (&optional (alpha 255))
  "The one sanctioned colour in the black-and-white game: the King in
Yellow's #ffff00. Used only to mark the yellow path so it stands out."
  (make-color 255 255 0 alpha))

(-> draw-rectangle-outline
    (scalar scalar scalar scalar t &key (:thickness nonnegative-integer))
    t)
(defun draw-rectangle-outline (left top width height color &key (thickness 1))
  (let* ((x    (round left))
         (y    (round top))
         (w    (round width))
         (h    (round height))
         (line (max 1 (round thickness)))
         (line (min line w h))
         (ptr  (claylib::c-ptr color)))
    (when (and (plusp w)
               (plusp h)
               (plusp line))
      (claylib/ll:draw-rectangle x y w line ptr)
      (when (> h line)
        (claylib/ll:draw-rectangle x
                                   (+ y (- h line))
                                   w
                                   line
                                   ptr))
      (let ((middle-height (- h (* 2 line))))
        (when (plusp middle-height)
          (claylib/ll:draw-rectangle x
                                     (+ y line)
                                     line
                                     middle-height
                                     ptr)
          (when (> w line)
            (claylib/ll:draw-rectangle (+ x (- w line))
                                       (+ y line)
                                       line
                                       middle-height
                                       ptr)))))))

(defun draw-centered-text (text center-x center-y size color)
  (let* ((width (text-width text size))
         (x (- center-x (/ width 2)))
         (y (- center-y (/ size 2))))
    (draw-text-at text x y size color)
    (values x y width)))

(defun virtual-screen-scale ()
  (min (/ (float (get-screen-width) 1.0) +virtual-width+)
       (/ (float (get-screen-height) 1.0) +virtual-height+)))

(defun screen-to-virtual (x y)
  (let* ((scale (virtual-screen-scale))
         (target-width (* +virtual-width+ scale))
         (target-height (* +virtual-height+ scale))
         (offset-x (/ (- (get-screen-width) target-width) 2))
         (offset-y (/ (- (get-screen-height) target-height) 2)))
    (values (/ (- x offset-x) scale)
            (/ (- y offset-y) scale))))

(defun virtual-mouse-position ()
  (screen-to-virtual (get-mouse-x) (get-mouse-y)))

(defun virtual-mouse-x ()
  (multiple-value-bind (x y)
      (virtual-mouse-position)
    (declare (ignore y))
    x))

(defun virtual-mouse-y ()
  (multiple-value-bind (x y)
      (virtual-mouse-position)
    (declare (ignore x))
    y))

(defun draw-line-between (x1 y1 x2 y2 color)
  (claylib/ll:draw-line (round x1)
                        (round y1)
                        (round x2)
                        (round y2)
                        (claylib::c-ptr color)))

(defun single-float-value (value)
  (coerce value 'single-float))

(defun make-vector2f (x y)
  (make-vector2 (single-float-value x)
                (single-float-value y)))

(defun draw-thick-line-between (x1 y1 x2 y2 color thickness)
  (let ((start (make-vector2f x1 y1))
        (end   (make-vector2f x2 y2)))
    (claylib/ll:draw-line-ex (claylib::c-ptr start)
                              (claylib::c-ptr end)
                              (single-float-value thickness)
                              (claylib::c-ptr color))))

(defun draw-triangle-points (x1 y1 x2 y2 x3 y3 color &key filled-p)
  (let ((v1 (make-vector2f x1 y1))
        (v2 (make-vector2f x2 y2))
        (v3 (make-vector2f x3 y3)))
    (if filled-p
        (claylib/ll:draw-triangle (claylib::c-ptr v1)
                                  (claylib::c-ptr v2)
                                  (claylib::c-ptr v3)
                                  (claylib::c-ptr color))
        (claylib/ll:draw-triangle-lines (claylib::c-ptr v1)
                                        (claylib::c-ptr v2)
                                        (claylib::c-ptr v3)
                                        (claylib::c-ptr color)))))
