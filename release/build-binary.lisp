(require :asdf)

(setf uiop:*compile-file-warnings-behaviour* :warn)

(defun getenv-nonempty (name)
  (handler-case
      (let ((value (uiop:getenv name)))
        (and value
             (plusp (length value))
             value))
    (error (condition)
      (format *error-output*
              "~&[immortal-coil] Could not read environment variable ~a: ~a~%"
              name
              condition)
      nil)))

(defun ensure-directory-env-pushed (name)
  (let ((value (getenv-nonempty name)))
    (when value
      (pushnew (uiop:ensure-directory-pathname value)
               asdf:*central-registry*
               :test #'equal))))

(defun output-pathname ()
  (or (getenv-nonempty "IMMORTAL_COIL_BINARY")
      #+windows "immortal-coil.exe"
      #-windows "immortal-coil"))

(defun load-release-system ()
  (ensure-directory-env-pushed "IMMORTAL_COIL_CLAYLIB_DIR")
  (pushnew (uiop:getcwd) asdf:*central-registry* :test #'equal)
  (if (find-package '#:ql)
      (funcall (read-from-string "ql:quickload") :immortal-coil)
      (progn
        (let ((uiop:*compile-file-failure-behaviour* :warn))
          (asdf:load-system :claylib))
        (asdf:load-system :immortal-coil))))

(defun loaded-symbol (package-name symbol-name)
  (let ((package (find-package package-name)))
    (unless package
      (error "Package ~a is not loaded." package-name))
    (multiple-value-bind (symbol status)
        (find-symbol symbol-name package)
      (unless status
        (error "Symbol ~a::~a is not present." package-name symbol-name))
      symbol)))

(defun eager-future-call (symbol-name &rest arguments)
  (apply (loaded-symbol "EAGER-FUTURE2" symbol-name) arguments))

(defun cffi-call (symbol-name &rest arguments)
  (apply (loaded-symbol "CFFI" symbol-name) arguments))

(defun set-loaded-symbol-value (package-name symbol-name value)
  (setf (symbol-value (loaded-symbol package-name symbol-name)) value))

(defun release-library-directory ()
  (or (getenv-nonempty "IMMORTAL_COIL_LIB_DIR")
      (let ((root (getenv-nonempty "IMMORTAL_COIL_ROOT")))
        (when root
          (namestring
           (merge-pathnames "lib/" (uiop:ensure-directory-pathname root)))))))

(defun windows-release-p ()
  (or (member :win32 *features*)
      (member :windows *features*)))

(defun release-shared-object-names ()
  (or (let ((value (getenv-nonempty "IMMORTAL_COIL_SHARED_OBJECTS")))
        (and value
             (remove-if (lambda (part)
                          (zerop (length part)))
                        (uiop:split-string value :separator ";"))))
      (if (windows-release-p)
          '("libraylib.dll" "libraygui.dll" "librayshim.dll")
          '("libraylib.so" "libraygui.so" "librayshim.x86_64-pc-linux-gnu.so"))))

(defun release-directory-file-name (directory file-name)
  (if directory
      (let ((last-index (1- (length directory))))
        (if (and (plusp (length directory))
                 (member (char directory last-index) '(#\/ #\\)))
            (format nil "~a~a" directory file-name)
            (format nil "~a~c~a"
                    directory
                    (if (windows-release-p) #\\ #\/)
                    file-name)))
      file-name))

(defun sbcl-load-shared-object (file-name)
  (let* ((package (find-package "SB-ALIEN"))
         (loader  (and package
                       (find-symbol "LOAD-SHARED-OBJECT" package))))
    (when loader
      (funcall loader file-name)
      t)))

(defun load-release-shared-object (file-name)
  (handler-case
      (sbcl-load-shared-object file-name)
    (error (condition)
      (format *error-output*
              "~&[immortal-coil] Could not load shared object ~a: ~a~%"
              file-name
              condition)
      nil)))

(defun load-release-shared-objects ()
  (let ((directory (release-library-directory))
        (names     (release-shared-object-names)))
    (when names
      (format *error-output*
              "~&[immortal-coil] Loading bundled shared objects from ~a.~%"
              (or directory "system paths"))
      (dolist (name names)
        (load-release-shared-object
         (release-directory-file-name directory name))))))

(defun push-release-foreign-library-directory ()
  (let ((directory (release-library-directory)))
    (when directory
      (pushnew directory
               (symbol-value
                (loaded-symbol "CFFI" "*FOREIGN-LIBRARY-DIRECTORIES*"))
               :test #'equal))))

(defun reload-claylib-foreign-libraries ()
  (push-release-foreign-library-directory)
  (dolist (library-name '("LIBRAYLIB" "LIBRAYGUI" "LIBRAYSHIM"))
    (cffi-call "LOAD-FOREIGN-LIBRARY"
               (loaded-symbol "CLAYLIB/WRAP" library-name))))

(defun make-release-color (red green blue alpha)
  (funcall (loaded-symbol "CLAYLIB" "MAKE-COLOR") red green blue alpha))

(defun rehydrate-claylib-colors ()
  (let ((colors '(("+LIGHTGRAY+" 200 200 200 255)
                  ("+GRAY+" 130 130 130 255)
                  ("+DARKGRAY+" 80 80 80 255)
                  ("+YELLOW+" 253 249 0 255)
                  ("+GOLD+" 255 203 0 255)
                  ("+ORANGE+" 255 161 0 255)
                  ("+PINK+" 255 109 194 255)
                  ("+RED+" 230 41 55 255)
                  ("+MAROON+" 190 33 55 255)
                  ("+GREEN+" 0 228 48 255)
                  ("+LIME+" 0 158 47 255)
                  ("+DARKGREEN+" 0 117 44 255)
                  ("+SKYBLUE+" 102 191 255 255)
                  ("+BLUE+" 0 121 241 255)
                  ("+DARKBLUE+" 0 82 172 255)
                  ("+PURPLE+" 200 122 255 255)
                  ("+VIOLET+" 135 60 190 255)
                  ("+DARKPURPLE+" 112 31 126 255)
                  ("+BEIGE+" 211 176 131 255)
                  ("+BROWN+" 127 106 79 255)
                  ("+DARKBROWN+" 76 63 47 255)
                  ("+WHITE+" 255 255 255 255)
                  ("+BLACK+" 0 0 0 255)
                  ("+BLANK+" 0 0 0 0)
                  ("+MAGENTA+" 255 0 255 255)
                  ("+RAYWHITE+" 245 245 245 255))))
    (dolist (entry colors)
      (destructuring-bind (name red green blue alpha) entry
        (set-loaded-symbol-value "CLAYLIB"
                                 name
                                 (make-release-color red green blue alpha)))))
  (set-loaded-symbol-value "CLAYLIB"
                           "*CLAYLIB-BACKGROUND*"
                           (symbol-value (loaded-symbol "CLAYLIB" "+RAYWHITE+"))))

(defun rehydrate-game-colors ()
  (set-loaded-symbol-value "IMMORTAL-COIL"
                           "*DRAW-COLOR*"
                           (make-release-color 255 255 255 255))
  (set-loaded-symbol-value "IMMORTAL-COIL"
                           "*TITLE-LOGO-SAMPLE-COLOR*"
                           (make-release-color 0 0 0 255))
  (set-loaded-symbol-value "IMMORTAL-COIL"
                           "*TITLE-LOGO-TINT-COLOR*"
                           (make-release-color 255 255 255 255)))

(defun rehydrate-release-foreign-objects ()
  (rehydrate-claylib-colors)
  (rehydrate-game-colors))

(defun stop-eager-future-workers ()
  (eager-future-call "ADVISE-THREAD-POOL-SIZE" 0)
  (loop repeat 100
        until (zerop (eager-future-call "THREAD-POOL-SIZE"))
        do (sleep 0.05))
  (unless (zerop (eager-future-call "THREAD-POOL-SIZE"))
    (error "Eager Future2 workers did not stop before image save.")))

(defun release-main ()
  (load-release-shared-objects)
  (reload-claylib-foreign-libraries)
  (rehydrate-release-foreign-objects)
  (eager-future-call "ADVISE-THREAD-POOL-SIZE" 10)
  (funcall (loaded-symbol "IMMORTAL-COIL" "MAIN")))

(load-release-system)
(stop-eager-future-workers)

(sb-ext:save-lisp-and-die
 (output-pathname)
 :toplevel #'release-main
 :executable t
 :compression t)
