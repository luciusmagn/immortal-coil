(in-package #:immortal-coil)

(defparameter *dream-maze-static-path*
  (dialog-asset-pathname "audio/maze/crt-static.mp3"))

(defparameter *dream-maze-footstep-paths*
  (loop for index from 1 to 6
        collect
        (dialog-asset-pathname
         (format nil "audio/maze/footstep-~2,'0d.ogg" index))))

(defparameter *dream-maze-static-min-volume* 0.015)
(defparameter *dream-maze-static-max-volume* 0.42)
(defparameter *dream-maze-static-near-distance* 0.45)
(defparameter *dream-maze-static-far-distance* 7.5)
(defparameter *dream-maze-footstep-volume* 0.34)
(defparameter *dream-maze-footstep-step-distance* 0.58)

(defvar *dream-maze-static-asset* nil)
(defvar *dream-maze-static-sound* nil)
(defvar *dream-maze-static-load-attempted-p* nil)
(defvar *dream-maze-footstep-assets* nil)
(defvar *dream-maze-footstep-sounds* #())
(defvar *dream-maze-footstep-index* 0)
(defvar *dream-maze-footsteps-load-attempted-p* nil)

(-> ensure-dream-maze-static-sound () t)
(defun ensure-dream-maze-static-sound ()
  (unless (or *dream-maze-static-sound*
              *dream-maze-static-load-attempted-p*
              (not (audio-device-ready-p)))
    (setf *dream-maze-static-load-attempted-p* t)
    (let ((asset (make-sound-asset-maybe *dream-maze-static-path*
                                         "dream maze static")))
      (when asset
        (setf *dream-maze-static-asset* asset
              *dream-maze-static-sound* (asset asset))
        (setf (volume *dream-maze-static-sound*) 0.0
              (pan *dream-maze-static-sound*) 0.5
              (pitch *dream-maze-static-sound*) 1.0))))
  *dream-maze-static-sound*)

(-> ensure-dream-maze-footstep-sounds () vector)
(defun ensure-dream-maze-footstep-sounds ()
  (unless (or (plusp (length *dream-maze-footstep-sounds*))
              *dream-maze-footsteps-load-attempted-p*
              (not (audio-device-ready-p)))
    (setf *dream-maze-footsteps-load-attempted-p* t
          *dream-maze-footstep-assets*
          (remove nil
                  (mapcar #'(lambda (path)
                              (make-sound-asset-maybe path
                                                      "dream maze footstep"))
                          *dream-maze-footstep-paths*))
          *dream-maze-footstep-sounds*
          (coerce (mapcar #'asset *dream-maze-footstep-assets*) 'vector)
          *dream-maze-footstep-index*
          0)
    (loop for sound across *dream-maze-footstep-sounds*
          do (setf (volume sound)
                   (scaled-sound-volume *dream-maze-footstep-volume*)
                   (pan sound) 0.5
                   (pitch sound) 1.0)))
  *dream-maze-footstep-sounds*)

(-> dream-maze-sound-playing-p (t) boolean)
(defun dream-maze-sound-playing-p (sound)
  (handler-case
      (claylib/ll:is-sound-playing-p (claylib::c-ptr sound))
    (error (condition)
      (runtime-warn "Could not query dream maze sound playback: ~a" condition)
      nil)))

(-> stop-dream-maze-sound (t string) t)
(defun stop-dream-maze-sound (sound description)
  (handler-case
      (claylib/ll:stop-sound (claylib::c-ptr sound))
    (error (condition)
      (runtime-warn "Could not stop ~a: ~a" description condition))))

(-> stop-dream-maze-static () t)
(defun stop-dream-maze-static ()
  (when *dream-maze-static-sound*
    (setf (volume *dream-maze-static-sound*) 0.0)
    (stop-dream-maze-sound *dream-maze-static-sound* "dream maze static")))

(-> clear-dream-maze-audio-resources () t)
(defun clear-dream-maze-audio-resources ()
  (stop-dream-maze-static)
  (setf *dream-maze-static-asset* nil
        *dream-maze-static-sound* nil
        *dream-maze-static-load-attempted-p* nil
        *dream-maze-footstep-assets* nil
        *dream-maze-footstep-sounds* #()
        *dream-maze-footstep-index* 0
        *dream-maze-footsteps-load-attempted-p* nil))

(-> dream-maze-nearest-exit-cue (dream-maze-minigame)
    (values scalar scalar scalar))
(defun dream-maze-nearest-exit-cue (game)
  (let ((best-distance +dream-maze-max-depth+)
        (best-pan 0.5)
        (best-closeness 0.0))
    (dolist (exit *dream-maze-exits*)
      (let* ((exit-x (+ (dream-maze-exit-x exit) 0.5))
             (exit-y (+ (dream-maze-exit-y exit) 0.5))
             (dx (- exit-x (dream-maze-minigame-x game)))
             (dy (- exit-y (dream-maze-minigame-y game)))
             (distance (sqrt (+ (* dx dx) (* dy dy)))))
        (when (< distance best-distance)
          (let* ((side (+ (* (- dx) (sin (dream-maze-minigame-angle game)))
                          (* dy (cos (dream-maze-minigame-angle game)))))
                 (side-ratio (/ side (max 0.01 distance)))
                 (closeness
                   (clamp01
                    (/ (- *dream-maze-static-far-distance* distance)
                       (- *dream-maze-static-far-distance*
                          *dream-maze-static-near-distance*)))))
            (setf best-distance distance
                  best-pan (clamp01 (+ 0.5 (* 0.44 side-ratio)))
                  best-closeness closeness)))))
    (values best-distance best-pan best-closeness)))

(-> dream-maze-static-volume-for-closeness (scalar) scalar)
(defun dream-maze-static-volume-for-closeness (closeness)
  (+ *dream-maze-static-min-volume*
     (* *dream-maze-static-max-volume*
        (expt (clamp01 closeness) 1.55))))

(-> update-dream-maze-static (dream-maze-minigame) t)
(defun update-dream-maze-static (game)
  (let ((sound (ensure-dream-maze-static-sound)))
    (when sound
      (multiple-value-bind (distance pan closeness)
          (dream-maze-nearest-exit-cue game)
        (declare (ignore distance))
        (setf (volume sound)
              (scaled-sound-volume
               (dream-maze-static-volume-for-closeness closeness))
              (pan sound) pan
              (pitch sound) (+ 0.96 (* 0.05 closeness)))
        (unless (dream-maze-sound-playing-p sound)
          (play-sound-maybe sound "dream maze static"))))))

(-> next-dream-maze-footstep () t)
(defun next-dream-maze-footstep ()
  (let ((sounds (ensure-dream-maze-footstep-sounds)))
    (unless (zerop (length sounds))
      (let ((sound (aref sounds *dream-maze-footstep-index*)))
        (setf *dream-maze-footstep-index*
              (mod (1+ *dream-maze-footstep-index*)
                   (length sounds)))
        sound))))

(-> play-dream-maze-footstep () t)
(defun play-dream-maze-footstep ()
  (let ((sound (next-dream-maze-footstep)))
    (when sound
      (setf (volume sound)
            (scaled-sound-volume *dream-maze-footstep-volume*)
            (pan sound) 0.5
            (pitch sound) (+ 0.92 (/ (get-random-value 0 16) 100.0)))
      (play-sound-maybe sound "dream maze footstep"))))

(-> update-dream-maze-footsteps (dream-maze-minigame scalar) t)
(defun update-dream-maze-footsteps (game moved-distance)
  (when (plusp moved-distance)
    (incf (dream-maze-minigame-step-distance game) moved-distance)
    (loop while (>= (dream-maze-minigame-step-distance game)
                    *dream-maze-footstep-step-distance*)
          do (decf (dream-maze-minigame-step-distance game)
                   *dream-maze-footstep-step-distance*)
             (play-dream-maze-footstep))))

(register-minigame-reset-hook 'clear-dream-maze-audio-resources)
