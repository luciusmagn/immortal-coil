(dialog-start "base/awake")

(dialog-text "base/awake"
             "you awake in a strange world..."
             :next "base/name")

(dialog-string "base/name"
               "what does the room call you?"
               :response-key "player-name"
               :max-length 24
               :target "base/feel")

(dialog-text "base/feel"
             "{player-name}. or at least that's how you feel..."
             :next "base/exit-bed")

(dialog-choice "base/exit-bed"
               "exit bed?"
               (dialog-option "yes" "base/exited-bed")
               (dialog-option "no" "base/sleep"))

(dialog-text "base/exited-bed"
             "you stand beside the bed. a night stand waits under the wrong shadow."
             :next "base/night-stand")

(dialog-pick "base/night-stand"
             "what do you take from the night stand?"
             (dialog-option "glass of water" "ship/wake")
             (dialog-option "matchbook" "base/count-doors")
             (dialog-option "brass key" "base/count-doors")
             (dialog-option "nothing" "base/count-doors"))

(dialog-text "ship/wake"
             "the glass is suddenly weightless. the room becomes a cockpit."
             :next "ship/alarm")

(dialog-particles "ship/wake" :stars :fade-seconds 6.5)

(dialog-text "ship/alarm"
             "captain {player-name}, the wireframe lane is collapsing."
             :next "ship/flight")

(dialog-minigame "ship/flight"
                 "keep the ship inside the open wireframe gates."
                 :game :wire-flight
                 :success "ship/threaded"
                 :failure "ship/crash-loop")

(dialog-text "ship/threaded"
             "you thread the line. for one impossible second, the ship is quiet.")

(dialog-text "ship/crash-loop"
             "the ship breaks open. loop {ship-loop} begins before you finish dying."
             :next "ship/wake-repeat")

(dialog-text "ship/wake-repeat"
             "captain {player-name}, the wireframe lane is collapsing again."
             :next "ship/flight")

(dialog-number "base/count-doors"
               "how many doors do you count?"
               :response-key "door-count"
               :min 0
               :max 9
               :target "base/door-count-branch")

(dialog-branch "base/door-count-branch"
               (dialog-case '(>= (dialog-value "door-count" 0) 5)
                            "base/too-many-doors")
               (dialog-default "base/choose-door"))

(dialog-text "base/too-many-doors"
             "you decide the room is lying about the number."
             :next "base/choose-door")

(dialog-pick "base/choose-door"
             "which one feels least hostile?"
             (dialog-option "left" "base/listen")
             (dialog-option "center" "base/listen")
             (dialog-option "right" "base/listen"))

(dialog-list "base/listen"
             "select a sound from the hall."
             (dialog-option "breathing" "base/heard-breathing")
             (dialog-option "static" "base/heard-static")
             (dialog-option "water" "base/heard-water")
             (dialog-option "glass" "base/heard-glass")
             (dialog-option "keys" "base/heard-keys")
             (dialog-option "bells" "base/heard-bells")
             (dialog-option "steps" "base/heard-steps")
             (dialog-option "wood" "base/heard-wood")
             (dialog-option "silence" "base/heard-silence")
             (dialog-option "hinges" "base/heard-hinges"
                            :when #'(lambda ()
                                      (>= (dialog-value "door-count" 0) 5))))

(dialog-text "base/heard-breathing"
             "the breathing stops when you notice it.")

(dialog-text "base/heard-static"
             "the static folds into a voice and then gives up.")

(dialog-text "base/heard-water"
             "the water runs uphill behind the door.")

(dialog-text "base/heard-glass"
             "glass shifts in the wall like teeth.")

(dialog-text "base/heard-keys"
             "the keys turn by themselves.")

(dialog-text "base/heard-bells"
             "the bells are too distant to be outside.")

(dialog-text "base/heard-steps"
             "the steps stop one pace from the threshold.")

(dialog-text "base/heard-wood"
             "wood creaks where no wood should be.")

(dialog-text "base/heard-silence"
             "the silence notices you first.")

(dialog-text "base/heard-hinges"
             "the hinges count themselves out loud.")

(dialog-text "base/sleep"
             "you rolled over and went back to sleep, nothing of interest happened...")
