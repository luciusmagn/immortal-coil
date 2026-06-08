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
                :serial t
                :components
                ((:file "package")
                 (:file "types")
                 (:file "config")
                 (:file "util")
                 (:file "company-label")
                 (:file "selection")

                 (:module "dialog-base"
                  :pathname "dialog"
                  :serial t
                  :components
                  ((:file "bundle")
                   (:file "manifest")
                   (:file "store")))

                 (:file "graph")

                 (:module "dialog-authoring"
                  :pathname "dialog"
                  :serial t
                  :components
                  ((:file "dsl")
                   (:file "patterns")))

                 (:module "minigame"
                  :serial t
                  :components
                  ((:file "core")))

                 (:module "dialog-loading"
                  :pathname "dialog"
                  :serial t
                  :components
                  ((:file "script")))

                 (:module "save-dev"
                  :pathname "save"
                  :serial t
                  :components
                  ((:file "dev")))

                 (:file "mod")

                 (:module "text"
                  :serial t
                  :components
                  ((:file "template")
                   (:file "layout")))

                 (:module "audio"
                  :serial t
                  :components
                  ((:file "resources")
                   (:file "story-music")))

                 (:module "title"
                  :serial t
                  :components
                  ((:file "music")
                   (:file "logo")
                   (:file "particles")))

                 (:module "audio-core"
                  :pathname "audio"
                  :serial t
                  :components
                  ((:file "core")))

                 (:module "particles"
                  :serial t
                  :components
                  ((:file "rising")
                   (:file "star")
                   (:file "field")))

                 (:file "play-state")

                 (:module "text-runtime"
                  :pathname "text"
                  :serial t
                  :components
                  ((:file "runtime")))

                 (:module "save"
                  :serial t
                  :components
                  ((:file "core")))

                 (:module "dialog-runtime"
                  :pathname "dialog"
                  :serial t
                  :components
                  ((:file "conversation")
                   (:file "choice")
                   (:file "input")))

                 (:module "minigame-runtime"
                  :pathname "minigame"
                  :serial t
                  :components
                  ((:file "node")))

                 (:module "editor"
                  :serial t
                  :components
                  ((:file "state")
                   (:file "draft")
                   (:file "text-edit")
                   (:file "rendering")))

                 (:file "fullscreen")

                 (:module "options"
                  :serial t
                  :components
                  ((:file "core")
                   (:file "menu")))

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
