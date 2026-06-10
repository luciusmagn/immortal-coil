;;; War leader path, grafted from the hall-sound leaves. The sounds keep
;;; their first reading; the building answers them with a knock.

(dialog-set-next "base/listen/static" "war/static")
(dialog-set-next "base/listen/bells" "war/bells")
(dialog-set-next "base/listen/glass" "war/glass")

(dialog-text "war/static"
             "the voice finishes its numbers and starts the same list over. closer than the radio, someone in the hall shifts their weight."
             :next "war/knock")

(dialog-text "war/bells"
             "the bells ring on. footsteps pass your door at a walk, unhurried. whoever it is has heard them for days."
             :next "war/knock")

(dialog-text "war/glass"
             "the thuds keep their slow count. the window glass is taped in a wide X. you do not remember taping it."
             :next "war/knock")

(dialog-text "war/knock"
             "two knocks, a pause, one knock. the door opens before you answer."
             :next "war/aide")

(dialog-conversation "war/aide"
                     (dialog-left "Brandt"
                                  "you slept four hours, chancellor. the eastern line held.")
                     (dialog-right "you"
                                   "and the city?")
                     (dialog-left "Brandt"
                                  "the third district is still ringing. the cabinet is waiting.")
                     :next "war/corridor")

(dialog-text "war/corridor"
             "the corridor is carpeted and dim, every window taped and curtained. Brandt walks half a step behind with a folder he does not offer you."
             :next "war/doors")

(dialog-text "war/doors"
             "the doors along the corridor are numbered. the cabinet room is door {door-count}."
             :next "war/cabinet")

(dialog-text "war/cabinet"
             "a long table, mostly empty chairs. Olen stands at the map, where three tape lines have moved since the last briefing."
             :next "war/briefing")

(dialog-pick "war/briefing"
             "Olen waits by the map."
             (dialog-option "ask what moved" "war/moved")
             (dialog-option "ask about the bells" "war/bells-answer")
             (dialog-option "sit down and listen" "war/sit"))

(dialog-say "war/moved"
            "Olen"
            "the river line moved. we hold the bridge or we hold the rail yard. by morning, not both."
            :next "war/decision")

(dialog-say "war/bells-answer"
            "Olen"
            "the third district rings until the all-clear. there has been no all-clear since tuesday."
            :next "war/decision")

(dialog-text "war/sit"
             "you sit. Olen begins without being asked: the river line, the bridge, the rail yard. one of them can be held by morning."
             :next "war/decision")

(dialog-pick "war/decision"
             "Olen sets two pins beside the map and waits."
             (dialog-option "hold the bridge" "war/bridge")
             (dialog-option "hold the rail yard" "war/rail-yard")
             (dialog-option "ask for an hour" "war/hour"))

(dialog-on-enter "war/bridge"
                 '(setf (dialog-value "war-first-order") "bridge"))

(dialog-text "war/bridge"
             "Olen moves one tape line. east of the river, the rail yard crews will wait for trains that have already been rerouted. no one will tell them why."
             :next "war/return")

(dialog-on-enter "war/rail-yard"
                 '(setf (dialog-value "war-first-order") "rail-yard"))

(dialog-text "war/rail-yard"
             "Olen moves one tape line. the bridge garrison's final supply run is logged for 0400. the log does not say final."
             :next "war/return")

(dialog-on-enter "war/hour"
                 '(setf (dialog-value "war-first-order") "delay"))

(dialog-say "war/hour"
            "Olen"
            "you have until the bells stop."
            :next "war/hour-window")

(dialog-text "war/hour-window"
             "Brandt looks at the curtained window. the bells have not stopped since tuesday."
             :next "war/return")

(dialog-text "war/return"
             "Brandt walks you back along the numbered doors. in your room, the radio is still on."
             :next "war/radio")

(dialog-minigame "war/radio"
                 "a / d or left / right arrow keys tune the dial. find a clear band."
                 :game :war-radio
                 :success "war/radio-found"
                 :failure "war/radio-give-up")

(dialog-text "war/radio-found"
             "the static opens onto a clear band. a voice is reading numbers there too. you turn it down, not off, and sleep in your clothes."
             :next "base/awake")

(dialog-text "war/radio-give-up"
             "every band is the same weather. you turn it down, not off, and sleep in your clothes."
             :next "base/awake")
