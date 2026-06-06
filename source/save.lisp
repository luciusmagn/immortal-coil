(in-package #:immortal-coil)

(defparameter *save-file-path* nil)

(defun save-file-pathname ()
  (or *save-file-path*
      (let ((save-dir (uiop:getenv "IMMORTAL_COIL_SAVE_DIR")))
        (if save-dir
            (merge-pathnames "current.lisp"
                             (uiop:ensure-directory-pathname save-dir))
            (project-pathname "save/current.lisp")))))

(defun save-game-exists-p ()
  (handler-case
      (not (null (probe-file (save-file-pathname))))
    (error (condition)
      (runtime-warn "Could not check save file: ~a" condition)
      nil)))

(defun save-play-state-data ()
  (list :version 1
        :current-id (play-state-current-id *state*)
        :visible-count (play-state-visible-count *state*)
        :selected-index (play-state-selected-index *state*)
        :input-buffer (play-state-input-buffer *state*)
        :dialog-store (dialog-store-alist)
        :particle-field (particle-field-state-data)))

(defun write-save-data (data)
  (let ((path (save-file-pathname)))
    (ensure-directories-exist path)
    (with-open-file (stream path
                            :direction :output
                            :if-exists :supersede
                            :if-does-not-exist :create)
      (with-standard-io-syntax
        (let ((*print-readably* t))
          (print data stream))))))

(defun save-current-game ()
  (when *state*
    (handler-case
        (write-save-data (save-play-state-data))
      (error (condition)
        (runtime-warn "Could not save game: ~a" condition)))))

(defun read-save-data ()
  (when (save-game-exists-p)
    (handler-case
        (with-open-file (stream (save-file-pathname))
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
    (setf current-id (resolve-node-id current-id))
    (restore-dialog-store (getf data :dialog-store))
    (setf *state*
          (make-play-state :current-id current-id
                           :elapsed 0.0
                           :type-delay 0.0
                           :visible-count (if (integerp (getf data :visible-count))
                                              (max 0 (getf data :visible-count))
                                              0)
                           :selected-index (if (integerp (getf data :selected-index))
                                               (max 0 (getf data :selected-index))
                                               0)
                           :input-buffer (if (stringp (getf data :input-buffer))
                                             (getf data :input-buffer)
                                             "")))
    (restore-particle-field-state (getf data :particle-field))))

(defun load-current-game-save ()
  (handler-case
      (let ((data (read-save-data)))
        (when (valid-save-data-p data)
          (restore-play-state-from-save data)
          t))
    (error () nil)))

(setf *save-current-game-function* #'save-current-game)
