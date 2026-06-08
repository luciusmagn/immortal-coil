(in-package #:immortal-coil)

;;; Whitespace wrapping

(-> text-newline-char-p (character) boolean)
(defun text-newline-char-p (char)
  (or (char= char #\Newline)
      (char= char #\Return)))

(-> text-space-char-p (character) boolean)
(defun text-space-char-p (char)
  (not (null (member char '(#\Space #\Tab) :test #'char=))))

(-> split-text-paragraphs (string) (list-of string))
(defun split-text-paragraphs (text)
  (let ((paragraphs nil)
        (start      0))
    (loop for index from 0 below (length text)
          when (text-newline-char-p (char text index))
            do (push (subseq text start index) paragraphs)
               (setf start (1+ index)))
    (push (subseq text start) paragraphs)
    (nreverse paragraphs)))

(-> paragraph-words (string) (list-of string))
(defun paragraph-words (paragraph)
  (let ((words nil)
        (index 0)
        (length (length paragraph)))
    (loop while (< index length)
          do (loop while (and (< index length)
                              (text-space-char-p (char paragraph index)))
                   do (incf index))
             (let ((start index))
               (loop while (and (< index length)
                                 (not (text-space-char-p
                                       (char paragraph index))))
                     do (incf index))
               (when (< start index)
                 (push (subseq paragraph start index) words))))
    (nreverse words)))

(-> estimated-text-width (string nonnegative-integer) nonnegative-integer)
(defun estimated-text-width (text size)
  (round (* (length text) size 0.58)))

(-> text-width (string nonnegative-integer) nonnegative-integer)
(defun text-width (text size)
  (let ((measured-width (measure-text text size)))
    (if (or (plusp measured-width)
            (zerop (length text)))
        measured-width
        (estimated-text-width text size))))

(-> text-fits-width-p (string nonnegative-integer scalar) boolean)
(defun text-fits-width-p (text size max-width)
  (<= (text-width text size) max-width))

(-> word-fragment-end (string nonnegative-integer nonnegative-integer scalar)
    nonnegative-integer)
(defun word-fragment-end (word start size max-width)
  (let ((end  (1+ start))
        (last (1+ start)))
    (loop while (and (<= end (length word))
                     (text-fits-width-p (subseq word start end)
                                        size
                                        max-width))
          do (setf last end)
             (incf end))
    last))

(-> split-overlong-word (string nonnegative-integer scalar) (list-of string))
(defun split-overlong-word (word size max-width)
  (let ((fragments nil)
        (start     0))
    (loop while (< start (length word))
          for end = (word-fragment-end word start size max-width)
          do (push (subseq word start end) fragments)
             (setf start end))
    (nreverse fragments)))

(-> wrap-text-word (string
                    (list-of string)
                    string
                    nonnegative-integer
                    scalar)
    (values string (list-of string)))
(defun wrap-text-word (line lines word size max-width)
  (let ((candidate (if (zerop (length line))
                       word
                       (format nil "~a ~a" line word))))
    (cond
      ((text-fits-width-p candidate size max-width)
       (values candidate lines))
      ((plusp (length line))
       (wrap-text-word "" (cons line lines) word size max-width))
      (t
       (let ((fragments (split-overlong-word word size max-width)))
         (if (rest fragments)
             (values (car (last fragments))
                     (append (reverse (butlast fragments)) lines))
             (values word lines)))))))

(-> wrap-paragraph-lines (string nonnegative-integer scalar) (list-of string))
(defun wrap-paragraph-lines (paragraph size max-width)
  (let ((words (paragraph-words paragraph)))
    (if words
        (loop with line = ""
              with lines = nil
              for word in words
              do (multiple-value-setq (line lines)
                   (wrap-text-word line lines word size max-width))
              finally (return (nreverse (if (plusp (length line))
                                            (cons line lines)
                                            lines))))
        (list ""))))

(-> wrap-text-lines (string nonnegative-integer scalar) (list-of string))
(defun wrap-text-lines (text size max-width)
  (loop for paragraph in (split-text-paragraphs text)
        append (wrap-paragraph-lines paragraph size max-width)))

(-> visible-text-lines ((list-of string) nonnegative-integer) (list-of string))
(defun visible-text-lines (lines visible-count)
  (let ((visible-lines nil)
        (remaining     visible-count)
        (done-p        nil))
    (dolist (line lines)
      (unless done-p
        (let ((line-length (length line)))
          (cond
            ((>= remaining line-length)
             (push line visible-lines)
             (decf remaining line-length))
            ((plusp remaining)
             (push (subseq line 0 remaining) visible-lines)
             (setf done-p t))
            (t
             (setf done-p t))))))
    (or (nreverse visible-lines)
        (list ""))))


;;; Centered drawing

(-> centered-line-start-y (nonnegative-integer scalar nonnegative-integer scalar)
    scalar)
(defun centered-line-start-y (line-count center-y size line-height)
  (- center-y
     (/ (+ size
           (* line-height (max 0 (1- line-count))))
        2.0)))

(-> draw-centered-text-lines ((list-of string)
                              scalar
                              scalar
                              nonnegative-integer
                              t
                              &key
                              (:line-height scalar))
    (values scalar scalar nonnegative-integer))
(defun draw-centered-text-lines (lines center-x center-y size color
                                 &key (line-height *dialog-text-line-height*))
  (let* ((visible-lines (if lines lines (list "")))
         (start-y       (centered-line-start-y (length visible-lines)
                                               center-y
                                               size
                                               line-height))
         (last-x        center-x)
         (last-y        start-y)
         (last-width    0))
    (loop for line in visible-lines
          for row from 0
          for width = (text-width line size)
          for x = (- center-x (/ width 2.0))
          for y = (+ start-y (* row line-height))
          do (draw-text-at line x y size color)
             (setf last-x x
                   last-y y
                   last-width width))
    (values last-x last-y last-width)))

(-> draw-wrapped-centered-text (string
                                scalar
                                scalar
                                nonnegative-integer
                                t
                                scalar
                                &key
                                (:line-height scalar))
    (values scalar scalar nonnegative-integer))
(defun draw-wrapped-centered-text (text center-x center-y size color max-width
                                   &key
                                     (line-height
                                      *dialog-text-line-height*))
  (draw-centered-text-lines (wrap-text-lines text size max-width)
                            center-x
                            center-y
                            size
                            color
                            :line-height line-height))
