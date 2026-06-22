;;; Below: the rogue path's first dark branch. The bookkeeping floors
;;; beneath the tally, a darker delve with two hunters, and the clerk
;;; met in person. Entered through the bottom room's far door; rejoins
;;; at the landing.

(dialog-text "below/door"
             "the far door opens without sound on hinges kept oiled by somebody's schedule. behind it, stairs go down. below the bottom. the air coming up is warm and smells of paper."
             :next "below/stairs")

(dialog-text "below/stairs"
             "the white lines of the dungeon run down the stairwell with you and, somewhere in the dark, change their minds: by the first turning they are ruled lines, faint blue, margin-red at the left hand."
             :next "below/stairs-2")

(dialog-text "below/stairs-2"
             "the dungeon is drawn on graph paper down here. it always was. upstairs is just the cover."
             :next "below/shelves")

(dialog-text "below/shelves"
             "the walls become shelving without admitting a seam. ledgers, spine out, floor to dark, each spine chalked in the tidy clerk's hand. the shelving goes on past the torch in both directions. it is silent down here, the deep silence of paper."
             :next "below/tally-wall")

(dialog-text "below/tally-wall"
             "one wall is the tally wall. every chalk mark you have ever seen upstairs is here in master: rows of four struck with a fifth, floor by floor, years deep."
             :next "below/tally-wall-s2")

(dialog-text "below/tally-wall-s2"
             "under each tally, a shelf mark. the marks upstairs are totals. the books are down here."
             :next "below/your-shelf")

(dialog-text "below/your-shelf"
             "you find your floor's shelf because your hand finds it, the way hands do now. one ledger stands prouder than its row, recently used."
             :next "below/your-shelf-s2")

(dialog-text "below/your-shelf-s2"
             "the spine chalk is the name carved into the first step, letter for letter. the carving was never a warning. it is a spine label."
             :next "below/reading")

(dialog-text "below/reading"
             "you pull the book and open it on the shelf edge. last night, in the clerk's hand: bar lifted, third watch, lifted quiet. slept."
             :next "below/reading-s2")

(dialog-text "below/reading-s2"
             "tin balanced against door, dungeon custom, noted with approval. woke below. read the tally. left the fresh mark alone."
             :next "below/ink-wet")

(dialog-text "below/ink-wet"
             "the latest line says: reads own page. the ink is wet. you stand very still, and from somewhere in the stacks, unhurried, comes the sound of a pen keeping up."
             :next "below/reading-stand")

(dialog-text "below/reading-stand"
             "farther down the row, a reading stand holds another book open mid-line, ink wet on that one too. the spine chalk is nobody you know."
             :next "below/reading-stand-2")

(dialog-text "below/reading-stand-2"
             "somewhere overhead, right now, a stranger is lifting a bar, or counting doors, or balancing a tin, and the line is arriving here as they do it."
             :next "below/active-accounts")

(dialog-text "below/active-accounts"
             "you count the reading stands down the visible row: nine, each with its book open, each ink wet. nine accounts active tonight, yours among them. the dungeon is never empty. it is only ever apart."
             :next "below/two-walls")

(dialog-text "below/two-walls"
             "and the pacing finds you again, in the left wall, patient as bookkeeping."
             :next "below/two-walls-s2")

(dialog-text "below/two-walls-s2"
             "then, for the first time, an answer to it: a second pacing, in the right wall, half a step offset. two of them now, stereo, bracketing the stacks."
             :next "below/two-walls-s3")

(dialog-text "below/two-walls-s3"
             "the dark down here is audited in pairs."
             :next "below/descent-choice")

(dialog-text "below/descent-choice"
             "the stacks descend by ramps, floor under floor, and the lower floors are older: the ruled lines go brown, the spines go to leather, then to wood, then to clay."
             :next "below/descent-choice-s2")

(dialog-text "below/descent-choice-s2"
             "somewhere below all of it, a lamp is burning. you can smell the warm oil of it between the paper."
             :next "below/clay")

(dialog-text "below/clay"
             "on the last ramp you pass the oldest shelf: no books, one clay tablet, fired hard, holding a single ruled line in a hand that is the tidy hand's grandmother."
             :next "below/clay-s2")

(dialog-text "below/clay-s2"
             "you cannot read it. a building's first minute only ever says one thing: expected."
             :next "below/delve")

(dialog-minigame "below/delve"
                 "wasd or arrow keys step. find the lamp at the bottom of the stacks."
                 :game :rogue-delve
                 :success "below/lamp-floor"
                 :failure "below/turned-back"
                 :config (list :save-prefix "below"
                               :caught-target "below/audited"
                               :leave-target "below/turned-back"
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
                               :gen-width 27
                               :gen-height 17
                               :gen-hunters 2
                               :gen-monsters 6
                               :gen-items 5
                               :gen-traps 3))

(dialog-text "below/audited"
             "one of the pair steps out of its wall. you do not quite see it. the torch will not hold its light on it. the floor files you."
             :next "below/audited-2")

(dialog-text "below/audited-2"
             "you wake one ramp up, sitting against your own shelf, your book back in its place, one line newer: audited. found correct. carried up."
             :next "below/lamp-floor")

(dialog-text "below/turned-back"
             "the ramps refuse to add up and you fetch back against the tally wall twice, which down here is how a building says no. when you stop, the lamp smell is closer anyway."
             :next "below/turned-back-2")

(dialog-text "below/turned-back-2"
             "the floors move the destination instead of the traveler when the traveler is wanted. it is more efficient."
             :next "below/lamp-floor")

(dialog-text "below/lamp-floor"
             "the bottom floor of the stacks is one room wide and all desk: a single lamp, a single chair for visitors, and the clerk, in person, mid-line, who finishes the line before looking up, because the line is about you arriving and it would be wrong twice if interrupted."
             :next "below/clerk")

(dialog-say "below/clerk"
            "the clerk"
            "sit. you found the door ajar. i leave it ajar once a tenure, on instinct, and the instinct has never yet been wrong about who comes down."
            :next "below/clerk-2")

(dialog-say "below/clerk-2"
            "you"
            "you keep all of it. every floor. every step."
            :next "below/clerk-3")

(dialog-say "below/clerk-3"
            "the clerk"
            "somebody has to. a dungeon is a building that has decided to keep happening. the deciding takes minutes. the minutes are these. sit, i said. the chair is for sitting, not for symbolism."
            :next "below/clerk-questions")

(dialog-interrogation "below/clerk-questions"
                      "the clerk leaves the pen uncapped, point resting on a blotter cut to the size of a cell."
                      (:next "below/ribbon-book")
                      (:continue-label "let the clerk continue")
                      (:require-all t)
                      ("ask about the auditors"
                       :id "auditors"
                       :speaker "the clerk"
                       "the pair in the walls check my figures against the floors, step against entry, breath against margin. there were not always two."
                       "a discrepancy. once. one delver went a single hour unlogged, and for that hour the third floor did not entirely exist, and what it did instead is not in any book, because that is what unlogged means. never again. hence the pair.")
                      ("ask why the door was ajar"
                       :id "ajar-door"
                       :speaker "the clerk"
                       "once a tenure i leave one door ajar without choosing which one. the building chooses the rest. if nobody comes, the hinge gets oiled and the entry is voided."
                       "if someone comes, i receive them. that is all a summons is down here: a door doing its part before the person knows there is a part.")
                      ("ask what the ledger wants"
                       :id "ledger-wants"
                       :speaker "the clerk"
                       "wanting is expensive language. the ledger records. the building wants the recording done correctly. the people inside it want to leave with something carried out."
                       "i am employed at the narrow place where those wants can share a desk without tearing the paper. it is not dignified work. it is necessary work."))

(dialog-text "below/ribbon-book"
             "on the desk's far corner lies one ledger apart from all the others, closed, tied shut with a ribbon gone grey. the discrepancy's book."
             :next "below/ribbon-book-s2")

(dialog-text "below/ribbon-book-s2"
             "the clerk does not look at it, with the particular skill of someone who has practiced not looking at one thing for a very long time."
             :next "below/your-book")

(dialog-text "below/your-book"
             "your book is already on the desk, fetched ahead of you, because the floors move what is wanted."
             :next "below/your-book-s2")

(dialog-text "below/your-book-s2"
             "the clerk turns it around to face you and opens it at the first page: the inn before the stairs, the stairs before the name, the name carved fresh, the dust not yet on it."
             :next "below/first-line")

(dialog-text "below/first-line"
             "the first line of your account predates your first step. it says: expected. the clerk taps it once. everyone's says that, the clerk says."
             :next "below/first-line-s2")

(dialog-text "below/first-line-s2"
             "it is the only line i am given. everything after it, you write and i take down. people get the order wrong and it costs them years."
             :next "below/ask-choice")

(dialog-pick "below/ask-choice"
             "the lamp hisses gently. in the walls, the pair holds still, listening the way ledgers listen."
             (dialog-option "ask to be unlogged" "below/unlogged")
             (dialog-option "ask to read your ending" "below/ending")
             (dialog-option "take the book and go" "below/take-book"))

(dialog-on-enter "below/unlogged"
                 '(setf (dialog-value "below-asked") "unlogged"))

(dialog-say "below/unlogged"
            "the clerk"
            "i did that once. you saw the ribbon. but you have asked, and the asking is entered, and the rules let me offer the lesser form: one hour. unlogged. starting when you stand."
            :next "below/unlogged-2")

(dialog-say "below/unlogged-2"
            "you"
            "and then?"
            :next "below/unlogged-3")

(dialog-say "below/unlogged-3"
            "the clerk"
            "and then you will come back and sit down and ask me to resume, and i will not say anything unkind about it, because nobody has lasted the hour yet, and the trying is honorable."
            :next "below/unlogged-hour")

(dialog-text "below/unlogged-hour"
             "you stand, and the pen stops, and the walls go silent, both of them, total, and you walk the stacks unkept. no pacing. no pen. your steps land and are not received."
             :next "below/unlogged-hour-2")

(dialog-text "below/unlogged-hour-2"
             "it is the loneliest sound you have ever made, footfall on a floor that is not counting, and you last, by your own count, eleven minutes."
             :next "below/resume")

(dialog-text "below/resume"
             "you sit back down. resume, you say, and the pen takes you up mid-breath, and the relief of being received again is so plain on you that the clerk enters it, kindly, in the margin, where the totals do not see."
             :next "below/margin")

(dialog-on-enter "below/ending"
                 '(setf (dialog-value "below-asked") "ending"))

(dialog-text "below/ending"
             "the clerk turns to the last page without hunting for it. the page is ruled and blank except for one line, entered at the bottom, undated, in the tidy hand: climbed out. kept moving."
             :next "below/ending-2")

(dialog-say "below/ending-2"
            "the clerk"
            "we enter the ending first, for some. it is not a prediction. the floors do not predict. it is a vote."
            :next "below/ending-3")

(dialog-say "below/ending-3"
            "you"
            "whose vote?"
            :next "below/ending-4")

(dialog-say "below/ending-4"
            "the clerk"
            "the building's. it is allowed one per account, and it spends them rarely, and it does not explain itself to me, and i have stopped asking, because the votes have a way of being embarrassingly correct."
            :next "below/margin")

(dialog-on-enter "below/take-book"
                 '(setf (dialog-value "below-asked") "took"))

(dialog-text "below/take-book"
             "you pick the book up. the clerk does not stop you, which should have been the warning."
             :next "below/take-book-s2")

(dialog-text "below/take-book-s2"
             "it is heavier than pages, heavier each step, and at the third step the walls go silent, both of them, because your hours have nowhere to be kept while the book is in your hands."
             :next "below/take-book-2")

(dialog-text "below/take-book-2"
             "you stand in the unreceived silence with your own account dead-weight in your arms, and you carry it one more step, just to have done, and then you put it back on the desk."
             :next "below/take-book-2-2")

(dialog-text "below/take-book-2-2"
             "the pen resumes, and the clerk rules off the incident with one clean line and no comment, which is the kindest entry in the whole book."
             :next "below/margin")

(dialog-text "below/margin"
             "while the clerk rules the visit off, you look once more at your page, at the margin, which is wider than the entries need."
             :next "below/margin-2")

(dialog-text "below/margin-2"
             "the margin is where the clerk keeps what the totals do not see: slept well, for once. left the mark alone. asked the honorable thing."
             :next "below/receipt")

(dialog-text "below/receipt"
             "the clerk writes you a slip and folds it once: a receipt, in the tidy hand. CARRIED OUT: WHAT THEY KNOW NOW. no weight entered, no slot named. keep it or lose it, the clerk says."
             :next "below/receipt-2")

(dialog-text "below/receipt-2"
             "it is honored either way. it is the only receipt this desk issues, and everyone leaves with one."
             :next "below/escort")

(dialog-text "below/escort"
             "when it is time, the clerk stands, caps the pen, and the pair in the walls falls in, one each side, and the floors fold the ramps short for you, which is the building being polite."
             :next "below/escort-s2")

(dialog-text "below/escort-s2"
             "at your shelf, the book goes back in its place, prouder than its row."
             :next "below/escort-pace")

(dialog-text "below/escort-pace"
             "you climb between the pair, and for once it is you matching their steps, not them matching yours. one of those is being followed. the other is being seen home."
             :next "below/stand-closed")

(dialog-text "below/stand-closed"
             "passing the reading stands you count without meaning to: eight books open now."
             :next "below/stand-closed-2")

(dialog-text "below/stand-closed-2"
             "the ninth stands closed, ribbon fresh and grey, and the pair slows by it for the length of one step, which from auditors is a flag at half mast, and then the pen, somewhere, keeps writing yours."
             :next "below/tag-truth")

(dialog-text "below/tag-truth"
             "at the bottom room the tag still lies on the made bed, ink fresh, first line legible. RETURN IF FOUND."
             :next "below/tag-truth-s2")

(dialog-text "below/tag-truth-s2"
             "you understand it now, from the shelving side: it is not a plea. it is processing language."
             :next "below/tag-truth-s3")

(dialog-text "below/tag-truth-s3"
             "everything down here is logged out, and back in, and the tag is the slip."
             :next "below/close-door")

(dialog-text "below/close-door"
             "you close the far door behind you until the latch takes, and then the room's other door, quietly, the way you would on someone sleeping, and climb until the stair ends at furniture again, with your hours kept the whole way, in good hands, in the margin."
             :next "below/receipt-pocket")

(dialog-text "below/receipt-pocket"
             "on the landing you check your pocket once, professionally. the receipt is there, folded, weightless, taking up no slot, and you leave your hand on it a moment the way you would on a banister, and climb on."
             :next "rogue/landing-return")
