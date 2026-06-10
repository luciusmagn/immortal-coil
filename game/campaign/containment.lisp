;;; Containment path seeds, grafted from the dream maze. Forms, painted
;;; lines, and a designation come before any understanding of the role.

(dialog-set-next "dream/right-exit" "facility/desk")
(dialog-set-next "dream/maze-lost" "facility/found")

(dialog-text "facility/found"
             "at the next turn a man in a grey coat is waiting. he does not ask who you are, and you follow the painted line with him."
             :next "facility/desk")

(dialog-text "facility/desk"
             "the line ends at a standing desk with a sign-in sheet. the top three lines are filled in. the handwriting on all three is yours."
             :next "facility/designation")

(dialog-string "facility/designation"
               "the man taps the sheet: designation, not name. what do you write?"
               :response-key "facility-designation"
               :max-length 24
               :target "facility/card")

(dialog-text "facility/card"
             "he initials beside it and hands you a laminated card. one side reads IN THE EVENT OF RECURRENCE, REMAIN WHERE YOU ARE. the other side is blank."
             :next "facility/window")

(dialog-text "facility/window"
             "the corridor passes a wide window. the room beyond is dark: a bed, a night stand, a small table by the door. the man does not slow down here."
             :next "facility/window-choice")

(dialog-pick "facility/window-choice"
             "the man is three steps ahead."
             (dialog-option "ask whose room that is" "facility/ask")
             (dialog-option "stop at the glass" "facility/stop")
             (dialog-option "keep walking" "facility/walk"))

(dialog-say "facility/ask"
            "the grey coat"
            "yours, {facility-designation}. while you are on rotation."
            :next "facility/end")

(dialog-text "facility/stop"
             "the glass is cold. on the night stand inside there is a glass of water, full. the man waits without turning around."
             :next "facility/end")

(dialog-text "facility/walk"
             "the painted line turns left and the man follows it without checking. doors pass, numbered, all even."
             :next "facility/end")

(dialog-text "facility/end"
             "the line ends at a door with a brass handle. the man initials a second sheet and leaves the way you came. the handle is warm."
             :next "base/awake")
