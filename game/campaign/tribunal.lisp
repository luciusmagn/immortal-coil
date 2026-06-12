;;; The tribunal: the war's second dark branch. Years later, the
;;; signature returns as evidence and the numbers transcripts are read
;;; into the record. Entered by keeping a private record on the fourth
;;; morning; exits through the verdict.

(dialog-text "tribunal/keep"
             "you keep the pencil."
             :next "tribunal/keep-2")

(dialog-text "tribunal/keep-2"
             "that evening you buy a tin box from a hardware stall with your own coins, the first thing you have paid for in months, and the pencil copies go into it, and the box goes where boxes go that must be found by the right people and no others."
             :next "tribunal/keep-3")

(dialog-text "tribunal/keep-3"
             "keeping the record becomes the part of the day you do with your whole attention."
             :next "tribunal/seasons")

(dialog-text "tribunal/seasons"
             "the war ends the way the map said it would, only slower. the tape lines walk to the river, stand at the river for a winter, and cross it coming the other way."
             :next "tribunal/seasons-2")

(dialog-text "tribunal/seasons-2"
             "one morning the eight o'clock bell does not ring, and that is the armistice: not a treaty, an absence of bell, and people standing in the corridor listening to it."
             :next "tribunal/years")

(dialog-scene "tribunal/years"
              "three years later."
              :next "tribunal/letter")

(dialog-text "tribunal/letter"
             "the letter comes on good paper, from the commission for the clarification of wartime administration, which is what the victors have named the room where your war is being reread."
             :next "tribunal/letter-2")

(dialog-text "tribunal/letter-2"
             "it invites you to assist. the word assist is doing the work that handcuffs would do in a poorer country."
             :next "tribunal/arrival")

(dialog-text "tribunal/arrival"
             "the courtroom is a school gymnasium, because the courthouse burned in the last winter of the war."
             :next "tribunal/arrival-2")

(dialog-text "tribunal/arrival-2"
             "the lines of old ball games are still painted on the floor, and the commission's tables are arranged inside them, neatly, as if the rules of some earlier game still applied and everyone had agreed not to step out of bounds."
             :next "tribunal/oath")

(dialog-conversation "tribunal/oath"
                     (dialog-left "the presiding judge"
                                  "you were chancellor from the spring of the second year. you held the seals. you will be heard as a witness. whether you remain a witness is a matter for the evidence, not for me, and not for you. do you understand this?")
                     (dialog-right "you"
                                   "better than anything else i have been told in three years.")
                     (dialog-left "the presiding judge"
                                  "then you are sworn. sit. the commission reads slowly and the chairs are hard. both of these are deliberate.")
                     :next "tribunal/gallery-look")

(defun tribunal-gallery-target ()
  (if (dialog-value "district-train")
      "tribunal/gallery-known"
      "tribunal/gallery-strangers"))

(dialog-text "tribunal/gallery-look"
             "you sit. behind the rail, the gallery: sixty faces, coats over their arms because the gymnasium is warm, and every face is from the districts, and every face is here for the lists."
             :next #'tribunal-gallery-target)

(dialog-text "tribunal/gallery-strangers"
             "you know none of them. that is its own verdict, delivered before the first exhibit: you governed these faces for two years from behind glass and tape, and there is not one you can put a street to."
             :next "tribunal/charge")

(dialog-text "tribunal/gallery-known"
             "in the second row sits an old woman with her hands folded on a folded paper, and you know her. the canal district, the bell, the candle. Vasik, with one s. she does not look away when you find her."
             :next "tribunal/gallery-known-2")

(dialog-text "tribunal/gallery-known-2"
             "she has been waiting three years for you to find her, and her face says that the waiting was the easy part."
             :next "tribunal/charge")

(dialog-conversation "tribunal/charge"
                     (dialog-left "the prosecutor"
                                  "exhibit one. a rerouting order, dated tuesday, oh two hundred, moving the third district's winter allocation to kilometer nine. the commission will hear that nothing about this order is what it says. for now, one question. is this your signature?")
                     (dialog-right "you"
                                   "may i see it closer?")
                     (dialog-left "the prosecutor"
                                  "you may hold it. it has been three years. take your time. the commission is interested in your hands as well as your answer.")
                     :next "tribunal/signature-look")

(dialog-text "tribunal/signature-look"
             "you hold the order. the hand is small and even, slanted left at the line ends, steadier than your hand was that week, steadier than your hand is now."
             :next "tribunal/signature-look-2")

(dialog-text "tribunal/signature-look-2"
             "you signed a decree once and were glad of the shaking because the shaking looked like you. this does not shake anywhere."
             :next "tribunal/signature-look-3")

(dialog-text "tribunal/signature-look-3"
             "it is the best signature you have ever seen, and it is yours the way a portrait is you."
             :next "tribunal/signature-choice")

(dialog-pick "tribunal/signature-choice"
             "the gymnasium is quiet. somewhere behind you a chair creaks as the gallery leans."
             (dialog-option "claim it. the office was yours" "tribunal/claimed")
             (dialog-option "deny it. the hand is not yours" "tribunal/denied")
             (dialog-option "say you no longer know" "tribunal/unknown"))

(dialog-on-enter "tribunal/claimed"
                 '(setf (dialog-value "tribunal-signature") "claimed"))

(dialog-text "tribunal/claimed"
             "it is my signature, you say, because the office was mine, and what the office signed, i signed, whether my hand was in the room or not."
             :next "tribunal/claimed-2")

(dialog-text "tribunal/claimed-2"
             "the prosecutor blinks once, the way men blink when a door they were prepared to force stands open. behind you the gallery makes no sound at all, which from sixty people is a sound."
             :next "tribunal/vey")

(dialog-on-enter "tribunal/denied"
                 '(setf (dialog-value "tribunal-signature") "denied"))

(dialog-text "tribunal/denied"
             "the hand is not mine, you say, and it is true, and it sounds like a lie, because it is what every man in every gymnasium like this one has said since the bells stopped."
             :next "tribunal/denied-2")

(dialog-text "tribunal/denied-2"
             "the prosecutor nods as if you have answered a different and more useful question, and asks the clerk to mark that the witness disputes exhibit one."
             :next "tribunal/vey")

(dialog-on-enter "tribunal/unknown"
                 '(setf (dialog-value "tribunal-signature") "unknown"))

(dialog-text "tribunal/unknown"
             "i no longer know, you say. i signed so much. they brought the folders at eight and took them at six, and somewhere in the third winter i stopped being able to tell my hand from the war's."
             :next "tribunal/unknown-2")

(dialog-text "tribunal/unknown-2"
             "it is the truest thing said in the gymnasium all morning, and you watch it land as the worst possible answer, because the commission has a column for guilt and a column for innocence and no column for this."
             :next "tribunal/vey")

(dialog-conversation "tribunal/vey"
                     (dialog-left "Vey"
                                  "the chancellor was thorough. i wish to be exact about this. nothing moved in that building without the chancellor's office. i served the office. the office served the chancellor. the commission may draw the arrows itself.")
                     (dialog-right "you"
                                   "you wrote the decree, Vey.")
                     (dialog-left "Vey"
                                  "i drafted many documents. drafting is a clerk's act. signing is a sovereign's. the commission has the signature. i am only here to confirm the office was orderly, and it was. it was the most orderly office i ever served.")
                     :next "tribunal/vey-after")

(dialog-text "tribunal/vey-after"
             "Vey is being heard by a smaller commission in a smaller room, where his memory is excellent and his file is thin."
             :next "tribunal/vey-after-2")

(dialog-text "tribunal/vey-after-2"
             "cooperation has a tariff and he paid it early, in the currency he always kept ready: other men's orderliness."
             :next "tribunal/vey-after-3")

(dialog-text "tribunal/vey-after-3"
             "he passes you in the corridor at the recess and wishes you good health, and the terrible thing is that he means it."
             :next "tribunal/transcripts")

(dialog-text "tribunal/transcripts"
             "in the afternoon the commission reads the broadcasts into the record."
             :next "tribunal/transcripts-2")

(dialog-text "tribunal/transcripts-2"
             "a clerk stands at a lectern with three years of intercept flimsies and reads the numbers aloud, in groups, hour after hour, because the rules of evidence say the record must contain what the exhibit contains, and the exhibit contains the numbers."
             :next "tribunal/transcripts-listen")

(dialog-text "tribunal/transcripts-listen"
             "by the second hour the gymnasium has learned to read them the way you learned at the night office: this group the car weights, this group the departures, this group the heads."
             :next "tribunal/transcripts-listen-2")

(dialog-text "tribunal/transcripts-listen-2"
             "when the clerk reads the head counts the gallery goes still, and in the second row the old woman counts along with her lips moving, waiting for the night her number went by."
             :next "tribunal/clerk-voice")

(dialog-text "tribunal/clerk-voice"
             "in the third hour the clerk's voice gives out on a four."
             :next "tribunal/clerk-voice-2")

(dialog-text "tribunal/clerk-voice-2"
             "he stands holding the flimsy, mouth working, and nothing comes, and a second clerk rises from the recording table, takes the page, finds the four, and reads on from it without a seam."
             :next "tribunal/clerk-voice-3")

(dialog-text "tribunal/clerk-voice-3"
             "the rules say the count must be read. the rules do not say by whom."
             :next "tribunal/clerk-voice-4")

(dialog-text "tribunal/clerk-voice-4"
             "the station read these same numbers to the empty air for three years because a protocol asked it, and here is the same obedience, wearing the victors' coat, and you understand that the numbers have outlived the war and may outlive everyone in this room."
             :next "tribunal/recess")

(dialog-scene "tribunal/recess"
              "the recess."
              :next "tribunal/sorel")

(dialog-conversation "tribunal/sorel"
                     (dialog-left "Sorel"
                                  "they have had my ledgers since the spring. both sets. the ink for the building and the pencil for the truth. i am told i am a witness for the prosecution, a witness for the defense, and an unindicted question, depending on the day.")
                     (dialog-right "you"
                                   "which are you today?")
                     (dialog-left "Sorel"
                                  "today i am the person who taught the commission to read the numbers. somebody had to. it went faster than teaching you, chancellor. they wanted to learn.")
                     :next "tribunal/audit-ask")

(dialog-text "tribunal/audit-ask"
             "after the recess the prosecutor places the kilometer nine manifests on the witness table, loading figures and arrival figures, and asks whether the witness, given his celebrated thoroughness, would be good enough to reconcile them for the commission."
             :next "tribunal/audit-ask-2")

(dialog-text "tribunal/audit-ask-2"
             "now. aloud. in his own time. the gallery leans again. they know exactly what is being done to you, and most of them approve of it."
             :next "tribunal/audit")

(dialog-minigame "tribunal/audit"
                 "w/s or arrows move. space flags the line that does not match."
                 :game :war-audit
                 :success "tribunal/audit-found"
                 :failure "tribunal/audit-lost")

(dialog-text "tribunal/audit-found"
             "car four. eight hundred short between loading and arrival."
             :next "tribunal/audit-found-2")

(dialog-text "tribunal/audit-found-2"
             "you find it in under a minute, in front of everyone, the way you found it the first time, and your fluency is the exhibit: the commission watches the chancellor read the inventory of the third district like a man reading his own accounts."
             :next "tribunal/audit-found-3")

(dialog-text "tribunal/audit-found-3"
             "no further questions are necessary on the subject of what the chancellor was capable of knowing."
             :next "tribunal/brandt")

(dialog-text "tribunal/audit-lost"
             "the figures swim. three years, and they swim the same way, and your finger stops above the columns and will not come down."
             :next "tribunal/audit-lost-2")

(dialog-text "tribunal/audit-lost-2"
             "in the silence, Sorel rises from the witness bench, crosses the painted lines, and sets one finger on car four without being asked, exactly the way Brandt did, and the commission watches the chancellor be helped, and that is an exhibit too."
             :next "tribunal/brandt")

(dialog-text "tribunal/brandt"
             "Brandt is not in the gymnasium."
             :next "tribunal/brandt-2")

(dialog-text "tribunal/brandt-2"
             "Brandt is a deposition, read by a clerk with a cold, because Brandt went back for the bottom drawer in the last winter and the building was no longer his to walk through."
             :next "tribunal/brandt-3")

(dialog-text "tribunal/brandt-3"
             "the deposition ends: the pencil copy is filed where things are found again. signed, dated, and found, exactly as filed. he was right about the cabinet."
             :next "tribunal/brandt-4")

(dialog-text "tribunal/brandt-4"
             "you would give the rest of your life to tell him so, and the rest of your life is currently under discussion."
             :next "tribunal/verdict-eve")

(dialog-text "tribunal/verdict-eve"
             "the night before the verdict you are kept in a borrowed room above the gymnasium with a cot and a basin and one window."
             :next "tribunal/verdict-eve-2")

(dialog-text "tribunal/verdict-eve-2"
             "in the city the bells ring at dusk, struck slow and uneven, and you know the unevenness now: a tired arm, a list being read back into the world, name by recovered name."
             :next "tribunal/verdict-eve-3")

(dialog-text "tribunal/verdict-eve-3"
             "they are ringing the lists the other way. it takes hours. you stand at the window for all of it."
             :next "tribunal/statement-choice")

(dialog-pick "tribunal/statement-choice"
             "in the morning the presiding judge asks whether the witness wishes to make a statement before the commission rules."
             (dialog-option "read the names you kept" "tribunal/statement-names")
             (dialog-option "say you were the one they asked" "tribunal/statement-asked")
             (dialog-option "offer no statement" "tribunal/statement-none"))

(dialog-on-enter "tribunal/statement-names"
                 '(setf (dialog-value "tribunal-statement") "names"))

(dialog-text "tribunal/statement-names"
             "you open the tin box, which is an exhibit now and is lent back to you for this, and you read the pencil pages aloud: dates, car weights, head counts, and where you matched a count to a list, the names."
             :next "tribunal/statement-names-2")

(dialog-text "tribunal/statement-names-2"
             "you read for forty minutes. nobody stops you. it is not a defense. it was never going to be a defense."
             :next "tribunal/statement-names-3")

(dialog-text "tribunal/statement-names-3"
             "it is a bell, rung the other way, by the man who let it ring the first way, and the gymnasium hears it as exactly that."
             :next "tribunal/verdict-scene")

(dialog-on-enter "tribunal/statement-asked"
                 '(setf (dialog-value "tribunal-statement") "asked"))

(dialog-text "tribunal/statement-asked"
             "you say: the war was there every morning, asking to be lost more slowly, and i was the one it asked. i thought that if i stayed, the asking would at least pass through someone who hated the answer."
             :next "tribunal/statement-asked-2")

(dialog-text "tribunal/statement-asked-2"
             "i have had three years to consider whether that belief was a service or an alibi, and i have not finished, and i do not expect to. the judge writes one line. the gallery does not move."
             :next "tribunal/verdict-scene")

(dialog-on-enter "tribunal/statement-none"
                 '(setf (dialog-value "tribunal-statement") "none"))

(dialog-text "tribunal/statement-none"
             "no statement, you say. the words have all been used. every one of them was used in that building, on good paper, to move what was moved, and you will not ask the same words to move you back."
             :next "tribunal/statement-none-2")

(dialog-text "tribunal/statement-none-2"
             "the judge looks at you for a long moment with something that is not sympathy and is not contempt, and is possibly recognition."
             :next "tribunal/verdict-scene")

(defun tribunal-verdict-target ()
  (let ((sig (dialog-value "tribunal-signature" "unknown")))
    (cond
      ((string= sig "claimed") "tribunal/verdict-claimed")
      ((string= sig "denied") "tribunal/verdict-denied")
      (t "tribunal/verdict-unknown"))))

(dialog-scene "tribunal/verdict-scene"
              "the verdict."
              :next #'tribunal-verdict-target)

(dialog-text "tribunal/verdict-claimed"
             "the commission finds the office responsible and the man inseparable from the office, his own statement having closed the distance between them."
             :next "tribunal/verdict-claimed-2")

(dialog-text "tribunal/verdict-claimed-2"
             "the sentence is read slowly, in the gymnasium, inside the painted lines: custody of years, forfeiture of honors, and the entry of his name, in ink, on the consolidated list, in order of street and not of rank. you asked for the office. the office is what you get."
             :next "tribunal/after")

(dialog-text "tribunal/verdict-denied"
             "the commission finds that the hand on exhibit one cannot be established, the only man who could have drafted it being heard elsewhere, in the smaller room, where his memory is excellent. you are released as a witness, with thanks."
             :next "tribunal/verdict-denied-2")

(dialog-text "tribunal/verdict-denied-2"
             "outside the gymnasium the gallery files past you on the steps, and nobody touches you, and nobody speaks to you, and you understand that you have been acquitted into a city that has reached its own verdict and owns no gymnasium to read it in."
             :next "tribunal/after")

(dialog-text "tribunal/verdict-unknown"
             "the commission finds the question of the signature unresolved and the man before it diminished in a manner the statutes do not provide for."
             :next "tribunal/verdict-unknown-2")

(dialog-text "tribunal/verdict-unknown-2"
             "it orders supervision in place of custody: a registered address, a weekly signature at the district office, in your own hand, witnessed, forever."
             :next "tribunal/verdict-unknown-3")

(dialog-text "tribunal/verdict-unknown-3"
             "you will sign your name once a week for the rest of your life while a clerk watches your hand, and this is either the gentlest sentence the regulations contain or the most exact, and the commission, closing its folder, declines to say which."
             :next "tribunal/after")

(dialog-text "tribunal/after"
             "that night, wherever they have put you, the bells ring the recovered names until past midnight, uneven, patient."
             :next "tribunal/after-2")

(dialog-text "tribunal/after-2"
             "you lie listening with your eyes open, keeping your own count, and somewhere between one name and the next the counting becomes the old counting, backward, from ten."
             :next "base/awake")
