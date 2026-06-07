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
                 (:file "selection")
                 (:file "dialog-store")
                 (:file "graph")
                 (:file "dialog-dsl")
                 (:file "dialog-effects")
                 (:file "dialog-scripts")
                 (:file "graph-patterns")
                 (:file "dev-save")
                 (:file "mods")
                 (:file "text-template")
                 (:file "audio")
                 (:file "particles")
                 (:file "play-state")
                 (:file "save")
                 (:file "control-update")
                 (:file "control-rendering")
                 (:file "minigame")
                 (:file "title-logo")
                 (:file "title-particles")
                 (:file "fullscreen")
                 (:file "gameplay")
                 (:file "menu")
                 (:file "pause")
                 (:file "renderer")
                 (:file "main")))))


;; Github dependencies:
;; - cbaggers/livesupport
;; - GunioRobot/Eager-Future2
;; - alex-gutev/static-dispatch
;; - Shinmera/trivial-extensible-sequences
;;
;; GLFW
