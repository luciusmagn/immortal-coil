(in-package #:immortal-coil)

;;; Corner HUD. Four slots, one per screen corner, each holding a thunk that
;;; computes the string drawn there this frame (or NIL / "" to draw nothing).
;;; By default the top-left shows the SBCL the project was built with and the
;;; top-right shows a 24h clock; the two bottom slots are free. Any slot can
;;; be overridden at runtime with (set-hud-slot :corner (lambda () ...)), so a
;;; player or mod renders whatever it likes. The HUD is suppressed while the
;;; editor is active so it never overlaps the editor chrome.

(defconstant +hud-text-size+ 16)
(defconstant +hud-margin+ 14.0)

(defparameter *hud-build-sbcl-version* (lisp-implementation-version)
  "The SBCL version captured when this file loads, i.e. the build's SBCL.")

(-> hud-default-sbcl () string)
(defun hud-default-sbcl ()
  (format nil "SBCL-~a" *hud-build-sbcl-version*))

(-> hud-default-clock () string)
(defun hud-default-clock ()
  (multiple-value-bind (second minute hour) (get-decoded-time)
    (declare (ignore second))
    (format nil "~2,'0d:~2,'0d" hour minute)))

(defparameter *hud-slots*
  (list :top-left     #'hud-default-sbcl
        :top-right    #'hud-default-clock
        :bottom-left  nil
        :bottom-right nil)
  "Plist of corner -> thunk (or NIL). Each thunk takes no arguments and
returns the string to render in that corner this frame.")

(-> hud-slot-corner-p (t) boolean)
(defun hud-slot-corner-p (corner)
  (and (member corner '(:top-left :top-right :bottom-left :bottom-right)) t))

(defun set-hud-slot (corner thunk)
  "Override a HUD CORNER (:top-left :top-right :bottom-left :bottom-right)
with THUNK, a function of no arguments returning the string to draw there
each frame (NIL clears the slot). Returns THUNK. This is the player/mod entry
point: (set-hud-slot :bottom-right (lambda () (format nil \"fps ~d\" (fps))))."
  (if (hud-slot-corner-p corner)
      (progn (setf (getf *hud-slots* corner) thunk) thunk)
      (progn (runtime-warn "Unknown HUD corner: ~s" corner) nil)))

(-> hud-slot-text (t) (option string))
(defun hud-slot-text (corner)
  (let ((thunk (getf *hud-slots* corner)))
    (when thunk
      (handler-case
          (let ((value (funcall (resolve-function-designator thunk))))
            (and value (princ-to-string value)))
        (error (condition)
          (runtime-warn "HUD slot ~a failed: ~a" corner condition)
          nil)))))

(-> draw-hud-text (string scalar scalar boolean) t)
(defun draw-hud-text (text x y right-aligned-p)
  (let* ((left (if right-aligned-p (- x (text-width text +hud-text-size+)) x)))
    ;; a 1px shadow keeps it legible over any background
    (draw-text-at text (+ left 1.0) (+ y 1.0) +hud-text-size+
                  (make-color 0 0 0 170))
    (draw-text-at text left y +hud-text-size+
                  (make-color 255 255 255 190))))

(-> draw-hud-slot (t scalar scalar boolean) t)
(defun draw-hud-slot (corner x y right-aligned-p)
  (let ((text (hud-slot-text corner)))
    (when (and text (plusp (length text)))
      (draw-hud-text text x y right-aligned-p))))

(-> draw-hud () t)
(defun draw-hud ()
  (let ((right  (- +virtual-width+ +hud-margin+))
        (bottom (- +virtual-height+ +hud-margin+ +hud-text-size+)))
    (draw-hud-slot :top-left     +hud-margin+ +hud-margin+ nil)
    (draw-hud-slot :top-right    right        +hud-margin+ t)
    (draw-hud-slot :bottom-left  +hud-margin+ bottom       nil)
    (draw-hud-slot :bottom-right right        bottom       t)))
