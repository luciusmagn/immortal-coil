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
                 (:file "dialog-bundle-paths")
                 (:file "dialog-bundles")
                 (:file "dialog-manifest-normalization")
                 (:file "dialog-manifest-reader")
                 (:file "dialog-manifest")
                 (:file "selection")
                 (:file "dialog-store")
                 (:file "graph-state")
                 (:file "graph-models")
                 (:file "graph-conflicts")
                 (:file "graph-effects")
                 (:file "graph")
                 (:file "dialog-core-dsl")
                 (:file "dialog-choice-dsl")
                 (:file "dialog-branch-dsl")
                 (:file "dialog-input-dsl")
                 (:file "dialog-minigame-dsl")
                 (:file "dialog-effect-dsl")
                 (:file "dialog-effects")
                 (:file "minigame-registry")
                 (:file "dialog-scripts")
                 (:file "dialog-path-patterns")
                 (:file "dialog-choice-patterns")
                 (:file "graph-patterns")
                 (:file "dev-save-config")
                 (:file "dev-save-store")
                 (:file "dev-save-data")
                 (:file "dev-save")
                 (:file "mod-config")
                 (:file "mod-discovery")
                 (:file "mods")
                 (:file "text-template")
                 (:file "audio-assets")
                 (:file "short-sounds")
                 (:file "title-music")
                 (:file "audio")
                 (:file "rising-particles")
                 (:file "star-particles")
                 (:file "title-particle-system")
                 (:file "title-particle-motion")
                 (:file "title-logo")
                 (:file "title-particles")
                 (:file "particle-field-state")
                 (:file "particle-field-dispatch")
                 (:file "particles")
                 (:file "play-state")
                 (:file "save")
                 (:file "dialog-choice-update")
                 (:file "dialog-input-buffer")
                 (:file "dialog-number-update")
                 (:file "dialog-string-update")
                 (:file "dialog-choice-rendering")
                 (:file "dialog-input-rendering")
                 (:file "flight-minigame")
                 (:file "flight-rendering-geometry")
                 (:file "flight-tunnel-rendering")
                 (:file "flight-gate-rendering")
                 (:file "flight-player-rendering")
                 (:file "flight-minigame-rendering")
                 (:file "minigame")
                 (:file "fullscreen")
                 (:file "gameplay")
                 (:file "menu-state")
                 (:file "menu-geometry")
                 (:file "menu-actions")
                 (:file "menu-rendering")
                 (:file "menu")
                 (:file "pause-state")
                 (:file "pause-actions")
                 (:file "pause-rendering")
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
