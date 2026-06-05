(in-package #:immortal-coil)

(defvar *title-logo-texture-asset* nil)
(defvar *title-logo-image-asset* nil)
(defvar *title-logo-texture* nil)
(defvar *title-logo-sample-color* (make-color 0 0 0 255))

(defun title-logo-path ()
  (asdf:system-relative-pathname
   :immortal-coil
   "assets/logo/title-logo.png"))

(defun title-logo-loaded-p ()
  (and *title-logo-texture*
       *title-logo-image-asset*))

(defun title-logo-height ()
  (if *title-logo-texture-asset*
      (* +title-logo-width+
         (/ (height *title-logo-texture-asset*)
            (float (width *title-logo-texture-asset*) 1.0)))
      0.0))

(defun title-logo-left ()
  (- +virtual-center-x+ (/ +title-logo-width+ 2.0)))

(defun title-logo-top ()
  +title-logo-y+)

(defun load-title-logo ()
  (let ((path (title-logo-path)))
    (when (probe-file path)
      (setf *title-logo-texture-asset* (make-texture-asset path :load-now t)
            *title-logo-image-asset* (make-image-asset path :load-now t)
            *title-logo-texture* nil)
      (setf *title-logo-texture*
            (make-texture *title-logo-texture-asset*
                          (title-logo-left)
                          (title-logo-top)
                          :width +title-logo-width+
                          :height (title-logo-height)
                          :tint (make-color 255 255 255 255))))))

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
        (values (min (1- (width *title-logo-image-asset*))
                     (max 0 (floor (* local-x (width *title-logo-image-asset*)))))
                (min (1- (height *title-logo-image-asset*))
                     (max 0 (floor (* local-y (height *title-logo-image-asset*))))))))))

(defun title-logo-white-at-p (x y)
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
         520))))

(defun title-logo-particle-color (x y alpha)
  (if (title-logo-white-at-p x y)
      (make-color 0 0 0 alpha)
      (make-color 255 255 255 alpha)))
