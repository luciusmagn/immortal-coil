;;; The other ledger: the jrpg path's first dark branch. Mira's book of
;;; names, years, and who they left behind, read after breakfast as
;;; promised. The economy that farms heroes, kept in a fair hand.
;;; Entered from the asked-about-the-swords answer; rejoins at supper.

(dialog-text "ledger/breakfast"
             "breakfast is included and it is good. you eat all of it. Mira watches your plate the way Oren watches the road. nothing else happens until the plate is clean."
             :next "ledger/table-cleared")

(dialog-text "ledger/table-cleared"
             "then the table is wiped, dried, and wiped again, and the other ledger comes down from the shelf above the till, wrapped in oilcloth, heavier than the ledger that takes the rooms."
             :next "ledger/cover")

(dialog-text "ledger/cover"
             "the cover says nothing. books that say nothing on the cover are the ones a village keeps longest."
             :next "ledger/first-page")

(dialog-conversation "ledger/first-page"
                     (dialog-left "Mira"
                                  "first page. read the columns out loud once, so i know you have them.")
                     (dialog-right "{player-name}"
                                   "name. year posted. year settled. left behind.")
                     (dialog-left "Mira"
                                  "left behind is the column that matters. the tower keeps the swords. i keep that one.")
                     :next "ledger/hand")

(dialog-text "ledger/hand"
             "the entries run back further than the inn's beams, and the hand never changes. not ages, not tires, not slants with the years. you look at Mira. Mira looks at the page and waits for you to keep reading."
             :next "ledger/early-names")

(dialog-text "ledger/early-names"
             "the early names have settled years a season after their posted years. spring postings, autumn settlements. the tower used to be quick. the column for left behind says things like a mother, the forge, a dog."
             :next "ledger/famine-year")

(dialog-text "ledger/famine-year"
             "one year holds four entries, posted in the same week. the left behind column for all four says: the granary. Mira's finger rests there a moment. the hill is worst in hungry years, she says. it knows when the valley cannot argue."
             :next "ledger/two-together")

(dialog-text "ledger/two-together"
             "entries forty-one and forty-two went up together, brothers, one notice between them. settled the same day. the left behind column is written once, across both lines, the way you rule a bracket: everyone."
             :next "ledger/crossed-out")

(dialog-text "ledger/crossed-out"
             "one entry is crossed out and re-entered two lines down. he came back, says Mira. sat at that table three winters, then walked up again one morning in spring. the book takes returns. it prefers not to."
             :next "ledger/terms-entry")

(dialog-text "ledger/terms-entry"
             "entry fifty-nine's settled column does not say a date. it says: by terms. you ask what terms. Mira turns the page instead of answering, and the turning is an answer, and the new page is the one with sixty-five on it."
             :next "ledger/sixty-five")

(dialog-text "ledger/sixty-five"
             "entry sixty-five: posted nine years ago, settled the same week. left behind: a wife, a daughter, a toll hut. you read it twice. Pell took the toll hut over nine years ago. Pell's slate-keeping started as a widow's arithmetic."
             :next "ledger/sixty-six")

(dialog-text "ledger/sixty-six"
             "entry sixty-six: posted six years ago. the settled column is blank. the left behind column says: a father who went up before him. carried back from the ditch by his child."
             :next "ledger/companion-father")

(dialog-conversation "ledger/companion-father"
                     (dialog-left "Mira"
                                  "yes. you walked home with the child of sixty-six's father. they know the page is here. they have never once asked to see it.")
                     (dialog-right "{player-name}"
                                   "why not?")
                     (dialog-left "Mira"
                                  "because the page does not say what they carried. only what was left. ledgers are honest, not complete. sit. there is one more entry.")
                     :next "ledger/sixty-seven")

(dialog-text "ledger/sixty-seven"
             "entry sixty-seven is yours. posted: the year on the notice above your basin. the name on it is the one you gave. the settled column is blank, and the left behind column is blank, and both blanks have been ruled and waiting a long time."
             :next "ledger/ruled-line")

(dialog-text "ledger/ruled-line"
             "the line was ruled before you arrived. the ink of the ruling has had years to brown. whatever you walked in from, the book was expecting a sixty-seven, the way an oven expects a loaf."
             :next "ledger/economy")

(dialog-conversation "ledger/economy"
                     (dialog-left "Mira"
                                  "now the part you will want to walk out on. stay in the chair. the village posts the notices. not the tower. the tower has never posted anything.")
                     (dialog-right "{player-name}"
                                   "BREAKFAST INCLUDED.")
                     (dialog-left "Mira"
                                  "a good notice needs one kind line. it is the kind line they trust. heroes are cautious about glory and careless about bread.")
                     :next "ledger/why")

(dialog-text "ledger/why"
             "she lays it out like change on the counter. the hill grows unless it is fed visitors. the tower meters the hill. the village provisions the visitors. everyone keeps their column and the valley stays a valley."
             :next "ledger/toma-loaf")

(dialog-text "ledger/toma-loaf"
             "the travel loaf survives the bridge because the bridge is as far as most of them get, and a loaf that comes back can be sold twice."
             :next "ledger/toma-loaf-s2")

(dialog-text "ledger/toma-loaf-s2"
             "Toma does not know that is why his recipe matters. or he knows the way bakers know things, in the hands and not the head."
             :next "ledger/oren-count")

(dialog-text "ledger/oren-count"
             "Oren's toll board counts slimes because the slime count is how the village prices a year's notice. six last week means a cheap, kind year. the year entry sixty-six went up, the board had no room left for marks."
             :next "ledger/back-room")

(dialog-text "ledger/payouts"
             "the back pages run the other way: the payout columns. what the village settles on the left behind. flour by the season, oil by the winter, a toll hut, a seat at the long table marked permanent."
             :next "ledger/payouts-2")

(dialog-text "ledger/payouts-2"
             "the sums are small and the rows are long. grief, entered this way, is a pension, and the pension is paid out of the next notice's takings, and the next notice needs a sixty-eight."
             :next "ledger/payouts-3")

(dialog-text "ledger/payouts-3"
             "you put your finger on the arithmetic and follow it around its one closed circle. the tower makes the left-behind. the left-behind cost the village."
             :next "ledger/payouts-3-s2")

(dialog-text "ledger/payouts-3-s2"
             "the village posts the notice. the notice feeds the tower. the circle has no door in it anywhere."
             :next "ledger/back-room")

(dialog-text "ledger/back-room"
             "Mira takes you to the room behind the till. on a board on the wall hang room keys, numbered, polished by handling. sixty-six of them. room four's hook is empty because the key is in your pocket."
             :next "ledger/chest")

(dialog-text "ledger/chest"
             "under the key board, a wooden chest like the one in your room, and in it, folded square, the effects nobody came back down for: a helmet still at the blacksmith's tag, a weather charm half memorized, a second-best knife."
             :next "ledger/chest-look")

(dialog-text "ledger/chest-look"
             "you stand at the chest a while. every item is an inventory of a morning like yours: packed by someone who loved them, carried up the north road, and entered, in the end, in the column it fit."
             :next "ledger/your-chest")

(dialog-text "ledger/your-chest"
             "you go up to room four before midday and open your own chest. rope, bread, the second-best knife. packed by hands that knew the inventory of this chest before you did. you repack it exactly and sit on the lid a while."
             :next "ledger/question-return")

(dialog-text "ledger/question-return"
             "when you come back down, the book is still on the table, open to sixty-seven, the way a question stays open."
             :next "ledger/question")

(dialog-pick "ledger/question"
             "Mira waits with her hands folded on the oilcloth, the way she waits for a guest to decide about a room."
             (dialog-option "ask what your line will say" "ledger/ask-line")
             (dialog-option "ask to be left out of the book" "ledger/ask-out")
             (dialog-option "ask who the book is for" "ledger/ask-reader"))

(dialog-on-enter "ledger/ask-line"
                 '(setf (jrpg-value "ledger-question") "line"))

(dialog-conversation "ledger/ask-line"
                     (dialog-left "Mira"
                                  "what every line says. what you settled, and what you left. you came down the hill, so the first half is already kind.")
                     (dialog-right "{player-name}"
                                   "and the second half?")
                     (dialog-left "Mira"
                                  "the second half is not written by you. it is written by who waits at the gate when you do not come back. you have seen who waits. write accordingly.")
                     :next "ledger/midday")

(dialog-on-enter "ledger/ask-out"
                 '(setf (jrpg-value "ledger-question") "out"))

(dialog-conversation "ledger/ask-out"
                     (dialog-left "Mira"
                                  "no. and you should hear why before you hate me for it. the book is how the left-behind get fed. blank space feeds nobody.")
                     (dialog-right "{player-name}"
                                   "then strike the rule under my settled column.")
                     (dialog-left "Mira"
                                  "i will not do that either. but i will tell you that you are the first sixty-seven in nine generations to ask, and that i am glad, and that the answer is still no.")
                     :next "ledger/midday")

(dialog-on-enter "ledger/ask-reader"
                 '(setf (jrpg-value "ledger-question") "reader"))

(dialog-conversation "ledger/ask-reader"
                     (dialog-left "Mira"
                                  "the next innkeeper. the book chooses them, in the end. whoever cannot stop reading it is the one who has to keep it.")
                     (dialog-right "{player-name}"
                                   "how long have you been reading it?")
                     (dialog-left "Mira"
                                  "since i was the one who waited at the gate. that is the other thing the book is for. it gives the waiting somewhere to stand.")
                     :next "ledger/midday")

(dialog-scene "ledger/midday"
              "midday."
              :next "ledger/traveler")

(dialog-text "ledger/traveler"
             "at midday a traveler comes in off the south road with dust to the knee and a folded paper in one hand. you know the fold. you know the paper. it is a notice, and the number on it is sixty-seven."
             :next "ledger/traveler-2")

(dialog-text "ledger/traveler-2"
             "your notice. still posted, two valleys over, doing its patient work. the traveler smooths it on the counter and asks if the tower business is still open, and whether the breakfast part is true."
             :next "ledger/traveler-talk")

(dialog-conversation "ledger/traveler-talk"
                     (dialog-left "Mira"
                                  "the sixty-seven is settled. you are early for the next posting. there is a room while you wait, and the breakfast part is always true.")
                     (dialog-right "{player-name}"
                                   "you could tell them. you could tell them right now what the room costs.")
                     (dialog-left "Mira"
                                  "i could. listen to what they ask next, and then tell me again.")
                     :next "ledger/traveler-asks")

(dialog-text "ledger/traveler-asks"
             "the traveler asks for the room nearest the north gate, to be woken at first light, and whether the village has a smith, because the sword wants an edge. they do not ask a single question with a person in it."
             :next "ledger/traveler-name")

(dialog-text "ledger/traveler-name"
             "Mira takes their name for the register. you watch her hand. the register and the other ledger are fed by the same pen. entry sixty-eight has just been opened, while you stood there holding your tea."
             :next "ledger/smith")

(dialog-text "ledger/smith"
             "all afternoon, from the forge at the square's edge, the sound of a sword taking an edge. the smith works with his back to the road."
             :next "ledger/smith-s2")

(dialog-text "ledger/smith-s2"
             "you ask Oren once how the smith feels about the work, and Oren says, he charges fair, in the tone of a closed gate."
             :next "ledger/notice-craft")

(dialog-text "ledger/notice-craft"
             "later you find the till drawer open and the blank notices in their stack, and beside them Mira's practice slate: the same words worked over and over, spacing, weight, where the kind line sits."
             :next "ledger/notice-craft-s2")

(dialog-text "ledger/notice-craft-s2"
             "WAITS, not LURKS. INCLUDED, not PROVIDED. craft."
             :next "ledger/square-after")

(dialog-text "ledger/square-after"
             "the square looks different from the table where you read the book. Toma's oven is a provisioner's oven. Oren's chain is a tally gate. Pell's slate, two miles north, is a widow's arithmetic that learned to charge."
             :next "ledger/square-still")

(dialog-text "ledger/oven-watch"
             "you watch Toma slide the day's loaves out and count them off to the cooling rack, and the count is the village's count: so many for the tables, so many for the road, one set aside, always, unexplained, in case."
             :next "ledger/spear-watch")

(dialog-text "ledger/spear-watch"
             "Oren walks the chain at dusk and touches each post once, an old soldier's inventory, and you realize the polished spear has never been about slimes. it is for the year the terms fail. there is always a year the terms fail. the book says so."
             :next "ledger/gate-dusk")

(dialog-text "ledger/square-still"
             "and it is still Oakbarrow. the bread still steams. Oren still polishes the spear nobody throws. both things are true. the book's whole weight is that it never makes you choose between them."
             :next "ledger/oven-watch")

(dialog-text "ledger/gate-dusk"
             "toward dusk you stand at the north gate with the chain under your hand. up the road, past the bridge, the tower holds its terms because you carried them down. the next one will carry something down too, or will not."
             :next "ledger/companion-walk-lead")

(dialog-text "ledger/companion-walk-lead"
             "{jrpg-companion} finds you there, the way they found you in the ditch and on the stair: at the exact moment the finding matters."
             :next "ledger/companion-walk")

(dialog-conversation "ledger/companion-walk"
                     (dialog-left "{jrpg-companion}"
                                  "she showed you the book. you have the face people come out of the inn with.")
                     (dialog-right "{player-name}"
                                   "you knew what it says?")
                     (dialog-left "{jrpg-companion}"
                                  "i know what it costs. i told you on the road: i wanted you to come back to something. i did not say the something was simple.")
                     :next "ledger/decision")

(dialog-pick "ledger/decision"
             "the afternoon stretches toward supper. the book is back in its oilcloth, but it does not leave you."
             (dialog-option "keep the village's secret" "ledger/keep-quiet")
             (dialog-option "tell Toma and Oren what the columns mean" "ledger/tell")
             (dialog-option "write a warning into notice 68" "ledger/warn"))

(dialog-on-enter "ledger/keep-quiet"
                 '(setf (jrpg-value "ledger-decision") "kept"))

(dialog-text "ledger/keep-quiet"
             "you keep it. you understand, by supper, that keeping it is not silence, it is membership. every adult in the valley who has ever gone quiet at the word tower is keeping it with you."
             :next "ledger/book-back")

(dialog-on-enter "ledger/tell"
                 '(setf (jrpg-value "ledger-decision") "told"))

(dialog-text "ledger/tell"
             "you tell them at the oven, plainly, columns and all. Toma wipes his hands for a long time. Oren looks at the spear. then Toma says, the bread is still good, in the voice of a man choosing his beam to stand under, and feeds you both."
             :next "ledger/tell-after")

(dialog-text "ledger/tell-after"
             "by supper you understand that they knew the shape, if not the columns. villages keep their books the way bodies keep their bones: inside, working, unlooked-at."
             :next "ledger/book-back")

(dialog-on-enter "ledger/warn"
                 '(setf (jrpg-value "ledger-decision") "warned"))

(dialog-text "ledger/warn"
             "you find next year's notice blank in the till drawer, waiting for its number, and you write small under the kind line: ASK ABOUT THE OTHER LEDGER FIRST. it is not much. it is a crack in a column, and columns do not heal."
             :next "ledger/warn-after")

(dialog-text "ledger/warn-after"
             "Mira finds it before supper, reads it twice, and does not strike it out. entered, she says, and nothing else, and you will spend years deciding what her voice did on the word."
             :next "ledger/book-back")

(dialog-text "ledger/book-back"
             "before supper the book goes back up. wrapped, tied, squared on the shelf above the till with both of Mira's hands. she puts it away the way you put away a thing you will take down again tomorrow."
             :next "ledger/rejoin")

(dialog-text "ledger/rejoin"
             "the supper bell rings from the inn porch, ordinary as weather, and you go in to the long table carrying the book's weight the way everyone at the table is carrying it: politely."
             :next "ledger/supper-watch")

(dialog-text "ledger/supper-watch"
             "the traveler sits at the long table and is fed like family: the good stew, the heel of the loaf, Oren's slime count told wrong on purpose for them too. every kindness is real. that is the part you could not have understood this morning."
             :next "ledger/supper-watch-2")

(dialog-text "ledger/supper-watch-2"
             "the village is not pretending to love its guests. it loves them, and enters them, with the same hand, at the same table, and when the traveler asks you to pass the bread, you pass it."
             :next "jrpg/evening-table")
