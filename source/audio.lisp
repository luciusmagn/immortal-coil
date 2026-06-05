(in-package #:immortal-coil)

(defvar *type-click-assets* nil)
(defvar *type-click-sounds* #())
(defvar *type-click-index* 0)
(defvar *choice-switch-asset* nil)
(defvar *choice-switch-sound* nil)
(defvar *start-confirm-asset* nil)
(defvar *start-confirm-sound* nil)
(defvar *title-music-asset* nil)
(defvar *title-music* nil)
(defvar *title-music-playing-p* nil)

(defparameter *title-music-volume* 0.38)

(defun type-click-paths ()
  (loop for i from 1 to 8
        for path = (asdf:system-relative-pathname
                    :immortal-coil
                    (format nil "assets/audio/typewriter~d.wav" i))
        when (probe-file path)
          collect path))

(defun load-type-clicks ()
  (setf *type-click-assets*
        (mapcar #'(lambda (path)
                    (make-sound-asset path :load-now t))
                (type-click-paths))
        *type-click-sounds*
        (coerce (mapcar #'asset *type-click-assets*) 'vector)
        *type-click-index*
        0)
  (loop for sound across *type-click-sounds*
        do (setf (volume sound) 0.18)))

(defun load-choice-switch ()
  (let ((path (asdf:system-relative-pathname
               :immortal-coil
               "assets/audio/choice-switch.wav")))
    (when (probe-file path)
      (setf *choice-switch-asset* (make-sound-asset path :load-now t)
            *choice-switch-sound* (asset *choice-switch-asset*))
      (setf (volume *choice-switch-sound*) 0.16))))

(defun load-start-confirm ()
  (let ((path (asdf:system-relative-pathname
               :immortal-coil
               "assets/audio/choice-switch.wav")))
    (when (probe-file path)
      (setf *start-confirm-asset* (make-sound-asset path :load-now t)
            *start-confirm-sound* (asset *start-confirm-asset*))
      (setf (volume *start-confirm-sound*) 0.24
            (pitch *start-confirm-sound*) 0.82))))

(defun load-title-music ()
  (let ((path (asdf:system-relative-pathname
               :immortal-coil
               "assets/audio/title-ambient-drone.mp3")))
    (when (probe-file path)
      (stop-title-music)
      (setf *title-music-asset* (make-music-asset path :load-now t)
            *title-music* (asset *title-music-asset*)
            *title-music-playing-p* nil)
      (setf (volume *title-music*) *title-music-volume*
            (looping *title-music*) t))))

(defun play-title-music ()
  (when (and *title-music*
             (not *title-music-playing-p*))
    (claylib/ll:play-music-stream (claylib::c-ptr *title-music*))
    (setf *title-music-playing-p* t)))

(defun stop-title-music ()
  (when (and *title-music*
             *title-music-playing-p*)
    (claylib/ll:stop-music-stream (claylib::c-ptr *title-music*))
    (setf *title-music-playing-p* nil)))

(defun update-title-music ()
  (when (and *title-music*
             *title-music-playing-p*)
    (claylib/ll:update-music-stream (claylib::c-ptr *title-music*))))

(defun next-type-click ()
  (unless (zerop (length *type-click-sounds*))
    (let ((sound (aref *type-click-sounds* *type-click-index*)))
      (setf *type-click-index*
            (mod (1+ *type-click-index*)
                 (length *type-click-sounds*)))
      sound)))

(defun play-type-click (text old-count new-count)
  (when (and (> new-count old-count)
             (find-if-not #'(lambda (char) (member char '(#\Space #\Tab #\Newline)))
                          text
                          :start old-count
                          :end new-count))
    (let ((sound (next-type-click)))
      (when sound
        (setf (pitch sound)
              (+ 0.92 (/ (get-random-value 0 16) 100.0)))
        (claylib/ll:play-sound (claylib::c-ptr sound))))))

(defun play-choice-switch ()
  (when *choice-switch-sound*
    (setf (pitch *choice-switch-sound*)
          (+ 0.98 (/ (get-random-value 0 8) 100.0)))
    (claylib/ll:play-sound (claylib::c-ptr *choice-switch-sound*))))

(defun play-start-confirm ()
  (when *start-confirm-sound*
    (setf (pitch *start-confirm-sound*) 0.82)
    (claylib/ll:play-sound (claylib::c-ptr *start-confirm-sound*))))

(defun load-audio ()
  (load-type-clicks)
  (load-choice-switch)
  (load-start-confirm)
  (load-title-music))

(defun clear-audio-resources ()
  (stop-title-music)
  (setf *type-click-assets* nil
        *type-click-sounds* #()
        *type-click-index* 0
        *choice-switch-asset* nil
        *choice-switch-sound* nil
        *start-confirm-asset* nil
        *start-confirm-sound* nil
        *title-music-asset* nil
        *title-music* nil
        *title-music-playing-p* nil))
