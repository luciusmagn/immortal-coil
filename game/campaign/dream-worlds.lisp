(dialog-particles "alice/fall" :rising :fade-seconds 3.0)
(dialog-music "alice/fall" "audio/alice-lyria-drone.mp3" :volume 0.24)

(dialog-text "alice/fall"
             "the left exit descends as a stairwell."
             :next "alice/table")

(dialog-text "alice/table"
             "at the bottom waits a table set for many people. every cup is turned upside down except one."
             :next "alice/choice")

(dialog-pick "alice/choice"
             "which courtesy do you accept?"
             (dialog-option "drink from the cup" "alice/cup")
             (dialog-option "answer the chair" "alice/chair")
             (dialog-option "follow the white thread" "alice/thread"))

(dialog-text "alice/cup"
             "the tea tastes like rainwater collected from a ceiling crack you remember."
             :next "alice/garden")

(dialog-text "alice/chair"
             "the empty chair asks whether you are awake. it does not wait for your answer."
             :next "alice/garden")

(dialog-text "alice/thread"
             "the white thread runs under every plate and up your sleeve."
             :next "alice/garden")

(dialog-text "alice/garden"
             "the way to the court runs through a garden of doors planted in rows, each with a number painted on it, fresh. a gardener moves down the row with a brush and a bucket of white."
             :next "alice/gardener")

(dialog-say "alice/gardener"
            "the gardener"
            "mind the wet ones. we repaint the numbers nightly. they will not hold still otherwise."
            :next "alice/gardener-2")

(dialog-say "alice/gardener-2"
            "you"
            "what were they before you painted them?"
            :next "alice/gardener-3")

(dialog-say "alice/gardener-3"
            "the gardener"
            "numbered. that is the trouble. a door takes whatever number you give it, and someone has been generous."
            :next "alice/garden-count")

(dialog-text "alice/garden-count"
             "you pass the painted rows. your eyes keep trying to total them, and you keep not letting them."
             :next "alice/queue")

(dialog-text "alice/queue"
             "outside the court there is a queue: the cup on a velvet cushion, the chair standing with its back straight, and the white thread coiled neatly on a nail, waiting to be called."
             :next "alice/queue-talk")

(dialog-say "alice/queue-talk"
            "the chair"
            "the defendant. good. we were told you would be late, so you are exactly on time."
            :next "alice/queue-talk-2")

(dialog-say "alice/queue-talk-2"
            "you"
            "what are you all witnesses to?"
            :next "alice/queue-talk-3")

(dialog-say "alice/queue-talk-3"
            "the chair"
            "the room, of course. everyone here is a witness to the room. you are the only one they had to send for."
            :next "alice/court")

(dialog-say "alice/court"
            "the card judge"
            "state your name, your crime, and the size of the room you came from."
            :next "alice/docket")

(dialog-say "alice/docket"
            "the card judge"
            "the docket reads: one room kept carelessly. one glass left standing. doors counted wrongly on at least one occasion. how do you plead?"
            :next "alice/plea")

(dialog-pick "alice/plea"
             "the jury sharpens its pencils all at once."
             (dialog-option "guilty" "alice/plea-guilty")
             (dialog-option "not guilty" "alice/plea-not")
             (dialog-option "ask whose room it is" "alice/plea-whose"))

(dialog-on-enter "alice/plea-guilty"
                 '(setf (dialog-value "alice-plea") "guilty"))

(dialog-say "alice/plea-guilty"
            "the card judge"
            "guilty of keeping a room. very honest. honesty is two points against you; the court prefers manners."
            :next "alice/witnesses")

(dialog-on-enter "alice/plea-not"
                 '(setf (dialog-value "alice-plea") "not-guilty"))

(dialog-say "alice/plea-not"
            "the card judge"
            "not guilty. then the room is keeping you, which is a different charge with the same sentence. proceed."
            :next "alice/witnesses")

(dialog-on-enter "alice/plea-whose"
                 '(setf (dialog-value "alice-plea") "whose"))

(dialog-say "alice/plea-whose"
            "the card judge"
            "whose indeed. that is the question before the court, and asking the question before the court is contempt of it. one point. proceed."
            :next "alice/witnesses")

(dialog-text "alice/witnesses"
             "three witnesses are sworn in: the cup, the chair, and the white thread. the cup is carried. the chair walks."
             :next "alice/cup-stand")

(dialog-say "alice/cup-stand"
            "the cup"
            "i was set down full and turned over empty, or set down empty and turned over full. it was dark in the cupboard either way."
            :next "alice/cup-stand-2")

(dialog-say "alice/cup-stand-2"
            "you"
            "is that testimony?"
            :next "alice/cup-stand-3")

(dialog-say "alice/cup-stand-3"
            "the cup"
            "it is the whole of my experience. the court asked for nothing less."
            :next "alice/chair-stand")

(dialog-say "alice/chair-stand"
            "the chair"
            "i asked the defendant whether they were awake. i am still waiting. i have been sat on while waiting, which i note without complaint."
            :next "alice/chair-stand-2")

(dialog-say "alice/chair-stand-2"
            "you"
            "i never answered because i did not know."
            :next "alice/chair-stand-3")

(dialog-say "alice/chair-stand-3"
            "the chair"
            "the witness thanks the defendant for answering at last, and notes the answer was given in court, under oath, three days late."
            :next "alice/thread-stand")

(dialog-say "alice/thread-stand"
            "the white thread"
            "i have measured the room. four walls. one window that is sometimes a wall. doors as numbered, numbering disputed."
            :next "alice/thread-stand-2")

(dialog-say "alice/thread-stand-2"
            "you"
            "how many doors did you find?"
            :next "alice/thread-stand-3")

(dialog-say "alice/thread-stand-3"
            "the white thread"
            "i found all of them. the court will not like the figure, so i have tied it in a knot."
            :next "alice/cross-choice")

(dialog-pick "alice/cross-choice"
             "the judge allows one cross-examination, on courtesy grounds."
             (dialog-option "cross-examine the cup" "alice/cross-cup")
             (dialog-option "cross-examine the chair" "alice/cross-chair")
             (dialog-option "cross-examine the thread" "alice/cross-thread"))

(dialog-on-enter "alice/cross-cup"
                 '(setf (dialog-value "alice-crossed") "cup"))

(dialog-say "alice/cross-cup"
            "you"
            "who fills you each night?"
            :next "alice/cross-cup-2")

(dialog-say "alice/cross-cup-2"
            "the cup"
            "someone with steady hands and no reflection i can hold. water has a poor memory for faces."
            :next "alice/cross-cup-3")

(dialog-say "alice/cross-cup-3"
            "you"
            "then your testimony is hearsay."
            :next "alice/cross-cup-4")

(dialog-say "alice/cross-cup-4"
            "the cup"
            "all water is hearsay. the court drinks it anyway."
            :next "alice/unfinished")

(dialog-on-enter "alice/cross-chair"
                 '(setf (dialog-value "alice-crossed") "chair"))

(dialog-say "alice/cross-chair"
            "you"
            "why did you ask if i was awake?"
            :next "alice/cross-chair-2")

(dialog-say "alice/cross-chair-2"
            "the chair"
            "because it is the polite form. one does not ask what one actually wonders, which is whether you can stop."
            :next "alice/cross-chair-3")

(dialog-say "alice/cross-chair-3"
            "you"
            "stop what?"
            :next "alice/cross-chair-4")

(dialog-say "alice/cross-chair-4"
            "the chair"
            "the witness has answered enough questions truthfully for one trial, and requests a cushion."
            :next "alice/unfinished")

(dialog-on-enter "alice/cross-thread"
                 '(setf (dialog-value "alice-crossed") "thread"))

(dialog-say "alice/cross-thread"
            "you"
            "untie the knot. how many doors?"
            :next "alice/cross-thread-2")

(dialog-say "alice/cross-thread-2"
            "the white thread"
            "objection. the figure is sealed."
            :next "alice/cross-thread-3")

(dialog-say "alice/cross-thread-3"
            "you"
            "overruled. how many?"
            :next "alice/cross-thread-4")

(dialog-say "alice/cross-thread-4"
            "the white thread"
            "as many as you counted, plus the one you use. the court may do its own arithmetic."
            :next "alice/unfinished")

(dialog-text "alice/unfinished"
             "the jury writes down the room before you finish describing it."
             :next "alice/smell")

(dialog-string "alice/smell"
               "the foreman asks what the room smells like. answer for the record."
               :response-key "alice-room-smell"
               :max-length 24
               :target "alice/recess")

(dialog-text "alice/recess"
             "the court recesses for tea at the long table. your cup is the witness. it pretends not to know you."
             :next "alice/tea")

(dialog-pick "alice/tea"
             "the judge pours, which is an honor with rules attached."
             (dialog-option "take it with both hands" "alice/tea-hands")
             (dialog-option "refuse politely" "alice/tea-refuse")
             (dialog-option "drink before the judge sits" "alice/tea-early"))

(dialog-on-enter "alice/tea-hands"
                 '(setf (dialog-value "alice-tea") "hands"))

(dialog-say "alice/tea-hands"
            "the card judge"
            "both hands. someone has raised you carefully, or you have been cold a long time. the court cannot tell the difference and finds it does not matter."
            :next "alice/evidence")

(dialog-on-enter "alice/tea-refuse"
                 '(setf (dialog-value "alice-tea") "refused"))

(dialog-say "alice/tea-refuse"
            "the card judge"
            "refused politely. the only thing refused politely in this court since the verdict of laughter. noted with approval and one point against."
            :next "alice/evidence")

(dialog-on-enter "alice/tea-early"
                 '(setf (dialog-value "alice-tea") "early"))

(dialog-say "alice/tea-early"
            "the card judge"
            "before i sit. so you drink first and ask afterward. the rerouted tea finds that familiar."
            :next "alice/evidence")

(dialog-text "alice/evidence"
             "after recess the exhibits are walked past the jury: a matchbook marked exhibit one, a brass key marked exhibit two, and a folded paper tag marked exhibit three, ink run, first line legible."
             :next "alice/evidence-smell")

(dialog-text "alice/evidence-smell"
             "the clerk enters {alice-room-smell} into evidence as the smell of the room, and seals the jar."
             :next "alice/doors")

(dialog-number "alice/doors"
               "the foreman asks: how many doors did the room have?"
               :response-key "door-count"
               :min 0
               :max 9
               :target "alice/deliberation")

(dialog-text "alice/deliberation"
             "the jury retires to deliberate, which here means turning their chairs around in place and whispering with their backs to the room. the whispering has a melody. you have until it resolves."
             :next "alice/deliberation-watch")

(dialog-pick "alice/deliberation-watch"
             "the foreman's pencil is the only one still moving."
             (dialog-option "listen for the melody's end" "alice/melody")
             (dialog-option "watch the judge instead" "alice/judge-watch")
             (dialog-option "count the jurors" "alice/juror-count"))

(dialog-on-enter "alice/melody"
                 '(setf (dialog-value "alice-deliberation") "listened"))

(dialog-text "alice/melody"
             "the melody is a lullaby with the intervals worn round, the kind sung by someone keeping their voice low through a door. it resolves on a note you know, and the chairs turn back."
             :next "alice/verdict-rise")

(dialog-on-enter "alice/judge-watch"
                 '(setf (dialog-value "alice-deliberation") "watched"))

(dialog-text "alice/judge-watch"
             "the judge passes the time signing blank pages, initialing each signature, and filing them in a drawer marked IN THE EVENT. he catches you watching and mouths: practice."
             :next "alice/verdict-rise")

(dialog-on-enter "alice/juror-count"
                 '(setf (dialog-value "alice-deliberation") "counted"))

(dialog-text "alice/juror-count"
             "you count the jurors twice and get two different numbers. you stop. the foreman, without turning, writes one more line."
             :next "alice/verdict-rise")

(dialog-text "alice/verdict-rise"
             "the chairs turn back. the foreman hands up the verdict folded in thirds, and the judge reads it to himself first, lips moving, the way you check a road before walking a guest onto it."
             :next "alice/verdict-record")

(dialog-say "alice/verdict-record"
            "the card judge"
            "for the record: the room measures as testified. the jar agrees with the defendant on the smell: {alice-room-smell}. the glass was full at every inspection. sentence follows."
            :next "alice/verdict")

(dialog-say "alice/verdict"
            "the card judge"
            "the court finds the room was yours all along. the sentence is that you go back and keep it."
            :next "alice/appeal-choice")

(dialog-pick "alice/appeal-choice"
             "the gavel hovers."
             (dialog-option "accept the sentence" "alice/accept")
             (dialog-option "appeal" "alice/appeal")
             (dialog-option "ask what keeping means" "alice/keeping")
             (dialog-option "refuse the sentence" "kept/refused"))

(dialog-on-enter "alice/accept"
                 '(setf (dialog-value "alice-sentence") "accepted"))

(dialog-say "alice/accept"
            "the card judge"
            "accepted with grace. the court is moved, and being moved, will now be redecorated. inspection follows."
            :next "alice/inspection")

(dialog-on-enter "alice/appeal"
                 '(setf (dialog-value "alice-sentence") "appealed"))

(dialog-say "alice/appeal"
            "the card judge"
            "the appeal is granted and denied. both rulings are final, and each cancels the other's costs. inspection follows."
            :next "alice/inspection")

(dialog-on-enter "alice/keeping"
                 '(setf (dialog-value "alice-sentence") "asked"))

(dialog-say "alice/keeping"
            "the card judge"
            "keeping means the glass filled, the doors counted, and the bed slept in by the same person who wakes in it. the court concedes the last condition is the hard one. inspection follows."
            :next "alice/inspection")

(dialog-text "alice/inspection"
             "the bailiff opens a door in the back of the court, and the court files through it into the room itself, which holds everyone comfortably and should not."
             :next "alice/inspection-bed")

(dialog-text "alice/inspection-bed"
             "the bed: present, made, marked exhibit four. the night stand: present. the glass: full, which the cup declines to explain under oath."
             :next "alice/inspection-doors")

(dialog-text "alice/inspection-doors"
             "the doors: numbering withheld pending appeal, the appeal having been granted and denied. the jury counts them silently and writes nothing down, which from a jury is fear."
             :next "alice/inspection-window")

(dialog-text "alice/inspection-window"
             "the window: present, sometimes a wall, currently a window, curtained from the far side."
             :next "alice/inspection-window-s2")

(dialog-text "alice/inspection-window-s2"
             "the bailiff taps it once with the gavel handle and notes for the record that something on the other side stopped tapping back years ago, and that the court misses it."
             :next "alice/inspection-glass")

(dialog-text "alice/inspection-glass"
             "the glass of water is entered, lifted to the light, found full to the line, and set back to the millimeter. the foreman writes one word beside it."
             :next "alice/inspection-glass-s2")

(dialog-text "alice/inspection-glass-s2"
             "from where you stand the word is either evidence or offering, and the foreman's hand covers it before you can choose."
             :next "alice/inspection-close")

(dialog-say "alice/inspection-close"
            "the card judge"
            "the room passes inspection. it always does. that has begun to trouble the court, but the court's trouble is not the defendant's sentence. you may go back to bed."
            :next "alice/effects")

(dialog-text "alice/effects"
             "before release, the clerk returns your effects: matchbook, brass key, paper tag. you did not arrive with them. you sign anyway."
             :next "alice/chambers")

(dialog-say "alice/chambers"
            "the card judge"
            "a word in chambers before you go. unofficially. which is to say, pour the tea."
            :next "alice/chambers-talk")

(dialog-say "alice/chambers-talk"
            "the card judge"
            "i have sentenced eleven defendants to keep that room. you are the first the room has kept back. the court does not know what to do with reciprocity. it is not in the rules."
            :next "alice/chambers-talk-2")

(dialog-say "alice/chambers-talk-2"
            "you"
            "what happened to the other eleven?"
            :next "alice/chambers-talk-3")

(dialog-say "alice/chambers-talk-3"
            "the card judge"
            "they wake elsewhere now, by every account comfortably. drink your tea. you take it with both hands, i am told. that will do, where you are going."
            :next "alice/garden-night")

(dialog-text "alice/garden-night"
             "the way out runs back through the garden of doors. at night the painted numbers are drying, and the gardener walks the rows blowing on them gently, one by one, like candles he has decided not to put out."
             :next "alice/garden-rows")

(dialog-text "alice/garden-rows"
             "walking the rows at night you finally see what daylight crowded out: the doors are planted in family plots."
             :next "alice/garden-rows-s2")

(dialog-text "alice/garden-rows-s2"
             "a row of fives, a row of sevens, and at the end, alone in turned earth with its number still wet, one door painted with the figure you gave the foreman, whatever it was, kept now, official."
             :next "alice/juror-gift")

(dialog-on-enter "alice/juror-gift"
                 '(setf (dialog-value "alice-foreman-pencil") t))

(dialog-text "alice/juror-gift"
             "at the garden gate a juror is waiting, out of uniform, which for a playing card means standing with the plain side forward."
             :next "alice/juror-gift-s2")

(dialog-text "alice/juror-gift-s2"
             "they press something into your hand and leave before thanks can be arranged: the foreman's pencil, sharpened down to a thumb's length of use."
             :next "alice/gate-gardener")

(dialog-say "alice/gate-gardener"
            "the gardener"
            "leaving by the gate. good. most defendants go over the wall, and the wall counts them, and then we have to repaint."
            :next "alice/gate-gardener-2")

(dialog-say "alice/gate-gardener-2"
            "you"
            "what do i owe for the gate?"
            :next "alice/gate-gardener-3")

(dialog-say "alice/gate-gardener-3"
            "the gardener"
            "the gate is free. the garden was the toll, and you paid it the day you walked through without counting. not many manage. the ones who do, we leave the gate unlocked for."
            :next "alice/thread-out")

(dialog-text "alice/thread-out"
             "the white thread is tied to your wrist now. it runs out under the courtroom door, and you follow it."
             :next "alice/thread-fork")

(dialog-pick "alice/thread-fork"
             "at the long table's leg, the thread forks: one strand runs up across the table toward the stair, and one runs down under the cloth, into the dark below the boards."
             (dialog-option "follow it up, across the table" "alice/table-again")
             (dialog-option "follow it down, under the table" "seam/under"))

(dialog-text "alice/table-again"
             "the thread crosses the long table, between the upturned cups, and they are all upright now, all full, all steaming faintly, a table set for everyone who has ever been sentenced to a room. your old place is cleared."
             :next "alice/goodbyes")

(dialog-say "alice/goodbyes"
            "the cup"
            "you will not see us again, or you will see us constantly. the distinction is administrative."
            :next "alice/goodbyes-2")

(dialog-say "alice/goodbyes-2"
            "you"
            "which administration?"
            :next "alice/goodbyes-3")

(dialog-say "alice/goodbyes-3"
            "the chair"
            "the room's. mind the stair. it pretends to be longer going up."
            :next "alice/cups-last")

(dialog-on-enter "alice/cups-last"
                 '(setf (dialog-value "alice-thread-pocket") t))

(dialog-text "alice/cups-last"
             "behind you, faint and final as a clock in another room, you hear the long table being cleared: every cup turned back over, one by one, in no hurry, by someone who knows exactly how many there are."
             :next "alice/stairwell-up")

(dialog-text "alice/stairwell-up"
             "at the top of the stairwell, the thread goes slack and slips off your wrist. you wind it twice around two fingers and put it in your pocket."
             :next "sys/reboot")


(dialog-music "rogue/ascii-reveal" "audio/rogue/chiptune-crypt.wav" :volume 0.20)

(dialog-minigame "rogue/ascii-reveal"
                 ""
                 :game :rogue-at-flash
                 :success "rogue/entrance"
                 :failure "rogue/entrance")

(dialog-particles "rogue/entrance" :rogue-glyphs :fade-seconds 2.5)

(dialog-text "rogue/entrance"
             "the upper exit opens onto a dungeon floor drawn in hard white lines."
             :next "rogue/inventory")

(dialog-text "rogue/inventory"
             "you have a ration, a ring you cannot identify, and no memory of which stairs brought you to this floor."
             :next "rogue/door")

(dialog-compass "rogue/door"
                "choose a door."
                (dialog-direction :north
                                  "rogue/north"
                                  :preview "the north door is damp stone. water beads on the handle.")
                (dialog-direction :east
                                  "rogue/east"
                                  :preview "the east door has a pale rib wedged under it.")
                (dialog-direction :west
                                  "rogue/west"
                                  :preview "the west door smells faintly of cold candle wax."))

(dialog-text "rogue/north"
             "the corridor smells of iron and wet rope. something invisible misses you by one square."
             :next "rogue/loot")

(dialog-text "rogue/east"
             "the bones are neatly stacked. someone has been sorting adventurers by height."
             :next "rogue/loot")

(dialog-text "rogue/west"
             "the altar offers a blessing in exchange for your map. older maps are already nailed beneath the candles."
             :next "rogue/loot")

(dialog-pick "rogue/loot"
             "on the floor:"
             (dialog-option "read the scroll" "rogue/scroll")
             (dialog-option "wear the ring" "rogue/ring")
             (dialog-option "eat the ration" "rogue/ration"))

(dialog-text "rogue/scroll"
             "the scroll is a scroll of identification. it names the ring: silver, old, and cursed."
             :next "rogue/unfinished")

(dialog-on-enter "rogue/ring"
                 '(setf (dialog-value "rogue-ring-worn") t))

(dialog-text "rogue/ring"
             "the ring fits. your hands fade from view, fingers first."
             :next "rogue/unfinished")

(dialog-text "rogue/ration"
             "the ration is hard bread and salt meat. it takes work to chew."
             :next "rogue/unfinished")

(dialog-text "rogue/unfinished"
             "at the corridor's end, a staircase leads down. your name is carved into the first step."
             :next "rogue/stairs")

(dialog-pick "rogue/stairs"
             "dust has settled in the cut lines."
             (dialog-option "take the stairs down" "rogue/floor-two")
             (dialog-option "go back the way you came" "rogue/back"))

(dialog-text "rogue/back"
             "you walk back. the door you came through is locked from the other side. the stairs are the way that is open."
             :next "rogue/floor-two")

(dialog-text "rogue/floor-two"
             "the steps are worn smooth in the middle, the way stone wears under years of feet. they end at a landing with three doors and a draft."
             :next "rogue/landing")

(dialog-compass "rogue/landing"
                "choose a door."
                (dialog-direction :north
                                  "rogue/armory"
                                  :preview "the north door is iron, slathered in oil and sticky to the touch.")
                (dialog-direction :east
                                  "rogue/cistern"
                                  :preview "standing water shows under the east door. the draft smells mineral.")
                (dialog-direction :west
                                  "rogue/shrine"
                                  :preview "wax has run under the west door and hardened in white ridges.")
                (dialog-direction :south
                                  "rogue/delve-entry"
                                  :preview "the south stair drops in a straight run. the air below it is colder."))

(dialog-on-enter "rogue/armory"
                 '(setf (dialog-value "rogue-floor2-room") "armory"))

(dialog-text "rogue/armory"
             "an armory, racks empty except one: a short sword, oiled, recently."
             :next "rogue/armory-s2")

(dialog-text "rogue/armory-s2"
             "the whetstone beside it is worn to a wafer, and the oil rag is folded in thirds over the rack arm, damp side in, the way someone folds who expects to need it again soon and does not expect to be thanked."
             :next "rogue/armory-choice")

(dialog-pick "rogue/armory-choice"
             "the rack waits."
             (dialog-option "take the sword" "rogue/take-sword")
             (dialog-option "leave it on the rack" "rogue/leave-sword"))

(dialog-on-enter "rogue/take-sword"
                 '(setf (dialog-value "rogue-sword") t))

(dialog-text "rogue/take-sword"
             "you take the sword. the rack's dust shows nine outlines where swords have been taken before, and one where a sword has always been returned."
             :next "rogue/far-hall")

(dialog-text "rogue/leave-sword"
             "you leave it. some things are oiled as bait, and the whetstone worried you more than the blade."
             :next "rogue/far-hall")

(dialog-on-enter "rogue/cistern"
                 '(setf (dialog-value "rogue-floor2-room") "cistern"))

(dialog-text "rogue/cistern"
             "a cistern room, ankle-deep. the water is clear and perfectly still except by the far wall, where it is still in a different way."
             :next "rogue/cistern-s2")

(dialog-text "rogue/cistern-s2"
             "held still, the way you hold a breath. you know that stillness from the inside now, from under the pines. you do it the courtesy of not staring."
             :next "rogue/cistern-choice")

(dialog-pick "rogue/cistern-choice"
             "your torchlight stops at the waterline."
             (dialog-option "wade straight across" "rogue/wade")
             (dialog-option "edge along the wall" "rogue/edge")
             (dialog-option "drink" "rogue/drink"))

(dialog-text "rogue/wade"
             "you cross loudly, on purpose, the way you would announce yourself at a door. nothing moves by the far wall until you are out of the water."
             :next "rogue/far-hall")

(dialog-text "rogue/edge"
             "you keep your shoulder to the stone the whole way. by the far door your sleeve is soaked and your count of your own footsteps is wrong by one."
             :next "rogue/far-hall")

(dialog-on-enter "rogue/drink"
                 '(setf (dialog-value "rogue-drank") t))

(dialog-text "rogue/drink"
             "you cup the water and drink. it is cold and tastes faintly of the glass on the night stand, which is not a flavor, and you drink again anyway."
             :next "rogue/far-hall")

(dialog-on-enter "rogue/shrine"
                 '(setf (dialog-value "rogue-floor2-room") "shrine"))

(dialog-text "rogue/shrine"
             "a shrine room. the altar here is smaller than the one above, and instead of maps, the offerings are keys. dozens, on nails, none labeled."
             :next "rogue/shrine-choice")

(dialog-pick "rogue/shrine-choice"
             "the candles are lit. someone keeps them lit."
             (dialog-option "offer your brass key" "rogue/offer-key"
                            :when '(dialog-value "has-brass-key"))
             (dialog-option "take a key" "rogue/take-key")
             (dialog-option "leave the keys alone" "rogue/leave-keys"))

(dialog-on-enter "rogue/take-key"
                 '(setf (dialog-value "rogue-took-key") t))

(dialog-text "rogue/offer-key"
             "you hang the brass key on an empty nail. it fits the nail the way it fit the lock. exactly. you should not have been surprised either time."
             :next "rogue/far-hall")

(dialog-text "rogue/take-key"
             "you take the nearest key. it is brass, warm from the candles, and the nail it leaves behind is the only empty one in the row."
             :next "rogue/far-hall")

(dialog-text "rogue/leave-keys"
             "you leave them. on the way out you count the nails, lose the count, and decide the count was not yours to make."
             :next "rogue/far-hall")

(dialog-text "rogue/delve-entry"
             "the stair drops past where stairs stop being furniture and start being terrain. cold air climbs it slowly, like something pacing itself, and there is no way on but down it."
             :next "rogue/delve")

(defun rogue-delve-bottom-target ()
  (if (>= (dialog-value "delve-marks" 0) 3)
      "rogue/delve-bottom-marked"
      "rogue/delve-bottom"))

(dialog-minigame "rogue/delve"
                 "wasd or arrow keys step. i opens your pack. move onto % stairs. find the bottom."
                 :game :rogue-delve
                 :success #'rogue-delve-bottom-target
                 :failure "rogue/delve-left"
                 :config (list :save-prefix "delve"
                               :caught-target "rogue/delve-caught"
                               :leave-target "rogue/delve-left"
                               :step-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/step.wav"))
                               :bump-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/bump.wav"))
                               :menu-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/menu.wav"))
                               :class-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/class.wav"))
                               :pickup-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/pickup.wav"))
                               :hit-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/hit.wav"))
                               :kill-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/kill.wav"))
                               :stairs-sound
                               (namestring (dialog-asset-pathname
                                            "audio/rogue/stairs.wav"))
                               :gen-floors 5
                               :gen-width 25
                               :gen-height 17
                               :gen-hunters 1
                               :gen-monsters 6
                               :gen-items 5
                               :gen-traps 3))

(dialog-on-enter "rogue/delve-bottom"
                 '(setf (dialog-value "rogue-delve-done") t))

(dialog-text "rogue/delve-bottom"
             "past the last door the stair gives out into a small room you know by furniture: a bed, a small table, a door. on the bed, made flat and square, lies one paper tag, ink fresh, first line legible."
             :next "rogue/bottom-choice")

(dialog-on-enter "rogue/delve-bottom-marked"
                 '(setf (dialog-value "rogue-delve-done") t))

(dialog-text "rogue/delve-bottom-marked"
             "past the last door the stair gives out into a small room you know by furniture: a bed, a small table, a door."
             :next "rogue/delve-bottom-marked-s2")

(dialog-text "rogue/delve-bottom-marked-s2"
             "the chalk marks you gathered on the way down have the same tidy strokes as the wall tally. on the bed lies one paper tag, ink fresh."
             :next "rogue/bottom-choice")

(dialog-pick "rogue/bottom-choice"
             "the tag lies on the bed. across the room, the far door stands ajar, and the air through the gap is warm, and smells of paper."
             (dialog-option "close the door on it and climb" "rogue/delve-after")
             (dialog-option "go through the far door" "below/door"))

(dialog-text "rogue/delve-after"
             "you do not take the tag. you close the door on it, quietly, the way you would on someone sleeping, and climb until the stair ends at furniture again: a far hall, and at the end of it a barred door."
             :next "rogue/far-door")

(dialog-text "rogue/delve-caught"
             "the pacing closes its distance all at once, from the one direction you were not counting. you wake on the landing with the torch relit and your hours kept for you. nothing is missing except the going down."
             :next "rogue/delve-return-choice")

(dialog-text "rogue/delve-left"
             "you climb back to the landing. the cold reaches the door behind you and stops there."
             :next "rogue/delve-return-choice")

(dialog-pick "rogue/delve-return-choice"
             "the stair is still open, and it is the only thing here that is."
             (dialog-option "go back down" "rogue/delve-entry")
             (dialog-option "climb to the landing" "rogue/landing"))

(dialog-text "rogue/far-hall"
             "the far hall narrows. along it, something keeps pace with you one wall away, matching your steps so well that stopping feels like an agreement. it ends where the floor does, at the head of a stair going down."
             :next "rogue/delve-entry")

(dialog-pick "rogue/far-door"
             "the hall ends at a barred door. the bar is on your side."
             (dialog-option "lift the bar quietly" "rogue/bar-quiet")
             (dialog-option "knock first" "rogue/bar-knock")
             (dialog-option "wait and listen" "rogue/bar-wait"))

(dialog-text "rogue/bar-quiet"
             "you lift the bar. it comes up smooth, lifted often. on the other side is a small room drawn in the same white lines: a bed, a small table, a door."
             :next "rogue/cell")

(dialog-text "rogue/bar-knock"
             "you knock. the thing pacing you in the wall stops. nothing answers, which is an answer, and you lift the bar. beyond is a small room: a bed, a small table, a door."
             :next "rogue/cell")

(dialog-text "rogue/bar-wait"
             "you wait. breathing, slow and even, on the other side of the door. you have heard it before, in a hall, through a different door. you lift the bar. the room beyond is empty: a bed, a small table, a door."
             :next "rogue/cell")

(dialog-text "rogue/cell"
             "the door has no lock plate on this side."
             :next "rogue/bed")

(dialog-pick "rogue/bed"
             "the torch is low."
             (dialog-option "search the bed" "rogue/pillow")
             (dialog-option "look at your hands" "rogue/hands"
                            :when '(dialog-value "rogue-ring-worn"))
             (dialog-option "open the door" "rogue/cell-door")
             (dialog-option "lie down" "rogue/sleep"))

(dialog-on-enter "rogue/cell-door"
                 '(setf (dialog-value "rogue-opened-cell") t))

(dialog-text "rogue/cell-door"
             "the door opens away from you, which doors here do not. beyond it the corridor runs both directions, lined with doors at even spacing, all shut."
             :next "rogue/cell-row")

(dialog-text "rogue/cell-row"
             "you try the nearest. inside: a bed, a small table, a door. the next: a bed, a small table, a door. the beds are all made. one of them has been slept in and remade badly."
             :next "rogue/row-choice")

(dialog-pick "rogue/row-choice"
             "the torch will not last the row."
             (dialog-option "check the badly made bed" "rogue/bad-bed")
             (dialog-option "listen at the shut doors" "rogue/row-listen")
             (dialog-option "find the stairs back" "rogue/stair-hunt")
             (dialog-option "press on past the torch's reach" "lightsout/press"))

(dialog-on-enter "rogue/bad-bed"
                 '(setf (dialog-value "rogue-floor3") "bed"))

(dialog-text "rogue/bad-bed"
             "under the badly remade blanket the sheet is still warm. on the small table, a glass of water, half gone. whoever sleeps here left in the middle of drinking it, or in the middle of the night, or both."
             :next "rogue/stair-hunt")

(dialog-on-enter "rogue/row-listen"
                 '(setf (dialog-value "rogue-floor3") "listened"))

(dialog-text "rogue/row-listen"
             "you go down the row with your ear to the wood. nothing. nothing. nothing. breathing, slow and even. nothing. you do not go back to the fourth door, and you are careful counting so you never have to wonder which it was."
             :next "rogue/stair-hunt")

(dialog-text "rogue/stair-hunt"
             "the stair you came down is not where you left it. in a dungeon that means you are remembering wrong. you prefer the dungeon's explanation. you walk the corridor to find it."
             :next "rogue/stair-maze")

(dialog-minigame "rogue/stair-maze"
                 "w/s or up/down move. a/d or left/right turn. find the stairs."
                 :game :dream-maze
                 :success "rogue/stair-found"
                 :failure "rogue/stair-lost"
                 :config (list :doors '(("@" "rogue/stair-found")
                                        ("?" "rogue/stair-lost")))
                 :outcomes (list "rogue/stair-found"
                                 "rogue/stair-lost"))

(dialog-text "rogue/stair-found"
             "the stairs are at the end you had not tried yet. going up, the carved name on the first step reads the same from below. carved names should not do that."
             :next "rogue/return-cell")

(dialog-text "rogue/stair-lost"
             "the corridor gives out before the torch does, barely. when you stop, you are outside a door you know by the bar leaning beside it, lifted often."
             :next "rogue/return-cell")

(dialog-text "rogue/return-cell"
             "you go back into the cell and shut the door. there is still no lock plate on this side. you set the ration tin against the door to wake you if it opens."
             :next "rogue/sleep")

(dialog-on-enter "rogue/pillow"
                 '(setf (dialog-value "rogue-matchbook") t))

(dialog-text "rogue/pillow"
             "under the pillow there is a paper matchbook, half used."
             :next "rogue/pillow-s2")

(dialog-text "rogue/pillow-s2"
             "inside the cover is a tally in pencil, the same clerk's hand as everywhere else down here, and one struck mark has been gone over twice, the way you redraw a line you wish you had not had to make."
             :next "rogue/sleep")

(dialog-text "rogue/hands"
             "they are coming back, fingers last."
             :next "rogue/sleep")

(defun rogue-wake-below-target ()
  (if (dialog-value "rogue-drank")
      "rogue/wake-below-drank"
      "rogue/wake-below"))

(dialog-text "rogue/sleep"
             "you lie down. the white lines of the room soften as the torch goes out."
             :next #'rogue-wake-below-target)

(dialog-text "rogue/wake-below"
             "you wake in the dark below ground with a new torch burning in the bracket, already half spent, lit by no one you heard. dungeons keep their own housekeeping."
             :next "rogue/housekeeping")

(dialog-text "rogue/wake-below-drank"
             "you wake in the dark below ground with a new torch burning in the bracket, and the taste of the cistern still in your mouth: cold, mineral, and exactly the taste of the glass on the night stand. dungeons keep their own housekeeping."
             :next "rogue/housekeeping")

(dialog-on-enter "rogue/housekeeping"
                 '(setf (dialog-value "rogue-saw-tally") t))

(dialog-text "rogue/housekeeping"
             "beside the torch bracket, chalked low on the stone in a tidy clerk's hand, is a tally you did not notice last night: rows of four struck through with a fifth, many rows, and one fresh mark at the end, still dusty."
             :next "rogue/housekeeping-s2")

(dialog-text "rogue/housekeeping-s2"
             "you wipe your thumb beside it and leave the mark alone."
             :next "rogue/identify")

(defun rogue-identify-target ()
  (if (dialog-value "rogue-took-key")
      "rogue/identify-key"
      "rogue/identify-plain"))

(dialog-text "rogue/identify"
             "by torchlight you lay out what you carry on the blanket and take stock, because taking stock is the whole religion down here."
             :next #'rogue-identify-target)

(dialog-text "rogue/identify-key"
             "the ration, the ring, and the shrine key. in this light the key's teeth match the memory of a lock you have only seen once, from very close, with your eye to the plate."
             :next "rogue/climb")

(dialog-text "rogue/identify-plain"
             "the ration, half gone now, and the ring. the unidentified stays unidentified. some mornings that is the only mercy a cellar offers, and you take it."
             :next "rogue/climb")

(defun rogue-companion-wall-target ()
  (if (dialog-value "rogue-sword")
      "rogue/wall-sword"
      "rogue/wall-bare"))

(dialog-text "rogue/climb"
             "you take the stairs up past the carved name, two floors of worn stone. on the second landing, the thing in the wall picks you up again, matching steps, patient as bookkeeping."
             :next #'rogue-companion-wall-target)

(dialog-text "rogue/wall-sword"
             "you draw the armory sword and rap the flat of it once against the stone, the way you would knock. the pacing stops, considers, and falls in again half a step farther off. an arrangement, then. dungeons run on arrangements."
             :next "rogue/landing-return")

(dialog-text "rogue/wall-bare"
             "you have nothing to knock with but knuckles, so you knock with knuckles. the wall is warmer than stone should be at this depth. the pacing keeps its distance the rest of the climb, and you choose to call that an answer."
             :next "rogue/landing-return")

(dialog-text "rogue/landing-return"
             "the landing with the three doors. the cistern door stands open. wet prints lead from the cistern to the blank end wall and stop there."
             :next "rogue/exit-door")

(dialog-text "rogue/exit-door"
             "a fourth door stands where the draft comes from, narrow, with a lock plate on this side. the dust at its foot shows the door has been opened many times, always toward you, never away."
             :next "rogue/exit-choice")

(dialog-pick "rogue/exit-choice"
             "the lock plate waits at eye height."
             (dialog-option "try the shrine key" "rogue/key-turn"
                            :when '(dialog-value "rogue-took-key"))
             (dialog-option "look through the keyhole" "rogue/keyhole")
             (dialog-option "leave it and climb on" "rogue/climb-on"))

(dialog-on-enter "rogue/key-turn"
                 '(setf (dialog-value "rogue-exit") "key"))

(dialog-text "rogue/key-turn"
             "the shrine key turns the way keys turn in locks they were cut for. the door opens on a small room: a bed, a night stand, a glass of water. warm air. you do not go in. you close it, gently, and leave the key in the plate."
             :next "rogue/climb-on")

(dialog-on-enter "rogue/keyhole"
                 '(setf (dialog-value "rogue-exit") "looked"))

(dialog-text "rogue/keyhole"
             "you put your eye to the keyhole. on the other side, at eye height, is darkness of a particular shape, and the draft through the hole smells of pine."
             :next "rogue/climb-on")

(dialog-text "rogue/climb-on"
             "you climb the last stair toward the white lines of the upper floor, and the dungeon does what dungeons do with those who keep moving: it lets you."
             :next "rogue/out")

(dialog-text "rogue/out"
             "the entrance hall again. your inventory is what it always was, plus what you know now. no slot carries that."
             :next "rogue/shrine-rest")

(dialog-text "rogue/shrine-rest"
             "you stop at the upper shrine on the way out, because down here you have learned to close accounts. the candles among the offered maps have burned to different heights, and one has guttered out."
             :next "rogue/candle-choice")

(dialog-pick "rogue/candle-choice"
             "there are fresh candles in a box below the altar, and a striker."
             (dialog-option "relight the guttered one" "rogue/relight")
             (dialog-option "let it stay out" "rogue/let-out")
             (dialog-option "light one of your own" "rogue/own-candle"))

(dialog-on-enter "rogue/relight"
                 '(setf (dialog-value "rogue-candle") "relit"))

(dialog-text "rogue/relight"
             "you relight it from its neighbor. the old cloth map above it shows a faded corridor and a small bed."
             :next "rogue/service-door")

(dialog-on-enter "rogue/let-out"
                 '(setf (dialog-value "rogue-candle") "out"))

(dialog-text "rogue/let-out"
             "you let it stay out. the map above it remains unreadable."
             :next "rogue/service-door")

(dialog-on-enter "rogue/own-candle"
                 '(setf (dialog-value "rogue-candle") "own"))

(dialog-text "rogue/own-candle"
             "you take a fresh candle, light it, and set it on the bare patch of altar."
             :next "rogue/service-door")

(dialog-text "rogue/service-door"
             "past the shrine is a service door. you open it. beyond are boards, stale air, and a room without torchlight."
             :next "sys/reboot")
