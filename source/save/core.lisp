(in-package #:immortal-coil)

;;; Path selection

(defparameter *save-file-path* nil)
(defvar *active-save-slot* nil)

(-> save-directory-pathname () pathname)
(defun save-directory-pathname ()
  (let ((save-dir (uiop:getenv "IMMORTAL_COIL_SAVE_DIR")))
    (if save-dir
        (uiop:ensure-directory-pathname save-dir)
        (project-pathname "save/"))))

(-> save-slot-pathname (string) pathname)
(defun save-slot-pathname (slot)
  (merge-pathnames (format nil "slot-~a.lisp" slot)
                   (save-directory-pathname)))

(-> new-save-slot-id () string)
(defun new-save-slot-id ()
  (multiple-value-bind (second minute hour day month year)
      (decode-universal-time (get-universal-time))
    (format nil "~4,'0d~2,'0d~2,'0d-~2,'0d~2,'0d~2,'0d"
            year month day hour minute second)))

(-> save-file-pathname () pathname)
(defun save-file-pathname ()
  (or *save-file-path*
      (when *active-save-slot*
        (save-slot-pathname *active-save-slot*))
      (merge-pathnames "current.lisp" (save-directory-pathname))))


;;; Save data

(-> save-play-state-data () save-data)
(defun save-play-state-data ()
  (list :version 1
        :saved-at (get-universal-time)
        :playtime (round *playtime-seconds*)
        :player-name (dialog-value "player-name" "")
        :slot *active-save-slot*
        :current-id (play-state-current-id *state*)
        :visible-count (play-state-visible-count *state*)
        :selected-index (play-state-selected-index *state*)
        :conversation-index (play-state-conversation-index *state*)
        :input-buffer (play-state-input-buffer *state*)
        :dialog-store (dialog-store-alist)
        :particle-field (particle-field-state-data)))

(-> save-data-current-id (save-data) t)
(defun save-data-current-id (data)
  (getf data :current-id))

(-> valid-save-data-p (t) boolean)
(defun valid-save-data-p (data)
  (and (listp data)
       (= (or (getf data :version) 0) 1)
       (stringp (save-data-current-id data))))

(-> save-data-nonnegative-integer (save-data keyword) nonnegative-integer)
(defun save-data-nonnegative-integer (data key)
  (let ((value (getf data key)))
    (if (integerp value)
        (max 0 value)
        0)))

(-> save-data-string (save-data keyword) string)
(defun save-data-string (data key)
  (let ((value (getf data key)))
    (if (stringp value)
        value
        "")))


;;; File IO

(-> list-save-slots () list)
(defun list-save-slots ()
  "Metadata plists for every readable save slot, newest first."
  (handler-case
      (let ((slots nil))
        (dolist (path (uiop:directory-files (save-directory-pathname)
                                            "slot-*.lisp"))
          (handler-case
              (with-open-file (stream path)
                (with-standard-io-syntax
                  (let ((data (read stream nil nil)))
                    (when (valid-save-data-p data)
                      (push (list :path path
                                  :slot (getf data :slot)
                                  :saved-at (or (getf data :saved-at) 0)
                                  :playtime (or (getf data :playtime) 0)
                                  :player-name (getf data :player-name ""))
                            slots)))))
            (error () nil)))
        (sort slots #'> :key (lambda (entry) (getf entry :saved-at))))
    (error (condition)
      (runtime-warn "Could not list save slots: ~a" condition)
      nil)))

(-> newest-save-slot () (option string))
(defun newest-save-slot ()
  (let ((entry (first (list-save-slots))))
    (when entry
      (getf entry :slot))))

(-> save-game-exists-p () boolean)
(defun save-game-exists-p ()
  (or (dev-save-override-exists-p)
      (not (null (list-save-slots)))
      (handler-case
          (not (null (probe-file (merge-pathnames
                                  "current.lisp"
                                  (save-directory-pathname)))))
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
      (let ((newest (newest-save-slot)))
        (when newest
          (setf *active-save-slot* newest))
        (read-save-data))))


;;; Restore

(-> restore-play-state-from-save (save-data) t)
(defun restore-play-state-from-save (data)
  (let ((current-id (resolve-node-id (save-data-current-id data))))
    (setf *playtime-seconds*
          (float (save-data-nonnegative-integer data :playtime)))
    (when (getf data :slot)
      (setf *active-save-slot* (getf data :slot)))
    (restore-dialog-store (getf data :dialog-store))
    (setf *state*
          (make-play-state
           :current-id current-id
           :elapsed 0.0
           :type-delay 0.0
           :visible-count (save-data-nonnegative-integer data :visible-count)
           :selected-index (save-data-nonnegative-integer data :selected-index)
           :conversation-index
           (save-data-nonnegative-integer data :conversation-index)
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


;;; Hook registration

(setf *save-current-game-function* #'save-current-game)
