;;; Carcosa — the deep throne of the King in Yellow.
;;;
;;; Reached by asking the King to take the crown off (jrpg/sword-choice). Here
;;; the bog-standard demon-lord frame gives way: the King is the ship-captain
;;; from the mutiny branch, his death-loop broken into Lost Carcosa. The crown
;;; is the next watch on the Lake of Hali. Composure — the will to keep your
;;; own face on — decides whether the player can still walk out.

(dialog-particles "carcosa/unmask" :motes :fade-seconds 4.0)
(dialog-sound "carcosa/no-mask" "audio/jrpg/bell.wav" :volume 0.26)
(dialog-sound "carcosa/crown-offer" "audio/jrpg/bell.wav" :volume 0.22)
(dialog-sound "carcosa/take-crown" "audio/jrpg/bell.wav" :volume 0.30)

(dialog-on-enter "carcosa/unmask"
                 '(jrpg-spend-composure 2))

(dialog-conversation "carcosa/unmask"
                     (dialog-right "{player-name}"
                                   "take the crown off. let me see.")
                     (dialog-left "the King"
                                  "everyone asks, at the end. i did, once. there was nothing under it to take off.")
                     :next "carcosa/stranger")

;;; The court is alive: a figure who unmasked before you, willing to be asked.

(dialog-text "carcosa/stranger"
             "a figure stands apart from the pale ones, in a mantle the colour of the King's, a mask held in one hand. he does not put it on."
             :next "carcosa/stranger-talk")

(dialog-conversation "carcosa/stranger-talk"
                     (dialog-left "the Stranger"
                                  "you came up the road with the sign on you and did not turn back. that is rarer than the King thinks.")
                     (dialog-right "{player-name}"
                                   "who are you?")
                     (dialog-left "the Stranger"
                                  "ask. i have been here long enough to answer, and not so long that i have stopped wanting to.")
                     :next "carcosa/stranger-questions")

(dialog-on-enter "carcosa/stranger-questions"
                 '(jrpg-spend-composure 1))

(dialog-interrogation "carcosa/stranger-questions"
                      "the Stranger holds his mask the way a man holds a thing he has decided not to need."
                      (:next "carcosa/no-mask")
                      (:continue-label "turn back to the King")
                      ("ask about the pale figures"
                       :id "court"
                       :speaker "the Stranger"
                       "the crew. from the crossings that went wrong. each kept the last thing it was doing and lost the rest. he keeps them now. it is the keeping he could not manage when it counted.")
                      ("ask about the lake"
                       :id "lake"
                       :speaker "the Stranger"
                       "Hali. every dark water there ever was, seen from the far shore. he crossed it past counting and it never let him land right. then it landed him here and called it a throne.")
                      ("ask why the Stranger goes unmasked too"
                       :id "mask"
                       :speaker "the Stranger"
                       "i unmasked early. it is easier than they say and worse. you stop being someone's and start being the room's. keep yours on while you can still feel it on your face."))

(dialog-on-enter "carcosa/no-mask"
                 '(jrpg-spend-composure 2))

(dialog-text "carcosa/no-mask"
             "the King turns his face full to the lamp. no mask, and no face under it: only the front of a man worn down to the thread, like the coat. you have watched a thing wear out this way before, and cannot place where."
             :next "carcosa/lake-1")

(dialog-say "carcosa/lake-1"
            "the King"
            "i was a captain. i had a crossing to make and a crew who trusted me to make it. i made it wrong, and the dark put me back at the start to make it again."
            :next "carcosa/lake-2")

(dialog-say "carcosa/lake-2"
            "the King"
            "again, and again. you stop counting past a number. the crew never knew. from where they stood every crossing came out clean. they buried the dead from the tries that only i remember."
            :next "carcosa/lake-3")

(dialog-say "carcosa/lake-3"
            "the King"
            "then they decided, kindly, that i was not the one they served, and took the bridge from me, and put me off. the dark did not bring me back to the ship that time. it brought me here, to the lake, which had always been the same lake."
            :next "carcosa/courtiers")

(dialog-text "carcosa/courtiers"
             "you understand the pale figures now. he keeps them the way he could not keep them then. they do not blame him. that is the part he cannot bear, and the reason he answers Mira's letters in yellow: it is the one hand that still does what he means."
             :next "carcosa/crown-offer")

(dialog-on-enter "carcosa/crown-offer"
                 '(jrpg-spend-composure 1))

(dialog-say "carcosa/crown-offer"
            "the King"
            "the crown is not a prize, {player-name}. it is the next watch. someone holds the lake back from the strand. you came up with the sign already on you. you could set it down here, with me, and rest. most do."
            :next "carcosa/throne-choice")

(dialog-pick "carcosa/throne-choice"
             "the crown is yellow in a room with no other colour."
             (dialog-option "take the crown" "carcosa/take-crown")
             (dialog-option "set it down and walk out" "carcosa/refuse-crown"
                            :unless '(not (jrpg-composed-p)))
             (dialog-option "ask him to let the songs go" "carcosa/terms-songs"))

(dialog-on-enter "carcosa/take-crown"
                 '(setf (jrpg-value "jrpg-vane-answer") "crown"))

(dialog-text "carcosa/take-crown"
             "you take it up. it weighs less than a crown should, the way the coat weighs less than a coat. the King steps back into the line of pale figures and becomes one of them, eased. the lake is yours to hold now."
             :next "carcosa/king-end")

(dialog-text "carcosa/king-end"
             "you answer Mira's next letter in yellow and find you know the hand. the first grey of dawn could raise a tempest, if you let it. you keep the watch instead. no one is left to relieve you, which is the whole of what a watch is."
             :next "sys/reboot")

(dialog-on-enter "carcosa/refuse-crown"
                 '(setf (jrpg-value "jrpg-vane-answer") "refused-crown"))

(dialog-text "carcosa/refuse-crown"
             "you set the crown on the carpet and back toward the door. he does not stop you; no one crowned stops anyone leaving. you keep your own face the whole way down the stair. it is the hardest mile of the road, and you walk it."
             :next "carcosa/descend")

(dialog-on-enter "carcosa/terms-songs"
                 '(setf (jrpg-value "jrpg-vane-answer") "songs"))

(dialog-text "carcosa/terms-songs"
             "you ask him to let the songs finish. he considers it longer than a King should have to. then he lifts the sign off the strand, only the strand, and along the walls a few pale figures finish the gesture they were keeping, and are gone."
             :next "carcosa/terms-songs-2")

(dialog-text "carcosa/terms-songs-2"
             "you walk out to a town that can hold a tune again by the time you reach it. it costs him. you do not ask what. the lake takes the difference, the way it always has."
             :next "carcosa/descend")

(dialog-text "carcosa/descend"
             "you come down the shore road alone, the tower dropping behind the ridge. at the inn Mira has the ledger open, and a second book beside it you have not seen, and the look of someone who has waited to show you both."
             :next "ledger/breakfast")
