(in-package #:immortal-coil)

(defvar *story-music-asset* nil)
(defvar *story-music* nil)
(defvar *story-music-path* nil)
(defvar *story-music-playing-p* nil)
(defvar *story-music-volume* 0.28)

;;; The relative path most recently handed to set-story-music, kept so a
;;; save can record which track is playing portably (the resolved
;;; *story-music-path* is an absolute, machine-specific pathname).
(defvar *story-music-source* nil)

;;; A (path volume) selection carried from a loaded save, applied once the
;;; menu has finished tearing down title/story audio for the transition.
(defvar *pending-restored-music* nil)

(-> story-music-effective-volume () scalar)
(defun story-music-effective-volume ()
  (* *story-music-volume*
     (clamp01 *music-volume-scale*)))

(-> sync-story-music-volume () t)
(defun sync-story-music-volume ()
  (when *story-music*
    (setf (volume *story-music*) (story-music-effective-volume))))

(-> story-music-pathname (t) pathname)
(defun story-music-pathname (path)
  (etypecase path
    (pathname path)
    (string
     (let ((pathname (parse-namestring path)))
       (if (uiop:absolute-pathname-p pathname)
           pathname
           (project-pathname path))))))

(-> stop-story-music () t)
(defun stop-story-music ()
  (when (and *story-music*
             *story-music-playing-p*)
    (handler-case
        (claylib/ll:stop-music-stream (claylib::c-ptr *story-music*))
      (error (condition)
        (runtime-warn "Could not stop story music: ~a" condition))))
  (setf *story-music-playing-p* nil))

(-> clear-story-music-resources () t)
(defun clear-story-music-resources ()
  (stop-story-music)
  (setf *story-music-asset* nil
        *story-music* nil
        *story-music-path* nil
        *story-music-playing-p* nil))

(-> story-music-same-path-p (pathname) boolean)
(defun story-music-same-path-p (path)
  (and *story-music-path*
       (equal (namestring *story-music-path*)
              (namestring path))))

(-> load-story-music (pathname scalar) t)
(defun load-story-music (path volume)
  (clear-story-music-resources)
  (configure-music-stream-buffer)
  (if (probe-file path)
      (let ((asset (make-music-asset-maybe path "story music")))
        (when asset
          (setf *story-music-asset* asset
                *story-music* (asset *story-music-asset*)
                *story-music-path* path
                *story-music-volume* volume
                *story-music-playing-p* nil)
          (setf (volume *story-music*) (story-music-effective-volume)
                (looping *story-music*) t)))
      (runtime-warn "Story music does not exist: ~a" path)))

(-> play-story-music-loaded () t)
(defun play-story-music-loaded ()
  (when *story-music*
    (handler-case
        (progn
          (sync-story-music-volume)
          (unless *story-music-playing-p*
            (claylib/ll:play-music-stream (claylib::c-ptr *story-music*))
            (setf *story-music-playing-p* t)))
      (error (condition)
        (runtime-warn "Could not play story music: ~a" condition)
        (setf *story-music-playing-p* nil)))))

(-> set-story-music (t &key (:volume scalar)) t)
(defun set-story-music (path &key (volume 0.28))
  (if (audio-device-ready-p)
      (let ((pathname (story-music-pathname path)))
        (unless (story-music-same-path-p pathname)
          (load-story-music pathname volume))
        (setf *story-music-volume* volume
              *story-music-source* (if (stringp path)
                                       path
                                       (namestring pathname)))
        (play-story-music-loaded))
      (runtime-warn "Story music skipped; audio device is not ready: ~a"
                    path)))

(-> active-story-music-selection () t)
(defun active-story-music-selection ()
  "The track to record in a save: (path volume) while playing, else nil."
  (when (and *story-music-playing-p* *story-music-source*)
    (list *story-music-source* *story-music-volume*)))

(-> apply-restored-story-music () t)
(defun apply-restored-story-music ()
  "Resume the track carried from a loaded save, after the menu's teardown."
  (let ((selection *pending-restored-music*))
    (setf *pending-restored-music* nil)
    (when (and (consp selection)
               (stringp (first selection)))
      (set-story-music (first selection)
                       :volume (if (realp (second selection))
                                   (second selection)
                                   0.28)))))

(-> update-story-music-stream () t)
(defun update-story-music-stream ()
  (when (and *story-music*
             *story-music-playing-p*)
    (handler-case
        (claylib/ll:update-music-stream (claylib::c-ptr *story-music*))
      (error (condition)
        (runtime-warn "Could not update story music: ~a" condition)
        (setf *story-music-playing-p* nil)))))

(-> update-story-music () t)
(defun update-story-music ()
  (sync-story-music-volume)
  (update-story-music-stream))
