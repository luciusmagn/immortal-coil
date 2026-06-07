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
             (dialog-option "matchbook"      "base/count-doors")
             (dialog-option "brass key"      "base/count-doors")
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
