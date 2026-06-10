(in-package #:immortal-coil)

;;; Text editing

(-> editor-node-text-editable-p (node) boolean)
(defun editor-node-text-editable-p (node)
  (not (null (member (node-kind node)
                     '(:text :say :choice :number :string :minigame)))))

(-> editor-start-text-edit () boolean)
(defun editor-start-text-edit ()
  (if (and *editor-active-p* *state*)
      (let ((node (current-node)))
        (if (editor-node-text-editable-p node)
            (progn
              (setf *editor-mode* :edit-text
                    *editor-edit-node-id* (node-id node)
                    *editor-text-buffer* (node-text node)
                    *editor-text-cursor-index* (length *editor-text-buffer*)
                    *editor-text-backspace-held-seconds* 0.0
                    *editor-text-backspace-repeat-accumulator* 0.0
                    *editor-text-cursor-held-seconds* 0.0
                    *editor-text-cursor-repeat-accumulator* 0.0
                    *editor-text-cursor-repeat-direction* nil
                    *editor-status-message* "EDITOR: EDITING TEXT")
              (play-choice-switch)
              t)
            (progn
              (setf *editor-status-message* "EDITOR: TEXT NOT EDITABLE")
              (play-choice-switch)
              nil)))
      nil))

(-> editor-text-buffer-length () nonnegative-integer)
(defun editor-text-buffer-length ()
  (length *editor-text-buffer*))

(-> editor-clamp-text-cursor () nonnegative-integer)
(defun editor-clamp-text-cursor ()
  (setf *editor-text-cursor-index*
        (min (max 0 *editor-text-cursor-index*)
             (editor-text-buffer-length))))

(-> editor-set-text-cursor (integer) nonnegative-integer)
(defun editor-set-text-cursor (index)
  (setf *editor-text-cursor-index*
        (min (max 0 index)
             (editor-text-buffer-length))))

(-> editor-move-text-cursor (integer) nonnegative-integer)
(defun editor-move-text-cursor (delta)
  (editor-set-text-cursor (+ (editor-clamp-text-cursor) delta)))

(-> editor-insert-text-character (character) boolean)
(defun editor-insert-text-character (char)
  (and (< (length *editor-text-buffer*) *editor-text-max-length*)
       (let* ((cursor (editor-clamp-text-cursor))
              (prefix (subseq *editor-text-buffer* 0 cursor))
              (suffix (subseq *editor-text-buffer* cursor)))
         (setf *editor-text-buffer*
               (concatenate 'string prefix (string char) suffix)
               *editor-text-cursor-index* (1+ cursor))
         (play-input-click)
         t)))

(-> editor-delete-text-characters (nonnegative-integer) boolean)
(defun editor-delete-text-characters (count)
  (let* ((cursor (editor-clamp-text-cursor))
         (delete-count (min count cursor)))
    (when (plusp delete-count)
      (setf *editor-text-buffer*
            (concatenate 'string
                         (subseq *editor-text-buffer*
                                 0
                                 (- cursor delete-count))
                         (subseq *editor-text-buffer* cursor))
            *editor-text-cursor-index* (- cursor delete-count))
      (play-choice-switch)
      t)))

(-> editor-delete-text-forward-characters (nonnegative-integer) boolean)
(defun editor-delete-text-forward-characters (count)
  (let* ((cursor (editor-clamp-text-cursor))
         (length (editor-text-buffer-length))
         (delete-count (min count (- length cursor))))
    (when (plusp delete-count)
      (setf *editor-text-buffer*
            (concatenate 'string
                         (subseq *editor-text-buffer* 0 cursor)
                         (subseq *editor-text-buffer*
                                 (+ cursor delete-count)))
            *editor-text-cursor-index* cursor)
      (play-choice-switch)
      t)))

(-> reset-editor-text-backspace-repeat () t)
(defun reset-editor-text-backspace-repeat ()
  (setf *editor-text-backspace-held-seconds* 0.0
        *editor-text-backspace-repeat-accumulator* 0.0)
  t)

(-> reset-editor-text-cursor-repeat () t)
(defun reset-editor-text-cursor-repeat ()
  (setf *editor-text-cursor-held-seconds* 0.0
        *editor-text-cursor-repeat-accumulator* 0.0
        *editor-text-cursor-repeat-direction* nil)
  t)

(-> editor-text-backspace-interval () seconds)
(defun editor-text-backspace-interval ()
  (max 0.025
       (- 0.13 (* *editor-text-backspace-held-seconds* 0.04))))

(-> editor-text-cursor-interval () seconds)
(defun editor-text-cursor-interval ()
  (max 0.025
       (- 0.13 (* *editor-text-cursor-held-seconds* 0.04))))

(-> editor-text-backspace-repeat-count (seconds) nonnegative-integer)
(defun editor-text-backspace-repeat-count (dt)
  (cond
    ((not (is-key-down-p +key-backspace+))
     (reset-editor-text-backspace-repeat)
     0)
    ((is-key-pressed-p +key-backspace+)
     (reset-editor-text-backspace-repeat)
     1)
    (t
     (incf *editor-text-backspace-held-seconds* dt)
     (if (< *editor-text-backspace-held-seconds* 0.26)
         0
         (let ((interval (editor-text-backspace-interval))
               (count 0))
           (incf *editor-text-backspace-repeat-accumulator* dt)
           (loop while (>= *editor-text-backspace-repeat-accumulator*
                           interval)
                 do (incf count)
                    (decf *editor-text-backspace-repeat-accumulator*
                          interval))
           count)))))

(-> editor-delete-text-character () boolean)
(defun editor-delete-text-character ()
  (editor-delete-text-characters 1))

(-> editor-delete-text-forward-character () boolean)
(defun editor-delete-text-forward-character ()
  (editor-delete-text-forward-characters 1))

(-> editor-delete-text-repeat (seconds) boolean)
(defun editor-delete-text-repeat (dt)
  (editor-delete-text-characters
   (editor-text-backspace-repeat-count dt)))

(-> editor-text-cursor-held-direction () (option navigation-direction))
(defun editor-text-cursor-held-direction ()
  (let ((left-p  (is-key-down-p +key-left+))
        (right-p (is-key-down-p +key-right+)))
    (cond
      ((and left-p (not right-p)) -1)
      ((and right-p (not left-p)) 1))))

(-> editor-text-cursor-direction-pressed-p (navigation-direction) boolean)
(defun editor-text-cursor-direction-pressed-p (direction)
  (if (minusp direction)
      (is-key-pressed-p +key-left+)
      (is-key-pressed-p +key-right+)))

(-> editor-text-cursor-repeat-delta (seconds) integer)
(defun editor-text-cursor-repeat-delta (dt)
  (let ((direction (editor-text-cursor-held-direction)))
    (cond
      ((null direction)
       (reset-editor-text-cursor-repeat)
       0)
      ((or (not (eql direction *editor-text-cursor-repeat-direction*))
           (editor-text-cursor-direction-pressed-p direction))
       (setf *editor-text-cursor-held-seconds* 0.0
             *editor-text-cursor-repeat-accumulator* 0.0
             *editor-text-cursor-repeat-direction* direction)
       direction)
      (t
       (incf *editor-text-cursor-held-seconds* dt)
       (if (< *editor-text-cursor-held-seconds* 0.26)
           0
           (let ((interval (editor-text-cursor-interval))
                 (count    0))
             (incf *editor-text-cursor-repeat-accumulator* dt)
             (loop while (>= *editor-text-cursor-repeat-accumulator*
                             interval)
                   do (incf count)
                      (decf *editor-text-cursor-repeat-accumulator*
                            interval))
             (* direction count)))))))

(-> drain-editor-text-input (seconds) t)
(defun drain-editor-text-input (dt)
  (unless (editor-control-down-p)
    (loop for code = (get-char-pressed)
          until (zerop code)
          for char = (code-char code)
          when (and char (string-input-character-p char))
            do (editor-insert-text-character char)))
  (editor-delete-text-repeat dt))

(-> editor-cancel-text-edit () boolean)
(defun editor-cancel-text-edit ()
  (setf *editor-mode* :play
        *editor-text-buffer* ""
        *editor-text-cursor-index* 0
        *editor-edit-node-id* nil
        *editor-text-backspace-held-seconds* 0.0
        *editor-text-backspace-repeat-accumulator* 0.0
        *editor-text-cursor-held-seconds* 0.0
        *editor-text-cursor-repeat-accumulator* 0.0
        *editor-text-cursor-repeat-direction* nil
        *editor-status-message* "EDITOR: TEXT EDIT CANCELED")
  (play-choice-switch)
  t)

(-> editor-reset-current-text-display (dialog-id) t)
(defun editor-reset-current-text-display (node-id)
  (when (and *state*
             (equal (play-state-current-id *state*) node-id))
    (setf (play-state-elapsed *state*) 0.0
          (play-state-type-delay *state*) 0.0
          (play-state-visible-count *state*) 0)))

(-> editor-save-text-edit () boolean)
(defun editor-save-text-edit ()
  (let ((node-id *editor-edit-node-id*)
        (text *editor-text-buffer*))
    (if (and node-id
             (node-exists-p node-id)
             (editor-append-text-rewrite node-id text))
        (progn
          (dialog-set-text node-id text)
          (editor-reset-current-text-display node-id)
          (setf *editor-mode* :play
                *editor-text-buffer* ""
                *editor-text-cursor-index* 0
                *editor-edit-node-id* nil
                *editor-text-backspace-held-seconds* 0.0
                *editor-text-backspace-repeat-accumulator* 0.0
                *editor-text-cursor-held-seconds* 0.0
                *editor-text-cursor-repeat-accumulator* 0.0
                *editor-text-cursor-repeat-direction* nil
                *editor-status-message* "EDITOR: TEXT SAVED")
          (play-start-confirm)
          t)
        (progn
          (setf *editor-status-message* "EDITOR: TEXT SAVE FAILED")
          (play-choice-switch)
          nil))))

(-> update-editor-text-cursor-controls (seconds) boolean)
(defun update-editor-text-cursor-controls (dt)
  (let ((delta (editor-text-cursor-repeat-delta dt)))
    (cond
      ((not (zerop delta))
       (editor-move-text-cursor delta)
       t)
      ((is-key-pressed-p +key-home+)
       (reset-editor-text-cursor-repeat)
       (editor-set-text-cursor 0)
       t)
      ((is-key-pressed-p +key-end+)
       (reset-editor-text-cursor-repeat)
       (editor-set-text-cursor (editor-text-buffer-length))
       t)
      ((is-key-pressed-p +key-delete+)
       (reset-editor-text-cursor-repeat)
       (editor-delete-text-forward-character)
       t)
      (t nil))))

(-> update-editor-text-edit (seconds) boolean)
(defun update-editor-text-edit (dt)
  (cond
    ((or (is-key-pressed-p +key-escape+)
         (editor-control-key-pressed-p +key-g+))
     (editor-cancel-text-edit))
    ((or (string-submit-pressed-p)
         (editor-control-key-pressed-p +key-s+))
     (editor-save-text-edit))
    ((or (is-key-pressed-p +key-page-up+)
         (editor-control-key-pressed-p +key-b+))
     (editor-return-to-previous-node))
    ((update-editor-text-cursor-controls dt)
     t)
    (t
     (drain-editor-text-input dt)
     t)))


;;; Controls

(-> editor-toggle-store-overlay () boolean)
(defun editor-toggle-store-overlay ()
  (setf *editor-store-overlay-p* (not *editor-store-overlay-p*)
        *editor-status-message*
        (if *editor-store-overlay-p*
            "EDITOR: STATE SHOWN"
            "EDITOR: STATE HIDDEN"))
  (play-choice-switch)
  t)

(-> editor-toggle-help-overlay () boolean)
(defun editor-toggle-help-overlay ()
  (setf *editor-help-overlay-p* (not *editor-help-overlay-p*)
        *editor-status-message*
        (if *editor-help-overlay-p*
            "EDITOR: HELP SHOWN"
            "EDITOR: HELP HIDDEN"))
  (play-choice-switch)
  t)

(-> editor-close-help-overlay () boolean)
(defun editor-close-help-overlay ()
  (setf *editor-help-overlay-p* nil
        *editor-status-message* "EDITOR: HELP HIDDEN")
  (play-choice-switch)
  t)


;;; Bookmarks

(-> editor-clear-key-prefix () t)
(defun editor-clear-key-prefix ()
  (setf *editor-key-prefix* nil)
  t)

(-> editor-prefix-key-pressed-p (integer) boolean)
(defun editor-prefix-key-pressed-p (key)
  (or (is-key-pressed-p key)
      (editor-control-key-pressed-p key)))

(-> editor-start-key-prefix (editor-key-prefix string) boolean)
(defun editor-start-key-prefix (prefix status)
  (setf *editor-key-prefix* prefix
        *editor-status-message* status)
  t)

(-> editor-cancel-key-prefix () boolean)
(defun editor-cancel-key-prefix ()
  (editor-clear-key-prefix)
  (setf *editor-status-message* "EDITOR: PREFIX CANCELED")
  (play-choice-switch)
  t)

(-> editor-bookmark-node-valid-p (t) boolean)
(defun editor-bookmark-node-valid-p (node-id)
  (and (stringp node-id)
       (node-exists-p node-id)))

(-> editor-prune-bookmarks () list)
(defun editor-prune-bookmarks ()
  (setf *editor-bookmarks*
        (remove-if-not #'editor-bookmark-node-valid-p *editor-bookmarks*)))

(-> editor-bookmark-count () nonnegative-integer)
(defun editor-bookmark-count ()
  (length (editor-prune-bookmarks)))

(-> editor-bookmark-current-node () boolean)
(defun editor-bookmark-current-node ()
  (editor-clear-key-prefix)
  (if (and *editor-active-p* *state*)
      (let ((node-id (play-state-current-id *state*)))
        (setf *editor-bookmarks*
              (cons node-id
                    (remove node-id *editor-bookmarks* :test #'equal))
              *editor-status-message*
              (format nil "EDITOR: BOOKMARKED ~a" node-id))
        (play-start-confirm)
        t)
      (progn
        (setf *editor-status-message* "EDITOR: NO NODE TO BOOKMARK")
        (play-choice-switch)
        nil)))

(-> editor-jump-to-bookmark () boolean)
(defun editor-jump-to-bookmark ()
  (editor-clear-key-prefix)
  (let ((target (first (editor-prune-bookmarks))))
    (cond
      ((null target)
       (setf *editor-status-message* "EDITOR: NO BOOKMARKS")
       (play-choice-switch)
       nil)
      ((jump-to-node target)
       (setf *editor-bookmarks*
             (append (rest *editor-bookmarks*) (list target))
             *editor-status-message*
             (format nil "EDITOR: BOOKMARK ~a" target))
       (play-start-confirm)
       t)
      (t
       (setf *editor-status-message* "EDITOR: BOOKMARK JUMP FAILED")
       (play-choice-switch)
       nil))))

(-> update-editor-key-prefix-controls () boolean)
(defun update-editor-key-prefix-controls ()
  (case *editor-key-prefix*
    (:control-x
     (cond
       ((or (is-key-pressed-p +key-escape+)
            (editor-control-key-pressed-p +key-g+))
        (editor-cancel-key-prefix))
       ((editor-prefix-key-pressed-p +key-r+)
        (editor-start-key-prefix :control-x-r "EDITOR: C-x r"))
       (t t)))
    (:control-x-r
     (cond
       ((or (is-key-pressed-p +key-escape+)
            (editor-control-key-pressed-p +key-g+))
        (editor-cancel-key-prefix))
       ((editor-prefix-key-pressed-p +key-m+)
        (editor-bookmark-current-node))
       ((editor-prefix-key-pressed-p +key-j+)
        (editor-jump-to-bookmark))
       (t t)))
    (t
     (when (editor-control-key-pressed-p +key-x+)
       (editor-start-key-prefix :control-x "EDITOR: C-x")))))

(-> update-editor-help-overlay-controls () boolean)
(defun update-editor-help-overlay-controls ()
  (cond
    ((editor-control-key-pressed-p +key-h+)
     (editor-toggle-help-overlay))
    (*editor-help-overlay-p*
     (when (or (is-key-pressed-p +key-escape+)
               (editor-control-key-pressed-p +key-g+))
       (editor-close-help-overlay))
     t)
    (t nil)))

(-> editor-insert-selection-direction () (option navigation-direction))
(defun editor-insert-selection-direction ()
  (cond
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-right+))
     1)
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-left+))
     -1)))

(-> editor-confirm-insert-menu () boolean)
(defun editor-confirm-insert-menu ()
  (let ((kind (editor-current-insert-kind)))
    (editor-select-insert-kind kind)
    (setf *editor-mode* :play)
    (case *editor-insert-action*
      (:replace
       (setf *editor-insert-action* :insert)
       (editor-replace-current-node kind))
      (t
       (editor-insert-node-at-current-link kind)))))

(-> update-editor-insert-menu () boolean)
(defun update-editor-insert-menu ()
  (let ((direction (editor-insert-selection-direction)))
    (cond
      ((or (is-key-pressed-p +key-escape+)
           (editor-control-key-pressed-p +key-g+))
       (editor-cancel-insert-menu))
      ((and direction
            (editor-move-insert-selection direction))
       t)
      ((confirm-pressed-p)
       (editor-confirm-insert-menu))
      (t t))))

(-> update-editor-controls (&optional seconds) boolean)
(defun update-editor-controls (&optional (dt (get-frame-time)))
  (when *editor-active-p*
    (let ((panel (active-editor-panel)))
      (cond
        (panel
         (panel-update panel dt))
        ((update-editor-help-overlay-controls)
         t)
        ((update-editor-key-prefix-controls)
         t)
        ((or (is-key-pressed-p +key-page-up+)
             (editor-control-key-pressed-p +key-b+))
         (editor-return-to-previous-node)
         t)
        ((or (is-key-pressed-p +key-insert+)
             (editor-control-key-pressed-p +key-i+))
         (editor-open-insert-menu))
        ((editor-control-key-pressed-p +key-r+)
         (editor-open-replace-menu))
        ((editor-control-key-pressed-p +key-a+)
         (editor-add-node-detail))
        ((editor-control-key-pressed-p +key-p+)
         (editor-cycle-current-minigame))
        ((editor-control-key-pressed-p +key-f+)
         (editor-cycle-current-particles))
        ((editor-control-key-pressed-p +key-k+)
         (editor-cycle-current-sound))
        ((editor-control-key-pressed-p +key-m+)
         (editor-cycle-current-music))
        ((editor-control-key-pressed-p +key-l+)
         (editor-start-node-target-edit))
        ((editor-control-key-pressed-p +key-v+)
         (editor-toggle-choice-reveal))
        ((editor-control-key-pressed-p +key-y+)
         (editor-start-node-fields-edit))
        ((or (is-key-pressed-p +key-f3+)
             (editor-control-key-pressed-p +key-s+))
         (editor-toggle-store-overlay))
        ((update-editor-store-overlay-controls)
         t)
        ((editor-control-key-pressed-p +key-o+)
         (editor-start-node-detail-edit))
        ((and (or (is-key-pressed-p +key-delete+)
                  (editor-control-key-pressed-p +key-d+))
              (not *editor-store-overlay-p*))
         (editor-delete-current-node))
        ((or (is-key-pressed-p +key-f2+)
             (editor-control-key-pressed-p +key-e+))
         (editor-start-text-edit))
        ((is-key-pressed-p +key-f6+)
         (editor-cycle-insert-kind))))))


;;; Panel registration

(defclass editor-insert-panel (editor-panel) ())

(register-editor-panel
 (make-instance 'editor-insert-panel :mode :insert))

(defmethod panel-update ((panel editor-insert-panel) dt)
  (declare (ignore dt))
  (update-editor-insert-menu))

(defclass editor-text-edit-panel (editor-panel) ())

(register-editor-panel
 (make-instance 'editor-text-edit-panel :mode :edit-text))

(defmethod panel-update ((panel editor-text-edit-panel) dt)
  (update-editor-text-edit dt))

(defmethod panel-save ((panel editor-text-edit-panel))
  (editor-save-text-edit))
