(in-package #:immortal-coil)

;;; Story one-shot sounds

(defvar *story-sound-assets* (make-hash-table :test #'equal))

(defparameter *story-sound-volume* 0.50)

(-> story-sound-effective-volume (scalar) scalar)
(defun story-sound-effective-volume (volume-scale)
  (scaled-sound-volume volume-scale))

(-> story-sound-pathname (t) pathname)
(defun story-sound-pathname (path)
  (etypecase path
    (pathname path)
    (string
     (let ((pathname (parse-namestring path)))
       (if (uiop:absolute-pathname-p pathname)
           pathname
           (project-pathname path))))))

(-> story-sound-cache-key (pathname) string)
(defun story-sound-cache-key (path)
  (namestring path))

(-> cached-story-sound-asset (pathname) t)
(defun cached-story-sound-asset (path)
  (gethash (story-sound-cache-key path) *story-sound-assets*))

(defun (setf cached-story-sound-asset) (asset path)
  (setf (gethash (story-sound-cache-key path) *story-sound-assets*) asset))

(-> load-story-sound-asset (pathname) t)
(defun load-story-sound-asset (path)
  (or (cached-story-sound-asset path)
      (when (probe-file path)
        (let ((asset (make-sound-asset-maybe path "story sound")))
          (when asset
            (setf (cached-story-sound-asset path) asset))
          asset))))

(-> play-story-sound (t &key (:volume scalar)) t)
(defun play-story-sound (path &key (volume *story-sound-volume*))
  (if (audio-device-ready-p)
      (let* ((pathname (story-sound-pathname path))
             (asset (load-story-sound-asset pathname)))
        (if asset
            (let ((sound (asset asset)))
              (setf (volume sound) (story-sound-effective-volume volume))
              (play-sound-maybe sound "story sound"))
            (runtime-warn "Story sound does not exist: ~a" pathname)))
      (runtime-warn "Story sound skipped; audio device is not ready: ~a"
                    path)))

(-> clear-story-sound-resources () t)
(defun clear-story-sound-resources ()
  (clrhash *story-sound-assets*)
  t)

;;; Hardware sounds

(defun play-crt-power-on ()
  "The tube waking: a relay thunk, a rising whine, a static burst."
  (play-story-sound "assets/audio/sys/crt-on.wav" :volume 0.65))

(defun play-crt-power-off ()
  "The tube dying: the picture collapses, the whine falls, a static snap."
  (play-story-sound "assets/audio/sys/crt-off.wav" :volume 0.65))
