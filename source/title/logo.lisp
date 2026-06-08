(in-package #:immortal-coil)

(defvar *title-logo-texture-asset* nil)
(defvar *title-logo-image-asset* nil)
(defvar *title-logo-texture* nil)
(defvar *title-logo-sample-color* (make-color 0 0 0 255))

(-> fallback-title-logo-path () pathname)
(defun fallback-title-logo-path ()
  (project-pathname "assets/logo/title-logo.png"))

(-> configured-title-logo-path () pathname)
(defun configured-title-logo-path ()
  (handler-case
      (or (loop with winner = nil
                for bundle in (configured-dialog-bundles)
                for logo = (dialog-bundle-title-logo bundle)
                when logo
                  do (setf winner logo)
                finally (return winner))
          (fallback-title-logo-path))
    (error (condition)
      (runtime-warn "Could not resolve configured title logo: ~a" condition)
      (fallback-title-logo-path))))

(defun title-logo-image-ready-p ()
  (and *title-logo-image-asset*
       (plusp (width *title-logo-image-asset*))
       (plusp (height *title-logo-image-asset*))))

(defun title-logo-loaded-p ()
  (and *title-logo-texture*
       (title-logo-image-ready-p)
       (plusp (title-logo-height))))

(defun title-logo-height ()
  (if (and *title-logo-texture-asset*
           (plusp (width *title-logo-texture-asset*)))
      (* +title-logo-width+
         (/ (height *title-logo-texture-asset*)
            (float (width *title-logo-texture-asset*) 1.0)))
      0.0))

(defun title-logo-left ()
  (- +virtual-center-x+ (/ +title-logo-width+ 2.0)))

(defun title-logo-top ()
  +title-logo-y+)

(-> load-title-logo-from-path (pathname) boolean)
(defun load-title-logo-from-path (path)
  (cond
    ((not (probe-file path))
     (runtime-warn "Title logo does not exist: ~a" path)
     nil)
    (t
     (handler-case
         (progn
           (clear-title-logo)
           (setf *title-logo-texture-asset* (make-texture-asset path :load-now t)
                 *title-logo-image-asset* (make-image-asset path :load-now t)
                 *title-logo-texture* nil)
           (setf *title-logo-texture*
                 (make-texture *title-logo-texture-asset*
                               (title-logo-left)
                               (title-logo-top)
                               :width +title-logo-width+
                               :height (title-logo-height)
                               :tint (make-color 255 255 255 255)))
           t)
       (error (condition)
         (runtime-warn "Could not load title logo ~a: ~a" path condition)
         (clear-title-logo)
         nil)))))

(-> load-title-logo () boolean)
(defun load-title-logo ()
  (let ((path (configured-title-logo-path))
        (fallback (fallback-title-logo-path)))
    (or (load-title-logo-from-path path)
        (and (not (equal (namestring path) (namestring fallback)))
             (load-title-logo-from-path fallback)))))

(defun clear-title-logo ()
  (setf *title-logo-texture-asset* nil
        *title-logo-image-asset* nil
        *title-logo-texture* nil))

(defun draw-title-logo (&optional (alpha-scale 1.0))
  (when *title-logo-texture*
    (setf (tint *title-logo-texture*)
          (make-color 255 255 255 (round (* 255 (clamp01 alpha-scale)))))
    (draw-object *title-logo-texture*)))

(defun title-logo-point-image-coordinates (x y)
  (when (title-logo-loaded-p)
    (let* ((left (title-logo-left))
           (top (title-logo-top))
           (height (title-logo-height))
           (local-x (/ (- x left) +title-logo-width+))
           (local-y (/ (- y top) height)))
      (when (and (<= 0.0 local-x 1.0)
                 (<= 0.0 local-y 1.0))
        (let ((image-width (width *title-logo-image-asset*))
              (image-height (height *title-logo-image-asset*)))
          (values (min (1- image-width)
                       (max 0 (floor (* local-x image-width))))
                  (min (1- image-height)
                       (max 0 (floor (* local-y image-height))))))))))

(defun title-logo-white-at-p (x y)
  (handler-case
      (multiple-value-bind (image-x image-y)
          (title-logo-point-image-coordinates x y)
        (when image-x
          (claylib/ll:get-image-color
           (claylib::c-ptr *title-logo-sample-color*)
           (claylib::c-ptr (asset *title-logo-image-asset*))
           image-x
           image-y)
          (> (+ (r *title-logo-sample-color*)
                (g *title-logo-sample-color*)
                (b *title-logo-sample-color*))
             520)))
    (error (condition)
      (runtime-warn "Could not sample title logo: ~a" condition)
      nil)))

(defun title-logo-particle-color (x y alpha)
  (if (title-logo-white-at-p x y)
      (make-color 0 0 0 alpha)
      (make-color 255 255 255 alpha)))
