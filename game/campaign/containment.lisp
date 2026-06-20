;;; Containment path seeds, grafted from the dream maze. Forms, painted
;;; lines, and a designation come before any understanding of the role.

(defun facility-desk-target ()
  (if (dialog-value "facility-designation")
      "facility/desk-again"
      "facility/desk"))

(dialog-set-next "dream/right-exit" "facility/found")
(dialog-set-next "dream/maze-lost" "facility/found")

(dialog-text "facility/found"
             "at the next turn a man in a grey coat is waiting. he does not ask who you are, and you follow the painted line with him."
             :next #'facility-desk-target)

(dialog-text "facility/desk"
             "the line ends at a standing desk with a sign-in sheet. the top three lines are filled in. the handwriting on all three is yours."
             :next "facility/designation")

(dialog-string "facility/designation"
               "the man taps the sheet: designation, not name. what do you write?"
               :response-key "facility-designation"
               :max-length 24
               :target "facility/card")

(dialog-text "facility/desk-again"
             "the line ends at the standing desk. there is a new line on the sign-in sheet, dated today, blank, and your designation is already printed beside it. M-3 does not need to tap the sheet twice."
             :next "facility/window")

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
             :next "facility/rotation2")


;;; Second rotation: the badge, the archive, and the empty bed.

(dialog-scene "facility/rotation2"
              "second rotation."
              :next "facility/badge-ready")

(dialog-text "facility/badge-ready"
             "your badge is ready. the printed designation is {facility-designation}, the photograph is of the back of someone's head, and M-3 says the photographs are always of the back of someone's head, for everyone's comfort."
             :next "facility/archive-duty")

(dialog-say "facility/archive-duty"
            "M-3"
            "new duty before the watch. the archive wants its files walked back to the shelf. carry them spine out and do not read while walking. reading while walking is how recurrences start."
            :next "facility/archive")

(dialog-text "facility/archive"
             "the archive is one room, longer than the corridor that contains it. the returns trolley holds four files. the spines read: CROSSING. HILL HOUSE. THIRD DISTRICT. OAKBARROW."
             :next "facility/archive-choice")

(dialog-pick "facility/archive-choice"
             "the shelf gaps are labeled in the same hand as the rerouting slip on the trolley."
             (dialog-option "shelve them unread" "facility/shelve")
             (dialog-option "open the thinnest file" "facility/open-file")
             (dialog-option "check who signed them out" "facility/check-card"))

(dialog-on-enter "facility/shelve"
                 '(setf (dialog-value "facility-archive") "shelved"))

(dialog-text "facility/shelve"
             "you shelve all four, spine out, unread. they go in with the soft fit of files that live there, between neighbors whose labels you do not let your eyes rest on."
             :next "facility/watch2")

(dialog-on-enter "facility/open-file"
                 '(setf (dialog-value "facility-archive") "read"))

(dialog-text "facility/open-file"
             "the thinnest file is OAKBARROW. inside is one page: an inn ledger line, photographed, and under it a note in pencil. SUBJECT SLEEPS WELL HERE. RECOMMEND NO CHANGE."
             :next "facility/watch2")

(dialog-on-enter "facility/check-card"
                 '(setf (dialog-value "facility-archive") "checked"))

(dialog-text "facility/check-card"
             "each file's card shows one borrower, over and over, signed by designation. the designation is not yours. the handwriting is."
             :next "facility/watch2")

(dialog-text "facility/watch2"
             "the watch. M-3 draws the curtain back and goes still in a new way. the room is lit. the bed is empty, made, and the glass on the night stand is gone."
             :next "facility/incident")

(dialog-say "facility/incident"
            "M-3"
            "subject not in containment. do not say missing. say not in containment. take the card out of your pocket, {facility-designation}, and hold it where i can see it."
            :next "facility/incident-choice")

(dialog-pick "facility/incident-choice"
             "the card reads: IN THE EVENT OF RECURRENCE, REMAIN WHERE YOU ARE."
             (dialog-option "remain where you are" "facility/remain")
             (dialog-option "walk the line to the room's door" "facility/breach-walk")
             (dialog-option "watch M-3 instead of the window" "facility/watch-m3"))

(dialog-on-enter "facility/remain"
                 '(setf (dialog-value "facility-incident") "remained"))

(dialog-text "facility/remain"
             "you remain. the corridor lights dim once, in order, and somewhere in the dark of the room a door you cannot see opens and closes, unhurried. when the lights settle, the bed is slept in, and someone is sleeping in it."
             :next "facility/incident-after")

(dialog-on-enter "facility/breach-walk"
                 '(setf (dialog-value "facility-incident") "walked"))

(dialog-text "facility/breach-walk"
             "you follow the line toward the room's door. the line ends at it. your hand is on the brass handle, and the handle is warm, and M-3 says your designation once, quietly, the way you would say a name."
             :next "facility/breach-back")

(dialog-text "facility/breach-back"
             "you let go and walk back. behind you the latch clicks, inward. by the time you reach the window, the bed is slept in, and someone is sleeping in it."
             :next "facility/incident-after")

(dialog-on-enter "facility/watch-m3"
                 '(setf (dialog-value "facility-incident") "watched"))

(dialog-text "facility/watch-m3"
             "you watch M-3. M-3 watches the window and breathes the drill: in for four, hold for four, out for four. it is the breathing from the hall, slow and even, and he is not aware he is doing it."
             :next "facility/incident-after")

(dialog-text "facility/incident-after"
             "0744: recurrence concluded. subject in containment. M-3 initials the line, then initials it again with a different letter, catches himself, and draws one neat stroke through the first."
             :next "facility/rotation2-out")

(dialog-say "facility/rotation2-out"
            "M-3"
            "rotation concluded. you did well, which is filed under the same heading as you did badly, so do not let it keep you up. same time."
            :next "facility/rotation2-end")

(dialog-text "facility/rotation2-end"
             "the walk out passes the archive. through the door, on the returns trolley, there is one new file. you carry your own eyes past it, spine out."
             :next "facility/rotation3")


;;; Third rotation: the new file.

(dialog-scene "facility/rotation3"
              "third rotation."
              :next "facility/trolley")

(dialog-say "facility/trolley"
            "M-3"
            "one return today. walk it back, spine out. shelf gap is marked. {facility-designation} — today i would especially not read while walking."
            :next "facility/file-carry")

(dialog-text "facility/file-carry"
             "the file is heavier than the four from yesterday together. the spine label is new, the ink not long dry. it reads: ROOM."
             :next "facility/file-choice")

(dialog-pick "facility/file-choice"
             "the marked gap is at the end of the longest shelf, past the others."
             (dialog-option "shelve it unread" "facility/file-shelve")
             (dialog-option "open it at the gap" "facility/file-open")
             (dialog-option "read just the first page" "facility/file-page"))

(dialog-on-enter "facility/file-shelve"
                 '(setf (dialog-value "facility-room-file") "shelved"))

(dialog-text "facility/file-shelve"
             "you shelve it. it goes in stiffly, a file that has never lived anywhere yet, and the shelf takes its weight with a sound like a held breath let go two rooms away."
             :next "facility/file-after")

(dialog-on-enter "facility/file-open"
                 '(setf (dialog-value "facility-room-file") "opened"))

(dialog-text "facility/file-open"
             "you open it at the gap, which is against the instruction but not against the card. inside there are no pages. there is a paper matchbook, a brass key on a loop of white thread, and a laminated card with both sides blank."
             :next "facility/file-after")

(dialog-on-enter "facility/file-page"
                 '(setf (dialog-value "facility-room-file") "read"))

(dialog-text "facility/file-page"
             "the first page is an inventory. BED, ONE. NIGHT STAND, ONE. GLASS, ONE, FULL. DOORS, FIGURE DISPUTED. SUBJECT, ONE, RECURRING. the second page is the first page again, and you stop there on your own."
             :next "facility/file-after")

(dialog-say "facility/file-after"
            "M-3"
            "filed is filed. whatever you did or did not do between the trolley and the shelf is between you and appendix two, and appendix two does not read while walking either."
            :next "facility/kettle")

(dialog-text "facility/kettle"
             "the staff room kettle is warm. there is one mug, grey, designation stenciled, and a tin of the kind of tea that exists to be acceptable to everyone. you drink it standing up, reading the notice board, the way you would in any job. for four minutes it works."
             :next "facility/locker")

(dialog-on-enter "facility/locker"
                 '(setf (dialog-value "facility-second-coat") t))

(dialog-text "facility/locker"
             "the staff room has one row of lockers, designations stenciled on grey doors. yours opens on a folded coat, grey, your size, smelling faintly of the corridor. behind it hangs another coat that is also yours, older, the elbows gone soft."
             :next "facility/rotation3-end")

(dialog-text "facility/rotation3-end"
             "he initials your third rotation, and under his initials, for the first time, he writes the date in full, as if some dates deserve to be found again."
             :next "facility/appendix-one")

(dialog-say "facility/appendix-one"
            "M-3"
            "before you go. appendix one, in full, since you have earned it: the subject is whoever is in the room when you look. that is the whole text. i have been here long enough to add a sentence, if i wanted."
            :next "facility/appendix-ask")

(dialog-conversation "facility/appendix-ask"
                     (dialog-right "you"
                                   "what sentence would you add?")
                     (dialog-left "M-3"
                                  "look less.")
                     (dialog-right "you"
                                   "is that advice or procedure?")
                     (dialog-left "M-3"
                                  "here, {facility-designation}, the difference is seniority. same time. the handle is warm.")
                     :next "facility/notice-board")

(dialog-text "facility/notice-board"
             "by the staff room door there is a notice board, mostly thumbtacks. the one notice reads: ROTATION SCHEDULES ARE POSTED IN ADVANCE. ANY STAFF MEMBER FINDING THEIR OWN NAME FURTHER DOWN THE SCHEDULE THAN EXPECTED SHOULD CONSULT APPENDIX TWO RATHER THAN THE SCHEDULE."
             :next "release/second-notice")

(dialog-text "facility/walk3"
             "the walk out is yours alone tonight; M-3 stays with the binder. the painted line carries you past the curtained window, and you keep your eyes on the line the whole way, and the curtain stays a curtain, and that is the first rotation you would call easy."
             :next "facility/clipboard")

(dialog-text "facility/clipboard"
             "at the desk by the door, the sign-in sheet has been replaced for the new week. the top line of the fresh page is already filled in, dated tomorrow, in handwriting you are done pretending not to recognize."
             :next "facility/clipboard-choice")

(dialog-pick "facility/clipboard-choice"
             "the pen hangs on its chain. tomorrow's line waits, already claimed by a hand that writes ahead of you."
             (dialog-option "initial today and go" "facility/clipboard-today")
             (dialog-option "initial tomorrow's line as well" "nightshift/initialed"))

(dialog-text "facility/clipboard-today"
             "you initial today instead, and leave tomorrow to whoever keeps arriving."
             :next "base/awake")
