(in-package #:immortal-coil)

(-> save-game-exists-p () boolean)
(defun save-game-exists-p ()
  (or (dev-save-override-exists-p)
      (handler-case
          (not (null (probe-file (save-file-pathname))))
        (error (condition)
          (runtime-warn "Could not check save file: ~a" condition)
          nil))))

(-> write-save-data (save-data) t)
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

(-> save-current-game () t)
(defun save-current-game ()
  (when *state*
    (handler-case
        (write-save-data (save-play-state-data))
      (error (condition)
        (runtime-warn "Could not save game: ~a" condition)))))

(-> read-save-data () t)
(defun read-save-data ()
  (when (save-game-exists-p)
    (handler-case
        (with-open-file (stream (save-file-pathname))
          (with-standard-io-syntax
            (read stream nil nil)))
      (error () nil))))

(-> current-save-data () t)
(defun current-save-data ()
  (or (dev-save-override-data)
      (read-save-data)))
