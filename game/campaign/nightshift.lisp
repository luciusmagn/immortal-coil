;;; Nightshift: the facility path's first dark branch. Reassigned to
;;; the room side of the glass: the log read from inside, and the
;;; predecessor's notes in the night stand. Entered by initialing
;;; tomorrow's line; exits through the succession.

(dialog-text "nightshift/initialed"
             "you initial tomorrow's line as well, under the handwriting you are done pretending not to recognize, and the two sets of initials sit together on the page like a signature and its countersignature, which is what they are."
             :next "nightshift/m3-still")

(dialog-text "nightshift/m3-still"
             "M-3 is behind you, the way he is always behind you at the exact moments the procedure requires a witness. he looks at the sheet for a long time, and then he says, reassignment, then, in the voice of a man initialing something inside himself."
             :next "nightshift/briefing")

(dialog-say "nightshift/briefing"
            "M-3"
            "fourth rotation, {facility-designation}. the room side. you will want to hear the duties. there are none. that is the hard part. the room side has no duties, only conditions, and the conditions keep themselves."
            :next "nightshift/walk-in")

(dialog-text "nightshift/walk-in"
             "he walks you down the painted line to the door with the brass handle, and initials a sheet you have never seen, and holds the door, and does not say good luck, because the facility files luck under appendix two."
             :next "nightshift/inside")

(dialog-text "nightshift/inside"
             "the room receives you. there is no other word for it. bed under the window, night stand, glass full to the line, the small table by the door, and the door clicking shut behind you with the sound of a thing concluding."
             :next "nightshift/glass-inside")

(dialog-text "nightshift/glass-inside"
             "from this side, the observation window is a curtain, drawn. you can see the corridor's light along its hem when the corridor is lit, which is how the room tells its time: hem-light for rotations, dark for the long hours, and the long hours are most of them."
             :next "nightshift/drawer")

(dialog-text "nightshift/drawer"
             "the night stand has one drawer. inside, where the inventory says nothing lives, there is a school notebook, soft with handling, and on its cover, in pencil, in a hand you know from a column of initials: NOTES. FOR THE NEXT ONE."
             :next "nightshift/notes-1")

(dialog-text "nightshift/notes-1"
             "the predecessor's notes are practical the way only the desperate are practical. drink before 0603. they log the drinking and worry if it is late. the worry travels upward in reports."
             :next "nightshift/notes-1-2")

(dialog-text "nightshift/notes-1-2"
             "spare them the reports. the water is good. it is the one thing here with no second purpose."
             :next "nightshift/notes-2")

(dialog-text "nightshift/notes-2"
             "count the doors when you need to. it upsets the new watchers, but count anyway: the counting keeps the doors honest, and appendix two is their problem. your figure will be disputed. dispute is the room breathing. let it."
             :next "nightshift/notes-3")

(dialog-text "nightshift/notes-3"
             "the last page of notes is later than the rest, the pencil pressed harder."
             :next "nightshift/notes-3-2")

(dialog-text "nightshift/notes-3-2"
             "when you hear the binder's pages through the wall, that is the log being read, and you are the subject of the sentence being written. it is possible to sleep through this. it took me years. start tonight."
             :next "nightshift/palimpsest")

(dialog-text "nightshift/palimpsest"
             "the notebook is older than its cover."
             :next "nightshift/palimpsest-2")

(dialog-text "nightshift/palimpsest-2"
             "under M-3's pencil, where the rubber has worn the paper soft, an earlier hand shows through, and under that another, the layers going down like wallpaper in an old house."
             :next "nightshift/palimpsest-3")

(dialog-text "nightshift/palimpsest-3"
             "the earliest legible layer is just numbers: in for four. hold for four. out for four."
             :next "nightshift/palimpsest-2")

(dialog-text "nightshift/palimpsest-2"
             "the notes are a relay, you understand, passed room-keeper to room-keeper down years nobody totals, every generation erasing just enough to make space and never enough to lose the drill. you are not the next one. you are the latest one. the difference is company."
             :next "nightshift/first-watch")

(dialog-scene "nightshift/first-watch"
              "the first watch, from inside."
              :next "nightshift/hem-light")

(dialog-text "nightshift/hem-light"
             "the hem of the curtain lights: a rotation has begun on the far side. you lie in the bed with your arm over the blanket and listen to the watch happening to you: the curtain's rings sliding back, the held breath at the glass, the pencil."
             :next "nightshift/being-read")

(dialog-text "nightshift/being-read"
             "through the wall, faintly, the binder's pages turn. someone is reading your 0552, your 0603, your eleven minutes. the log read from inside sounds like weather on a roof: above you, about you, and nothing you can do from under it except be accurately reported."
             :next "nightshift/hem-shadows")

(dialog-text "nightshift/hem-shadows"
             "the hem becomes your social life. you learn the watchers by their shadows along it: M-3's, still as furniture. the day shift's, rocking heel to toe at the hour's end."
             :next "nightshift/hem-shadows-2")

(dialog-text "nightshift/hem-shadows-2"
             "the new ones, whose shadows lean in too close and jerk back when the glass fogs. you have opinions about all of them. the room files your opinions under breathing."
             :next "nightshift/perform")

(dialog-text "nightshift/perform"
             "you drink before 0603, per the notes, and feel the watch relax through a wall and a curtain, which should not be a feeling and is one. spared a report, somewhere a grey coat initials a calm line, and the calm line is your doing. the room side has its competences."
             :next "nightshift/meals")

(dialog-text "nightshift/meals"
             "meals arrive during intervals that contain no one: you look away at the lawful moment, and the small table has a tray on it, and the tray is warm. the notes cover this too."
             :next "nightshift/meals-2")

(dialog-text "nightshift/meals-2"
             "do not try to catch the tray. the trying is logged, and worse, it works once, and you will wish it had not."
             :next "nightshift/eleven")

(dialog-text "nightshift/eleven"
             "the eleven minutes are the morning's whole craft."
             :next "nightshift/eleven-2")

(dialog-text "nightshift/eleven-2"
             "wake at 0552 and rise at 0603, the notes say, because fewer minutes reads as distress and more reads as decline, and eleven is the kept middle, the figure the far side can initial without a report."
             :next "nightshift/eleven-3")

(dialog-text "nightshift/eleven-3"
             "you lie in the kept middle each morning, holding the facility's nerves steady with your stillness."
             :next "nightshift/count")

(dialog-text "nightshift/count"
             "in the long hours you count the doors."
             :next "nightshift/count-2")

(dialog-text "nightshift/count-2"
             "the figure comes out wrong by one, which is correct: the count of this room has been wrong by one since before your handwriting, and the wrongness is load-bearing."
             :next "nightshift/count-3")

(dialog-text "nightshift/count-3"
             "you log it in the notebook, in pencil, under the predecessor's last entry. figure disputed. room breathing. all well."
             :next "nightshift/watchers-note")

(dialog-text "nightshift/watchers-note"
             "deep in the notebook, one page is set apart, written calmer than the rest: about the watchers. they are more frightened than you. you have the room. they have the corridor, and the corridor has them."
             :next "nightshift/watchers-note-2")

(dialog-text "nightshift/watchers-note-2"
             "be watchable. it is the only kindness that travels in that direction, and it travels."
             :next "nightshift/new-watcher")

(dialog-scene "nightshift/new-watcher"
              "some rotations later."
              :next "nightshift/new-voice")

(dialog-text "nightshift/new-voice"
             "a new watcher comes to the glass: you can tell by the curtain rings, drawn back too fast, and the breathing, unschooled, picking up the drill late. someone's first rotation. somewhere out there, M-3 is standing away from the glass, teaching by not helping."
             :next "nightshift/gift")

(dialog-text "nightshift/gift"
             "you stir, and do not wake, and take the next breath the familiar way, deliberately, the way it was once taken at you: a breath like a hand held out through glass."
             :next "nightshift/gift-2")

(dialog-text "nightshift/gift-2"
             "on the far side, a held breath answers it. the gift passes. you are the subject of someone's first line now, and you have made it a kind one."
             :next "nightshift/spelling")

(dialog-text "nightshift/spelling"
             "the new watcher's pencil is slow through the wall, stopping at the hard words, and you can hear the handbook being consulted, pages against pages."
             :next "nightshift/spelling-2")

(dialog-text "nightshift/spelling-2"
             "you breathe slower on those nights, spacing yourself out like dictation, giving them time to spell you correctly. it is the room side's one vanity: being a fair copy."
             :next "nightshift/audit")

(dialog-text "nightshift/audit"
             "once a year, two grey coats inventory the room around you while you hold the kept middle of the bed. bed, one. night stand, one. glass, one, full."
             :next "nightshift/audit-2")

(dialog-text "nightshift/audit-2"
             "doors, and here the two of them count separately, compare, and write the dispute down with visible relief: figure disputed, room breathing, all well, initials, initials. the wrongness passes its inspection, load-bearing as ever."
             :next "nightshift/recurrence")

(dialog-scene "nightshift/recurrence"
              "recurrence, from inside."
              :next "nightshift/lights-dim")

(dialog-text "nightshift/lights-dim"
             "the corridor lights dim once, in order, away from the desk and back: you know the sequence from the hem. then the room's far wall has a door in it that the inventory disputes, open, unhurried, with a dark behind it that is not the corridor's."
             :next "nightshift/card-inside")

(dialog-text "nightshift/card-inside"
             "the laminated card is in the drawer where you put it, and you hold it in the dark. IN THE EVENT OF RECURRENCE, REMAIN WHERE YOU ARE. from this side of the glass, the instruction reads differently."
             :next "nightshift/card-inside-2")

(dialog-text "nightshift/card-inside-2"
             "it is not a restriction. it is a promise extracted from the room: that remaining is possible, and that where you are will hold still enough to be remained in."
             :next "nightshift/remain-inside")

(dialog-text "nightshift/remain-inside"
             "you remain where you are. the room goes somewhere with you in it, the way a berth goes somewhere with its sleeper, and what passes outside the disputed door passes politely."
             :next "nightshift/remain-inside-2")

(dialog-text "nightshift/remain-inside-2"
             "at the pace of a thing pacing itself, and you breathe the drill, in for four, hold for four, out for four, until the wall is a wall."
             :next "nightshift/morning-after")

(dialog-text "nightshift/morning-after"
             "in the morning the glass is full to the line, refilled per schedule during an interval you would swear contained no one, and the log through the wall reads one line longer than the night you remember."
             :next "nightshift/morning-after-2")

(dialog-text "nightshift/morning-after-2"
             "you initial the notebook instead. both records are kept. only one of them is yours."
             :next "nightshift/souvenirs")

(dialog-text "nightshift/souvenirs"
             "some mornings after recurrence the room comes back carrying. a pine needle on the sill. flour dust in the blanket's weave."
             :next "nightshift/souvenirs-2")

(dialog-text "nightshift/souvenirs-2"
             "once, pressed flat under the glass of water, a tram ticket, punched, from a city whose name the inventory disputes. the room travels, and files its travels, and you are the cabinet."
             :next "nightshift/souvenirs-2")

(dialog-text "nightshift/souvenirs-2"
             "you keep them in the drawer with the notebook: needle, dust folded in paper, ticket. the inventory never objects. the drawer was always going to hold this."
             :next "nightshift/souvenirs-2-2")

(dialog-text "nightshift/souvenirs-2-2"
             "somewhere in an archive a file gets a line longer each time, and you could write the spine labels yourself now: CROSSING. HILL HOUSE. THIRD DISTRICT. OAKBARROW."
             :next "nightshift/mug")

(dialog-text "nightshift/mug"
             "one tray arrives with a mug on it. grey, designation stenciled, yours, from the staff room locker row you will never stand in again. nobody initials a reason."
             :next "nightshift/mug-2")

(dialog-text "nightshift/mug-2"
             "somebody on the far side simply decided the room side should have its own mug, and fought whatever paperwork that took, and lost the fight quietly, and sent it anyway."
             :next "nightshift/mug-2")

(dialog-text "nightshift/mug-2"
             "you drink the acceptable tea from your own mug at the lawful hour, and through the wall the binder's pages turn, and the line being written about you is calm, and the mug is the calmest thing in it."
             :next "nightshift/m3-glass")

(dialog-scene "nightshift/m3-glass"
              "the long acquaintance."
              :next "nightshift/m3-watch")

(dialog-text "nightshift/m3-watch"
             "M-3 takes the watch himself some rotations, you learn his rings on the curtain rail, slower than anyone's, and his breathing, which is the drill worn so smooth it is just breath now."
             :next "nightshift/m3-watch-2")

(dialog-text "nightshift/m3-watch-2"
             "he was on the room side once. nobody breathes like that from reading a handbook. the drill is what you take with you when they let you out."
             :next "nightshift/wall-talk")

(dialog-conversation "nightshift/wall-talk"
                     (dialog-left "M-3, through the glass"
                                  "the curtain stays shut, {facility-designation}, per procedure. procedure does not mention the wall, and the wall carries sound, and i am old enough to stand near it. how is the room.")
                     (dialog-right "you"
                                   "breathing. the figure is still disputed.")
                     (dialog-left "M-3, through the glass"
                                  "good. when the figure settles, that is when we worry. the notes in the drawer. they were mine. i never knew who got them. file that wherever you file things now.")
                     :next "nightshift/bad-nights")

(dialog-text "nightshift/bad-nights"
             "on the bad nights, and the room side has them, M-3 stands at the wall after hours and reads you the day's log line aloud, low, against every procedure he has ever initialed. subject slept."
             :next "nightshift/bad-nights-2")

(dialog-text "nightshift/bad-nights-2"
             "figure disputed. classification unchanged. read in his voice, through stone, it is not a report. it is a tucking in."
             :next "nightshift/succession")

(dialog-text "nightshift/succession"
             "so the cycle shows you its whole shape at last: subject, then handler, then the long seniority of standing near walls. the second coat in your locker, elbows gone soft."
             :next "nightshift/succession-2")

(dialog-text "nightshift/succession-2"
             "the column of initials that stop being letters and start being yours. the facility does not hire. it rotates."
             :next "nightshift/offer")

(dialog-say "nightshift/offer"
            "M-3, through the glass"
            "my rotation is ending, {facility-designation}. not the shift. the tenure. the desk will want someone who has read the log from both sides, and the room will want someone it has already kept. you may have either chair. the facility asks you not to want both."
            :next "nightshift/choice")

(dialog-pick "nightshift/choice"
             "through the wall, the binder waits, and through the curtain, the bed, and both of them are yours in the way that matters: by initialed hours."
             (dialog-option "stay the subject. keep the room" "nightshift/stay-room")
             (dialog-option "take the grey coat. become M-3" "nightshift/take-coat")
             (dialog-option "walk the painted line out" "nightshift/walk-out"))

(dialog-on-enter "nightshift/stay-room"
                 '(setf (dialog-value "nightshift-end") "room"))

(dialog-text "nightshift/stay-room"
             "you keep the room. the notebook gets a new first page in your hand: NOTES. FOR THE NEXT ONE, which is how the room side says forever."
             :next "nightshift/stay-room-2")

(dialog-text "nightshift/stay-room-2"
             "through the wall, a new pencil takes up the log, unschooled, careful, and you drink before 0603, and spare them the report, and the room breathes its disputed figure around you, honest as ever."
             :next "nightshift/end-glass")

(dialog-on-enter "nightshift/take-coat"
                 '(setf (dialog-value "nightshift-end") "coat"))

(dialog-text "nightshift/take-coat"
             "the coat fits the way the older coat in the locker always promised it would."
             :next "nightshift/take-coat-2")

(dialog-text "nightshift/take-coat-2"
             "on your first watch from the corridor side you draw the curtain back slowly, rings one at a time, and stand away from the glass, and the sleeper inside stirs, and takes the next breath the familiar way, and you hold yours, per the drill, and the drill holds."
             :next "nightshift/take-coat-2")

(dialog-text "nightshift/take-coat-2"
             "you initial the line M-3 initialed for years, and under it, for the first time, you write the date in full. some dates deserve to be found again. you understand the sentence now from the inside of the hand that writes it."
             :next "nightshift/end-glass")

(dialog-on-enter "nightshift/walk-out"
                 '(setf (dialog-value "nightshift-end") "out"))

(dialog-text "nightshift/walk-out"
             "you walk the painted line out, past the desk, past the sheet with its column of your initials, and the line carries you to a door you have never been shown, and the handle is warm."
             :next "nightshift/walk-out-2")

(dialog-text "nightshift/walk-out-2"
             "on the other side of the door someone has just let go of it, the way someone always has, and you go through anyway, which is the one move the facility never files, because it cannot see past its own doors."
             :next "nightshift/end-glass")

(dialog-text "nightshift/end-glass"
             "and last, wherever the choice has put you, there is a glass of water, full to its line, and you stand it where it goes, to the millimeter, because the keeping of it was never the facility's."
             :next "nightshift/end-glass-2")

(dialog-text "nightshift/end-glass-2"
             "it was always the room's, and the room's people's, and you are one of them now, whichever side of the glass you kept."
             :next "nightshift/end")

(dialog-text "nightshift/end"
             "however the rotation ends, it ends the same way every rotation has ever ended: with a bed, a night stand, a glass of water full to the line, and sleep arriving per schedule, during an interval that contains no one, to refill you."
             :next "base/awake")
