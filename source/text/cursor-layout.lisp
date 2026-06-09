(in-package #:immortal-coil)

;;; Cursor-aware wrapped text

(defstruct text-cursor-layout-segment
  (source-start  0 :type nonnegative-integer)
  (source-end    0 :type nonnegative-integer)
  (display-start 0 :type nonnegative-integer)
  (display-end   0 :type nonnegative-integer))

(defstruct text-cursor-layout-line
  (text         "" :type string)
  (segments     nil :type list)
  (source-start 0 :type nonnegative-integer)
  (source-end   0 :type nonnegative-integer))

(-> text-cursor-layout-empty-line
    (nonnegative-integer nonnegative-integer)
    text-cursor-layout-line)
(defun text-cursor-layout-empty-line (source-start source-end)
  (make-text-cursor-layout-line :source-start source-start
                                :source-end source-end))

(-> text-cursor-layout-line-empty-p (text-cursor-layout-line) boolean)
(defun text-cursor-layout-line-empty-p (line)
  (zerop (length (text-cursor-layout-line-text line))))

(-> text-cursor-layout-line-with-word
    (text-cursor-layout-line string nonnegative-integer nonnegative-integer)
    text-cursor-layout-line)
(defun text-cursor-layout-line-with-word (line word source-start source-end)
  (let* ((old-text (text-cursor-layout-line-text line))
         (empty-p  (zerop (length old-text)))
         (new-text (if empty-p
                       word
                       (format nil "~a ~a" old-text word)))
         (display-start (if empty-p
                            0
                            (1+ (length old-text))))
         (display-end (+ display-start (length word)))
         (segment (make-text-cursor-layout-segment
                   :source-start source-start
                   :source-end source-end
                   :display-start display-start
                   :display-end display-end)))
    (make-text-cursor-layout-line
     :text new-text
     :segments (append (text-cursor-layout-line-segments line)
                       (list segment))
     :source-start (text-cursor-layout-line-source-start line)
     :source-end source-end)))

(-> text-cursor-word-fragments
    (string nonnegative-integer nonnegative-integer scalar)
    list)
(defun text-cursor-word-fragments (word source-start size max-width)
  (let ((fragments nil)
        (start     0))
    (loop while (< start (length word))
          for end = (word-fragment-end word start size max-width)
          do (push (list (subseq word start end)
                         (+ source-start start)
                         (+ source-start end))
                   fragments)
             (setf start end))
    (nreverse fragments)))

(-> text-cursor-layout-line-for-fragment
    (string nonnegative-integer nonnegative-integer)
    text-cursor-layout-line)
(defun text-cursor-layout-line-for-fragment (fragment source-start source-end)
  (text-cursor-layout-line-with-word
   (text-cursor-layout-empty-line source-start source-start)
   fragment
   source-start
   source-end))

(-> text-cursor-layout-add-overlong-word
    (string
     nonnegative-integer
     nonnegative-integer
     nonnegative-integer
     scalar
     list)
    (values text-cursor-layout-line list))
(defun text-cursor-layout-add-overlong-word (word
                                             source-start
                                             source-end
                                             size
                                             max-width
                                             lines)
  (declare (ignore source-end))
  (let ((fragments (text-cursor-word-fragments word
                                               source-start
                                               size
                                               max-width)))
    (loop for fragment in (butlast fragments)
          do (destructuring-bind (text start end) fragment
               (push (text-cursor-layout-line-for-fragment text start end)
                     lines)))
    (destructuring-bind (text start end)
        (first (last fragments))
      (values (text-cursor-layout-line-for-fragment text start end)
              lines))))

(-> text-cursor-layout-add-word
    (text-cursor-layout-line
     list
     string
     nonnegative-integer
     nonnegative-integer
     nonnegative-integer
     scalar)
    (values text-cursor-layout-line list))
(defun text-cursor-layout-add-word (line
                                    lines
                                    word
                                    source-start
                                    source-end
                                    size
                                    max-width)
  (let* ((line-text (text-cursor-layout-line-text line))
         (candidate (if (zerop (length line-text))
                        word
                        (format nil "~a ~a" line-text word))))
    (cond
      ((text-fits-width-p candidate size max-width)
       (values (text-cursor-layout-line-with-word line
                                                  word
                                                  source-start
                                                  source-end)
               lines))
      ((not (text-cursor-layout-line-empty-p line))
       (text-cursor-layout-add-word
        (text-cursor-layout-empty-line source-start source-start)
        (cons line lines)
        word
        source-start
        source-end
        size
        max-width))
      (t
       (text-cursor-layout-add-overlong-word word
                                             source-start
                                             source-end
                                             size
                                             max-width
                                             lines)))))

(-> text-paragraph-ranges (string) list)
(defun text-paragraph-ranges (text)
  (let ((ranges nil)
        (start 0))
    (loop for index from 0 below (length text)
          when (text-newline-char-p (char text index))
            do (push (list start index) ranges)
               (setf start (1+ index)))
    (push (list start (length text)) ranges)
    (nreverse ranges)))

(-> text-cursor-layout-paragraph
    (string nonnegative-integer nonnegative-integer nonnegative-integer scalar list)
    list)
(defun text-cursor-layout-paragraph (text start end size max-width lines)
  (let ((index start)
        (line (text-cursor-layout-empty-line start start))
        (word-seen-p nil))
    (loop while (< index end)
          do (loop while (and (< index end)
                              (text-space-char-p (char text index)))
                   do (incf index))
             (let ((word-start index))
               (loop while (and (< index end)
                                 (not (text-space-char-p
                                       (char text index))))
                     do (incf index))
               (when (< word-start index)
                 (setf word-seen-p t)
                 (multiple-value-setq (line lines)
                   (text-cursor-layout-add-word
                    line
                    lines
                    (subseq text word-start index)
                    word-start
                    index
                    size
                    max-width)))))
    (cons (if word-seen-p
              line
              (text-cursor-layout-empty-line start end))
          lines)))

(-> text-cursor-layout-lines (string nonnegative-integer scalar)
    (list-of text-cursor-layout-line))
(defun text-cursor-layout-lines (text size max-width)
  (let ((lines nil))
    (dolist (range (text-paragraph-ranges text))
      (destructuring-bind (start end) range
        (setf lines
              (text-cursor-layout-paragraph text
                                            start
                                            end
                                            size
                                            max-width
                                            lines))))
    (or (nreverse lines)
        (list (text-cursor-layout-empty-line 0 0)))))

(-> text-cursor-layout-line-strings
    ((list-of text-cursor-layout-line))
    (list-of string))
(defun text-cursor-layout-line-strings (lines)
  (mapcar #'text-cursor-layout-line-text lines))

(-> text-cursor-layout-end-width
    (text-cursor-layout-line nonnegative-integer)
    nonnegative-integer)
(defun text-cursor-layout-end-width (line size)
  (text-width (text-cursor-layout-line-text line) size))

(-> text-cursor-layout-prefix-width
    (text-cursor-layout-line nonnegative-integer nonnegative-integer)
    nonnegative-integer)
(defun text-cursor-layout-prefix-width (line display-index size)
  (text-width (subseq (text-cursor-layout-line-text line)
                      0
                      (min display-index
                           (length (text-cursor-layout-line-text line))))
              size))

(-> text-cursor-layout-line-cursor-width
    (text-cursor-layout-line nonnegative-integer nonnegative-integer)
    (values boolean nonnegative-integer))
(defun text-cursor-layout-line-cursor-width (line cursor size)
  (let ((segments (text-cursor-layout-line-segments line)))
    (cond
      ((null segments)
       (values (and (<= (text-cursor-layout-line-source-start line) cursor)
                    (<= cursor (text-cursor-layout-line-source-end line)))
               0))
      ((or (< cursor (text-cursor-layout-line-source-start line))
           (> cursor (text-cursor-layout-line-source-end line)))
       (values nil 0))
      (t
       (loop with previous-segment = nil
             for segment in segments
             do (cond
                  ((< cursor
                      (text-cursor-layout-segment-source-start segment))
                   (return
                     (values t
                             (if previous-segment
                                 (text-cursor-layout-prefix-width
                                  line
                                  (text-cursor-layout-segment-display-start
                                   segment)
                                  size)
                                 0))))
                  ((<= cursor
                       (text-cursor-layout-segment-source-end segment))
                   (let ((display-index
                           (+ (text-cursor-layout-segment-display-start
                               segment)
                              (- cursor
                                 (text-cursor-layout-segment-source-start
                                  segment)))))
                     (return
                       (values t
                               (text-cursor-layout-prefix-width
                                line
                                display-index
                                size))))))
                (setf previous-segment segment)
             finally (return
                       (values t
                               (text-cursor-layout-end-width line size))))))))

(-> text-cursor-layout-placement
    ((list-of text-cursor-layout-line) nonnegative-integer nonnegative-integer)
    (values nonnegative-integer nonnegative-integer))
(defun text-cursor-layout-placement (lines cursor size)
  (let ((fallback-index 0)
        (fallback-width 0))
    (loop for line in lines
          for index from 0
          do (multiple-value-bind (found-p width)
                 (text-cursor-layout-line-cursor-width line cursor size)
               (when found-p
                 (return-from text-cursor-layout-placement
                   (values index width))))
             (when (<= (text-cursor-layout-line-source-end line) cursor)
               (setf fallback-index index
                     fallback-width (text-cursor-layout-end-width line size))))
    (values fallback-index fallback-width)))
