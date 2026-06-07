(in-package #:immortal-coil)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (-> dialog-id-string (t) string)
  (defun dialog-id-string (value)
    (typecase value
      (string value)
      (symbol (string-downcase (symbol-name value)))
      (t (princ-to-string value))))

  (-> dialog-ascii-alphanumeric-p (character) boolean)
  (defun dialog-ascii-alphanumeric-p (char)
    (or (char<= #\a char #\z)
        (char<= #\A char #\Z)
        (char<= #\0 char #\9)))

  (-> dialog-fragment-character (character) character)
  (defun dialog-fragment-character (char)
    (if (dialog-ascii-alphanumeric-p char)
        (char-downcase char)
        #\-))

  (-> dialog-id-fragment (t) string)
  (defun dialog-id-fragment (value)
    (let ((separator-p t))
      (labels ((write-fragment (stream)
                 (loop for char across (dialog-id-string value)
                       for fragment-char = (dialog-fragment-character char)
                       do (cond
                            ((char= fragment-char #\-)
                             (unless separator-p
                               (write-char #\- stream)
                               (setf separator-p t)))
                            (t
                             (write-char fragment-char stream)
                             (setf separator-p nil))))))
        (let ((fragment (string-right-trim
                         '(#\-)
                         (with-output-to-string (stream)
                           (write-fragment stream)))))
          (if (plusp (length fragment))
              fragment
              "node")))))

  (-> dialog-child-id (t t) dialog-id)
  (defun dialog-child-id (parent child)
    (let ((parent-id (string-right-trim '(#\/) (dialog-id-string parent)))
          (child-id  (dialog-id-fragment child)))
      (if (plusp (length parent-id))
          (format nil "~a/~a" parent-id child-id)
          child-id)))

  (-> dialog-path-node-id (t integer) dialog-id)
  (defun dialog-path-node-id (parent step)
    (if (<= step 1)
        (dialog-id-string parent)
        (dialog-child-id parent step)))

  (-> dialog-path-text-string (t) string)
  (defun dialog-path-text-string (text)
    (typecase text
      (string text)
      (t
       (runtime-warn "Dialog path text should be a string, got: ~s" text)
       (princ-to-string text)))))

(-> dialog-define-path (t list &key (:next (option dialog-id))) dialog-id)
(defun dialog-define-path (id texts &key next)
  (let ((path-id (dialog-id-string id)))
    (if texts
        (loop with count = (length texts)
              for text in texts
              for step from 1
              for node-id = (dialog-path-node-id path-id step)
              for next-id = (cond
                              ((< step count)
                               (dialog-path-node-id path-id (1+ step)))
                              (next
                               next))
              do (dialog-text node-id
                              (dialog-path-text-string text)
                              :next next-id))
        (runtime-warn "Dialog path has no text nodes: ~a" path-id))
    path-id))
