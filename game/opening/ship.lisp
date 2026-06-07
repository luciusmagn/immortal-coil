(dialog-text "ship/wake"
             "the glass is cold in your hand. in its reflection, the bed is a crash couch and the night stand is a console."
             :next "ship/name")

(dialog-string "ship/name"
               "what does the room call you?"
               :response-key "player-name"
               :max-length 24
               :target "ship/alarm")

(dialog-text "ship/alarm"
             "captain {player-name}, the wireframe lane is collapsing."
             :next "ship/flight")

(dialog-minigame "ship/flight"
                 "use wasd or arrow keys. keep the ship inside the open wireframe gates."
                 :game :wire-flight
                 :success "ship/threaded"
                 :failure "ship/crash-return")

(dialog-text "ship/threaded"
             "you thread the line. for one impossible second, the ship is quiet.")

(dialog-text "ship/crash-return"
             "white lines fill your eyes. the next breath catches in the same alarm."
             :next "ship/alarm")
