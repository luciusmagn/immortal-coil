(in-package #:immortal-coil)

;;; Audio asset discovery

(defparameter *editor-music-file-types* '("mp3" "ogg" "flac"))
(defparameter *editor-sound-file-types* '("wav" "ogg" "flac"))
(defparameter *editor-music-volume* 0.28)
(defparameter *editor-sound-volume* 0.50)

(-> editor-pathname-name (pathname) string)
(defun editor-pathname-name (path)
  (namestring path))

(-> editor-same-pathname-p (pathname pathname) boolean)
(defun editor-same-pathname-p (left right)
  (string= (editor-pathname-name left)
           (editor-pathname-name right)))

(-> editor-existing-pathname-name (pathname) string)
(defun editor-existing-pathname-name (path)
  (handler-case
      (namestring (truename path))
    (error (condition)
      (declare (ignore condition))
      (namestring path))))

(-> editor-safe-directory-files (pathname) list)
(defun editor-safe-directory-files (directory)
  (handler-case
      (uiop:directory-files directory)
    (error (condition)
      (runtime-warn "Could not scan editor asset files in ~a: ~a"
                    directory
                    condition)
      nil)))

(-> editor-safe-subdirectories (pathname) list)
(defun editor-safe-subdirectories (directory)
  (handler-case
      (uiop:subdirectories directory)
    (error (condition)
      (runtime-warn "Could not scan editor asset subdirectories in ~a: ~a"
                    directory
                    condition)
      nil)))

(-> editor-recursive-directory-files (pathname) list)
(defun editor-recursive-directory-files (directory)
  (append (editor-safe-directory-files directory)
          (loop for subdirectory in (editor-safe-subdirectories directory)
                append (editor-recursive-directory-files subdirectory))))

(-> editor-audio-file-p (pathname list) boolean)
(defun editor-audio-file-p (path file-types)
  (let ((type (pathname-type path)))
    (and type
         (not (null (member (string-downcase type)
                            file-types
                            :test #'string=))))))

(-> editor-generated-asset-path-p (pathname) boolean)
(defun editor-generated-asset-path-p (path)
  (not (null (member "generated"
                     (pathname-directory path)
                     :test #'string=))))

(-> editor-music-file-p (pathname) boolean)
(defun editor-music-file-p (path)
  (editor-audio-file-p path *editor-music-file-types*))

(-> editor-sound-file-p (pathname) boolean)
(defun editor-sound-file-p (path)
  (and (editor-audio-file-p path *editor-sound-file-types*)
       ;; Generated audio currently contains long music renders.
       (not (editor-generated-asset-path-p path))))

(-> editor-draft-dialog-bundle () (option dialog-bundle))
(defun editor-draft-dialog-bundle ()
  (let ((draft-path (editor-draft-script-pathname)))
    (find-if #'(lambda (bundle)
                 (member draft-path
                         (dialog-bundle-script-paths bundle)
                         :test #'editor-same-pathname-p))
             *loaded-dialog-bundles*)))

(-> editor-path-under-root-p (pathname pathname) boolean)
(defun editor-path-under-root-p (root path)
  (let ((root-name (editor-existing-pathname-name
                    (uiop:ensure-directory-pathname root)))
        (path-name (editor-existing-pathname-name path)))
    (and (<= (length root-name) (length path-name))
         (string= root-name
                  path-name
                  :end2 (length root-name)))))

(-> editor-bundle-asset-label (dialog-bundle pathname) (option string))
(defun editor-bundle-asset-label (bundle path)
  (let ((root (dialog-bundle-asset-root bundle)))
    (when (editor-path-under-root-p root path)
      (subseq (editor-existing-pathname-name path)
              (length (editor-existing-pathname-name
                       (uiop:ensure-directory-pathname root)))))))

(-> editor-bundle-audio-asset-labels (dialog-bundle function) list)
(defun editor-bundle-audio-asset-labels (bundle file-predicate)
  (sort
   (remove-duplicates
    (remove nil
            (loop for path in (editor-recursive-directory-files
                               (dialog-bundle-asset-root bundle))
                  when (funcall file-predicate path)
                    collect (editor-bundle-asset-label bundle path)))
    :test #'string=)
   #'string<))

(-> editor-bundle-music-asset-labels (dialog-bundle) list)
(defun editor-bundle-music-asset-labels (bundle)
  (editor-bundle-audio-asset-labels bundle #'editor-music-file-p))

(-> editor-bundle-sound-asset-labels (dialog-bundle) list)
(defun editor-bundle-sound-asset-labels (bundle)
  (editor-bundle-audio-asset-labels bundle #'editor-sound-file-p))

(-> editor-loaded-audio-asset-paths (function) list)
(defun editor-loaded-audio-asset-paths (file-predicate)
  (sort
   (remove-duplicates
    (loop for bundle in *loaded-dialog-bundles*
          append (loop for path in (editor-recursive-directory-files
                                    (dialog-bundle-asset-root bundle))
                       when (funcall file-predicate path)
                         collect (namestring path)))
    :test #'string=)
   #'string<))

(-> editor-loaded-music-asset-paths () list)
(defun editor-loaded-music-asset-paths ()
  (editor-loaded-audio-asset-paths #'editor-music-file-p))

(-> editor-loaded-sound-asset-paths () list)
(defun editor-loaded-sound-asset-paths ()
  (editor-loaded-audio-asset-paths #'editor-sound-file-p))

(-> editor-music-asset-selections () list)
(defun editor-music-asset-selections ()
  (let ((bundle (editor-draft-dialog-bundle)))
    (append (if bundle
                (editor-bundle-music-asset-labels bundle)
                (editor-loaded-music-asset-paths))
            (list :stop))))

(-> editor-sound-asset-selections () list)
(defun editor-sound-asset-selections ()
  (let ((bundle (editor-draft-dialog-bundle)))
    (append (if bundle
                (editor-bundle-sound-asset-labels bundle)
                (editor-loaded-sound-asset-paths))
            (list :none))))


;;; Draft persistence

(-> editor-write-set-music-form (t dialog-id t) t)
(defun editor-write-set-music-form (stream node-id selection)
  (format stream "~&(dialog-set-music ~s ~s)~2%"
          node-id
          selection))

(-> editor-append-music-edit (dialog-id t) boolean)
(defun editor-append-music-edit (node-id selection)
  (handler-case
      (let ((path (editor-draft-script-pathname)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;;; music edit for ~s~%" node-id)
          (editor-write-set-music-form stream node-id selection))
        t)
    (error (condition)
      (runtime-warn "Could not append editor music edit: ~a" condition)
      nil)))

(-> editor-write-set-sound-form (t dialog-id t) t)
(defun editor-write-set-sound-form (stream node-id selection)
  (if (eq selection :none)
      (format stream "~&(dialog-clear-sound ~s)~2%" node-id)
      (format stream "~&(dialog-set-sound ~s ~s)~2%"
              node-id
              selection)))

(-> editor-append-sound-edit (dialog-id t) boolean)
(defun editor-append-sound-edit (node-id selection)
  (handler-case
      (let ((path (editor-draft-script-pathname)))
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (format stream "~&;;; sound edit for ~s~%" node-id)
          (editor-write-set-sound-form stream node-id selection))
        t)
    (error (condition)
      (runtime-warn "Could not append editor sound edit: ~a" condition)
      nil)))


;;; Editor controls

(-> editor-current-music-selection (node) (option t))
(defun editor-current-music-selection (node)
  (let ((selection (node-story-music-selection node))
        (bundle (editor-draft-dialog-bundle)))
    (cond
      ((eq selection :stop)
       :stop)
      ((and bundle (stringp selection))
       (handler-case
           (let ((label (editor-bundle-asset-label
                         bundle
                         (parse-namestring selection))))
             (or label selection))
         (error (condition)
           (runtime-warn "Could not read editor music path ~s: ~a"
                         selection
                         condition)
           selection)))
      (t selection))))

(-> editor-next-music-selection ((option t) list) t)
(defun editor-next-music-selection (current-selection selections)
  (let* ((position (and current-selection
                        (position current-selection
                                  selections
                                  :test #'equal)))
         (next-position (if position
                            (mod (1+ position) (length selections))
                            0)))
    (nth next-position selections)))

(-> editor-music-selection-pathname (t (option dialog-bundle)) (option pathname))
(defun editor-music-selection-pathname (selection bundle)
  (unless (eq selection :stop)
    (if bundle
        (dialog-asset-pathname selection :bundle bundle)
        (story-music-pathname selection))))

(-> editor-music-selection-label (t) string)
(defun editor-music-selection-label (selection)
  (let ((label (if (eq selection :stop)
                   "STOP"
                   (source-designator-name selection))))
    (if (<= (length label) 54)
        label
        (concatenate 'string
                     (subseq label 0 51)
                     "..."))))

(-> editor-current-sound-selection (node) t)
(defun editor-current-sound-selection (node)
  (let ((selection (node-story-sound-selection node))
        (bundle (editor-draft-dialog-bundle)))
    (cond
      ((null selection)
       :none)
      ((and bundle (stringp selection))
       (handler-case
           (let ((label (editor-bundle-asset-label
                         bundle
                         (parse-namestring selection))))
             (or label selection))
         (error (condition)
           (runtime-warn "Could not read editor sound path ~s: ~a"
                         selection
                         condition)
           selection)))
      (t selection))))

(-> editor-next-sound-selection (t list) t)
(defun editor-next-sound-selection (current-selection selections)
  (editor-next-music-selection current-selection selections))

(-> editor-sound-selection-pathname (t (option dialog-bundle)) (option pathname))
(defun editor-sound-selection-pathname (selection bundle)
  (unless (eq selection :none)
    (if bundle
        (dialog-asset-pathname selection :bundle bundle)
        (story-sound-pathname selection))))

(-> editor-sound-selection-label (t) string)
(defun editor-sound-selection-label (selection)
  (let ((label (if (eq selection :none)
                   "NONE"
                   (source-designator-name selection))))
    (if (<= (length label) 54)
        label
        (concatenate 'string
                     (subseq label 0 51)
                     "..."))))

(-> editor-apply-music-selection (node t) boolean)
(defun editor-apply-music-selection (node selection)
  (let ((bundle (editor-draft-dialog-bundle)))
    (let ((*current-dialog-bundle* bundle))
      (dialog-set-music (node-id node) selection))
    (if (eq selection :stop)
        (stop-story-music)
        (let ((path (editor-music-selection-pathname selection bundle)))
          (when path
            (set-story-music path :volume *editor-music-volume*)))))
  t)

(-> editor-cycle-current-music () boolean)
(defun editor-cycle-current-music ()
  (if (and *editor-active-p* *state*)
      (let* ((node (current-node))
             (selections (editor-music-asset-selections)))
        (if selections
            (let ((selection (editor-next-music-selection
                              (editor-current-music-selection node)
                              selections)))
              (if (editor-append-music-edit (node-id node) selection)
                  (progn
                    (editor-apply-music-selection node selection)
                    (setf *editor-status-message*
                          (format nil "EDITOR: MUSIC ~a"
                                  (editor-music-selection-label selection)))
                    (play-start-confirm)
                    t)
                  (progn
                    (setf *editor-status-message*
                          "EDITOR: MUSIC WRITE FAILED")
                    (play-choice-switch)
                    nil)))
            (progn
              (setf *editor-status-message* "EDITOR: NO MUSIC ASSETS")
              (play-choice-switch)
              nil)))
      nil))

(-> editor-apply-sound-selection (node t) boolean)
(defun editor-apply-sound-selection (node selection)
  (let ((bundle (editor-draft-dialog-bundle)))
    (let ((*current-dialog-bundle* bundle))
      (dialog-set-sound (node-id node) selection))
    (let ((path (editor-sound-selection-pathname selection bundle)))
      (when path
        (play-story-sound path :volume *editor-sound-volume*))))
  t)

(-> editor-cycle-current-sound () boolean)
(defun editor-cycle-current-sound ()
  (if (and *editor-active-p* *state*)
      (let* ((node (current-node))
             (selections (editor-sound-asset-selections)))
        (if selections
            (let ((selection (editor-next-sound-selection
                              (editor-current-sound-selection node)
                              selections)))
              (if (editor-append-sound-edit (node-id node) selection)
                  (progn
                    (editor-apply-sound-selection node selection)
                    (setf *editor-status-message*
                          (format nil "EDITOR: SOUND ~a"
                                  (editor-sound-selection-label selection)))
                    (play-start-confirm)
                    t)
                  (progn
                    (setf *editor-status-message*
                          "EDITOR: SOUND WRITE FAILED")
                    (play-choice-switch)
                    nil)))
            (progn
              (setf *editor-status-message* "EDITOR: NO SOUND ASSETS")
              (play-choice-switch)
              nil)))
      nil))
