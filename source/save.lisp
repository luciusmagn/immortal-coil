(in-package #:immortal-coil)

(defparameter *save-file-path*
  (asdf:system-relative-pathname :immortal-coil "save/current.lisp"))

(defun save-game-exists-p ()
  (not (null (probe-file *save-file-path*))))

(defun save-play-state-data ()
  (list :version 1
        :current-id (play-state-current-id *state*)
        :visible-count (play-state-visible-count *state*)
        :selected-index (play-state-selected-index *state*)
        :input-buffer (play-state-input-buffer *state*)
        :dialog-store (dialog-store-alist)))

(defun write-save-data (data)
  (ensure-directories-exist *save-file-path*)
  (with-open-file (stream *save-file-path*
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (with-standard-io-syntax
      (let ((*print-readably* t))
        (print data stream)))))

(defun save-current-game ()
  (when *state*
    (write-save-data (save-play-state-data))))

(defun read-save-data ()
  (when (save-game-exists-p)
    (handler-case
        (with-open-file (stream *save-file-path*)
          (with-standard-io-syntax
            (read stream nil nil)))
      (error () nil))))

(defun save-data-current-id (data)
  (getf data :current-id))

(defun valid-save-data-p (data)
  (and (listp data)
       (= (or (getf data :version) 0) 1)
       (stringp (save-data-current-id data))))

(defun restore-play-state-from-save (data)
  (let ((current-id (save-data-current-id data)))
    (find-node current-id)
    (restore-dialog-store (getf data :dialog-store))
    (setf *state*
          (make-play-state :current-id current-id
                           :elapsed 0.0
                           :type-delay 0.0
                           :visible-count (or (getf data :visible-count) 0)
                           :selected-index (or (getf data :selected-index) 0)
                           :input-buffer (or (getf data :input-buffer) "")))))

(defun load-current-game-save ()
  (handler-case
      (let ((data (read-save-data)))
        (when (valid-save-data-p data)
          (restore-play-state-from-save data)
          t))
    (error () nil)))

(setf *save-current-game-function* #'save-current-game)
