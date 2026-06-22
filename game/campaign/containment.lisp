;;; Containment path seeds, grafted from the dream maze. Forms, painted
;;; lines, and a designation come before any understanding of the role.

(defun facility-desk-target ()
  (if (dialog-value "facility-designation")
      "facility/desk-again"
      "facility/desk"))

(dialog-set-next "dream/right-exit" "facility/found")
(dialog-set-next "dream/maze-lost" "facility/found")

(dialog-particles "facility/found" :motes :fade-seconds 5.0)

(dialog-text "facility/found"
             "at the next turn a man in a grey coat is waiting. he does not ask who you are. you follow the painted line with him."
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
             "the line ends at the standing desk. a new line on the sheet, dated today, blank. your designation is already printed beside it. M-3 does not tap the sheet twice."
             :next "facility/window")

(dialog-text "facility/card"
             "he initials beside it and hands you a laminated card. one side reads IN THE EVENT OF RECURRENCE, REMAIN WHERE YOU ARE. the other side is blank."
             :next "facility/window")

(dialog-text "facility/window"
             "the corridor passes a wide window. the room beyond is dark: a bed, a night stand, a small table by the door. the man does not slow here."
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
             "the glass is cold. on the night stand inside, a glass of water, full. the man waits without turning."
             :next "facility/end")

(dialog-text "facility/walk"
             "the painted line turns left. the man follows it without checking. the doors are numbered, all even."
             :next "facility/end")

(dialog-text "facility/end"
             "the line ends at a door with a brass handle. the man initials a second sheet and leaves the way you came. the handle is warm."
             :next "facility/rotation")


;;; First rotation: the log, the watch, and the test route.

(dialog-scene "facility/rotation"
              "first rotation."
              :next "facility/issue")

(dialog-text "facility/issue"
             "the man in the grey coat waits at the desk with a clipboard and a second card. his badge reads M-3. yours will be ready by the second rotation, he says."
             :next "facility/handbook")

(dialog-say "facility/handbook"
            "M-3"
            "three duties, {facility-designation}. read the log. watch the room. walk the route. in that order, every rotation, and initial each one."
            :next "facility/log")

(dialog-text "facility/log"
             "the log is a ring binder chained to the desk. the entries are in different hands, all careful."
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
             "you initial the page. your initials go at the bottom of a long column. higher up, in older ink, the initials are already yours."
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
             "second duty. the observation window is curtained on the corridor side. M-3 draws the curtain back and stands away from the glass."
             :next "facility/watch-room")

(dialog-text "facility/watch-room"
             "the room is lit now. someone is asleep in the bed, turned away, one arm over the blanket. the glass on the night stand is full. the door key is on the small table."
             :next "facility/watch-stir")

(dialog-text "facility/watch-stir"
             "the sleeper stirs and does not wake. they take a breath. you know the breath. you stop your own."
             :next "facility/watch-choice")

(dialog-pick "facility/watch-choice"
             "the log line for the watch is still blank."
             (dialog-option "log it plainly" "facility/watch-plain")
             (dialog-option "log a familiarity report" "facility/watch-report")
             (dialog-option "draw the curtain" "facility/watch-curtain"))

(dialog-on-enter "facility/watch-plain"
                 '(setf (dialog-value "facility-watch") "plain"))

(dialog-text "facility/watch-plain"
             "0710: subject asleep. no events. you write it. it is true, and it is a lie, and you let both stand."
             :next "facility/route")

(dialog-on-enter "facility/watch-report"
                 '(setf (dialog-value "facility-watch") "reported"))

(dialog-say "facility/watch-report"
            "M-3"
            "a familiarity report on the first rotation. that is thorough, or it is bad. i file it either way. it is the same form."
            :next "facility/route")

(dialog-on-enter "facility/watch-curtain"
                 '(setf (dialog-value "facility-watch") "curtained"))

(dialog-text "facility/watch-curtain"
             "you draw the curtain. M-3 initials the watch line for you, without comment, and logs the time."
             :next "facility/route")

(dialog-text "facility/route"
             "third duty. the route is the corridor itself, walked to the far end and back, without leaving the painted line."
             :next "facility/route-walk")

(dialog-minigame "facility/route-walk"
                 "w/s or up/down move. a/d or left/right turn. walk the route to an exit."
                 :game :dream-maze
                 :success "facility/route-logged"
                 :failure "facility/route-recurrence")

(dialog-text "facility/route-logged"
             "route walked, both directions, line unbroken. M-3 initials the third box. for a moment he looks relieved."
             :next "facility/clock-out")

(dialog-on-enter "facility/route-recurrence"
                 '(setf (dialog-value "facility-recurrence") t))

(dialog-text "facility/route-recurrence"
             "the corridor brings you back to the desk from the wrong direction. M-3 stamps the third box RECURRENCE. he is not surprised. remain where you are, he says, per the card."
             :next "facility/recurrence-wait")

(dialog-text "facility/recurrence-wait"
             "you remain where you are. the corridor lights dim once, in order, away from the desk and back. somewhere a door closes."
             :next "facility/clock-out")

(dialog-say "facility/clock-out"
            "M-3"
            "rotation concluded, {facility-designation}. your card is updated. read the other side on your own time. it begins now."
            :next "facility/card-back")

(dialog-text "facility/card-back"
             "the blank side of the card is not blank now. it reads: IN THE EVENT OF FAMILIARITY, REPORT IT. IN THE EVENT OF REPORTING IT, SEE APPENDIX ONE."
             :next "facility/walk-out")

(dialog-text "facility/walk-out"
             "M-3 walks you back along the line, past the curtained window, to the door with the brass handle. he initials the second sheet, says same time, and leaves the way you came."
             :next "facility/rotation-end")

(dialog-text "facility/rotation-end"
             "the handle is warm. on the other side of the door someone has just let go of it."
             :next "facility/rotation2")


;;; Second rotation: the badge, the archive, and the empty bed.

(dialog-scene "facility/rotation2"
              "second rotation."
              :next "facility/badge-ready")

(dialog-text "facility/badge-ready"
             "your badge is ready. the designation reads {facility-designation}. the photograph is the back of someone's head. they always are, M-3 says. it is for everyone's comfort."
             :next "facility/archive-duty")

(dialog-say "facility/archive-duty"
            "M-3"
            "new duty before the watch. the archive wants its files walked back to the shelf. carry them spine out. do not read while walking. that is how recurrences start."
            :next "facility/archive")

(dialog-text "facility/archive"
             "the archive is one room, longer than the corridor that holds it. the returns trolley has four files. the spines read: CROSSING. HILL HOUSE. THIRD DISTRICT. OAKBARROW."
             :next "facility/archive-choice")

(dialog-pick "facility/archive-choice"
             "the shelf gaps are labeled in the same hand as the rerouting slip on the trolley."
             (dialog-option "shelve them unread" "facility/shelve")
             (dialog-option "open the thinnest file" "facility/open-file")
             (dialog-option "check who signed them out" "facility/check-card"))

(dialog-on-enter "facility/shelve"
                 '(setf (dialog-value "facility-archive") "shelved"))

(dialog-text "facility/shelve"
             "you shelve all four, spine out, unread. they fit. you do not let your eyes rest on the labels beside them."
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
             "the watch. M-3 draws the curtain back and goes still. the room is lit. the bed is empty and made. the glass on the night stand is gone."
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
             "you remain. the corridor lights dim once, in order. in the dark of the room a door opens and closes. when the lights settle, someone is asleep in the bed."
             :next "facility/incident-after")

(dialog-on-enter "facility/breach-walk"
                 '(setf (dialog-value "facility-incident") "walked"))

(dialog-text "facility/breach-walk"
             "you follow the line to the room's door. your hand is on the brass handle. it is warm. M-3 says your designation once, quietly, the way you say a name."
             :next "facility/breach-back")

(dialog-text "facility/breach-back"
             "you let go and walk back. behind you the latch clicks, inward. by the time you reach the window, someone is asleep in the bed."
             :next "facility/incident-after")

(dialog-on-enter "facility/watch-m3"
                 '(setf (dialog-value "facility-incident") "watched"))

(dialog-text "facility/watch-m3"
             "you watch M-3. he watches the window and breathes the drill: in for four, hold for four, out for four. he does not know he is doing it."
             :next "facility/incident-after")

(dialog-text "facility/incident-after"
             "0744: recurrence concluded. subject in containment. M-3 initials the line, then initials it again with a different letter, catches himself, and strikes the first through."
             :next "facility/rotation2-out")

(dialog-say "facility/rotation2-out"
            "M-3"
            "rotation concluded. you did well. that is filed under the same heading as you did badly, so do not let it keep you up. same time."
            :next "facility/rotation2-end")

(dialog-text "facility/rotation2-end"
             "the walk out passes the archive. through the door, on the returns trolley, one new file. you keep your eyes ahead and walk past it."
             :next "facility/rotation3")


;;; Third rotation: the new file.

(dialog-scene "facility/rotation3"
              "third rotation."
              :next "facility/trolley")

(dialog-say "facility/trolley"
            "M-3"
            "one return today. walk it back, spine out. the shelf gap is marked. {facility-designation} - today, especially, do not read while walking."
            :next "facility/file-carry")

(dialog-text "facility/file-carry"
             "the file is heavier than yesterday's four together. the spine label is new, the ink not long dry. it reads: ROOM."
             :next "facility/file-choice")

(dialog-pick "facility/file-choice"
             "the marked gap is at the end of the longest shelf, past the others."
             (dialog-option "shelve it unread" "facility/file-shelve")
             (dialog-option "open it at the gap" "facility/file-open")
             (dialog-option "read just the first page" "facility/file-page"))

(dialog-on-enter "facility/file-shelve"
                 '(setf (dialog-value "facility-room-file") "shelved"))

(dialog-text "facility/file-shelve"
             "you shelve it. it goes in stiff. the shelf takes the weight."
             :next "facility/file-after")

(dialog-on-enter "facility/file-open"
                 '(setf (dialog-value "facility-room-file") "opened"))

(dialog-text "facility/file-open"
             "you open it at the gap. against the instruction, not against the card. inside there are no pages: a paper matchbook, a brass key on a loop of white thread, and a card blank on both sides."
             :next "facility/file-after")

(dialog-on-enter "facility/file-page"
                 '(setf (dialog-value "facility-room-file") "read"))

(dialog-text "facility/file-page"
             "the first page is an inventory. BED, ONE. NIGHT STAND, ONE. GLASS, ONE, FULL. DOORS, FIGURE DISPUTED. SUBJECT, ONE, RECURRING. the second page is the first page again. you stop there."
             :next "facility/file-after")

(dialog-say "facility/file-after"
            "M-3"
            "filed is filed. whatever you did between the trolley and the shelf is between you and appendix two. appendix two does not read while walking either."
            :next "facility/kettle")

(dialog-text "facility/kettle"
             "the staff room kettle is warm. one mug, grey, a designation stenciled on it. a tin of tea chosen to be acceptable to everyone."
             :next "facility/kettle-s2")

(dialog-text "facility/kettle-s2"
             "you drink it standing up, reading the notice board, the way you would in any job. for four minutes it works."
             :next "facility/locker")

(dialog-on-enter "facility/locker"
                 '(setf (dialog-value "facility-second-coat") t))

(dialog-text "facility/locker"
             "one row of lockers, designations stenciled on grey doors. yours opens on a folded coat, grey, your size. behind it hangs another coat, also yours, older, the elbows gone soft."
             :next "facility/rotation3-end")

(dialog-text "facility/rotation3-end"
             "he initials your third rotation. under his initials, for the first time, he writes the date in full."
             :next "facility/appendix-one")

(dialog-say "facility/appendix-one"
            "M-3"
            "before you go. appendix one, in full, since you have earned it: the subject is whoever is in the room when you look. that is the whole text. i could add a sentence by now, if i wanted to."
            :next "facility/appendix-ask")

(dialog-say "facility/appendix-ask"
            "you"
            "what sentence would you add?"
            :next "facility/appendix-ask-2")

(dialog-say "facility/appendix-ask-2"
            "M-3"
            "look less."
            :next "facility/appendix-ask-3")

(dialog-say "facility/appendix-ask-3"
            "you"
            "is that advice or procedure?"
            :next "facility/appendix-ask-4")

(dialog-say "facility/appendix-ask-4"
            "M-3"
            "here, {facility-designation}, that is the same question with more years on it. same time."
            :next "facility/notice-board")

(dialog-text "facility/notice-board"
             "by the staff room door there is a notice board, mostly thumbtacks. the one notice reads: ROTATION SCHEDULES ARE POSTED IN ADVANCE."
             :next "facility/notice-board-s2")

(dialog-text "facility/notice-board-s2"
             "ANY STAFF MEMBER FINDING THEIR OWN NAME FURTHER DOWN THE SCHEDULE THAN EXPECTED SHOULD CONSULT APPENDIX TWO RATHER THAN THE SCHEDULE."
             :next "release/second-notice")

(dialog-text "facility/walk3"
             "the walk out is yours alone tonight. M-3 stays with the binder."
             :next "facility/walk3-s2")

(dialog-text "facility/walk3-s2"
             "the line carries you past the curtained window. you keep your eyes on the line the whole way. the curtain stays shut. it is the first rotation you would call easy."
             :next "facility/clipboard")

(dialog-text "facility/clipboard"
             "at the desk by the door, the sign-in sheet is new for the week. the top line of the fresh page is filled in, dated tomorrow, in your handwriting."
             :next "facility/clipboard-choice")

(dialog-pick "facility/clipboard-choice"
             "the pen hangs on its chain. tomorrow's line is already written, in your hand, waiting to be initialed."
             (dialog-option "initial today and go" "facility/clipboard-today")
             (dialog-option "initial tomorrow's line as well" "nightshift/initialed"))

(dialog-text "facility/clipboard-today"
             "you initial today. you leave tomorrow to whoever keeps arriving."
             :next "sys/reboot")
