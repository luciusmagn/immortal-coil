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
                  ((:module "bundle"
                    :serial t
                    :components
                    ((:file "core")))
                   (:module "manifest"
                    :serial t
                    :components
                    ((:file "core")))
                   (:file "store")))

                 (:module "graph"
                  :serial t
                  :components
                  ((:file "core")))

                 (:module "dialog-authoring"
                  :pathname "dialog"
                  :serial t
                  :components
                  ((:module "dsl"
                    :serial t
                    :components
                    ((:file "core")))
                   (:file "patterns")))

                 (:module "minigame"
                  :serial t
                  :components
                  ((:file "core")))

                 (:module "dialog-loading"
                  :pathname "dialog"
                  :serial t
                  :components
                  ((:module "script"
                    :serial t
                    :components
                    ((:file "core")))))

                 (:module "save-dev"
                  :pathname "save/dev"
                  :serial t
                  :components
                  ((:file "core")))

                 (:module "mod"
                  :serial t
                  :components
                  ((:file "core")))

                 (:module "text"
                  :serial t
                  :components
                  ((:file "template")))

                 (:module "audio"
                  :serial t
                  :components
                  ((:file "resources")))

                 (:module "title"
                  :serial t
                  :components
                  ((:file "music")
                   (:file "logo")
                   (:module "particles"
                    :serial t
                    :components
                    ((:file "core")))))

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
                   (:module "field"
                    :serial t
                    :components
                    ((:file "core")))))

                 (:module "play-state"
                  :serial t
                  :components
                  ((:file "core")))

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
                  ((:module "choice"
                    :serial t
                    :components
                    ((:file "core")))
                   (:module "input"
                    :serial t
                    :components
                    ((:file "core")))))

                 (:module "minigame-runtime"
                  :pathname "minigame"
                  :serial t
                  :components
                  ((:file "node")))

                 (:file "fullscreen")
                 (:file "gameplay")

                 (:module "menu"
                  :serial t
                  :components
                  ((:file "core")))

                 (:module "pause"
                  :serial t
                  :components
                  ((:file "core")))

                 (:file "renderer")
                 (:file "main")))))


;; Github dependencies:
;; - cbaggers/livesupport
;; - GunioRobot/Eager-Future2
;; - alex-gutev/static-dispatch
;; - Shinmera/trivial-extensible-sequences
;;
;; GLFW
