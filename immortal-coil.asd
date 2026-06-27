(asdf:defsystem #:immortal-coil
  :description "A an always-branching game about trees"
  :author "Lukáš Hozda"
  :version "1.0.0"
  :serial t
  :depends-on (#:alexandria
               #:cffi
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

                 (:module "ui"
                  :serial t
                  :components
                  ((:file "list-panel")))

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

                 (:module "mod"
                  :serial t
                  :components
                  ((:file "core")))

                 (:module "text"
                  :serial t
                  :components
                  ((:file "template")
                   (:file "layout")
                   (:file "cursor-layout")))

                 (:module "audio"
                  :serial t
                  :components
                  ((:file "resources")
                   (:file "story-sound")
                   (:file "story-music")))

                 (:module "title"
                  :serial t
                  :components
                  ((:file "music")
                   (:file "particles")))

                 (:module "audio-core"
                  :pathname "audio"
                  :serial t
                  :components
                  ((:file "core")))

                 (:module "particles"
                  :serial t
                  :components
                  ((:file "definitions")
                   (:file "system")
                   (:file "rising")
                   (:file "star")
                   (:file "warp")
                   (:file "snow")
                   (:file "ash")
                   (:file "motes")
                   (:file "rogue-glyphs")
                   (:file "tatters")
                   (:file "field")))

                 (:file "play-state")
                 (:file "journal")
                 (:file "tree-view")

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
                   (:file "choice-option-edit")
                   (:file "conversation-entry-edit")
                   (:module "node"
                    :serial t
                    :components
                    ((:file "target-edit")
                     (:file "fields-edit")))
                   (:file "store-edit")
                   (:file "audio")
                   (:file "text-edit")
                   (:file "rendering")))

                 (:module "mod-ui"
                  :pathname "mod/editor"
                  :serial t
                  :components
                  ((:file "core")
                   (:file "manifest")
                   (:file "ui")))

                 (:file "fullscreen")

                 (:module "options"
                  :serial t
                  :components
                  ((:file "core")
                   (:file "menu")))

                 (:file "gameplay")

                 (:file "screen")
                 (:file "tile-labeler")
                 (:file "scene-builder")

                 (:file "menu")

                 (:file "pause")

                 (:file "hud")

                 (:file "renderer")
                 (:file "main")))))


;; Github dependencies:
;; - cbaggers/livesupport
;; - GunioRobot/Eager-Future2
;; - alex-gutev/static-dispatch
;; - Shinmera/trivial-extensible-sequences
;;
;; GLFW
