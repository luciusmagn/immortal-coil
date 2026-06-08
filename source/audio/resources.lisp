(in-package #:immortal-coil)

;;; Asset helpers

(-> make-sound-asset-maybe (pathname string) t)
(defun make-sound-asset-maybe (path description)
  (handler-case
      (make-sound-asset path :load-now t)
    (error (condition)
      (runtime-warn "Could not load ~a: ~a (~a)"
                    description
                    path
                    condition)
      nil)))

(-> make-music-asset-maybe (pathname string) t)
(defun make-music-asset-maybe (path description)
  (handler-case
      (make-music-asset path :load-now t)
    (error (condition)
      (runtime-warn "Could not load ~a: ~a (~a)"
                    description
                    path
                    condition)
      nil)))

(-> audio-device-ready-p () boolean)
(defun audio-device-ready-p ()
  (handler-case
      (claylib/ll:is-audio-device-ready-p)
    (error (condition)
      (runtime-warn "Could not query audio device readiness: ~a" condition)
      nil)))

(-> play-sound-maybe (t string) t)
(defun play-sound-maybe (sound description)
  (handler-case
      (claylib/ll:play-sound (claylib::c-ptr sound))
    (error (condition)
      (runtime-warn "Could not play ~a: ~a" description condition))))


;;; Short sounds

(defvar *type-click-assets* nil)
(defvar *type-click-sounds* #())
(defvar *type-click-index* 0)
(defvar *choice-switch-asset* nil)
(defvar *choice-switch-sound* nil)
(defvar *start-confirm-asset* nil)
(defvar *start-confirm-sound* nil)

(defparameter *type-click-volume* 0.18)
(defparameter *choice-switch-volume* 0.16)
(defparameter *start-confirm-volume* 0.82)

(-> scaled-sound-volume (scalar) scalar)
(defun scaled-sound-volume (base-volume)
  (* base-volume (clamp01 *sound-volume-scale*)))

(-> type-click-paths () list)
(defun type-click-paths ()
  (loop for i from 1 to 8
        for path = (project-pathname
                    (format nil "assets/audio/typewriter~d.wav" i))
        when (probe-file path)
          collect path))

(-> load-type-clicks () t)
(defun load-type-clicks ()
  (setf *type-click-assets*
        (remove nil
                (mapcar #'(lambda (path)
                            (make-sound-asset-maybe path "type click"))
                        (type-click-paths)))
        *type-click-sounds*
        (coerce (mapcar #'asset *type-click-assets*) 'vector)
        *type-click-index*
        0)
  (loop for sound across *type-click-sounds*
        do (setf (volume sound)
                 (scaled-sound-volume *type-click-volume*))))

(-> load-choice-switch () t)
(defun load-choice-switch ()
  (let ((path (project-pathname "assets/audio/choice-switch.wav")))
    (when (probe-file path)
      (let ((asset (make-sound-asset-maybe path "choice switch")))
        (when asset
          (setf *choice-switch-asset* asset
                *choice-switch-sound* (asset *choice-switch-asset*))
          (setf (volume *choice-switch-sound*)
                (scaled-sound-volume *choice-switch-volume*)))))))

(-> load-start-confirm () t)
(defun load-start-confirm ()
  (let ((path (or (probe-file (project-pathname "assets/audio/start-confirm.wav"))
                  (probe-file (project-pathname "assets/audio/choice-switch.wav")))))
    (when path
      (let ((asset (make-sound-asset-maybe path "start confirm")))
        (when asset
          (setf *start-confirm-asset* asset
                *start-confirm-sound* (asset *start-confirm-asset*))
          (setf (volume *start-confirm-sound*)
                (scaled-sound-volume *start-confirm-volume*)
                (pitch *start-confirm-sound*) 1.0))))))

(-> next-type-click () t)
(defun next-type-click ()
  (unless (zerop (length *type-click-sounds*))
    (let ((sound (aref *type-click-sounds* *type-click-index*)))
      (setf *type-click-index*
            (mod (1+ *type-click-index*)
                 (length *type-click-sounds*)))
      (setf (volume sound)
            (scaled-sound-volume *type-click-volume*))
      sound)))

(-> non-blank-text-range-p (string nonnegative-integer nonnegative-integer)
    boolean)
(defun non-blank-text-range-p (text old-count new-count)
  (not (null
        (find-if-not #'(lambda (char)
                         (member char '(#\Space #\Tab #\Newline)))
                     text
                     :start old-count
                     :end new-count))))

(-> play-type-click (string nonnegative-integer nonnegative-integer) t)
(defun play-type-click (text old-count new-count)
  (when (and (> new-count old-count)
             (non-blank-text-range-p text old-count new-count))
    (let ((sound (next-type-click)))
      (when sound
        (setf (pitch sound)
              (+ 0.92 (/ (get-random-value 0 16) 100.0)))
        (play-sound-maybe sound "type click")))))

(-> play-input-click () t)
(defun play-input-click ()
  (let ((sound (next-type-click)))
    (when sound
      (setf (pitch sound)
            (+ 0.94 (/ (get-random-value 0 12) 100.0)))
      (play-sound-maybe sound "input click"))))

(-> play-choice-switch () t)
(defun play-choice-switch ()
  (when *choice-switch-sound*
    (setf (volume *choice-switch-sound*)
          (scaled-sound-volume *choice-switch-volume*))
    (setf (pitch *choice-switch-sound*)
          (+ 0.98 (/ (get-random-value 0 8) 100.0)))
    (play-sound-maybe *choice-switch-sound* "choice switch")))

(-> play-start-confirm () t)
(defun play-start-confirm ()
  (when *start-confirm-sound*
    (setf (volume *start-confirm-sound*)
          (scaled-sound-volume *start-confirm-volume*)
          (pitch *start-confirm-sound*) 1.0)
    (play-sound-maybe *start-confirm-sound* "start confirm")))

(-> clear-short-sound-resources () t)
(defun clear-short-sound-resources ()
  (setf *type-click-assets* nil
        *type-click-sounds* #()
        *type-click-index* 0
        *choice-switch-asset* nil
        *choice-switch-sound* nil
        *start-confirm-asset* nil
        *start-confirm-sound* nil))
