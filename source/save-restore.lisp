(in-package #:immortal-coil)

(-> restore-play-state-from-save (save-data) t)
(defun restore-play-state-from-save (data)
  (let ((current-id (resolve-node-id (save-data-current-id data))))
    (restore-dialog-store (getf data :dialog-store))
    (setf *state*
          (make-play-state
           :current-id current-id
           :elapsed 0.0
           :type-delay 0.0
           :visible-count (save-data-nonnegative-integer data :visible-count)
           :selected-index (save-data-nonnegative-integer data :selected-index)
           :input-buffer (save-data-string data :input-buffer)))
    (restore-particle-field-state (getf data :particle-field))))

(-> load-current-game-save () boolean)
(defun load-current-game-save ()
  (handler-case
      (let ((data (current-save-data)))
        (when (valid-save-data-p data)
          (restore-play-state-from-save data)
          t))
    (error () nil)))

(-> restore-dev-save-override () boolean)
(defun restore-dev-save-override ()
  (handler-case
      (let ((data (dev-save-override-data)))
        (when (valid-save-data-p data)
          (restore-play-state-from-save data)
          t))
    (error (condition)
      (runtime-warn "Could not restore dev save override: ~a" condition)
      nil)))
