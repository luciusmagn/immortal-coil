(in-package #:immortal-coil)

(defvar *story-music-asset* nil)
(defvar *story-music* nil)
(defvar *story-music-path* nil)
(defvar *story-music-playing-p* nil)
(defvar *story-music-volume* 0.28)

(-> story-music-effective-volume () scalar)
(defun story-music-effective-volume ()
  (* *story-music-volume*
     (clamp01 *music-volume-scale*)))

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
          (setf (volume *story-music*) (story-music-effective-volume))
          (unless *story-music-playing-p*
            (claylib/ll:play-music-stream (claylib::c-ptr *story-music*))
            (setf *story-music-playing-p* t)))
      (error (condition)
        (runtime-warn "Could not play story music: ~a" condition)
        (setf *story-music-playing-p* nil)))))

(-> set-story-music (t &key (:volume scalar)) t)
(defun set-story-music (path &key (volume 0.28))
  (let ((pathname (story-music-pathname path)))
    (unless (story-music-same-path-p pathname)
      (load-story-music pathname volume))
    (setf *story-music-volume* volume)
    (play-story-music-loaded)))

(-> update-story-music () t)
(defun update-story-music ()
  (when (and *story-music*
             *story-music-playing-p*)
    (handler-case
        (progn
          (setf (volume *story-music*) (story-music-effective-volume))
          (claylib/ll:update-music-stream (claylib::c-ptr *story-music*)))
      (error (condition)
        (runtime-warn "Could not update story music: ~a" condition)
        (setf *story-music-playing-p* nil)))))
