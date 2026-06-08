(in-package #:immortal-coil)

;;; Manifest form construction

(-> mod-editor-safe-id-fragment (string) string)
(defun mod-editor-safe-id-fragment (id)
  (let ((fragment
          (with-output-to-string (stream)
            (loop for char across (string-downcase id)
                  do (write-char
                      (cond
                        ((or (alphanumericp char)
                             (char= char #\-)
                             (char= char #\_))
                         char)
                        ((or (char= char #\/)
                             (char= char #\Space)
                             (char= char #\.))
                         #\-)
                        (t #\-))
                      stream)))))
    (if (mod-editor-nonempty-string-p fragment)
        fragment
        "new-mod")))

(-> mod-editor-root-path-for-id (string) pathname)
(defun mod-editor-root-path-for-id (id)
  (uiop:ensure-directory-pathname
   (merge-pathnames (format nil "mods/~a/"
                            (mod-editor-safe-id-fragment id))
                    (project-root-pathname))))

(-> mod-editor-manifest-path-for-id (string) pathname)
(defun mod-editor-manifest-path-for-id (id)
  (merge-pathnames "manifest.lisp"
                   (mod-editor-root-path-for-id id)))

(-> mod-editor-mod-id-exists-p (string) boolean)
(defun mod-editor-mod-id-exists-p (id)
  (not (null (probe-file (mod-editor-manifest-path-for-id id)))))

(-> mod-editor-unique-create-id () string)
(defun mod-editor-unique-create-id ()
  (loop for index from 0
        for id = (if (zerop index)
                     "new-mod"
                     (format nil "new-mod-~d" (1+ index)))
        unless (mod-editor-mod-id-exists-p id)
          return id))

(-> mod-editor-default-manifest-form () plist)
(defun mod-editor-default-manifest-form ()
  (list :id "new-mod"
        :name "New Mod"
        :version "0.1.0"
        :description ""
        :author ""
        :depends-on '("immortal-coil/base")
        :scripts '("story.lisp")
        :assets "assets/"))

(-> mod-editor-remove-start-keys (plist) plist)
(defun mod-editor-remove-start-keys (form)
  (remf form :start)
  (remf form :start-node)
  (remf form :root-node)
  form)

(-> mod-editor-updated-manifest-form () plist)
(defun mod-editor-updated-manifest-form ()
  (let* ((form (copy-list (or *mod-manifest-original-form*
                              (mod-editor-default-manifest-form))))
         (id (mod-editor-trim (mod-manifest-field-value :id)))
         (name (mod-editor-trim (mod-manifest-field-value :name)))
         (version (mod-editor-trim (mod-manifest-field-value :version)))
         (description (mod-editor-trim
                       (mod-manifest-field-value :description)))
         (author (mod-editor-trim (mod-manifest-field-value :author)))
         (scripts (mod-editor-list-field-values
                   (mod-manifest-field-value :scripts)))
         (assets (mod-editor-trim (mod-manifest-field-value :assets)))
         (dependencies (mod-editor-list-field-values
                        (mod-manifest-field-value :depends-on)))
         (start (mod-editor-trim (mod-manifest-field-value :start))))
    (setf (getf form :id) id
          (getf form :name) name
          (getf form :version) version
          (getf form :description) description
          (getf form :author) author
          (getf form :scripts) scripts
          (getf form :assets) (if (mod-editor-nonempty-string-p assets)
                                  assets
                                  "assets/")
          (getf form :depends-on) dependencies)
    (if (mod-editor-nonempty-string-p start)
        (setf (getf form :start) start)
        (mod-editor-remove-start-keys form))
    form))

(-> mod-editor-manifest-valid-p () boolean)
(defun mod-editor-manifest-valid-p ()
  (cond
    ((not (mod-editor-nonempty-string-p
           (mod-manifest-field-value :id)))
     (setf *mod-manifest-status* "ID IS REQUIRED")
     nil)
    ((null (mod-editor-list-field-values
            (mod-manifest-field-value :scripts)))
     (setf *mod-manifest-status* "AT LEAST ONE SCRIPT IS REQUIRED")
     nil)
    (t t)))

(-> mod-editor-write-manifest-form (pathname plist) boolean)
(defun mod-editor-write-manifest-form (path form)
  (handler-case
      (progn
        (ensure-directories-exist path)
        (with-open-file (stream path
                                :direction :output
                                :if-exists :supersede
                                :if-does-not-exist :create)
          (let ((*print-pretty* t)
                (*print-case* :downcase))
            (write form :stream stream :escape t :pretty t)
            (terpri stream)))
        t)
    (error (condition)
      (runtime-warn "Could not write mod manifest ~a: ~a"
                    path
                    condition)
      (setf *mod-manifest-status* "MANIFEST SAVE FAILED")
      nil)))

(-> mod-editor-relative-pathname (pathname string) pathname)
(defun mod-editor-relative-pathname (root path)
  (resolve-relative-pathname root path))

(-> mod-editor-first-script-path (pathname) pathname)
(defun mod-editor-first-script-path (root)
  (mod-editor-relative-pathname
   root
   (first (mod-editor-list-field-values
           (mod-manifest-field-value :scripts)))))

(-> mod-editor-asset-root-path (pathname) pathname)
(defun mod-editor-asset-root-path (root)
  (let ((assets (mod-editor-trim (mod-manifest-field-value :assets))))
    (uiop:ensure-directory-pathname
     (mod-editor-relative-pathname root
                                   (if (mod-editor-nonempty-string-p assets)
                                       assets
                                       "assets/")))))

(-> mod-editor-create-initial-script (pathname) boolean)
(defun mod-editor-create-initial-script (path)
  (handler-case
      (progn
        (unless (probe-file path)
          (ensure-directories-exist path)
          (with-open-file (stream path
                                  :direction :output
                                  :if-exists :error
                                  :if-does-not-exist :create)
            (format stream ";;; Story nodes for this mod.~2%")))
        t)
    (error (condition)
      (runtime-warn "Could not create mod script ~a: ~a"
                    path
                    condition)
      (setf *mod-manifest-status* "SCRIPT CREATE FAILED")
      nil)))

(-> mod-editor-launch-editor (pathname pathname string) t)
(defun mod-editor-launch-editor (manifest-path draft-script-path target-name)
  (reset-mod-editor-state)
  (start-mod-editor-session manifest-path
                            :target-name target-name
                            :draft-script-path draft-script-path))

(-> mod-editor-save-new-manifest () boolean)
(defun mod-editor-save-new-manifest ()
  (let* ((id (mod-editor-trim (mod-manifest-field-value :id)))
         (root (mod-editor-root-path-for-id id))
         (manifest-path (merge-pathnames "manifest.lisp" root))
         (script-path (mod-editor-first-script-path root))
         (asset-root (mod-editor-asset-root-path root))
         (form (mod-editor-updated-manifest-form)))
    (cond
      ((probe-file manifest-path)
       (setf *mod-manifest-status* "MOD MANIFEST ALREADY EXISTS")
       (play-choice-switch)
       nil)
      ((not (mod-editor-create-initial-script script-path))
       nil)
      (t
       (ensure-directories-exist asset-root)
       (when (mod-editor-write-manifest-form manifest-path form)
         (play-start-confirm)
         (mod-editor-launch-editor manifest-path
                                   script-path
                                   (getf form :name))
         t)))))

(-> mod-editor-save-existing-manifest () boolean)
(defun mod-editor-save-existing-manifest ()
  (let* ((path *mod-manifest-path*)
         (current-text (and path
                            (mod-editor-read-file-string path)))
         (form (mod-editor-updated-manifest-form)))
    (cond
      ((not path)
       (setf *mod-manifest-status* "NO MANIFEST PATH")
       (play-choice-switch)
       nil)
      ((not (and current-text
                 *mod-manifest-original-text*
                 (string= current-text *mod-manifest-original-text*)))
       (setf *mod-manifest-status* "MANIFEST CHANGED ON DISK")
       (play-choice-switch)
       nil)
      (t
       (let* ((root (pathname-parent-directory path))
              (script-path (mod-editor-first-script-path root))
              (asset-root (mod-editor-asset-root-path root)))
         (ensure-directories-exist asset-root)
         (when (mod-editor-create-initial-script script-path)
           (when (mod-editor-write-manifest-form path form)
             (play-start-confirm)
             (mod-editor-launch-editor path
                                       script-path
                                       (getf form :name))
             t)))))))

(-> mod-editor-save-and-open () boolean)
(defun mod-editor-save-and-open ()
  (if (mod-editor-manifest-valid-p)
      (case *mod-manifest-action*
        (:edit
         (mod-editor-save-existing-manifest))
        (t
         (mod-editor-save-new-manifest)))
      (progn
        (play-choice-switch)
        nil)))


;;; Opening workflows

(-> mod-editor-fill-default-create-fields () t)
(defun mod-editor-fill-default-create-fields ()
  (let ((id (mod-editor-unique-create-id)))
    (setf (mod-manifest-field-value :id) id
          (mod-manifest-field-value :name) "New Mod"
          (mod-manifest-field-value :version) "0.1.0"
          (mod-manifest-field-value :author) ""
          (mod-manifest-field-value :description) ""
          (mod-manifest-field-value :scripts) "story.lisp"
          (mod-manifest-field-value :assets) "assets/"
          (mod-manifest-field-value :depends-on) "immortal-coil/base"
          (mod-manifest-field-value :start) "")))

(-> open-create-mod-editor () t)
(defun open-create-mod-editor ()
  (reset-mod-editor-state)
  (setf *mod-editor-mode* :manifest
        *mod-manifest-action* :create
        *mod-manifest-original-form* (mod-editor-default-manifest-form)
        *mod-manifest-status* "C-s SAVE AND ENTER EDITOR")
  (mod-editor-fill-default-create-fields)
  (play-choice-switch))

(-> mod-editor-editable-bundles () list)
(defun mod-editor-editable-bundles ()
  (remove-if-not #'dialog-bundle-manifest-path
                 (mod-dialog-bundles)))

(-> open-edit-mod-picker () t)
(defun open-edit-mod-picker ()
  (reset-mod-editor-state)
  (let ((bundles (mod-editor-editable-bundles)))
    (if bundles
        (setf *mod-editor-mode* :picker
              *mod-picker-bundles* bundles
              *mod-picker-index* 0
              *mod-manifest-status* "SELECT MOD")
        (setf *mod-manifest-status* "NO MANIFEST MODS FOUND")))
  (play-choice-switch))

(-> mod-editor-fill-bundle-fields (dialog-bundle plist) t)
(defun mod-editor-fill-bundle-fields (bundle form)
  (setf (mod-manifest-field-value :id) (dialog-bundle-id bundle)
        (mod-manifest-field-value :name) (dialog-bundle-name bundle)
        (mod-manifest-field-value :version) (or (dialog-bundle-version bundle)
                                                "")
        (mod-manifest-field-value :author) (or (dialog-bundle-author bundle)
                                               "")
        (mod-manifest-field-value :description)
        (or (dialog-bundle-description bundle) "")
        (mod-manifest-field-value :scripts)
        (mod-editor-join-list-values
         (mod-editor-relative-script-labels bundle))
        (mod-manifest-field-value :assets)
        (mod-editor-relative-asset-label bundle)
        (mod-manifest-field-value :depends-on)
        (mod-editor-join-list-values (dialog-bundle-dependencies bundle))
        (mod-manifest-field-value :start)
        (or (manifest-start-node (dialog-bundle-manifest-path bundle)
                                 form)
            "")))

(-> open-mod-manifest-editor (dialog-bundle) t)
(defun open-mod-manifest-editor (bundle)
  (let* ((path (dialog-bundle-manifest-path bundle))
         (form (and path
                    (read-dialog-manifest-form path)))
         (text (and path
                    (mod-editor-read-file-string path))))
    (if (and path form text)
        (progn
          (reset-mod-editor-state)
          (setf *mod-editor-mode* :manifest
                *mod-manifest-action* :edit
                *mod-manifest-path* path
                *mod-manifest-original-text* text
                *mod-manifest-original-form* form
                *mod-manifest-status* "C-s SAVE AND ENTER EDITOR")
          (mod-editor-fill-bundle-fields bundle form)
          (play-choice-switch))
        (progn
          (setf *mod-manifest-status* "COULD NOT OPEN MANIFEST")
          (play-choice-switch)))))
