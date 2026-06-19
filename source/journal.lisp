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
(defconstant +journal-choice-indent+ 36.0)
(defconstant +journal-speech-indent+ 22.0)
(defconstant +journal-input-indent+ 22.0)

(defvar *journal-choice-focus-index* nil)


;;; Render model

(defstruct journal-render-line
  (text        "" :type string)
  (kind        :text :type journal-entry-kind)
  (entry-index 0 :type nonnegative-integer)
  (first-p     nil :type boolean)
  (gap-p       nil :type boolean))


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
          (play-state-journal-scroll *state*) 0
          *journal-choice-focus-index* nil)
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
        (play-state-journal-scroll *state*) 0
        *journal-choice-focus-index* nil)
  (play-choice-switch)
  t)

(-> close-journal () t)
(defun close-journal ()
  (setf (play-state-journal-open-p *state*) nil
        (play-state-journal-scroll *state*) 0
        *journal-choice-focus-index* nil)
  (play-choice-switch)
  t)

(-> journal-scroll-by (integer) nonnegative-integer)
(defun journal-scroll-by (delta)
  (setf *journal-choice-focus-index* nil)
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
        (journal-jump-to-choice -1))
       ((is-key-pressed-p +key-page-down+)
        (journal-jump-to-choice 1))
       ((is-key-pressed-p +key-home+)
        (setf (play-state-journal-scroll *state*) 1000000
              *journal-choice-focus-index* nil))
       ((is-key-pressed-p +key-end+)
        (setf (play-state-journal-scroll *state*) 0
              *journal-choice-focus-index* nil)))
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

(-> journal-choice-label (string) string)
(defun journal-choice-label (text)
  (let* ((clean (journal-clean-text text))
         (length (length clean)))
    (cond
      ((and (>= length 2)
            (char= (char clean 0) #\>)
            (char= (char clean 1) #\Space))
       (subseq clean 2))
      ((and (plusp length)
            (char= (char clean 0) #\>))
       (journal-clean-text (subseq clean 1)))
      (t clean))))

(-> journal-speaker-label (plist) string)
(defun journal-speaker-label (entry)
  (let ((speaker (journal-clean-text (getf entry :speaker ""))))
    (if (plusp (length speaker))
        (string-upcase speaker)
        "")))

(-> journal-entry-display-text (plist) string)
(defun journal-entry-display-text (entry)
  (let ((text (getf entry :text "")))
    (case (getf entry :kind)
      (:choice
       (format nil "CHOICE  ~a" (journal-choice-label text)))
      (:input
       (format nil "YOU  ~a" text))
      ((:say :conversation)
       (let ((speaker (journal-speaker-label entry)))
         (if (plusp (length speaker))
             (format nil "~a  ~a" speaker text)
             text)))
      (:minigame
       (format nil "MINIGAME  ~a" text))
      (t text))))

(-> journal-kind-indent (journal-entry-kind) scalar)
(defun journal-kind-indent (kind)
  (case kind
    (:choice +journal-choice-indent+)
    ((:say :conversation) +journal-speech-indent+)
    (:input +journal-input-indent+)
    (t 0.0)))

(-> journal-entry-wrap-width (plist) scalar)
(defun journal-entry-wrap-width (entry)
  (max 120.0
       (- (journal-content-width)
          (journal-kind-indent (getf entry :kind))
          10.0)))

(-> journal-entry-lines (plist) (list-of string))
(defun journal-entry-lines (entry)
  (wrap-text-lines (journal-entry-display-text entry)
                   +journal-text-size+
                   (journal-entry-wrap-width entry)))

(-> journal-entry-render-lines (plist nonnegative-integer)
    (list-of journal-render-line))
(defun journal-entry-render-lines (entry entry-index)
  (let ((kind (getf entry :kind)))
    (append
     (loop for text in (journal-entry-lines entry)
           for first-p = t then nil
           collect (make-journal-render-line :text text
                                             :kind kind
                                             :entry-index entry-index
                                             :first-p first-p))
     (loop repeat +journal-entry-gap-lines+
           collect (make-journal-render-line :kind kind
                                             :entry-index entry-index
                                             :gap-p t)))))

(-> journal-render-lines () (list-of journal-render-line))
(defun journal-render-lines ()
  (let ((entries (play-state-journal-entries *state*)))
    (if entries
        (loop for entry in entries
              for entry-index from 0
              append (journal-entry-render-lines entry entry-index))
        (list (make-journal-render-line :text "no entries yet"
                                        :kind :text)))))

(-> journal-max-scroll ((list-of journal-render-line)) nonnegative-integer)
(defun journal-max-scroll (lines)
  (max 0 (- (length lines) (journal-visible-line-count))))

(-> journal-clamped-scroll ((list-of journal-render-line)) nonnegative-integer)
(defun journal-clamped-scroll (lines)
  (let ((scroll (min (play-state-journal-scroll *state*)
                     (journal-max-scroll lines))))
    (setf (play-state-journal-scroll *state*) scroll)
    scroll))

(-> journal-visible-window ((list-of journal-render-line))
    (values nonnegative-integer nonnegative-integer))
(defun journal-visible-window (lines)
  (let* ((visible-count (journal-visible-line-count))
         (scroll        (journal-clamped-scroll lines))
         (end           (max 0 (- (length lines) scroll)))
         (start         (max 0 (- end visible-count))))
    (values start end)))

(-> journal-visible-lines ((list-of journal-render-line))
    (list-of journal-render-line))
(defun journal-visible-lines (lines)
  (multiple-value-bind (start end)
      (journal-visible-window lines)
    (subseq lines start end)))

(-> journal-scroll-for-start-index
    ((list-of journal-render-line) nonnegative-integer)
    nonnegative-integer)
(defun journal-scroll-for-start-index (lines start)
  (let* ((visible-count (journal-visible-line-count))
         (target-end    (min (length lines)
                             (+ start visible-count))))
    (max 0 (- (length lines) target-end))))

(-> journal-choice-line-indexes ((list-of journal-render-line))
    (list-of nonnegative-integer))
(defun journal-choice-line-indexes (lines)
  (loop for line in lines
        for index from 0
        when (and (eq (journal-render-line-kind line) :choice)
                  (journal-render-line-first-p line)
                  (not (journal-render-line-gap-p line)))
          collect index))

(-> journal-previous-choice-line-index
    ((list-of journal-render-line) nonnegative-integer)
    (option nonnegative-integer))
(defun journal-previous-choice-line-index (lines reference)
  (loop for index in (journal-choice-line-indexes lines)
        when (< index reference)
          maximize index))

(-> journal-next-choice-line-index
    ((list-of journal-render-line) nonnegative-integer)
    (option nonnegative-integer))
(defun journal-next-choice-line-index (lines reference)
  (loop for index in (journal-choice-line-indexes lines)
        when (> index reference)
          return index))

(-> journal-choice-reference-index
    ((list-of journal-render-line))
    nonnegative-integer)
(defun journal-choice-reference-index (lines)
  (multiple-value-bind (start end)
      (journal-visible-window lines)
    (declare (ignore start))
    (min (length lines)
         (or *journal-choice-focus-index* end))))

(-> journal-jump-to-choice (navigation-direction) boolean)
(defun journal-jump-to-choice (direction)
  (let* ((lines (journal-render-lines))
         (reference (journal-choice-reference-index lines))
         (target (if (plusp direction)
                     (journal-next-choice-line-index lines reference)
                     (journal-previous-choice-line-index lines reference))))
    (when target
      (setf *journal-choice-focus-index* target)
      (setf (play-state-journal-scroll *state*)
            (journal-scroll-for-start-index lines target))
      (play-choice-switch)
      t)))

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
  (draw-text-at "J CLOSE   UP/DOWN SCROLL   PGUP/PGDN CHOICES   HOME/END"
                (journal-content-left)
                (- (+ +journal-panel-top+ +journal-panel-height+) 36.0)
                14
                (make-color 255 255 255 190)))

(-> journal-render-line-color (journal-render-line t) t)
(defun journal-render-line-color (line base-color)
  (declare (ignore base-color))
  (if (journal-render-line-gap-p line)
      (make-color 255 255 255 0)
      (case (journal-render-line-kind line)
        (:choice (make-color 255 255 255 255))
        ((:say :conversation) (make-color 255 255 255 245))
        (:input (make-color 255 255 255 230))
        (:scene (make-color 255 255 255 190))
        (:minigame (make-color 255 255 255 218))
        (t (make-color 255 255 255 210)))))

(-> journal-render-line-x (journal-render-line) scalar)
(defun journal-render-line-x (line)
  (+ (journal-content-left)
     (journal-kind-indent (journal-render-line-kind line))))

(-> draw-journal-choice-marker (scalar scalar t) t)
(defun draw-journal-choice-marker (x y color)
  (let ((mid-y (+ y (/ +journal-line-height+ 2.0))))
    (draw-triangle-points (+ x 14.0) mid-y
                          x (- mid-y 8.0)
                          x (+ mid-y 8.0)
                          color
                          :filled-p t)
    (claylib/ll:draw-rectangle (round (+ x 18.0))
                               (round (- mid-y 2.0))
                               11
                               4
                               (claylib::c-ptr color))))

(-> draw-journal-speech-marker (scalar scalar t) t)
(defun draw-journal-speech-marker (x y color)
  (claylib/ll:draw-rectangle (round (+ x 3.0))
                             (round (+ y 2.0))
                             4
                             (round (- +journal-line-height+ 5.0))
                             (claylib::c-ptr color)))

(-> draw-journal-input-marker (scalar scalar t) t)
(defun draw-journal-input-marker (x y color)
  (let ((mid-y (+ y (/ +journal-line-height+ 2.0))))
    (claylib/ll:draw-rectangle (round (+ x 2.0))
                               (round (- mid-y 2.0))
                               12
                               4
                               (claylib::c-ptr color))))

(-> draw-journal-line-marker (journal-render-line scalar scalar t) t)
(defun draw-journal-line-marker (line x y color)
  (when (and (journal-render-line-first-p line)
             (not (journal-render-line-gap-p line)))
    (case (journal-render-line-kind line)
      (:choice (draw-journal-choice-marker x y color))
      ((:say :conversation) (draw-journal-speech-marker x y color))
      (:input (draw-journal-input-marker x y color)))))

(-> draw-journal-lines ((list-of journal-render-line) t) t)
(defun draw-journal-lines (lines color)
  (loop for line in lines
        for row from 0
        for y = (+ (journal-content-top)
                   (* row +journal-line-height+))
        for line-color = (journal-render-line-color line color)
        unless (journal-render-line-gap-p line)
          do (draw-journal-line-marker line
                                       (journal-content-left)
                                       y
                                       line-color)
             (draw-text-at (journal-render-line-text line)
                           (journal-render-line-x line)
                           y
                           +journal-text-size+
                           line-color)))

(-> draw-journal-scrollbar ((list-of journal-render-line) t) t)
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
