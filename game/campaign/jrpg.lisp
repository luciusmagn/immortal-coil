(dialog-particles "jrpg/inn" :rising :fade-seconds 2.0)
(dialog-music "jrpg/inn" "audio/jrpg-plain-drone.mp3" :volume 0.24)

(dialog-text "jrpg/inn"
             "the match flares. the room is plainly an inn room: checked blanket, wooden chest, and a quest notice nailed above the basin."
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
                 '(setf (dialog-value "jrpg-companion") "the childhood friend"))
(dialog-on-enter "jrpg/mage"
                 '(setf (dialog-value "jrpg-companion") "the quiet mage"))
(dialog-on-enter "jrpg/knight"
                 '(setf (dialog-value "jrpg-companion") "the knight with no helmet"))

(dialog-text "jrpg/friend"
             "the childhood friend knows your favorite bread and nothing else about you."
             :next "jrpg/field")

(dialog-text "jrpg/mage"
             "the quiet mage carries a spellbook full of pressed leaves and unpaid bills."
             :next "jrpg/field")

(dialog-text "jrpg/knight"
             "the knight with no helmet has excellent posture and a terrible sense of direction."
             :next "jrpg/field")

(dialog-text "jrpg/field"
             "the road north is bright and harmless. slimes wait in the grass with professional patience."
             :next "jrpg/slime")

(dialog-choice "jrpg/slime"
               "a slime appears."
               (dialog-option "attack" "jrpg/slime-attack")
               (dialog-option "magic" "jrpg/slime-magic"))

(dialog-text "jrpg/slime-attack"
             "you strike the slime. it divides into two smaller administrative problems."
             :next "jrpg/tower")

(dialog-text "jrpg/slime-magic"
             "{jrpg-companion} reads the spell upside down. the slime becomes embarrassed and leaves."
             :next "jrpg/tower")

(dialog-text "jrpg/tower"
             "the north tower is exactly where the map says it is. its door has the same brass keyhole as the room you woke in."
             :next "jrpg/demon-lord")

(dialog-say "jrpg/demon-lord"
            "demon lord"
            "hero, you have come at last. please ignore the bed in the corner."
            :next "jrpg/unfinished")

(dialog-text "jrpg/unfinished"
             "the battle music should start here, but the room is quiet enough to hear the innkeeper turning pages downstairs."
             :next "base/awake")
