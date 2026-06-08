(dialog-particles "jrpg/inn" :rising :fade-seconds 2.0)
(dialog-music "jrpg/inn" "audio/jrpg-lyria-drone.mp3" :volume 0.24)

(defun jrpg-combat-result-target ()
  (let ((result (jrpg-value "jrpg-last-battle" "victory")))
    (cond
      ((string= result "retreat")
       "jrpg/slime-retreat")
      (t
       "jrpg/road-clear"))))


;;; Opening quest

(dialog-on-enter "jrpg/inn"
                 '(jrpg-init-state))

(dialog-text "jrpg/inn"
             "the match flares. you are in an inn room: checked blanket, wooden chest, wash basin, and a quest notice nailed above the basin."
             :next "jrpg/notice")

(dialog-text "jrpg/notice"
             "BRAVE ONE: THE DEMON LORD WAITS IN THE NORTH TOWER. BREAKFAST INCLUDED."
             :next "jrpg/keeper")

(dialog-say "jrpg/keeper"
            "innkeeper"
            "you are late, hero. the bridge guard has been polishing the same spear since dawn."
            :next "jrpg/party")

(dialog-pick "jrpg/party"
             "who joins you at the village gate?"
             (dialog-option "the childhood friend" "jrpg/friend")
             (dialog-option "the quiet mage" "jrpg/mage")
             (dialog-option "the knight with no helmet" "jrpg/knight"))

(dialog-on-enter "jrpg/friend"
                 '(jrpg-set-companion "the childhood friend"))
(dialog-on-enter "jrpg/mage"
                 '(jrpg-set-companion "the quiet mage"))
(dialog-on-enter "jrpg/knight"
                 '(jrpg-set-companion "the knight with no helmet"))

(dialog-text "jrpg/friend"
             "the childhood friend knows your favorite bread and nothing else about you."
             :next "jrpg/gate")

(dialog-text "jrpg/mage"
             "the quiet mage carries a spellbook full of pressed leaves and unpaid bills."
             :next "jrpg/gate")

(dialog-text "jrpg/knight"
             "the knight with no helmet has excellent posture and a terrible sense of direction."
             :next "jrpg/gate")


;;; Village gate hooks

(dialog-pick "jrpg/gate"
             "at the village gate, {jrpg-companion} waits by the road north."
             (dialog-option "leave at once" "jrpg/gate-leave")
             (dialog-option "buy bread" "jrpg/gate-bread")
             (dialog-option "ask the guard" "jrpg/gate-guard"))

(dialog-on-enter "jrpg/gate-leave"
                 '(setf (jrpg-value "jrpg-gate-choice") "leave"))

(dialog-text "jrpg/gate-leave"
             "you leave before anyone can add another errand."
             :next "jrpg/overworld")

(dialog-on-enter "jrpg/gate-bread"
                 '(setf (jrpg-value "jrpg-gate-choice") "bread"))

(dialog-on-enter "jrpg/gate-bread"
                 '(jrpg-adjust-number "jrpg-gold" -2))

(dialog-on-enter "jrpg/gate-bread"
                 '(jrpg-adjust-number "jrpg-potions" 1))

(dialog-text "jrpg/gate-bread"
             "the baker sells you a heel of bread and calls it a travel ration. the bag feels one item heavier."
             :next "jrpg/overworld")

(dialog-on-enter "jrpg/gate-guard"
                 '(setf (jrpg-value "jrpg-gate-choice") "guard"))

(dialog-text "jrpg/gate-guard"
             "the bridge guard says the north road is safe except for slimes, wolves, bandits, weather, and the demon lord."
             :next "jrpg/overworld")


;;; Overworld and first battle

(dialog-minigame "jrpg/overworld"
                 "arrows or wasd move. cross the overworld road."
                 :game :jrpg-overworld
                 :success "jrpg/slime-arrives"
                 :failure "jrpg/slime-arrives")

(dialog-text "jrpg/slime-arrives"
             "the grass shakes. a slime hops onto the road and waits for its turn."
             :next "jrpg/slime-combat")

(dialog-minigame "jrpg/slime-combat"
                 "choose a command. arrows or wasd move. enter or space confirms."
                 :game :jrpg-combat
                 :success #'jrpg-combat-result-target
                 :failure "jrpg/slime-defeat")

(dialog-text "jrpg/slime-retreat"
             "you return to the road sign. NORTH TOWER is still painted in stiff letters."
             :next "jrpg/tower-road")

(dialog-text "jrpg/slime-defeat"
             "you wake on the road with {jrpg-companion} shaking your shoulder and the slime hopping away."
             :next "jrpg/tower-road")

(dialog-text "jrpg/road-clear"
             "the slime is gone. {jrpg-companion} says this means you are doing very well."
             :next "jrpg/tower-road")

(dialog-text "jrpg/tower-road"
             "the north tower is exactly where the map says it is."
             :next "jrpg/tower-choice")


;;; Tower approach

(dialog-pick "jrpg/tower-choice"
             "how do you approach the tower?"
             (dialog-option "front door" "jrpg/tower-front")
             (dialog-option "side stair" "jrpg/tower-side")
             (dialog-option "wait until morning" "jrpg/tower-wait"))

(dialog-on-enter "jrpg/tower-front"
                 '(setf (jrpg-value "jrpg-tower-approach") "front"))

(dialog-text "jrpg/tower-front"
             "the front door has a brass keyhole below an iron handle."
             :next "jrpg/demon-hall")

(dialog-on-enter "jrpg/tower-side"
                 '(setf (jrpg-value "jrpg-tower-approach") "side"))

(dialog-text "jrpg/tower-side"
             "the side stair is narrow and full of cobwebs. halfway up, it joins the front hall anyway."
             :next "jrpg/demon-hall")

(dialog-on-enter "jrpg/tower-wait"
                 '(setf (jrpg-value "jrpg-tower-approach") "wait"))

(dialog-text "jrpg/tower-wait"
             "you wait until morning. the tower is still there."
             :next "jrpg/demon-hall")

(dialog-text "jrpg/demon-hall"
             "inside, a long carpet leads to a large door. two torches burn beside it because this is the kind of place that has two torches."
             :next "jrpg/demon-lord")

(dialog-say "jrpg/demon-lord"
            "demon lord"
            "hero, you have come at last. the notice did not lie."
            :next "jrpg/demon-choice")

(dialog-pick "jrpg/demon-choice"
             "what do you do?"
             (dialog-option "draw your sword" "jrpg/demon-fight")
             (dialog-option "ask about terms" "jrpg/demon-terms")
             (dialog-option "open the treasure chest" "jrpg/demon-chest"))

(dialog-on-enter "jrpg/demon-fight"
                 '(setf (jrpg-value "jrpg-demon-approach") "fight"))

(dialog-text "jrpg/demon-fight"
             "you draw your sword. {jrpg-companion} nods like this is exactly how stories are supposed to go."
             :next "jrpg/chapter-end")

(dialog-on-enter "jrpg/demon-terms"
                 '(setf (jrpg-value "jrpg-demon-approach") "terms"))

(dialog-text "jrpg/demon-terms"
             "the demon lord says the terms are simple: the village stops sending heroes, and he stops having to defeat them."
             :next "jrpg/chapter-end")

(dialog-on-enter "jrpg/demon-chest"
                 '(setf (jrpg-value "jrpg-demon-approach") "chest"))

(dialog-text "jrpg/demon-chest"
             "the chest contains one potion, three coins, and a note that says FOR HERO."
             :next "jrpg/chapter-end")

(dialog-text "jrpg/chapter-end"
             "the battle music should start here. instead, the room is quiet enough to hear the innkeeper turning pages downstairs.")
