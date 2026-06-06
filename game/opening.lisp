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
             "the glass is cold in your hand. in its reflection, the bed is a crash couch and the night stand is a console."
             :next "ship/alarm")

(dialog-particles "ship/wake" :stars :fade-seconds 6.5)

(dialog-text "ship/alarm"
             "captain {player-name}, the wireframe lane is collapsing."
             :next "ship/flight")

(dialog-minigame "ship/flight"
                 "use wasd or arrow keys. keep the ship inside the open wireframe gates."
                 :game :wire-flight
                 :success "ship/threaded"
                 :failure "ship/crash-return")

(dialog-text "ship/threaded"
             "you thread the line. for one impossible second, the ship is quiet.")

(dialog-text "ship/crash-return"
             "white lines fill your eyes. the next breath catches in the same alarm."
             :next "ship/alarm")

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

(dialog-list-path "base/listen"
                  "select a sound from the hall."
                  ("breathing"
                   "the breathing stops when you notice it.")
                  ("static"
                   "under the static, a voice has been waiting.")
                  ("water"
                   "the water runs uphill behind the door.")
                  ("glass"
                   "glass shifts in the wall like teeth.")
                  ("keys"
                   "the keys turn by themselves.")
                  ("bells"
                   "the bells are too distant to be outside.")
                  ("steps"
                   "the steps stop one pace from the threshold.")
                  ("wood"
                   "wood creaks where no wood should be.")
                  ("silence"
                   "the silence notices you first.")
                  ("hinges"
                   :when #'(lambda ()
                             (>= (dialog-value "door-count" 0) 5))
                   "the hinges count themselves out loud."))

(dialog-text "base/sleep"
             "you rolled over and went back to sleep, nothing of interest happened...")
