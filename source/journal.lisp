(in-package #:immortal-coil)

;;; Chronological gameplay journal

(defconstant +journal-max-entries+ 600)
(defconstant +journal-panel-left+ 116.0)
(defconstant +journal-panel-top+ 78.0)
(defconstant +journal-panel-width+ 1048.0)
(defconstant +journal-panel-height+ 564.0)
(defconstant +journal-padding-x+ 34.0)
(defconstant +journal-padding-y+ 28.0)
(defconstant +journal-title-size+ 24)
(defconstant +journal-text-size+ 16)
(defconstant +journal-line-height+ 22.0)
(defconstant +journal-entry-gap-lines+ 1)


;;; Entry storage

(-> journal-begin-node-visit (node) nonnegative-integer)
(defun journal-begin-node-visit (node)
  (declare (ignore node))
  (when *state*
    (incf (play-state-journal-visit-index *state*))
    (setf (play-state-journal-recorded *state*) nil)
    (play-state-journal-visit-index *state*)))

(-> journal-record-key (journal-entry-kind t) list)
(defun journal-record-key (kind detail)
  (list (play-state-journal-visit-index *state*) kind detail))

(-> journal-recorded-p (list) boolean)
(defun journal-recorded-p (key)
  (not (null (member key
                     (play-state-journal-recorded *state*)
                     :test #'equal))))

(-> journal-mark-recorded (list) list)
(defun journal-mark-recorded (key)
  (push key (play-state-journal-recorded *state*)))

(-> journal-clean-text (t) string)
(defun journal-clean-text (text)
  (string-trim '(#\Space #\Tab #\Newline #\Return)
               (if (stringp text) text (princ-to-string text))))

(-> journal-text-present-p (string) boolean)
(defun journal-text-present-p (text)
  (plusp (length (journal-clean-text text))))

(-> make-journal-entry (journal-entry-kind dialog-id string string) plist)
(defun make-journal-entry (kind node-id speaker text)
  (list :kind kind
        :node-id node-id
        :speaker (journal-clean-text speaker)
        :text (journal-clean-text text)))

(-> journal-trim-entries (list) list)
(defun journal-trim-entries (entries)
  (let ((count (length entries)))
    (if (> count +journal-max-entries+)
        (last entries +journal-max-entries+)
        entries)))

(-> journal-add-entry (plist) plist)
(defun journal-add-entry (entry)
  (when *state*
    (setf (play-state-journal-entries *state*)
          (journal-trim-entries
           (append (play-state-journal-entries *state*)
                   (list entry)))
          (play-state-journal-scroll *state*) 0)
    entry))

(-> journal-record-once
    (journal-entry-kind t dialog-id string string)
    (option plist))
(defun journal-record-once (kind detail node-id speaker text)
  (when (and *state*
             (journal-text-present-p text))
    (let ((key (journal-record-key kind detail)))
      (unless (journal-recorded-p key)
        (journal-mark-recorded key)
        (journal-add-entry
         (make-journal-entry kind node-id speaker text))))))

(-> journal-record-node-visible (node) (option plist))
(defun journal-record-node-visible (node)
  (let ((kind (node-kind node)))
    (journal-record-once (case kind
                           (:say :say)
                           (:scene :scene)
                           (:minigame :minigame)
                           (t :text))
                         :node
                         (node-id node)
                         (or (node-speaker node) "")
                         (node-display-text node))))

(-> journal-record-choice-selection (node choice) (option plist))
(defun journal-record-choice-selection (node choice)
  (journal-record-once :choice
                       (list :choice (play-state-selected-index *state*))
                       (node-id node)
                       "choice"
                       (format nil "> ~a" (choice-display-label choice))))

(-> journal-record-input-response (node string) (option plist))
(defun journal-record-input-response (node value)
  (journal-record-once :input
                       :input
                       (node-id node)
                       "you"
                       value))

(-> journal-record-conversation-entry (node conversation-entry) (option plist))
(defun journal-record-conversation-entry (node entry)
  (journal-record-once :conversation
                       (list :conversation
                             (play-state-conversation-index *state*))
                       (node-id node)
                       (conversation-entry-display-speaker entry)
                       (conversation-entry-display-text entry)))


;;; Input

(-> journal-open-p () boolean)
(defun journal-open-p ()
  (and *state*
       (play-state-journal-open-p *state*)))

(-> input-node-capturing-text-p () boolean)
(defun input-node-capturing-text-p ()
  (and *state*
       (typep (current-node) 'input-node)
       (story-text-visible-p (current-node))))

(-> journal-key-pressed-p () boolean)
(defun journal-key-pressed-p ()
  (is-key-pressed-p +key-j+))

(-> journal-toggle-pressed-p () boolean)
(defun journal-toggle-pressed-p ()
  (and (journal-key-pressed-p)
       (not (input-node-capturing-text-p))))

(-> open-journal () t)
(defun open-journal ()
  (setf (play-state-journal-open-p *state*) t
        (play-state-journal-scroll *state*) 0)
  (play-choice-switch)
  t)

(-> close-journal () t)
(defun close-journal ()
  (setf (play-state-journal-open-p *state*) nil
        (play-state-journal-scroll *state*) 0)
  (play-choice-switch)
  t)

(-> journal-scroll-by (integer) nonnegative-integer)
(defun journal-scroll-by (delta)
  (setf (play-state-journal-scroll *state*)
        (max 0 (+ (play-state-journal-scroll *state*) delta))))

(-> update-journal-controls () boolean)
(defun update-journal-controls ()
  (cond
    ((journal-open-p)
     (cond
       ((or (is-key-pressed-p +key-escape+)
            (journal-key-pressed-p))
        (close-journal))
       ((or (is-key-pressed-p +key-up+)
            (is-key-pressed-p +key-w+))
        (journal-scroll-by 3))
       ((or (is-key-pressed-p +key-down+)
            (is-key-pressed-p +key-s+))
        (journal-scroll-by -3))
       ((is-key-pressed-p +key-page-up+)
        (journal-scroll-by 12))
       ((is-key-pressed-p +key-page-down+)
        (journal-scroll-by -12))
       ((is-key-pressed-p +key-home+)
        (setf (play-state-journal-scroll *state*) 1000000))
       ((is-key-pressed-p +key-end+)
        (setf (play-state-journal-scroll *state*) 0)))
     t)
    ((journal-toggle-pressed-p)
     (open-journal)
     t)
    (t nil)))


;;; Rendering

(-> journal-content-left () scalar)
(defun journal-content-left ()
  (+ +journal-panel-left+ +journal-padding-x+))

(-> journal-content-top () scalar)
(defun journal-content-top ()
  (+ +journal-panel-top+ +journal-padding-y+ 52.0))

(-> journal-content-width () scalar)
(defun journal-content-width ()
  (- +journal-panel-width+ (* 2 +journal-padding-x+) 30.0))

(-> journal-content-height () scalar)
(defun journal-content-height ()
  (- +journal-panel-height+ (* 2 +journal-padding-y+) 94.0))

(-> journal-visible-line-count () nonnegative-integer)
(defun journal-visible-line-count ()
  (max 1 (floor (/ (journal-content-height)
                   +journal-line-height+))))

(-> journal-entry-prefix (plist) string)
(defun journal-entry-prefix (entry)
  (let ((speaker (getf entry :speaker)))
    (case (getf entry :kind)
      (:choice "")
      (:scene "")
      (:minigame "")
      (t (if (and speaker (plusp (length speaker)))
             (format nil "~a: " speaker)
             "")))))

(-> journal-entry-display-text (plist) string)
(defun journal-entry-display-text (entry)
  (let ((prefix (journal-entry-prefix entry)))
    (format nil "~a~a" prefix (getf entry :text ""))))

(-> journal-entry-lines (plist) (list-of string))
(defun journal-entry-lines (entry)
  (wrap-text-lines (journal-entry-display-text entry)
                   +journal-text-size+
                   (journal-content-width)))

(-> journal-render-lines () (list-of string))
(defun journal-render-lines ()
  (let ((entries (play-state-journal-entries *state*)))
    (if entries
        (loop for entry in entries
              append (append (journal-entry-lines entry)
                             (make-list +journal-entry-gap-lines+
                                        :initial-element "")))
        (list "no entries yet"))))

(-> journal-max-scroll ((list-of string)) nonnegative-integer)
(defun journal-max-scroll (lines)
  (max 0 (- (length lines) (journal-visible-line-count))))

(-> journal-clamped-scroll ((list-of string)) nonnegative-integer)
(defun journal-clamped-scroll (lines)
  (let ((scroll (min (play-state-journal-scroll *state*)
                     (journal-max-scroll lines))))
    (setf (play-state-journal-scroll *state*) scroll)
    scroll))

(-> journal-visible-lines ((list-of string)) (list-of string))
(defun journal-visible-lines (lines)
  (let* ((visible-count (journal-visible-line-count))
         (scroll        (journal-clamped-scroll lines))
         (end           (max 0 (- (length lines) scroll)))
         (start         (max 0 (- end visible-count))))
    (subseq lines start end)))

(-> draw-journal-panel (t) t)
(defun draw-journal-panel (color)
  (claylib/ll:draw-rectangle (round +journal-panel-left+)
                             (round +journal-panel-top+)
                             (round +journal-panel-width+)
                             (round +journal-panel-height+)
                             (claylib::c-ptr
                              (make-color 0 0 0 248)))
  (draw-rectangle-outline +journal-panel-left+
                          +journal-panel-top+
                          +journal-panel-width+
                          +journal-panel-height+
                          color
                          :thickness 2)
  (draw-centered-text "JOURNAL"
                      +virtual-center-x+
                      (+ +journal-panel-top+ 38.0)
                      +journal-title-size+
                      color)
  (draw-text-at "J CLOSE   UP/DOWN SCROLL   HOME/END"
                (journal-content-left)
                (- (+ +journal-panel-top+ +journal-panel-height+) 36.0)
                14
                (make-color 255 255 255 190)))

(-> draw-journal-lines ((list-of string) t) t)
(defun draw-journal-lines (lines color)
  (loop for line in lines
        for row from 0
        do (draw-text-at line
                         (journal-content-left)
                         (+ (journal-content-top)
                            (* row +journal-line-height+))
                         +journal-text-size+
                         color)))

(-> draw-journal-scrollbar ((list-of string) t) t)
(defun draw-journal-scrollbar (lines color)
  (let* ((max-scroll (journal-max-scroll lines))
         (visible-count (journal-visible-line-count)))
    (when (plusp max-scroll)
      (let* ((track-height (journal-content-height))
             (track-left (+ +journal-panel-left+
                            +journal-panel-width+
                            -42.0))
             (track-top (journal-content-top))
             (thumb-height (max 28.0
                                (* track-height
                                   (/ visible-count
                                      (max visible-count
                                           (length lines))))))
             (progress (- 1.0
                          (/ (play-state-journal-scroll *state*)
                             (float max-scroll 1.0))))
             (thumb-top (+ track-top
                           (* (- track-height thumb-height)
                              (clamp01 progress)))))
        (claylib/ll:draw-rectangle (round track-left)
                                   (round track-top)
                                   3
                                   (round track-height)
                                   (claylib::c-ptr
                                    (make-color 255 255 255 70)))
        (claylib/ll:draw-rectangle (round (- track-left 2))
                                   (round thumb-top)
                                   7
                                   (round thumb-height)
                                   (claylib::c-ptr color))))))

(-> draw-journal-overlay () t)
(defun draw-journal-overlay ()
  (when (journal-open-p)
    (let* ((color (make-color 255 255 255 245))
           (lines (journal-render-lines)))
      (draw-journal-panel color)
      (draw-journal-lines (journal-visible-lines lines) color)
      (draw-journal-scrollbar lines color))))
