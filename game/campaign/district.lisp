;;; The third district at night: the war's first dark branch. The
;;; chancellor goes to see what the numbers count, against all advice.
;;; Bells, lists, empty coats, the loaded train. Restrained throughout.
;;; Entered from the map room on day three; rejoins at the fourth morning.

(dialog-particles "district/advice" :ash :fade-seconds 4.0)

(dialog-say "district/advice"
            "Sorel"
            "chancellor, no. the gate logs. whatever you see there, the log will say you saw it, and the log will not say why."
            :next "district/advice-2")

(dialog-say "district/advice-2"
            "you"
            "i have read your columns twice. i want to read the district once."
            :next "district/advice-3")

(dialog-say "district/advice-3"
            "Sorel"
            "then take Brandt, take a plain coat, and do not sign anything. not a receipt. not a condolence. nothing with your hand on it leaves that district."
            :next "district/coat")

(dialog-text "district/coat"
             "Brandt brings two coats from the clerks' rack, wool, unmarked, smelling of other men's tobacco. yours is tight across the shoulders. his fits. neither of you says anything about the rack having coats to spare."
             :next "district/night")

(dialog-scene "district/night"
              "that night."
              :next "district/wire")

(dialog-text "district/wire"
             "you leave by the kitchen entrance, past the ministry wire, into streets the blackout has simplified to walls and curbs. Brandt walks half a step ahead with his hands out of his pockets, the way men walk who want sentries to see their hands."
             :next "district/first-bell")

(dialog-text "district/first-bell"
             "the bells start when you cross the canal. not an alarm. a slow count, struck by hand, the strikes uneven the way a tired arm is uneven. in the office, behind glass and tape, you had taken the unevenness for distance."
             :next "district/checkpoint")

(dialog-say "district/checkpoint"
            "a sentry"
            "curfew, grandfathers. papers."
            :next "district/checkpoint-2")

(dialog-say "district/checkpoint-2"
            "you"
            "night shift, rail depot. we are late."
            :next "district/checkpoint-3")

(dialog-say "district/checkpoint-3"
            "a sentry"
            "everyone at the depot is late. it is that kind of depot. go by Tanners Row, the long way. you do not want the short way tonight."
            :next "district/maze-setup")

(dialog-text "district/maze-setup"
             "Tanners Row is barricaded at the far end. the long way becomes the longer way, lefts and rights through a district closed up tight around the curfew."
             :next "district/streets")

(dialog-minigame "district/streets"
                 "w/s or up/down move. a/d or left/right turn. find your way through the curfew streets."
                 :game :dream-maze
                 :success "district/streets-through"
                 :failure "district/streets-patrol")

(dialog-text "district/streets-through"
             "you come out of the lanes by the parish hall with the bell still counting overhead, close now, each strike arriving through the soles of your boots."
             :next "district/bells")

(dialog-text "district/streets-patrol"
             "a patrol takes you the last three streets, politely, two boys with one lantern, who believe the depot story because believing it is easier for everyone."
             :next "district/streets-patrol-s2")

(dialog-text "district/streets-patrol-s2"
             "they leave you at the parish hall. the bell is overhead now, each strike arriving through the soles of your boots."
             :next "district/bells")

(dialog-text "district/bells"
             "the ringer is not a priest. he is a clerk in fingerless gloves with a list nailed to the post beside the rope, and he strikes once per name, reading by a shielded candle, pausing between names to rest his arm."
             :next "district/ringer")

(dialog-say "district/ringer"
            "the ringer"
            "if you are here for someone, the list is in order of street, not name. take the candle. bring it back."
            :next "district/ringer-2")

(dialog-say "district/ringer-2"
            "you"
            "how long is the list tonight?"
            :next "district/ringer-3")

(dialog-say "district/ringer-3"
            "the ringer"
            "shorter than the bell makes it sound. longer than yesterday. it has been longer than yesterday for eleven days."
            :next "district/lists")

(dialog-text "district/lists"
             "the lists are everywhere once you know their shape. nailed to doors, slid behind window glass, chalked on the school gate and half washed off."
             :next "district/lists-2")

(dialog-text "district/lists-2"
             "names in ink, and against the names, in pencil, single words: REROUTED. HELD. ASK. the pencil hand is always the same. someone walks this district every day, keeping the lists agreeing."
             :next "district/woman")

(dialog-say "district/woman"
            "an old woman"
            "sir. you have a list face. is Anders Vasik on yours? car four, they said. three weeks monday."
            :next "district/woman-2")

(dialog-say "district/woman-2"
            "you"
            "i do not have a list. i am sorry."
            :next "district/woman-3")

(dialog-say "district/woman-3"
            "an old woman"
            "no, you have one. yours is the big one, i think. when you find it, he is spelled with one s. they keep adding the second s and then he is two people, and nobody can find either of them."
            :next "district/vasik")

(dialog-text "district/vasik"
             "at the parish hall, while the ringer rests his arm, Brandt runs a finger down the bell list by candlelight. Vasik, Anders, with two s's, struck once eleven days ago."
             :next "district/vasik-2")

(dialog-text "district/vasik-2"
             "Vasik, Anders, with two s's again, struck once last night. one man, misspelled into two, and both of them rung for, and neither of them him."
             :next "district/school")

(dialog-text "district/school"
             "on the school gate, under the chalked names, someone small has been practicing the pencil words in a careful column: rerouted, held, ask. the handwriting is a child's. the spelling is perfect. children learn the words there are lessons for."
             :next "district/depot-walk")

(dialog-text "district/depot-walk"
             "Brandt says nothing for two streets. then: car four, chancellor. the audit. eight hundred short. you both keep walking, because the arithmetic walks with you either way."
             :next "district/depot")

(dialog-text "district/depot"
             "the coat depot is the old tram barn, lit inside by storm lamps. through the inspection door: rails of coats, hundreds, hung in order of size, each with a tag wired to the collar."
             :next "district/depot-2")

(dialog-text "district/depot-2"
             "the tags are stamped REROUTED and then a date. the coats have not gone anywhere. only the dates have."
             :next "district/coats")

(dialog-text "district/coats"
             "you walk one rail of them with the candle. mens coats, then womens, then a long stretch where the rail hangs lower. you stop reading the tags there. Brandt takes the candle from your hand without being asked."
             :next "district/counting-room")

(dialog-text "district/counting-room"
             "at the back of the barn, a lit office. through the glass: a clerk at a telephone, reading from a ledger in a clear, exhausted voice."
             :next "district/counting-room-2")

(dialog-text "district/counting-room-2"
             "numbers, in groups, with the receiver lying on the desk beside a tin clock. nobody is on the other end at this hour. the protocol does not say the line must be answered. it says the count must be read."
             :next "district/counting")

(dialog-say "district/counting"
            "Brandt"
            "that is the broadcast, chancellor. or its little brother. the station reads what the clerks read in. there will be a room like this in every district."
            :next "district/counting-2")

(dialog-say "district/counting-2"
            "you"
            "and the clear band carries it to whoever keeps the big list."
            :next "district/counting-3")

(dialog-say "district/counting-3"
            "Brandt"
            "to whoever keeps the big list. which is kept where lists are kept. one floor under your office, i would think. i have never checked. checking is on the list of things that get a man rerouted."
            :next "district/siding-choice")

(dialog-pick "district/siding-choice"
             "past the barn, the rail cut runs toward the siding. the bell has stopped. your feet are already cold."
             (dialog-option "go down to the siding" "district/siding")
             (dialog-option "you have seen enough" "district/enough"))

(dialog-on-enter "district/enough"
                 '(setf (dialog-value "district-train") "unseen"))

(dialog-text "district/enough"
             "you turn back at the head of the rail cut."
             :next "district/enough-s2")

(dialog-text "district/enough-s2"
             "behind you, far down the grade, metal couples to metal once, softly, the way it does when a train is being made longer in the dark. you do not turn around."
             :next "district/enough-s3")

(dialog-text "district/enough-s3"
             "you keep walking up the grade, and the sound does not come again."
             :next "district/walk-back")

(dialog-text "district/siding"
             "the siding is lit by one lamp on one pole. the train is twelve cars, doors sealed, chalk marks fresh."
             :next "district/siding-s2")

(dialog-text "district/siding-s2"
             "the cars do not steam, but the night is cold enough that they should not be warm, and when you put your glove near the boards, they are warm."
             :next "district/sentry")

(dialog-say "district/sentry"
            "the sentry"
            "good evening, chancellor."
            :next "district/sentry-2")

(dialog-say "district/sentry-2"
            "you"
            "you know me."
            :next "district/sentry-3")

(dialog-say "district/sentry-3"
            "the sentry"
            "i opened a gate for you once, at kilometer nine. or i will have. the gate log is not particular about order. it only wants your name, and it has it."
            :next "district/train-choice")

(dialog-pick "district/train-choice"
             "the sentry stands aside from the nearest car. it is an invitation, or it is a record being made. maybe both."
             (dialog-option "order the car opened" "district/opened")
             (dialog-option "put your hand against the boards" "district/hand")
             (dialog-option "step back from it" "district/back"))

(dialog-on-enter "district/opened"
                 '(setf (dialog-value "district-train") "opened"))

(dialog-text "district/opened"
             "the sentry breaks the seal without hurry and rolls the door a hand's width."
             :next "district/opened-2")

(dialog-text "district/opened-2"
             "you stand in the gap of it for as long as you can make yourself, which is not long, and what is in the car is people, quiet, awake, arranged, looking back at you with the particular patience of the counted."
             :next "district/opened-3")

(dialog-text "district/opened-3"
             "nobody asks you for anything. that is the worst of it. they know a list face too."
             :next "district/resealed")

(dialog-text "district/resealed"
             "the door rolls shut. the sentry applies a new seal from a pocketful of them, stamped with tomorrow's date, and writes one line in the gate log in a fair clerk's hand."
             :next "district/shed")

(dialog-on-enter "district/hand"
                 '(setf (dialog-value "district-train") "touched"))

(dialog-text "district/hand"
             "you stand with your glove flat against the boards. the warmth is bodies."
             :next "district/hand-s2")

(dialog-text "district/hand-s2"
             "through the wood, very small, a knock answers your hand, once, level with it, and you do not knock back, because you are the chancellor, and there is nothing your knock would be except a promise."
             :next "district/shed")

(dialog-on-enter "district/back"
                 '(setf (dialog-value "district-train") "stepped-back"))

(dialog-text "district/back"
             "you step back from the car. the sentry nods as if this, too, is on a protocol somewhere, observed at distance, and enters one line in the gate log all the same."
             :next "district/shed")

(dialog-text "district/shed"
             "beside the siding stands the lamp shed, except it is not a lamp shed anymore. inside, floor to roof, luggage."
             :next "district/shed-2")

(dialog-text "district/shed-2"
             "cases, bundles, a pram, each with a paper receipt wired on, numbered in the fair clerk's hand. the receipts say RECLAIM ON RETURN."
             :next "district/shed-3")

(dialog-text "district/shed-3"
             "the shed is full and the train is twelve cars and the arithmetic of that stands in the doorway with you."
             :next "district/receipts")

(dialog-say "district/receipts"
            "the sentry"
            "we issue a receipt for everything. that is the regulation and i keep it. fourteen hundred receipts since the spring."
            :next "district/receipts-2")

(dialog-say "district/receipts-2"
            "you"
            "how many have been reclaimed?"
            :next "district/receipts-3")

(dialog-say "district/receipts-3"
            "the sentry"
            "the regulation does not have a column for that. i added one myself, in pencil, on the last page. it is easy to keep. it has one number in it and the number has not changed."
            :next "district/walk-back")

(dialog-text "district/walk-back"
             "the walk back is the same streets in reverse and nothing about them is the same. the lists on the doors have stopped being paper."
             :next "district/walk-back-s2")

(dialog-text "district/walk-back-s2"
             "Brandt returns the candle to the parish hall and you wait outside, under the silent bell, in a dead man's coat."
             :next "district/canal")

(dialog-text "district/canal"
             "you recross the canal as the early shift comes the other way, men with tins and women with kerchiefs, walking to work past the chalked gates without turning their heads."
             :next "district/canal-2")

(dialog-text "district/canal-2"
             "it is not that they do not see the lists. it is that the lists are part of the morning now, the way the cold is, and nobody stops for either."
             :next "district/dawn")

(dialog-scene "district/dawn"
              "the fourth morning, early."
              :next "district/kitchen")

(dialog-text "district/kitchen"
             "you come in by the kitchen entrance at five. the cook does not look up."
             :next "district/kitchen-s2")

(dialog-text "district/kitchen-s2"
             "on the table by your office door, someone has left the gate log's carbon, folded once, with your name in it twice: kilometer nine, and last night."
             :next "district/kitchen-s3")

(dialog-text "district/kitchen-s3"
             "there is no note attached. the carbon is the note."
             :next "district/boots")

(dialog-text "district/boots"
             "you leave your boots outside the office door, district mud to the laces, and when you look again at half past six they are back, cleaned, dressed, the laces pressed flat, and the mud is gone wherever mud goes in this building."
             :next "district/boots-2")

(dialog-text "district/boots-2"
             "it is the same everywhere you look now. the building digests. that is what it is for."
             :next "district/boots-3")

(dialog-text "district/boots-3"
             "you put on the clean boots. they fit exactly as well as yesterday. this morning that feels like an accusation."
             :next "district/vey")

(dialog-say "district/vey"
            "Vey"
            "you were seen, chancellor. i say this as a friend. a chancellor in a borrowed coat, at a siding, at night. there are two stories that explains, and only one of them keeps the government standing."
            :next "district/vey-2")

(dialog-say "district/vey-2"
            "you"
            "the cars are warm, Vey."
            :next "district/vey-3")

(dialog-say "district/vey-3"
            "Vey"
            "the cars are the district's contribution, moving on schedule, over a signature this office honors. you have seen the war from the map for two years. i would not recommend seeing it from the ground. the ground is not your office."
            :next "district/sorel-after")

(dialog-say "district/sorel-after"
            "Sorel"
            "you went. i can see it on you. nothing you signed, i hope."
            :next "district/sorel-after-2")

(dialog-say "district/sorel-after-2"
            "you"
            "nothing i signed. Sorel, the lists in pencil. one hand, all of them, the whole district."
            :next "district/sorel-after-3")

(dialog-say "district/sorel-after-3"
            "Sorel"
            "yes. mine. somebody must keep the district's books agreeing, chancellor, or when this is over, nobody will be findable again. i go thursdays, with the bread van. you are not the only one who reads columns until they are streets."
            :next "district/sorel-questions")

(dialog-interrogation "district/sorel-questions"
                      "Sorel sets the pencil down. there are twenty minutes before the bell, and she does not spend them hurrying."
                      (:next "district/decision")
                      (:continue-label "turn to the desk")
                      ("ask what the pencil lists are for"
                       :id "lists"
                       :speaker "Sorel"
                       "names against destinations. nothing the government would print, because the government is the destination. when this ends, a list is how a mother finds a son.")
                      ("ask how long she has kept them"
                       :id "long"
                       :speaker "Sorel"
                       "since the second siding opened. i told myself it was only bookkeeping. it is, chancellor. it is bookkeeping that means to be read in a kinder year.")
                      ("ask who else knows"
                       :id "knows"
                       :speaker "Sorel"
                       "the van driver knows the route and not the reason. you know both now. that is two more than is safe and one fewer than i can carry alone."))

(dialog-pick "district/decision"
             "the eight o'clock bell is twenty minutes away. the carbon of the gate log lies on the desk between you."
             (dialog-option "bring last night to the table" "district/to-table")
             (dialog-option "add it to the pencil record" "district/to-record")
             (dialog-option "burn the carbon" "district/to-ash"))

(dialog-on-enter "district/to-table"
                 '(setf (dialog-value "district-decision") "table"))

(dialog-text "district/to-table"
             "you will say it at the table, plainly, with the carbon in front of you: i went, i saw, the cars are not carrying coats."
             :next "district/to-table-2")

(dialog-text "district/to-table-2"
             "Vey will be courteous, Olen will be punctual, and the minutes will record that the chancellor reported on district morale."
             :next "district/to-table-3")

(dialog-text "district/to-table-3"
             "you know all this, and you will say it anyway, because the saying is now the only signature you trust."
             :next "district/rejoin")

(dialog-on-enter "district/to-record"
                 '(setf (dialog-value "district-decision") "record"))

(dialog-text "district/to-record"
             "you copy the carbon in pencil, in the small even hand, and Sorel files it where things are found again."
             :next "district/to-record-s2")

(dialog-text "district/to-record-s2"
             "the original you leave in the desk, slightly wrong in the drawer, so that whoever reads your drawers will believe they have found everything."
             :next "district/rejoin")

(dialog-on-enter "district/to-ash"
                 '(setf (dialog-value "district-decision") "ash"))

(dialog-text "district/to-ash"
             "you burn the carbon over the basin and wash the ash down. it changes nothing. the gate log's original is wherever originals are kept, one floor under your office, with the big list, growing."
             :next "district/to-ash-2")

(dialog-text "district/to-ash-2"
             "but your hands needed something to do, and now they have done it."
             :next "district/rejoin")

(dialog-text "district/rejoin"
             "you shave, change coats, and become the chancellor again, a man who has slept badly in his own building. the borrowed wool goes back to the clerks' rack. all day your shoulders remember it."
             :next "war/day4")
