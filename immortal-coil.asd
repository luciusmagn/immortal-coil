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
                 (:file "types")
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
                 (:file "rising-particles")
                 (:file "star-particles")
                 (:file "title-particle-system")
                 (:file "title-particle-motion")
                 (:file "title-logo")
                 (:file "title-particles")
                 (:file "particles")
                 (:file "play-state")
                 (:file "save")
                 (:file "dialog-choice-update")
                 (:file "dialog-input-update")
                 (:file "dialog-choice-rendering")
                 (:file "dialog-input-rendering")
                 (:file "flight-minigame")
                 (:file "flight-minigame-rendering")
                 (:file "minigame")
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
