;; clone skyizwhite/hsx and eyedouble/cl-json-web-tokens into local-projects
;; and claude-api
(eval-when (:compile-toplevel :load-toplevel :execute)
  (ql:quickload '(:alexandria
                  :serapeum
                  :claylib
                  :trivia)))

(asdf:defsystem #:immortal-coil
  :description "A an always-branching game about trees"
  :author "Lukáš Hozda"
  :version "1.0.0"
  :serial t
  :depends-on (#:alexandria
               #:serapeum
               #:claylib
               #:trivia)
  :components ((:module "source"
                :components
                ((:file "package")
                 (:file "config")
                 (:file "util")
                 (:file "dialog-store")
                 (:file "graph")
                 (:file "audio")
                 (:file "play-state")
                 (:file "control-update")
                 (:file "control-rendering")
                 (:file "particles")
                 (:file "title-logo")
                 (:file "title-particles")
                 (:file "fullscreen")
                 (:file "gameplay")
                 (:file "menu")
                 (:file "renderer")
                 (:file "main")))))


;; Github dependencies:
;; - cbaggers/livesupport
;; - GunioRobot/Eager-Future2
;; - alex-gutev/static-dispatch
;; - Shinmera/trivial-extensible-sequences
;;
;; GLFW
