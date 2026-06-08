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

(-> source-designator-name (t) string)
(defun source-designator-name (source)
  (typecase source
    (pathname (namestring source))
    (string source)
    (symbol (string-downcase (symbol-name source)))
    (t (princ-to-string source))))

(defun project-pathname (path)
  (typecase path
    (pathname path)
    (string (merge-pathnames path (project-root-pathname)))
    (t
     (runtime-warn "Expected pathname designator, got: ~s" path)
     (merge-pathnames (princ-to-string path)
                      (project-root-pathname)))))

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
