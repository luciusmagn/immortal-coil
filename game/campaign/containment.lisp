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
             :next "facility/rotation")


;;; First rotation: the log, the watch, and the test route.

(dialog-scene "facility/rotation"
              "first rotation."
              :next "facility/issue")

(dialog-text "facility/issue"
             "the man in the grey coat is waiting at the desk with a clipboard and a second laminated card. his badge reads M-3. yours, he says, will be ready by the second rotation."
             :next "facility/handbook")

(dialog-say "facility/handbook"
            "M-3"
            "three duties, {facility-designation}. read the log. watch the room. walk the route. in that order, every rotation, and initial each one."
            :next "facility/log")

(dialog-text "facility/log"
             "the log is a ring binder chained to the desk. the entries are in different hands, all of them careful."
             :next "facility/log-1")

(dialog-text "facility/log-1"
             "0552: subject woke. remained in bed eleven minutes. classification unchanged."
             :next "facility/log-2")

(dialog-text "facility/log-2"
             "0603: subject drank from the provided glass. glass refilled per schedule during next sleep interval. handler's note: subject never asks who refills it."
             :next "facility/log-3")

(dialog-text "facility/log-3"
             "0612: subject counted the doors. figure disputed. recount expected. see RECURRENCE, appendix two."
             :next "facility/log-choice")

(dialog-pick "facility/log-choice"
             "the next page is blank and dated today."
             (dialog-option "initial the log" "facility/log-initial")
             (dialog-option "read appendix two" "facility/appendix")
             (dialog-option "ask M-3 who the subject is" "facility/log-ask"))

(dialog-on-enter "facility/log-initial"
                 '(setf (dialog-value "facility-log") "initialed"))

(dialog-text "facility/log-initial"
             "you initial the page. your initials sit at the end of a column of initials, and partway up the column they stop being letters you recognize and start being yours anyway."
             :next "facility/watch")

(dialog-on-enter "facility/appendix"
                 '(setf (dialog-value "facility-log") "appendix"))

(dialog-text "facility/appendix"
             "appendix two is one paragraph. RECURRENCE: the return of a subject, object, or rotation already concluded. do not correct the subject. do not correct the room. initial both."
             :next "facility/watch")

(dialog-on-enter "facility/log-ask"
                 '(setf (dialog-value "facility-log") "asked"))

(dialog-say "facility/log-ask"
            "M-3"
            "the subject is whoever is in the room when you look. that is not an evasion, {facility-designation}. it is the whole of appendix one."
            :next "facility/watch")

(dialog-text "facility/watch"
             "second duty. the observation window is curtained from the corridor side now; M-3 draws the curtain back and stands away from the glass."
             :next "facility/watch-room")

(dialog-text "facility/watch-room"
             "the room is no longer dark. someone is asleep in the bed, turned away, one arm over the blanket. on the night stand the glass is full. the door key is on the small table, where keys are kept."
             :next "facility/watch-stir")

(dialog-text "facility/watch-stir"
             "the sleeper stirs but does not wake. for one moment, the way they take the next breath is so familiar that you stop taking yours."
             :next "facility/watch-choice")

(dialog-pick "facility/watch-choice"
             "the log line for the watch is still blank."
             (dialog-option "log it plainly" "facility/watch-plain")
             (dialog-option "log a familiarity report" "facility/watch-report")
             (dialog-option "draw the curtain" "facility/watch-curtain"))

(dialog-on-enter "facility/watch-plain"
                 '(setf (dialog-value "facility-watch") "plain"))

(dialog-text "facility/watch-plain"
             "0710: subject asleep. no events. you write it, and it is true, and writing it feels like the first lie you have told in this building."
             :next "facility/route")

(dialog-on-enter "facility/watch-report"
                 '(setf (dialog-value "facility-watch") "reported"))

(dialog-say "facility/watch-report"
            "M-3"
            "a familiarity report on the first rotation. that is either very thorough or very bad. i will file it either way. it is the same form."
            :next "facility/route")

(dialog-on-enter "facility/watch-curtain"
                 '(setf (dialog-value "facility-watch") "curtained"))

(dialog-text "facility/watch-curtain"
             "you draw the curtain. M-3 initials the watch line for you without comment, which is a kindness, and logs the time, which is not."
             :next "facility/route")

(dialog-text "facility/route"
             "third duty. the test route is the corridor itself, walked to the far end and back without leaving the painted line."
             :next "facility/route-walk")

(dialog-minigame "facility/route-walk"
                 "w/s or up/down move. a/d or left/right turn. walk the route to an exit."
                 :game :dream-maze
                 :success "facility/route-logged"
                 :failure "facility/route-recurrence")

(dialog-text "facility/route-logged"
             "route walked, both directions, line unbroken. M-3 initials the third box and looks, briefly, relieved."
             :next "facility/clock-out")

(dialog-on-enter "facility/route-recurrence"
                 '(setf (dialog-value "facility-recurrence") t))

(dialog-text "facility/route-recurrence"
             "the corridor brings you back to the desk from the direction you did not take. M-3 stamps the third box RECURRENCE without surprise and tells you to remain where you are, per the card."
             :next "facility/recurrence-wait")

(dialog-text "facility/recurrence-wait"
             "you remain where you are. the corridor lights dim once, in order, away from the desk and back. somewhere a door is initialed shut."
             :next "facility/clock-out")

(dialog-say "facility/clock-out"
            "M-3"
            "rotation concluded, {facility-designation}. your card has been updated. read the other side on your own time, which begins now."
            :next "facility/card-back")

(dialog-text "facility/card-back"
             "the blank side of the laminated card is no longer blank. it reads: IN THE EVENT OF FAMILIARITY, REPORT IT. IN THE EVENT OF REPORTING IT, SEE APPENDIX ONE."
             :next "facility/walk-out")

(dialog-text "facility/walk-out"
             "M-3 walks you back along the painted line, past the curtained window, to the door with the brass handle. he initials the second sheet, says same time, and leaves the way you came."
             :next "facility/rotation-end")

(dialog-text "facility/rotation-end"
             "the handle is warm. on the other side of the door someone has just let go of it."
             :next "base/awake")
