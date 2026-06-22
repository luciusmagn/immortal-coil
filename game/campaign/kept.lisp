;;; Kept: the alice path's first dark branch. The defendant refuses the
;;; sentence, so the court keeps them instead: a cell that is the room,
;;; visiting hours, and the annual appeal, denied with courtesy.
;;; Entered from the sentence; exits when the room files its writ.

(dialog-on-enter "kept/refused"
                 '(setf (dialog-value "alice-sentence") "refused"))

(dialog-particles "kept/refused" :motes :fade-seconds 5.0)

(dialog-say "kept/refused"
            "the card judge"
            "refused. the court has waited eleven defendants for someone to refuse. very well. if you will not keep the room, the court will keep you, and we will all see which of you misses the other first."
            :next "kept/gavel")

(dialog-text "kept/gavel"
             "the gavel comes down softly, the way a careful person closes a lid. the bailiff does not seize you. he offers his arm, the way you offer it to someone at a funeral."
             :next "kept/cell-walk")

(dialog-text "kept/cell-walk"
             "the way to the cells runs down a corridor of framed verdicts, each in its own hand, each ending in the word kept. the frames are straight. someone dusts them."
             :next "kept/induction")

(dialog-text "kept/induction"
             "at the cell door the bailiff reads the induction from a card, gently: the kept are entitled to weather, tea on thursdays, one appeal per annum, and the benefit of the doubt. the doubt is the court's. the benefit is yours."
             :next "kept/inventory")

(dialog-text "kept/inventory"
             "you sign the cell's inventory against receipt: one bed, one night stand, one glass, poured. one desk, one drawer, contents withheld."
             :next "kept/inventory-s2")

(dialog-text "kept/inventory-s2"
             "one window, condition variable. the bailiff countersigns, and his hand shakes on the window line, every time, you will learn."
             :next "kept/cell")

(dialog-text "kept/cell"
             "the cell is the room. bed under the window, night stand, glass of water poured to the line, desk with its one drawer. the door has a number you are not shown and a keyhole on both sides."
             :next "kept/cell-difference")

(dialog-text "kept/cell-difference"
             "you stand in it a long time looking for the difference, because there must be one, and there is: here, the glass sits a thumb's width off its ring mark. you move it back. you feel better. that is the cell working."
             :next "kept/first-night")

(dialog-text "kept/first-night"
             "the first night you lie awake cataloguing, and the cell offers you its sounds one at a time, politely, like exhibits: a clock without hands, the curtain on the far side of the window, a stair pretending to be longer than it is."
             :next "kept/visiting")

(dialog-scene "kept/visiting"
              "visiting hours."
              :next "kept/visitors-rule")

(dialog-text "kept/visitors-rule"
             "visiting hours are thursdays, the notice says, most days. the notice does not say which days are thursdays. you learn to tell by the corridor: on thursdays it smells faintly of tea."
             :next "kept/cup-visit")

(dialog-say "kept/cup-visit"
            "the cup"
            "i testified against you, you will recall. i have brought you tea, which is how witnesses apologize."
            :next "kept/cup-visit-2")

(dialog-say "kept/cup-visit-2"
            "you"
            "is it from the long table?"
            :next "kept/cup-visit-3")

(dialog-say "kept/cup-visit-3"
            "the cup"
            "it is from your place at it. your place is kept cleared. that is not the same as kept empty, whatever the chair tells you."
            :next "kept/cup-questions")

(dialog-interrogation "kept/cup-questions"
                      "the tea steams between you and the cup waits, with the patience of something that has nowhere it would rather be."
                      (:next "kept/tea-ceremony")
                      (:continue-label "pour the first cup")
                      ("ask what it testified to"
                       :id "testimony"
                       :speaker "the cup"
                       "the second cup is for that. you will ask, and i will answer, and we will both prefer the answer to not knowing. the first cup is only for being glad you are here.")
                      ("ask why a witness apologizes at all"
                       :id "apology"
                       :speaker "the cup"
                       "because a true testimony and a kind one are rarely the same cup, and i poured the true one. tea is the only apology a cup is shaped to make.")
                      ("ask whether the verdict can be appealed"
                       :id "appeal"
                       :speaker "the cup"
                       "everything here can be appealed. that is what keeping means. the appeal is heard, enjoyed, and denied with courtesy. drink before it cools."))

(dialog-text "kept/tea-ceremony"
             "tea with the cup has rules the cup never states and always keeps: the kept pours, the visitor steams, nobody mentions the trial until the second cup, and then both of you mention nothing else."
             :next "kept/tea-ceremony-s2")

(dialog-text "kept/tea-ceremony-s2"
             "it is the best hour of the week and you both pretend it is ordinary."
             :next "kept/chair-cushion")

(dialog-text "kept/chair-cushion"
             "the chair cannot visit. a chair holds its ground. that is what a chair is for."
             :next "kept/chair-cushion-2")

(dialog-text "kept/chair-cushion-2"
             "it sends a cushion instead, embroidered with a wall and a window, and the window is rendered in thread that catches the light only from where you sit. chairs know about sitting. it is the only thing they know."
             :next "kept/gardener-visit")

(dialog-say "kept/gardener-visit"
            "the gardener"
            "i am not supposed to bring these in. so i have brought them in. mind the soil."
            :next "kept/gardener-visit-2")

(dialog-say "kept/gardener-visit-2"
            "you"
            "doors. in pots."
            :next "kept/gardener-visit-3")

(dialog-say "kept/gardener-visit-3"
            "the gardener"
            "seedlings. fives, mostly. they do well on a sill. a door does not need to open to be company. mostly they are company by leaning."
            :next "kept/sill-doors")

(dialog-text "kept/sill-doors"
             "the door seedlings take to the sill. by the end of the season there are four small doors leaning into the light, none of them taller than the water glass, their painted numbers still wet. they do not open. they lean. it is company."
             :next "kept/weather")

(dialog-text "kept/weather"
             "the weather entitlement is honored monthly: the bailiff wheels it in on a tray. an hour of rain under glass. a box of frost, opened corner first."
             :next "kept/weather-s2")

(dialog-text "kept/weather-s2"
             "once, in some june, a full summer afternoon folded like linen, which you wore around your shoulders until it went through."
             :next "kept/weather-after")

(dialog-text "kept/weather-after"
             "you learn to ration the weather the way the district rationed flour. then you stop. you do not know where that thought comes from. the cell pretends not to have heard it. that is the cell at its kindest."
             :next "kept/smell-jar")

(dialog-text "kept/smell-jar"
             "once a season the clerk comes with the sealed jar, exhibit in trust, and lets you lift the lid for the length of one breath."
             :next "kept/smell-jar-2")

(dialog-text "kept/smell-jar-2"
             "the room smells of {alice-room-smell}, still, exactly, and you put the lid back yourself, because the clerk learned the first time not to be the one who ends it."
             :next "kept/jar-after")

(dialog-text "kept/jar-after"
             "after the jar, the cell is hardest."
             :next "kept/jar-after-2")

(dialog-text "kept/jar-after-2"
             "it has the furniture right and the smell wrong, and you sit with that until the corridor brings you its evening sounds, and the cell, to its credit, does not pretend the jar did not happen."
             :next "kept/first-appeal")

(dialog-scene "kept/first-appeal"
              "the first annual appeal."
              :next "kept/appeal-room")

(dialog-text "kept/appeal-room"
             "the appeal is heard in the same court, which has been redecorated, being moved. you are walked up through the corridor of verdicts, and the frames nod as you pass, very slightly, which frames learn to do where dusting is regular."
             :next "kept/appeal-hearing")

(dialog-say "kept/appeal-hearing"
            "the card judge"
            "the appellant appeals the keeping. the court has read the appeal twice, enjoyed it once, and denies it with courtesy. the courtesy is this: the court will also miss you when this ends, and the court does not say that to the kept."
            :next "kept/appeal-hearing-2")

(dialog-say "kept/appeal-hearing-2"
            "you"
            "when does it end?"
            :next "kept/appeal-hearing-3")

(dialog-say "kept/appeal-hearing-3"
            "the card judge"
            "when the room forgives you. the court has no jurisdiction over that and resents it annually."
            :next "kept/appeal-back")

(dialog-text "kept/appeal-back"
             "you are walked back down."
             :next "kept/appeal-back-s2")

(dialog-text "kept/appeal-back-s2"
             "the cell has been dusted in your absence, and the glass has been refilled to the line, and the four sill doors have turned, all together, a degree or two, the way plants turn."
             :next "kept/appeal-back-s3")

(dialog-text "kept/appeal-back-s3"
             "toward the corridor. toward where you come back from."
             :next "kept/frames-read")

(dialog-text "kept/frames-read"
             "on the appeal walks you learn the corridor by heart. eleven verdicts, eleven hands. the early ones are florid, all whereases. the late ones get shorter, as if the court were learning what mattered."
             :next "kept/frames-read-2")

(dialog-text "kept/frames-read-2"
             "the eleventh says only: the room was theirs all along. they have gone back to keep it. kept."
             :next "kept/twelfth-frame")

(dialog-text "kept/twelfth-frame"
             "at the corridor's end hangs a twelfth frame, empty, straight, dusted with the others. nobody has ever said it is yours."
             :next "kept/twelfth-frame-s2")

(dialog-text "kept/twelfth-frame-s2"
             "nobody has ever hung anything else in it. it is the most patient thing in the building, and the building contains the court."
             :next "kept/years")

(dialog-scene "kept/years"
              "the kept years."
              :next "kept/routine")

(dialog-text "kept/routine"
             "the years take a shape: tea on the thursdays the corridor announces, the gardener's seedlings outgrowing their pots, the annual walk up to be denied with courtesy."
             :next "kept/routine-s2")

(dialog-text "kept/routine-s2"
             "you keep the glass on its ring mark. it is not nothing. it is the whole job, in here."
             :next "kept/neighbor-visit")

(dialog-say "kept/neighbor-visit"
            "the defendant from the queue"
            "i was ahead of you in the plea line. unlawful possession of a staircase. i got the staircase. you got all this. visiting is allowed between my hearings, so i visit."
            :next "kept/neighbor-visit-2")

(dialog-say "kept/neighbor-visit-2"
            "you"
            "how is the staircase?"
            :next "kept/neighbor-visit-3")

(dialog-say "kept/neighbor-visit-3"
            "the defendant from the queue"
            "longer going up. it pretends, you know. they all pretend. yours taps, i hear. mine creaks on the third step out of sympathy. we are luckier than the ones whose furniture says nothing."
            :next "kept/seedlings-grown")

(dialog-text "kept/seedlings-grown"
             "the sill doors outgrow the sill in their fourth year and stand on the floor now, shoulder height, and the gardener measures them against the wall on visits, pencil marks and dates, the way doors are measured in houses where someone is growing."
             :next "kept/clock")

(dialog-text "kept/clock"
             "the cell's clock has no hands and keeps excellent time."
             :next "kept/clock-s2")

(dialog-text "kept/clock-s2"
             "you learn to read it by its face alone, the way the kept learn everything: by being present for all of it. when tea is near, the clock looks pleased."
             :next "kept/clock-s3")

(dialog-text "kept/clock-s3"
             "clocks have one expression more than people think."
             :next "kept/tap-one")

(dialog-text "kept/tap-one"
             "one night, low on the window glass, you tap once. it is not a plan. it is a hand doing what hands do at windows that are sometimes walls. nothing answers."
             :next "kept/tap-one-2")

(dialog-text "kept/tap-one-2"
             "you do it again the next night, once, the same place, and the night after, and it becomes the day's last entry, logged on glass."
             :next "kept/foreman-visit")

(dialog-say "kept/foreman-visit"
            "the foreman"
            "i never visit defendants. i am visiting the pencil. how is the pencil?"
            :next "kept/foreman-visit-2")

(dialog-say "kept/foreman-visit-2"
            "you"
            "i was never given it, here. it went to the other one. the one who went back."
            :next "kept/foreman-visit-3")

(dialog-say "kept/foreman-visit-3"
            "the foreman"
            "there is no other one. there is only ever the one of you. the pencil is in your coat, where i put it. look later, not now. the bailiff counts what i carry out."
            :next "kept/pencil")

(dialog-text "kept/pencil"
             "later, alone, you find it in the coat you did not arrive with: the foreman's pencil, sharpened to a thumb of use."
             :next "kept/pencil-2")

(dialog-text "kept/pencil-2"
             "there is one word in your hand on the cell wall by morning, low, behind the night stand, where inspections do not bend: KEPT. and under it, smaller: BY WHOM."
             :next "kept/eleven")

(dialog-text "kept/eleven"
             "you ask the cup, one thursday, about the eleven who accepted. the cup is quiet for a steep's length. they keep their rooms, it says. the rooms report it."
             :next "kept/eleven-s2")

(dialog-text "kept/eleven-s2"
             "nobody has asked the rooms the other question, because cups are the only ones rude enough, and we are not."
             :next "kept/second-courtesy")

(dialog-text "kept/second-courtesy"
             "the appeals grow courtlier by the year. the third is denied with courtesy and biscuits."
             :next "kept/second-courtesy-2")

(dialog-text "kept/second-courtesy-2"
             "the fifth, the judge reads a short poem he has written about the case, which rhymes kept with except and apologizes for it. the denying never wavers. under every denial is the same thing: the court would miss you."
             :next "kept/tap-answer")

(dialog-text "kept/tap-answer"
             "and one night, a winter's worth of taps in, the glass taps back. once. low. level with your hand."
             :next "kept/tap-answer-2")

(dialog-text "kept/tap-answer-2"
             "you sit very still in the dark, and your eyes are wet before you have decided anything about it, and you tap once more, and it answers once more, and then the window is a wall until morning, out of tact."
             :next "kept/drawer-opens")

(dialog-text "kept/drawer-opens"
             "in the year of the tapping, the desk drawer unlocks itself, contents no longer withheld. inside: eleven envelopes, sealed, addressed in eleven hands to THE NEXT ONE. you read them over eleven nights."
             :next "kept/drawer-opens-2")

(dialog-text "kept/drawer-opens-2"
             "they are thank-you notes. every one of them thanks the room. not the court. the room."
             :next "kept/drawer-after")

(dialog-text "kept/drawer-after"
             "you put them back in their order and add nothing, because the twelfth letter is not written with the pencil. it is written by staying, and you have stayed a long time."
             :next "kept/reinventory")

(dialog-text "kept/reinventory"
             "the morning after the glass taps back, the bailiff arrives unscheduled with the inventory and amends one line: window, condition variable, reciprocal."
             :next "kept/reinventory-s2")

(dialog-text "kept/reinventory-s2"
             "you both sign. his hand is steady on it, for the first time, and he says nothing, and leaves you the carbon."
             :next "kept/window-curtain")

(dialog-text "kept/window-curtain"
             "one night, late in some year, the curtain on the far side of the window moves. not weather. a hand's worth of movement, testing, the way you move a curtain when you are deciding about a room."
             :next "kept/window-curtain-2")

(dialog-text "kept/window-curtain-2"
             "you sit up in the dark and do not breathe, and it does not move again. for now."
             :next "kept/writ")

(dialog-scene "kept/writ"
              "the writ."
              :next "kept/writ-arrives")

(dialog-text "kept/writ-arrives"
             "it arrives at the next appeal, before the judge can deny you: a paper the bailiff carries at arm's length because it is warm. a writ, filed by the room. the room has engaged the long table as counsel."
             :next "kept/writ-arrives-2")

(dialog-text "kept/writ-arrives-2"
             "the cups stand in a row at the back of the court, upright, steaming, formal."
             :next "kept/writ-read")

(dialog-say "kept/writ-read"
            "the card judge"
            "the room moves for the return of its keeper, on the grounds that the glass has been filled by strangers for years, and is full, and has never once been drunk."
            :next "kept/writ-read-s2")

(dialog-say "kept/writ-read-s2"
            "the card judge"
            "the room states it did not raise a defendant to be kept by amateurs. the language is the room's. the court would never."
            :next "kept/recusal")

(dialog-say "kept/recusal"
            "the card judge"
            "before the court rules on the writ, the court must disclose: the court is moved. the court has been moved for years. a moved court cannot rule, and so, for the first time in its records, the court asks the defendant how this should end."
            :next "kept/choice")

(dialog-pick "kept/choice"
             "the court waits. the cups steam. somewhere down the corridor of verdicts, a frame is being dusted very slowly."
             (dialog-option "go home to the room" "kept/go-home")
             (dialog-option "stay kept, out of spite" "kept/stay")
             (dialog-option "ask the room to come in" "kept/summon"))

(dialog-on-enter "kept/go-home"
                 '(setf (dialog-value "kept-end") "returned"))

(dialog-text "kept/go-home"
             "you go home."
             :next "kept/go-home-s2")

(dialog-text "kept/go-home-s2"
             "the corridor of verdicts bows you out frame by frame, and the garden opens its gate without being asked, and the room receives you the way rooms do: by being exactly where you left it, with the water poured, and no questions, ever, about the years."
             :next "kept/corridor-last")

(dialog-on-enter "kept/stay"
                 '(setf (dialog-value "kept-end") "stayed"))

(dialog-text "kept/stay"
             "you refuse twice in one lifetime, which the court enters with something like pride. the writ is held in abeyance."
             :next "kept/stay-2")

(dialog-text "kept/stay-2"
             "the room sends, through counsel, one item for the cell: the glass from the night stand, full to the line. its line, not the cell's. you keep them both filled now. you keep two rooms."
             :next "kept/stay-3")

(dialog-text "kept/stay-3"
             "that is the spite. it is also the sentence. you keep two rooms now, and that turns out to be the title."
             :next "kept/corridor-last")

(dialog-on-enter "kept/summon"
                 '(setf (dialog-value "kept-end") "summoned"))

(dialog-text "kept/summon"
             "you ask the room to come in, and the court holds its breath. behind the witness chair, where everyone has avoided looking, there is a curtained window set into the back wall, and a door beside it."
             :next "kept/summon-2")

(dialog-text "kept/summon-2"
             "then the room is there, fitting inside the court the way the court once fit inside it, and you walk in, and it closes around you like a verdict going your way."
             :next "kept/cups-row")

(dialog-text "kept/cups-row"
             "as the court empties, the cups file past you in a row, each pausing at your shoulder for the length of a steep. that, from a cup, is an embrace."
             :next "kept/cups-row-s2")

(dialog-text "kept/cups-row-s2"
             "the last one in line is yours, the witness. it says nothing, having testified enough for one lifetime, and steams."
             :next "kept/corridor-last")

(dialog-text "kept/corridor-last"
             "on your last walk through the corridor of verdicts, however it has ended, the twelfth frame is filled: a verdict in a hand you know, because it is yours, in pencil, sharpened to a thumb of use."
             :next "kept/corridor-last-s2")

(dialog-text "kept/corridor-last-s2"
             "it says what the eleventh said, and one word more. kept. both ways."
             :next "kept/end")

(dialog-text "kept/end"
             "the sill doors come with you, wherever you have ended, four small numbered things leaning into whatever light there is, and sleep arrives the way the bailiff once did: offering its arm."
             :next "sys/reboot")
