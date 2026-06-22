;;; Lights out: the rogue path's second dark branch. The torch fails and
;;; the delve goes sight-starved. Entered by pressing on past the torch's
;;; reach; rejoins at the stair hunt.

(dialog-text "lightsout/press"
             "you press on past the torch's reach. it gutters brown, then goes out."
             :next "lightsout/dies")

(dialog-text "lightsout/dies"
             "you keep one hand on the wall and count doorframes by touch. another set of steps keeps half a pace behind yours."
             :next "lightsout/hide-setup")

(dialog-text "lightsout/hide-setup"
             "something comes down the middle of the corridor. you stop breathing."
             :next "lightsout/hold-still")

(dialog-minigame "lightsout/hold-still"
                 "space, w, or up arrow lets a breath out. stay quiet until it passes."
                 :game :forest-hide
                 :success "lightsout/passed"
                 :failure "lightsout/brushed"
                 :config '(:duration 9.0 :breath-rise 0.09))

(dialog-text "lightsout/passed"
             "it passes the way a barge passes a swimmer: a long displacement, a smell of cold wax and old fur, and the floor's count of your heartbeats. then the draft resumes, and the warm wall eases under your hand, and you both go on."
             :next "lightsout/middles")

(dialog-text "lightsout/brushed"
             "it slows beside you. something at coat height takes one breath of you, files the result, and moves on, unhurried, having found you to be exactly what the inventory says. being known is the toll."
             :next "lightsout/brushed-2")

(dialog-text "lightsout/brushed-2"
             "you pay it standing very still, and the corridor gives you back your lungs a size smaller."
             :next "lightsout/middles")

(dialog-text "lightsout/middles"
             "you understand the lanes now. the walls have their tenants and the brackets have their feeders, and the middle of a corridor is the lane left over, walked by whatever the rota could not cover. you keep to the wall."
             :next "lightsout/lamplighter-glow")

(dialog-text "lightsout/lamplighter-glow"
             "farther on, around no corner you can point to, there is almost-light, so faint you might be inventing it, the kind your eyes make for themselves after a lamp goes out. and a sound you know from somewhere upstairs: a taper, being carried with care."
             :next "lightsout/lamplighter")

(dialog-say "lightsout/lamplighter"
            "the lamplighter"
            "mind the bracket. wet oil. you are the one whose torch was levied. that was not mine. i light fair, whatever the season."
            :next "lightsout/lamplighter-2")

(dialog-say "lightsout/lamplighter-2"
            "you"
            "you light torches you cannot see, in the dark, to feed the dark."
            :next "lightsout/lamplighter-3")

(dialog-say "lightsout/lamplighter-3"
            "the lamplighter"
            "i light by touch, to a rota, and what the dark does with the light afterward is the dark's business and the ledger's. you want it to be sinister. it is groceries."
            :next "lightsout/lamplighter-questions")

(dialog-interrogation "lightsout/lamplighter-questions"
                      "the lamplighter waits at the bracket with the taper unlit, in no apparent hurry to explain himself further unless asked."
                      (:next "lightsout/etiquette")
                      (:continue-label "learn the rules")
                      ("ask how long he has walked the round"
                       :id "round"
                       :speaker "the lamplighter"
                       "longer than the torches last, shorter than the dark. you do not count a round in years. you count it in brackets, and i have lit a great many brackets.")
                      ("ask what happens if a bracket is missed"
                       :id "missed"
                       :speaker "the lamplighter"
                       "the dark goes hungry there and takes the difference from the next warm thing. usually a rat. once a lamplighter who argued the rota. i do not argue the rota.")
                      ("ask whether the dark ever refuses the light"
                       :id "refuse"
                       :speaker "the lamplighter"
                       "never. it is the most grateful thing i tend. a mouth that says thank you is not a monster. it is a guest, and i keep it fed like one."))

(dialog-say "lightsout/etiquette"
            "the lamplighter"
            "since you are walking my round: rules. never strike a light without offering it. announce yourself at the crossings. and if you feed it by hand, feed it small and feed it finished. the dark keeps what it is given. give it nothing you want back."
            :next "lightsout/etiquette-2")

(dialog-say "lightsout/etiquette-2"
            "you"
            "has it ever given anything back?"
            :next "lightsout/etiquette-3")

(dialog-say "lightsout/etiquette-3"
            "the lamplighter"
            "once. a candle, spent, returned to the upper shrine, stood back in its socket, guttered. nobody knows whose. the dark kept the burning and returned the wax. that is the dark being generous. study it."
            :next "lightsout/one-dark")

(dialog-say "lightsout/one-dark"
            "the lamplighter"
            "you are wondering if it is one dark or many. everyone walks a round wondering that."
            :next "lightsout/one-dark-2")

(dialog-say "lightsout/one-dark-2"
            "you"
            "which is it?"
            :next "lightsout/one-dark-3")

(dialog-say "lightsout/one-dark-3"
            "the lamplighter"
            "one, the way a river is one river. what you feed at this bracket is drunk at every bracket, and somewhere a dark that has never met you is a little less hungry because you stood here. that is either comforting or enormous. most people need it to be one or the other. it is both."
            :next "lightsout/round")

(dialog-text "lightsout/round"
             "you walk the round with the lamplighter, bracket to bracket, and learn the work by sound: the scrape of the taper, the catch of the wick."
             :next "lightsout/round-flame")

(dialog-text "lightsout/round-flame"
             "then, each time, comes the long soft pull as the new flame bends into the dark and is drunk, steadily, like a beast at a trough at evening."
             :next "lightsout/round-attending")

(dialog-text "lightsout/round-attending"
             "the lamplighter stands by each torch while it is taken, a hand on the bracket, the way a farmer stands at the rail at feeding. not guarding. attending."
             :next "lightsout/round-company")

(dialog-text "lightsout/round-company"
             "the dark eats better with company, is the theory, and the theory is the lamplighter's own, and nobody is in a position to argue."
             :next "lightsout/taper")

(dialog-text "lightsout/taper"
             "the taper itself is never offered. it rides cupped in the lamplighter's off hand, fed first at every stop, shielded with a shoulder when the dark leans in."
             :next "lightsout/taper-s2")

(dialog-text "lightsout/taper-s2"
             "the one protected flame on the round. the dark respects it the way a table respects the serving spoon."
             :next "lightsout/taper-2")

(dialog-text "lightsout/taper-2"
             "lit, the lamplighter says, from the lamp at the bottom of the stacks. the clerk's lamp. the building's first fire."
             :next "lightsout/taper-2-2")

(dialog-text "lightsout/taper-2-2"
             "if the taper goes out, the round starts again from the bottom, in the dark, on the ramps, and the lamplighter has done that walk twice in a tenure and aged a shelf-mark each time."
             :next "lightsout/your-turn")

(dialog-text "lightsout/your-turn"
             "halfway down the round, without ceremony, the lamplighter puts the taper in your hand. wet oil, two brackets, i will say when."
             :next "lightsout/your-turn-2")

(dialog-text "lightsout/your-turn-2"
             "and you light two torches by touch, shoulder shielding the mother flame, while the dark leans in around you like a stable at oats, and your hands do not shake, which both of you note and neither mentions."
             :next "lightsout/ration-manners")

(dialog-text "lightsout/ration-manners"
             "somewhere on the round your stomach states its business, and your hand finds the ration in your pocket and stops there."
             :next "lightsout/ration-manners-s2")

(dialog-text "lightsout/ration-manners-s2"
             "never eat in front of it, you remember, before the rule was given. the lamplighter, not turning: you will do, for a surface person."
             :next "lightsout/shrine-maps")

(dialog-text "lightsout/shrine-maps"
             "and the upper shrine assembles itself in your head, correctly this time: the candles are the table, and the maps nailed under them are reading matter."
             :next "lightsout/shrine-maps-2")

(dialog-text "lightsout/shrine-maps-2"
             "what the candles light, the dark reads while it eats. it likes to know its own shape, the lamplighter says. everyone does."
             :next "lightsout/licked-bracket")

(dialog-text "lightsout/licked-bracket"
             "one bracket on the round you find by touch before the lamplighter names it: the stone around it is polished smooth as the inside of a cup, a full arm's reach in every direction."
             :next "lightsout/licked-bracket-2")

(dialog-text "lightsout/licked-bracket-2"
             "the bad winter, is all the lamplighter says, and feeds that bracket first, and stands with it longest."
             :next "lightsout/short-rota")

(dialog-text "lightsout/short-rota"
             "two brackets on the round are empty. the rota is short, the lamplighter says, in the voice of a person rationing a household. the levies make up some of it."
             :next "lightsout/short-rota-2")

(dialog-text "lightsout/short-rota-2"
             "the rest, the dark goes without, and a dark that goes without gets ideas, and the ideas walk the middles of corridors."
             :next "lightsout/feed-choice")

(dialog-pick "lightsout/feed-choice"
             "at the round's last bracket the lamplighter pauses, taper down, and the dark settles in around the two of you, close, expectant, like a table waiting to be served."
             (dialog-option "feed it your dead torch stub" "lightsout/feed-stub")
             (dialog-option "feed it the ring" "lightsout/feed-ring"
                            :when '(not (dialog-value "rogue-ring-worn")))
             (dialog-option "give it nothing" "lightsout/feed-nothing"))

(dialog-on-enter "lightsout/feed-stub"
                 '(setf (dialog-value "lightsout-fed") "stub"))

(dialog-text "lightsout/feed-stub"
             "you hold out the dead stub and the lamplighter lights it one last time from the taper, because the dark takes its meals lit."
             :next "lightsout/feed-stub-2")

(dialog-text "lightsout/feed-stub-2"
             "the flame pulls long, bends, and is drunk to the wood, and the stub goes light in your fingers, then absent, taken cleanly, like a coin from an open palm."
             :next "lightsout/fed-after")

(dialog-on-enter "lightsout/feed-ring"
                 '(setf (dialog-value "lightsout-fed") "ring"))

(dialog-text "lightsout/feed-ring"
             "you hold out the unidentified ring, and the dark considers it the way you consider an unfamiliar dish, and takes it slowly, silver, curse and all."
             :next "lightsout/feed-ring-2")

(dialog-text "lightsout/feed-ring-2"
             "somewhere in the walls, the pacing makes a sound you have never heard from it, short and low, which you elect to file as laughter."
             :next "lightsout/fed-after")

(dialog-text "lightsout/fed-after"
             "the change is immediate and impossible to point at: the dark around you goes from standing to sitting. the corridor's pressure eases off your ears."
             :next "lightsout/fed-after-s2")

(dialog-text "lightsout/fed-after-s2"
             "fed, the lamplighter says, approvingly, and to the dark, not to you: there now. and the dark, demonstrably, is there."
             :next "lightsout/fed-after-2")

(dialog-text "lightsout/fed-after-2"
             "a fed dark has its own feel. it is the difference between being unwatched and being unbothered. you stand in it and understand why the lamplighter has held this round for a tenure. it is good to be left alone like this. that is the whole of the pay, and it is enough."
             :next "lightsout/walked-up")

(dialog-text "lightsout/walked-up"
             "the dark walks you back personally."
             :next "lightsout/walked-up-2")

(dialog-text "lightsout/walked-up-2"
             "there is no other way to put it. the warm wall on one side, a new warmth on the other. the corridor unrolls underfoot at exactly your stride. doors arrive when expected. the draft holds your bearing for you, steady on the same cheek the whole way."
             :next "lightsout/bracket-relit")

(dialog-on-enter "lightsout/feed-nothing"
                 '(setf (dialog-value "lightsout-fed") "nothing"))

(dialog-text "lightsout/feed-nothing"
             "you keep your pockets. the lamplighter does not judge, having rationed households too, and the dark does not punish, which is worse: it simply stops attending you."
             :next "lightsout/feed-nothing-2")

(dialog-text "lightsout/feed-nothing-2"
             "the dark stops attending you. the corridor goes from a place you are in to a distance you must cover."
             :next "lightsout/long-count")

(dialog-text "lightsout/long-count"
             "you cover it by arithmetic: doors counted, drafts banked, the warm wall your one rail. it takes what it takes."
             :next "lightsout/long-count-arrival")

(dialog-text "lightsout/long-count-arrival"
             "when you misstep, nothing catches you, and when you arrive, nothing congratulates you. you have never been this proud, or this alone."
             :next "lightsout/long-count-knock")

(dialog-text "lightsout/long-count-knock"
             "the warm wall stayed, is the thing you will keep from it."
             :next "lightsout/long-count-knock-s2")

(dialog-text "lightsout/long-count-knock-s2"
             "unfed, unobliged, the pacing held its half step the whole way, and at the last crossing it knocked once, low, level with your hand, and you knocked back."
             :next "lightsout/bracket-relit")

(dialog-text "lightsout/bracket-relit"
             "at the row's end, behind you, a bracket catches: the lamplighter, on the rota, restoring your stretch of corridor to the menu."
             :next "lightsout/bracket-relit-2")

(dialog-text "lightsout/bracket-relit-2"
             "the light reaches you at the ankles like tidewater and stops there, respectful. your eyes hurt at even this much. that is how far in you went."
             :next "lightsout/goodbye")

(dialog-text "lightsout/goodbye"
             "the lamplighter does not say goodbye, exactly."
             :next "lightsout/goodbye-s2")

(dialog-text "lightsout/goodbye-s2"
             "the taper dips once in your direction, the smallest light in the building acknowledging you over the new torch's shoulder, and the round goes on, bracket by bracket, into the dark it keeps, which keeps it back."
             :next "lightsout/rota-board")

(dialog-text "lightsout/rota-board"
             "at the junction by the stairs, the rota is chalked on the wall, bracket by bracket, in the lamplighter's square hand."
             :next "lightsout/rota-board-2")

(dialog-text "lightsout/rota-board-2"
             "your bracket's line has been amended tonight: levied, struck through, and after it, restored. the books balance. down here they always balance. the question is only ever out of whose bracket."
             :next "lightsout/torch-handed")

(dialog-text "lightsout/torch-handed"
             "a fresh torch stands in the next bracket, already half spent, which you now read correctly: half for you, half for the table."
             :next "lightsout/torch-handed-2")

(dialog-text "lightsout/torch-handed-2"
             "you take it, and tithe is the word you think, lifting it, and the flame leans once toward the dark, courteously, and the dark, courteously, declines."
             :next "lightsout/sight-back")

(dialog-text "lightsout/sight-back"
             "sight comes back the way feeling comes back to a slept-on arm: in pins, in stages, embarrassingly grateful."
             :next "lightsout/sight-back-2")

(dialog-text "lightsout/sight-back-2"
             "the row of doors stands where your count put them, every one, and you look at the corridor you crossed blind, and it is shorter than it was, and longer than it looks, and yours now. you have been here in the dark."
             :next "rogue/stair-hunt")
