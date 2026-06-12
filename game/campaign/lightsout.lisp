;;; Lights out: the rogue path's second dark branch. The torch economy
;;; fails, the delve goes sight-starved, and the etiquette of feeding
;;; the dark is learned by touch. Entered by pressing on past the
;;; torch's reach; rejoins at the stair hunt.

(dialog-text "lightsout/press"
             "you press on past the torch's reach, which is a decision the torch takes personally. it burns brown, then small, then honest, and you walk the row watching it die rather than rationing it, because rationing light is how the dark learns you are afraid of it."
             :next "lightsout/dies")

(dialog-text "lightsout/dies"
             "the torch dies between one door and the next. the dark does not fall. it arrives. it was waiting at the edge of the light the whole time, politely, the way the well-mannered wait, and now it comes in and takes its seat."
             :next "lightsout/first-minute")

(dialog-text "lightsout/first-minute"
             "the first minute is the worst, and you know the shape of bad minutes now, so you stand still inside it and count, and at sixty the corridor is still a corridor, your hand is still on stone, and the dark has not done anything except be all of it."
             :next "lightsout/lessons")

(dialog-text "lightsout/lessons"
             "the dark teaches by subtraction. with sight gone, the corridor hands you what is left: the draft on your right cheek that means a cross-passage, the floor's worn middle underfoot, the count of doors by their frames, four boards apart, knuckle height."
             :next "lightsout/lessons-2")

(dialog-text "lightsout/lessons-2"
             "doors, you learn, breathe. a shut room exhales under its door as you pass, a cool thread across the boot, each room's breath its own. the cells of the row go by like that, breath by breath, and one of them you pass quicker, and do not let yourself count which."
             :next "lightsout/crossing-instinct")

(dialog-text "lightsout/crossing-instinct"
             "at the first cross-passage you stop and say your name into the dark, out loud, before you know why. the crossing carries it both ways, and nothing answers, and the nothing has the texture of a nod, and you cross. some etiquette is older than the learning of it."
             :next "lightsout/warm-wall")

(dialog-text "lightsout/warm-wall"
             "and the wall. one wall is warmer than stone has any business being, and the warmth moves when you move, half a step offset, patient. the thing that paces you has not gone anywhere. in the dark, it is the only landmark that knows you back."
             :next "lightsout/reversal")

(dialog-text "lightsout/reversal"
             "you stop dead, once, as a test. the pacing goes on three steps, stops, and comes back two, and waits, the warmth of it level with your shoulder. then it sets off again, slower. you follow the warm wall. the hunter has become the handrail. neither of you remarks on it."
             :next "lightsout/count-wrong")

(dialog-text "lightsout/count-wrong"
             "your footstep count comes out wrong by one, again, the way it did along the cistern wall. in the dark you finally hear the extra step for what it is. not an echo. a contribution."
             :next "lightsout/strike")

(dialog-text "lightsout/strike"
             "at some corner you fish out your striker and snap one spark, for bearings."
             :next "lightsout/strike-2")

(dialog-text "lightsout/strike-2"
             "the spark leaps, bends sideways toward the open dark, stretches long like a thing being drunk through a straw, and goes out upward. sparks do not go out upward."
             :next "lightsout/strike-3")

(dialog-text "lightsout/strike-3"
             "you stand with the striker in your fist and revise the entire economy."
             :next "lightsout/economy")

(dialog-text "lightsout/economy"
             "the half-spent torches. the housekeeping that relights brackets nobody asked it to. the candles kept lit at the shrines. none of it was ever for the delvers. light, down here, is not equipment."
             :next "lightsout/economy-2")

(dialog-text "lightsout/economy-2"
             "it is fodder. the dungeon keeps the dark fed on a rota, and the rota is called torches."
             :next "lightsout/levy")

(dialog-text "lightsout/levy"
             "and your torch did not die early. it was levied. the dark is hungrier this season, the rota is short, and the dungeon balanced its books out of your bracket. somewhere a tidy hand has entered it: torch, one, levied. the delver can count."
             :next "lightsout/hide-setup")

(dialog-text "lightsout/hide-setup"
             "ahead, the corridor's draft goes still, which in a corridor is a held breath. something is coming the other way, down the middle of the dark, large enough to push warmth ahead of it, and the warm wall under your hand goes tense the way a held arm goes tense."
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
             "you understand the lanes now. the walls have their tenants and the brackets have their feeders, and the middle of a corridor is the lane left over, walked by whatever the rota could not cover. the edges are society. the middle is weather."
             :next "lightsout/lamplighter-glow")

(dialog-text "lightsout/lamplighter-glow"
             "farther on, around no corner you can point to, there is almost-light: not a glow, the memory of one, the way a room holds the shape of a lamp just out. and a sound you know from somewhere upstairs: a taper, being carried with care."
             :next "lightsout/lamplighter")

(dialog-conversation "lightsout/lamplighter"
                     (dialog-left "the lamplighter"
                                  "mind the bracket. wet oil. you are the one whose torch was levied. that was not mine. i light fair, whatever the season.")
                     (dialog-right "you"
                                   "you light torches you cannot see, in the dark, to feed the dark.")
                     (dialog-left "the lamplighter"
                                  "i light by touch, to a rota, and what the dark does with the light afterward is the dark's business and the ledger's. you want it to be sinister. it is groceries.")
                     :next "lightsout/etiquette")

(dialog-conversation "lightsout/etiquette"
                     (dialog-left "the lamplighter"
                                  "since you are walking my round: rules. never strike a light without offering it. announce yourself at the crossings. and if you feed it by hand, feed it small and feed it finished. the dark keeps what it is given. give it nothing you want back.")
                     (dialog-right "you"
                                   "has it ever given anything back?")
                     (dialog-left "the lamplighter"
                                  "once. a candle, spent, returned to the upper shrine, stood back in its socket, guttered. nobody knows whose. the dark kept the burning and returned the wax. that is the dark being generous. study it.")
                     :next "lightsout/one-dark")

(dialog-conversation "lightsout/one-dark"
                     (dialog-left "the lamplighter"
                                  "you are wondering if it is one dark or many. everyone walks a round wondering that.")
                     (dialog-right "you"
                                   "which is it?")
                     (dialog-left "the lamplighter"
                                  "one, the way a river is one river. what you feed at this bracket is drunk at every bracket, and somewhere a dark that has never met you is a little less hungry because you stood here. that is either comforting or enormous. most people need it to be one or the other. it is both.")
                     :next "lightsout/round")

(dialog-text "lightsout/round"
             "you walk the round with the lamplighter, bracket to bracket, and learn the work by sound: the scrape of the taper, the catch of the wick."
             :next "lightsout/round-2")

(dialog-text "lightsout/round-2"
             "and then, each time, the long soft pull as the new flame bends into the dark and is drunk, steadily, like a beast at a trough at evening."
             :next "lightsout/round-2")

(dialog-text "lightsout/round-2"
             "the lamplighter stands by each torch while it is taken, a hand on the bracket, the way a farmer stands at the rail at feeding. not guarding. attending."
             :next "lightsout/round-2-2")

(dialog-text "lightsout/round-2-2"
             "the dark eats better with company, is the theory, and the theory is the lamplighter's own, and nobody is in a position to argue."
             :next "lightsout/taper")

(dialog-text "lightsout/taper"
             "the taper itself is never offered. it rides cupped in the lamplighter's off hand, fed first at every stop, shielded with a shoulder when the dark leans in. the one protected flame on the round. the dark respects it the way a table respects the serving spoon."
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
             "somewhere on the round your stomach states its business, and your hand finds the ration in your pocket and stops there. never eat in front of it, you remember, before the rule was given. the lamplighter, not turning: you will do, for a surface person."
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
             "the change is immediate and impossible to point at: the dark around you goes from standing to sitting. the corridor's pressure eases off your ears. fed, the lamplighter says, approvingly, and to the dark, not to you: there now. and the dark, demonstrably, is there."
             :next "lightsout/fed-after-2")

(dialog-text "lightsout/fed-after-2"
             "a fed dark has a texture. it is the difference between a silent room and a quiet one, between being unobserved and being unbothered. you stand in it and understand why the lamplighter has held this round for a tenure: some work pays in atmosphere, and the wage is real."
             :next "lightsout/walked-up")

(dialog-text "lightsout/walked-up"
             "the dark walks you back personally."
             :next "lightsout/walked-up-2")

(dialog-text "lightsout/walked-up-2"
             "there is no other way to put it: the warm wall on one side, a new warmth on the other, the corridor unrolling underfoot at exactly your stride, doors arriving when expected, and the draft holding your bearing for you like a hat handed back."
             :next "lightsout/bracket-relit")

(dialog-on-enter "lightsout/feed-nothing"
                 '(setf (dialog-value "lightsout-fed") "nothing"))

(dialog-text "lightsout/feed-nothing"
             "you keep your pockets. the lamplighter does not judge, having rationed households too, and the dark does not punish, which is worse: it simply stops attending you."
             :next "lightsout/feed-nothing-2")

(dialog-text "lightsout/feed-nothing-2"
             "the way a waiter stops attending a table that is not ordering, and the corridor goes from a place you are in to a distance you must cover."
             :next "lightsout/long-count")

(dialog-text "lightsout/long-count"
             "you cover it by arithmetic: doors counted, drafts banked, the warm wall your one rail. it takes what it takes."
             :next "lightsout/long-count-2")

(dialog-text "lightsout/long-count-2"
             "when you misstep, nothing catches you, and when you arrive, nothing congratulates you, and you stand at the row's end prouder and lonelier than any light ever left you."
             :next "lightsout/long-count-2")

(dialog-text "lightsout/long-count-2"
             "the warm wall stayed, is the thing you will keep from it. unfed, unobliged, the pacing held its half step the whole way, and at the last crossing it knocked once, low, level with your hand, and you knocked back, because some accounts are kept in older coin than light."
             :next "lightsout/bracket-relit")

(dialog-text "lightsout/bracket-relit"
             "at the row's end, behind you, a bracket catches: the lamplighter, on the rota, restoring your stretch of corridor to the menu."
             :next "lightsout/bracket-relit-2")

(dialog-text "lightsout/bracket-relit-2"
             "the light reaches you at the ankles like tidewater and stops there, respectful. your eyes hurt at even this much, which is the dark's parting gift: proof of how far in you went."
             :next "lightsout/goodbye")

(dialog-text "lightsout/goodbye"
             "the lamplighter does not say goodbye, exactly. the taper dips once in your direction, the smallest light in the building acknowledging you over the new torch's shoulder, and the round goes on, bracket by bracket, into the dark it keeps, which keeps it back."
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
             "the row of doors stands where your count put them, every one, and you look at the corridor you crossed blind, and it is shorter than it was, and longer than it looks, and yours now, by the oldest claim there is: you have been here in the dark."
             :next "rogue/stair-hunt")
