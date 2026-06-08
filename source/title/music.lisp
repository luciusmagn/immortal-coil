(in-package #:immortal-coil)

(defvar *title-music-asset* nil)
(defvar *title-music* nil)
(defvar *title-music-playing-p* nil)

(defparameter *title-music-volume* 0.38)

(-> title-music-effective-volume (&optional scalar) scalar)
(defun title-music-effective-volume (&optional (volume-scale 1.0))
  (* *title-music-volume*
     (clamp01 *music-volume-scale*)
     (clamp01 volume-scale)))

(-> load-title-music () t)
(defun load-title-music ()
  (let ((path (project-pathname "assets/audio/title-ambient-drone.mp3")))
    (when (probe-file path)
      (stop-title-music)
      (let ((asset (make-music-asset-maybe path "title music")))
        (when asset
          (setf *title-music-asset* asset
                *title-music* (asset *title-music-asset*)
                *title-music-playing-p* nil)
          (setf (volume *title-music*) (title-music-effective-volume)
                (looping *title-music*) t))))))

(-> play-title-music () t)
(defun play-title-music ()
  (when *title-music*
    (setf (volume *title-music*) (title-music-effective-volume))
    (when (not *title-music-playing-p*)
      (handler-case
          (progn
            (claylib/ll:play-music-stream (claylib::c-ptr *title-music*))
            (setf *title-music-playing-p* t))
        (error (condition)
          (runtime-warn "Could not play title music: ~a" condition))))))

(-> stop-title-music () t)
(defun stop-title-music ()
  (when (and *title-music*
             *title-music-playing-p*)
    (handler-case
        (claylib/ll:stop-music-stream (claylib::c-ptr *title-music*))
      (error (condition)
        (runtime-warn "Could not stop title music: ~a" condition)))
    (setf *title-music-playing-p* nil)))

(-> update-title-music (&optional scalar) t)
(defun update-title-music (&optional (volume-scale 1.0))
  (when (and *title-music*
             *title-music-playing-p*)
    (handler-case
        (progn
          (setf (volume *title-music*)
                (title-music-effective-volume volume-scale))
          (claylib/ll:update-music-stream (claylib::c-ptr *title-music*)))
      (error (condition)
        (runtime-warn "Could not update title music: ~a" condition)
        (setf *title-music-playing-p* nil)))))

(-> clear-title-music-resources () t)
(defun clear-title-music-resources ()
  (stop-title-music)
  (setf *title-music-asset* nil
        *title-music* nil
        *title-music-playing-p* nil))
