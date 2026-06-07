(in-package #:immortal-coil)

(defvar *type-click-assets* nil)
(defvar *type-click-sounds* #())
(defvar *type-click-index* 0)
(defvar *choice-switch-asset* nil)
(defvar *choice-switch-sound* nil)
(defvar *start-confirm-asset* nil)
(defvar *start-confirm-sound* nil)

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
        do (setf (volume sound) 0.18)))

(-> load-choice-switch () t)
(defun load-choice-switch ()
  (let ((path (project-pathname "assets/audio/choice-switch.wav")))
    (when (probe-file path)
      (let ((asset (make-sound-asset-maybe path "choice switch")))
        (when asset
          (setf *choice-switch-asset* asset
                *choice-switch-sound* (asset *choice-switch-asset*))
          (setf (volume *choice-switch-sound*) 0.16))))))

(-> load-start-confirm () t)
(defun load-start-confirm ()
  (let ((path (or (probe-file (project-pathname "assets/audio/start-confirm.wav"))
                  (probe-file (project-pathname "assets/audio/choice-switch.wav")))))
    (when path
      (let ((asset (make-sound-asset-maybe path "start confirm")))
        (when asset
          (setf *start-confirm-asset* asset
                *start-confirm-sound* (asset *start-confirm-asset*))
          (setf (volume *start-confirm-sound*) 0.82
                (pitch *start-confirm-sound*) 1.0))))))

(-> next-type-click () t)
(defun next-type-click ()
  (unless (zerop (length *type-click-sounds*))
    (let ((sound (aref *type-click-sounds* *type-click-index*)))
      (setf *type-click-index*
            (mod (1+ *type-click-index*)
                 (length *type-click-sounds*)))
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
    (setf (pitch *choice-switch-sound*)
          (+ 0.98 (/ (get-random-value 0 8) 100.0)))
    (play-sound-maybe *choice-switch-sound* "choice switch")))

(-> play-start-confirm () t)
(defun play-start-confirm ()
  (when *start-confirm-sound*
    (setf (pitch *start-confirm-sound*) 1.0)
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
