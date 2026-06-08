(dialog-start "base/awake")

(dialog-particles "base/awake" :rising :immediate t)
(dialog-stop-music "base/awake")
(dialog-particles "ship/wake" :stars :fade-seconds 6.5)
(dialog-music "ship/wake" "audio/ship-lyria-drone.mp3" :volume 0.26)

(dialog-minigame-kind :wire-flight
                      :update #'update-flight-minigame-node
                      :draw #'draw-flight-minigame)

(dialog-minigame-kind :dream-maze
                      :update #'update-dream-maze-minigame-node
                      :draw #'draw-dream-maze-minigame)


;;; Base room

(dialog-text "base/awake"
             "you awake in a strange world..."
             :next "base/feel")

;; Move this below any node while developing, then use New Game.
;; (dialog-dev-save-here
;;  :store '(("player-name" . "dev"))
;;  :visible :all)

(dialog-text "base/feel"
             "or at least that's how you feel..."
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
             (dialog-option "matchbook"      "jrpg/inn")
             (dialog-option "brass key"      "forest/threshold")
             (dialog-option "nothing"        "base/count-doors"))

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
             "you rolled over and went back to sleep, nothing of interest happened..."
             :next "dream/start")


;;; Ship captain

(dialog-text "ship/wake"
             "the glass is cold in your hand. in its reflection, you notice restraint straps beside the bed and indicator lights under the night stand."
             :next "ship/name")

(dialog-string "ship/name"
               "what does the room call you?"
               :response-key "player-name"
               :max-length 24
               :target "ship/alarm")

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


;;; Dream maze

(dialog-say "dream/start"
            "the room"
            "a few moments later, you fall asleep"
            :next "dream/falling")

(dialog-say "dream/falling"
            "the dark"
            "you feel a falling sensation."
            :next "dream/maze")

(dialog-minigame "dream/maze"
                 "w/s move. a/d turn. find an exit."
                 :game :dream-maze
                 :success "dream/maze-exit"
                 :failure "dream/maze-lost")

(dialog-branch "dream/maze-exit"
               (dialog-case '(string= (dialog-value "dream-maze-exit" "")
                                      "left")
                            "alice/fall")
               (dialog-case '(string= (dialog-value "dream-maze-exit" "")
                                      "upper")
                            "rogue/entrance")
               (dialog-case '(string= (dialog-value "dream-maze-exit" "")
                                      "right")
                            "dream/right-exit")
               (dialog-default "dream/maze-lost"))

(dialog-say "dream/left-exit"
            "the hall"
            "past the left exit, you recognize the empty bed from the room you thought you left."
            :next "alice/fall")

(dialog-say "dream/upper-exit"
            "the hall"
            "past the upper exit, the ceiling has the same cracks you ignored above the bed."
            :next "rogue/entrance")

(dialog-say "dream/right-exit"
            "the hall"
            "past the right exit, the handle matches the door that was behind you."
            :next "base/awake")

(dialog-text "dream/maze-lost"
             "you lose the thread of which corridor came first."
             :next "base/awake")
