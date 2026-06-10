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
             :next "alice/court")

(dialog-text "alice/chair"
             "the empty chair asks whether you are awake. it does not wait for your answer."
             :next "alice/court")

(dialog-text "alice/thread"
             "the white thread runs under every plate and up your sleeve."
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

(dialog-conversation "alice/cup-stand"
                     (dialog-left "the cup"
                                  "i was set down full and turned over empty, or set down empty and turned over full. it was dark in the cupboard either way.")
                     (dialog-right "you"
                                   "is that testimony?")
                     (dialog-left "the cup"
                                  "it is the whole of my experience. the court asked for nothing less.")
                     :next "alice/chair-stand")

(dialog-conversation "alice/chair-stand"
                     (dialog-left "the chair"
                                  "i asked the defendant whether they were awake. i am still waiting. i have been sat on while waiting, which i note without complaint.")
                     (dialog-right "you"
                                   "i never answered because i did not know.")
                     (dialog-left "the chair"
                                  "the witness thanks the defendant for answering at last, and notes the answer was given in court, under oath, three days late.")
                     :next "alice/thread-stand")

(dialog-conversation "alice/thread-stand"
                     (dialog-left "the white thread"
                                  "i have measured the room. four walls. one window that is sometimes a wall. doors as numbered, numbering disputed.")
                     (dialog-right "you"
                                   "how many doors did you find?")
                     (dialog-left "the white thread"
                                  "i found all of them. the court will not like the figure, so i have tied it in a knot.")
                     :next "alice/cross-choice")

(dialog-pick "alice/cross-choice"
             "the judge allows one cross-examination, on courtesy grounds."
             (dialog-option "cross-examine the cup" "alice/cross-cup")
             (dialog-option "cross-examine the chair" "alice/cross-chair")
             (dialog-option "cross-examine the thread" "alice/cross-thread"))

(dialog-on-enter "alice/cross-cup"
                 '(setf (dialog-value "alice-crossed") "cup"))

(dialog-conversation "alice/cross-cup"
                     (dialog-right "you"
                                   "who fills you each night?")
                     (dialog-left "the cup"
                                  "someone with steady hands and no reflection i can hold. water has a poor memory for faces.")
                     (dialog-right "you"
                                   "then your testimony is hearsay.")
                     (dialog-left "the cup"
                                  "all water is hearsay. the court drinks it anyway.")
                     :next "alice/unfinished")

(dialog-on-enter "alice/cross-chair"
                 '(setf (dialog-value "alice-crossed") "chair"))

(dialog-conversation "alice/cross-chair"
                     (dialog-right "you"
                                   "why did you ask if i was awake?")
                     (dialog-left "the chair"
                                  "because it is the polite form. one does not ask what one actually wonders, which is whether you can stop.")
                     (dialog-right "you"
                                   "stop what?")
                     (dialog-left "the chair"
                                  "the witness has answered enough questions truthfully for one trial, and requests a cushion.")
                     :next "alice/unfinished")

(dialog-on-enter "alice/cross-thread"
                 '(setf (dialog-value "alice-crossed") "thread"))

(dialog-conversation "alice/cross-thread"
                     (dialog-right "you"
                                   "untie the knot. how many doors?")
                     (dialog-left "the white thread"
                                  "objection. the knot is load-bearing.")
                     (dialog-right "you"
                                   "overruled. how many?")
                     (dialog-left "the white thread"
                                  "as many as you counted, plus the one you use. the court may do its own arithmetic.")
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
               :target "alice/verdict")

(dialog-say "alice/verdict"
            "the card judge"
            "the court finds the room was yours all along. the sentence is that you go back and keep it."
            :next "alice/appeal-choice")

(dialog-pick "alice/appeal-choice"
             "the gavel hovers."
             (dialog-option "accept the sentence" "alice/accept")
             (dialog-option "appeal" "alice/appeal")
             (dialog-option "ask what keeping means" "alice/keeping"))

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
             :next "alice/inspection-close")

(dialog-say "alice/inspection-close"
            "the card judge"
            "the room passes inspection. it always does. that has begun to trouble the court, but the court's trouble is not the defendant's sentence. you may go back to bed."
            :next "alice/thread-out")

(dialog-text "alice/thread-out"
             "the white thread is tied to your wrist now. it runs out under the courtroom door, and you follow it."
             :next "base/awake")


(dialog-particles "rogue/entrance" :rising :fade-seconds 2.5)
(dialog-music "rogue/entrance" "audio/rogue-lyria-drone.mp3" :volume 0.26)

(dialog-text "rogue/entrance"
             "the upper exit opens onto a dungeon floor drawn in hard white lines."
             :next "rogue/inventory")

(dialog-text "rogue/inventory"
             "you have a ration, a ring you cannot identify, and no memory of which stairs brought you to this floor."
             :next "rogue/door")

(dialog-list "rogue/door"
             "choose a door."
             (dialog-option "north: damp stone" "rogue/north")
             (dialog-option "east: old bones" "rogue/east")
             (dialog-option "west: quiet altar" "rogue/west"))

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
             "the ration tastes like the breakfast you did not eat at the inn."
             :next "rogue/unfinished")

(dialog-text "rogue/unfinished"
             "at the corridor's end, a staircase leads down. your name is carved into the first step."
             :next "rogue/stairs")

(dialog-pick "rogue/stairs"
             "the carving is older than the dust on it."
             (dialog-option "take the stairs down" "rogue/floor-two")
             (dialog-option "go back the way you came" "rogue/back"))

(dialog-text "rogue/back"
             "you walk back. the door you came through is locked from the other side. the stairs are the way that is open."
             :next "rogue/floor-two")

(dialog-text "rogue/floor-two"
             "the steps are worn smooth in the middle, the way stone wears under years of feet. they end at a landing with three doors and a draft."
             :next "rogue/landing")

(dialog-list "rogue/landing"
             "choose a door."
             (dialog-option "north: oiled metal" "rogue/armory")
             (dialog-option "east: standing water" "rogue/cistern")
             (dialog-option "west: old wax" "rogue/shrine"))

(dialog-on-enter "rogue/armory"
                 '(setf (dialog-value "rogue-floor2-room") "armory"))

(dialog-text "rogue/armory"
             "an armory, racks empty except one: a short sword, oiled, recently. the whetstone beside it is worn to a wafer."
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
             "you hang the brass key on an empty nail. it fits the nail the way it fit the lock, which is to say exactly, which is to say you should not have been surprised either time."
             :next "rogue/far-hall")

(dialog-text "rogue/take-key"
             "you take the nearest key. it is brass, warm from the candles, and the nail it leaves behind is the only empty one in the row."
             :next "rogue/far-hall")

(dialog-text "rogue/leave-keys"
             "you leave them. on the way out you count the nails, lose the count, and decide the count was not yours to make."
             :next "rogue/far-hall")

(dialog-text "rogue/far-hall"
             "the far hall narrows. along it, something keeps pace with you one wall away, matching your steps so well that stopping feels like an agreement."
             :next "rogue/far-door"

)

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
             (dialog-option "find the stairs back" "rogue/stair-hunt"))

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
             "the stair you came down is not where you left it, which in a dungeon means you are remembering wrong, and you prefer the dungeon's explanation. you walk the corridor to find it."
             :next "rogue/stair-maze")

(dialog-minigame "rogue/stair-maze"
                 "w/s or up/down move. a/d or left/right turn. find the stairs."
                 :game :dream-maze
                 :success "rogue/stair-found"
                 :failure "rogue/stair-lost")

(dialog-text "rogue/stair-found"
             "the stairs are where stairs are: at the end you had not tried yet. going up, the carved name on the first step reads the same from below, which carved names should not."
             :next "rogue/return-cell")

(dialog-text "rogue/stair-lost"
             "the corridor gives out before the torch does, barely. when you stop, you are outside a door you know by the bar leaning beside it, lifted often."
             :next "rogue/return-cell")

(dialog-text "rogue/return-cell"
             "you go back into the cell because it is the room you know, and shut the door, and there is still no lock plate on this side, and tonight that is almost a comfort."
             :next "rogue/sleep")

(dialog-text "rogue/pillow"
             "under the pillow there is a paper matchbook, half used."
             :next "rogue/sleep")

(dialog-text "rogue/hands"
             "they are coming back, fingers last."
             :next "rogue/sleep")

(dialog-text "rogue/sleep"
             "you lie down. the white lines of the room soften as the torch goes out."
             :next "base/awake")
