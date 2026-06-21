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
        :current-hash (node-content-hash
                       (gethash (play-state-current-id *state*) *nodes*))
        :visible-count (play-state-visible-count *state*)
        :selected-index (play-state-selected-index *state*)
        :conversation-index (play-state-conversation-index *state*)
        :input-buffer (play-state-input-buffer *state*)
        :journal-entries (play-state-journal-entries *state*)
        :journal-visit-index (play-state-journal-visit-index *state*)
        :journal-recorded (play-state-journal-recorded *state*)
        :visited (play-state-visited *state*)
        :dialog-store (dialog-store-alist)
        :particle-field (particle-field-state-data)
        :story-music (active-story-music-selection)))

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

(-> save-data-list (save-data keyword) list)
(defun save-data-list (data key)
  (let ((value (getf data key)))
    (if (listp value)
        value
        nil)))


;;; Graph drift
;;;
;;; A save points at a node by id. The graph it was written against can move
;;; under it: the node may be edited (a different hash) or deleted entirely.
;;; We hash the node's content into the save, and on restore we resolve where
;;; to actually land: the saved node if it is intact, otherwise the most
;;; recent visited node that still exists.

(-> node-content-signature (t) string)
(defun node-content-signature (node)
  "A canonical string of a node's content for hashing. Dynamic (computed)
targets collapse to a marker, since they have no stable printed form."
  (flet ((tgt (target) (cond ((stringp target) target)
                             (target "<dyn>")
                             (t "<none>"))))
    (with-output-to-string (out)
      (format out "~a~%~a~%~a~%~a~%"
              (node-id node)
              (or (node-text node) "")
              (or (node-speaker node) "")
              (or (node-minigame node) ""))
      (format out "next:~a target:~a ok:~a fail:~a~%"
              (tgt (node-next node)) (tgt (node-target node))
              (tgt (node-success-target node)) (tgt (node-failure-target node)))
      (map nil
           (lambda (choice)
             (format out "choice:~a>~a~%"
                     (choice-label choice) (tgt (choice-target choice))))
           (node-choices node))
      (map nil
           (lambda (entry)
             (format out "line:~a:~a>~a~%"
                     (conversation-entry-side entry)
                     (conversation-entry-speaker entry)
                     (conversation-entry-text entry)))
           (node-conversation node)))))

(-> node-content-hash (t) (option integer))
(defun node-content-hash (node)
  (when node
    (sxhash (node-content-signature node))))

(-> most-recent-existing-visited-node (save-data) (option string))
(defun most-recent-existing-visited-node (data)
  "The newest visited node (the visited log is kept newest-first) that still
exists in the loaded graph, other than the saved current node."
  (let ((current (save-data-current-id data)))
    (loop for entry in (save-data-list data :visited)
          for id = (and (consp entry) (car entry))
          when (and (stringp id)
                    (not (equal id current))
                    (node-exists-p id))
            return id)))

(defvar *save-landing-status* :ok
  "Status of the last save restore: :ok, :missing, or :changed.")

(-> save-landing (save-data) (values string keyword))
(defun save-landing (data)
  "Where a save should resume. Returns (values target status): :ok if the
saved node is intact; :missing if it is gone; :changed if it still exists but
its content differs from when the save was written. For :missing or :changed,
target is the most recent visited node that still exists, otherwise the saved
node (if any) or the story start."
  (let* ((current   (save-data-current-id data))
         (node      (and (stringp current) (gethash current *nodes*)))
         (saved-hash (getf data :current-hash))
         (fallback  (or (most-recent-existing-visited-node data)
                        (and node current)
                        *story-start-node*)))
    (cond
      ((null node) (values fallback :missing))
      ((and (integerp saved-hash)
            (not (eql saved-hash (node-content-hash node))))
       (values fallback :changed))
      (t (values current :ok)))))

(-> save-needs-confirmation-p (save-data) boolean)
(defun save-needs-confirmation-p (data)
  "True when a save points at a node that no longer exists or has changed, so
the player should be asked before resuming at the fallback node."
  (not (eq (nth-value 1 (save-landing data)) :ok)))


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
  (multiple-value-bind (current-id status) (save-landing data)
    (setf *save-landing-status* status)
    (unless (eq status :ok)
      (runtime-warn "Saved node ~s is ~a; resuming at ~s"
                    (save-data-current-id data) status current-id))
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
           ;; a relocated landing node enters fresh; only an intact node keeps
           ;; its saved typewriter / selection / conversation position
           :visible-count (if (eq status :ok)
                              (save-data-nonnegative-integer data :visible-count)
                              0)
           :selected-index (if (eq status :ok)
                               (save-data-nonnegative-integer data :selected-index)
                               0)
           :choice-preview-index 0
           :choice-preview-elapsed 0.0
           :choice-preview-visible-count 0
           :conversation-index
           (if (eq status :ok)
               (save-data-nonnegative-integer data :conversation-index)
               0)
           :input-buffer (save-data-string data :input-buffer)
           :journal-entries (save-data-list data :journal-entries)
           :journal-open-p nil
           :journal-scroll 0
           :journal-visit-index
           (save-data-nonnegative-integer data :journal-visit-index)
           :journal-recorded (save-data-list data :journal-recorded)
           :visited (save-data-list data :visited)))
    (restore-particle-field-state (getf data :particle-field))
    (setf *pending-restored-music* (getf data :story-music))))

(defparameter *save-month-names*
  #("JAN" "FEB" "MAR" "APR" "MAY" "JUN"
    "JUL" "AUG" "SEP" "OCT" "NOV" "DEC"))

(-> save-slot-label (list) string)
(defun save-slot-label (entry)
  (multiple-value-bind (second minute hour day month year)
      (decode-universal-time (max 0 (getf entry :saved-at 0)))
    (declare (ignore second))
    (let* ((playtime (getf entry :playtime 0))
           (name (string-upcase (or (getf entry :player-name) ""))))
      (format nil "~a ~2,'0d ~d  ~2,'0d:~2,'0d  ~dH ~2,'0dM~@[  ~a~]"
              (aref *save-month-names* (1- month))
              day
              year
              hour
              minute
              (floor playtime 3600)
              (floor (mod playtime 3600) 60)
              (when (plusp (length name))
                (subseq name 0 (min 14 (length name))))))))

(-> load-game-slot (string) boolean)
(defun load-game-slot (slot)
  (handler-case
      (progn
        (setf *active-save-slot* slot)
        (let ((data (read-save-data)))
          (when (valid-save-data-p data)
            (restore-play-state-from-save data)
            t)))
    (error () nil)))

(-> delete-save-slot (string) boolean)
(defun delete-save-slot (slot)
  (handler-case
      (let ((path (save-slot-pathname slot)))
        (if (probe-file path)
            (progn
              (delete-file path)
              (when (and *active-save-slot*
                         (string= *active-save-slot* slot))
                (setf *active-save-slot* nil))
              t)
            (progn
              (runtime-warn "Cannot delete missing save slot: ~a" slot)
              nil)))
    (error (condition)
      (runtime-warn "Could not delete save slot ~a: ~a" slot condition)
      nil)))

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
