;;; One Pace From the Threshold
;;;
;;; A self-contained side story. It grows from the hall-sound leaf
;;; "base/listen/steps" ("the steps stop one pace from the threshold.") and
;;; continues the same situation instead of ending it: a winter night, someone
;;; on the landing who says they live here too, and the question of whether you
;;; open the door. Each route decides whose room it always was.

;;; Conditional destinations (delegates read the shared store).

(defun one-pace-bolts-target ()
  (if (<= (dialog-value "one-pace-bolts" 1) 0)
      "one-pace/unlatched"
      "one-pace/decide"))

(defun one-pace-knows-p ()
  (string= (dialog-value "one-pace-stance" "") "known"))

(defun one-pace-held-target ()
  (if (one-pace-knows-p)
      "one-pace/held-known"
      "one-pace/held-stranger"))

(defun one-pace-forced-target ()
  (if (one-pace-knows-p)
      "one-pace/forced-known"
      "one-pace/forced-stranger"))


;;; Graft: the leaf used to dead-end. now the scene keeps going.

(dialog-set-next "base/listen/steps" "one-pace/landing")


;;; Arrival (linear path + the new snow field, drone, footfall)

(dialog-path "one-pace/landing"
  "the steps belong to someone on the landing outside your room. snow-melt drips off their boots onto the boards."
  "they knock once, then wait, one pace back from the door."
  (:next "one-pace/answer"))

(dialog-particles "one-pace/landing" :one-pace/snow :fade-seconds 3.0)
(dialog-music "one-pace/landing" "audio/one-pace-drone.mp3" :volume 0.24)
(dialog-sound "one-pace/landing" "audio/step.wav" :volume 0.5)


;;; Answer (horizontal choice-path)

(dialog-choice-path "one-pace/answer"
  "answer them?"
  ("say you're awake"
   "your voice comes out smaller than you meant it to."
   (:next "one-pace/stairs"))
  ("stay quiet"
   "you hold still. the board under your own foot ticks anyway."
   (:next "one-pace/stairs")))


;;; The exchange through the door (conversation node)

(dialog-conversation "one-pace/stairs"
  (dialog-left "the landing" "it's me. open the door, it's freezing out here.")
  (dialog-right "you" "it's late.")
  (dialog-left "the landing" "i know what time it is. i lost my key again.")
  :next "one-pace/first-look")


;;; First look (vertical pick-path)

(dialog-pick-path "one-pace/first-look"
  "what do you do?"
  ("look under the door"
   :id "gap"
   "two boots, wet to the laces. a duffel bag set down beside them."
   (:next "one-pace/coat"))
  ("turn on the hall light"
   :id "light"
   "the switch clicks. no light comes. they didn't turn theirs on either."
   (:next "one-pace/coat"))
  ("press your ear to the wood"
   :id "ear"
   "breathing, slow and tired. a zipper, then nothing."
   (:next "one-pace/coat")))


;;; The coat and the name (text, string input, spoken substitution)

(dialog-text "one-pace/coat"
  "a heavy coat hangs on the back of your door. snow-stained, not yours. there is a name written on the laundry tag in marker."
  :next "one-pace/name")

(dialog-string "one-pace/name"
  "what does the tag say?"
  :response-key "one-pace-name"
  :max-length 24
  :target "one-pace/after-name")

(dialog-say "one-pace/after-name"
  "the landing"
  "{one-pace-name}. that's my coat you're standing next to. now will you let me in?"
  :next "one-pace/recognise")

(dialog-sound "one-pace/after-name" "audio/held-breath.wav" :volume 0.4)


;;; Stance (plain pick; children set the shared flag on enter)

(dialog-pick "one-pace/recognise"
  "do you know that name?"
  (dialog-option "you know exactly whose it is" "one-pace/known")
  (dialog-option "you have never heard it" "one-pace/stranger"))

(dialog-text "one-pace/known"
  "you know it. they had this room before you did. when they left you moved your bed under the window, and you never gave the key back."
  :next "one-pace/bolts")

(dialog-on-enter "one-pace/known"
  '(setf (dialog-value "one-pace-stance") "known"))

(dialog-text "one-pace/stranger"
  "you have lived here alone for two years. the name on the tag means nothing to you."
  :next "one-pace/bolts")

(dialog-on-enter "one-pace/stranger"
  '(setf (dialog-value "one-pace-stance") "stranger"))


;;; Counting the locks (number with a delegate target)

(dialog-number "one-pace/bolts"
  "how many locks are between you and the landing?"
  :response-key "one-pace-bolts"
  :min 0
  :max 3
  :target #'one-pace-bolts-target)

(dialog-text "one-pace/unlatched"
  "there is nothing to undo. the handle turns on its own weight and the door swings in."
  :next "one-pace/let-open")


;;; The decision (pick with conditional options, plus an appended one)

(dialog-pick "one-pace/decide"
  "the handle turns. they are not knocking anymore."
  (dialog-option "throw your weight against the door" "one-pace/grab")
  (dialog-option "step back and let it open" "one-pace/let-open")
  (dialog-option "tell them they have the wrong door"
                 "one-pace/wrong-door"
                 :when '(string= (dialog-value "one-pace-stance" "") "stranger"))
  (dialog-option "say their name back"
                 "one-pace/say-name"
                 :when '(string= (dialog-value "one-pace-stance" "") "known"))
  (dialog-option "pretend the room is empty"
                 "one-pace/wait"
                 :unless '(string= (dialog-value "one-pace-stance" "") "known")))

;; appended option: visible, but locked unless you counted real locks
(dialog-add-choice "one-pace/decide"
  "wedge the chair under the handle too"
  "one-pace/grab"
  :enabled-when '(>= (dialog-value "one-pace-bolts" 0) 2))


;;; Bracing (list-path for what you grab, a thud, then the minigame)

(dialog-list-path "one-pace/grab"
  "before you brace it, what do you put in your hands?"
  ("the back of the chair" "cold varnish, familiar." (:next "one-pace/brace-setup"))
  ("the lamp by the bed" "the cord is short, but it reaches." (:next "one-pace/brace-setup"))
  ("the brass key" "the one you never returned. it bites your palm." (:next "one-pace/brace-setup"))
  ("just your hands" "palms flat on the wood. it is enough or it is not." (:next "one-pace/brace-setup"))
  ("the coat off the hook" "heavy, snow-cold, not yours." (:next "one-pace/brace-setup")))

(dialog-text "one-pace/brace-setup"
  "you set yourself against the door. the handle drops. the first push moves you a finger's width."
  :next "one-pace/brace")

(dialog-sound "one-pace/brace-setup" "audio/strain.wav" :volume 0.5)

(dialog-minigame "one-pace/brace"
  "hold space, w, or the up arrow to brace the door. keep it shut until they give up. arrow keys work too."
  :game :one-pace/brace
  :success "one-pace/held"
  :failure "one-pace/forced")


;;; Held (delegate next sends each stance to its own morning)

(dialog-text "one-pace/held"
  "after a while the pushing stops. the boots go back down the stairs, slow. you stay against the door until your arms shake."
  :next #'one-pace-held-target)

(dialog-text "one-pace/held-known"
  "in the morning there is an envelope under the door. the lease inside has two names. one of them is {one-pace-name}. the room was theirs before it was yours, and you kept them on the stairs all night."
  :next "one-pace/dawn")

(dialog-text "one-pace/held-stranger"
  "in the morning the coat is still on the door, and it still isn't yours. a neighbor says a man spent the night trying doors along the street, looking for a house two down from this one. you bolted the right door."
  :next "one-pace/dawn")


;;; Forced (the door gives; stance decides who comes in)

(dialog-text "one-pace/forced"
  "the lock tears out of the frame and the door gives all at once."
  :next #'one-pace-forced-target)

(dialog-sound "one-pace/forced" "audio/strain.wav" :volume 0.6)

(dialog-say "one-pace/forced-known"
  "them"
  "you could have just opened the door."
  :next "one-pace/forced-known-2")

(dialog-text "one-pace/forced-known-2"
  "they set the bag down and look around the room like they are checking it is still theirs. you have said that same sentence to yourself, on the other side of a door, more than once."
  :next "one-pace/dawn")

(dialog-text "one-pace/forced-stranger"
  "a man you have never seen stands in the doorway, snow to his knees, a key in his hand that fits no lock here. he looks at you, then at the number on your door, and steps back. wrong house."
  :next "one-pace/dawn")


;;; Letting it open

(dialog-text "one-pace/let-open"
  "you take your hands off the door and step back. it opens. they come in stamping snow off their boots, set the kettle on, and the night becomes ordinary again."
  :next "one-pace/dawn")


;;; Stranger: send them away

(dialog-say "one-pace/wrong-door"
  "you"
  "you have the wrong door. there is no one here by that name."
  :next "one-pace/wrong-door-2")

(dialog-text "one-pace/wrong-door-2"
  "the handle stops turning. a long breath on the other side. then the weight leaves the door and the boots go back down the stairs without arguing."
  :next "one-pace/dawn")


;;; Known: answer them

(dialog-say "one-pace/say-name"
  "you"
  "{one-pace-name}. i kept your room."
  :next "one-pace/say-name-2")

(dialog-text "one-pace/say-name-2"
  "the pushing stops. after a moment they say your name back. for a while neither of you moves, or opens the door, or goes."
  :next "one-pace/dawn")


;;; Waiting it out (a second pick using the inverted predicates)

(dialog-text "one-pace/wait"
  "you stand still and breathe through your mouth. the handle turns once more, testing the latch."
  :next "one-pace/wait-choice")

(dialog-pick "one-pace/wait-choice"
  "they are still there."
  (dialog-option "keep still" "one-pace/let-go-quiet")
  (dialog-option "give them the room"
                 "one-pace/say-name"
                 :unless '(string= (dialog-value "one-pace-stance" "") "stranger"))
  (dialog-option "throw the last bolt"
                 "one-pace/grab"
                 :enabled-unless '(>= (dialog-value "one-pace-bolts" 0) 3)))

(dialog-text "one-pace/let-go-quiet"
  "you wait them out. the weight leaves the door and the stairs take them back down. you never find out whose room it was."
  :next "one-pace/dawn")


;;; Dawn (shared close; stop the drone, return to the room)

(dialog-text "one-pace/dawn"
  "either way, the house is quiet by morning. you go back to the room you have made yours."
  :next "base/awake")

(dialog-stop-music "one-pace/dawn")
