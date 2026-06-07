(dialog-say "dream/start"
            "the room"
            "a few moments later, you fall asleep"
            :next "dream/falling")

(dialog-say "dream/falling"
            "the dark"
            "you feel a falling sensation."
            :next "dream/maze")

(dialog-minigame "dream/maze"
                 "w/s move. a/d turn. find an exit."
                 :game :dream-maze
                 :success "dream/maze-exit"
                 :failure "dream/maze-lost")

(dialog-branch "dream/maze-exit"
               (dialog-case '(string= (dialog-value "dream-maze-exit" "")
                                      "left")
                            "dream/left-exit")
               (dialog-case '(string= (dialog-value "dream-maze-exit" "")
                                      "upper")
                            "dream/upper-exit")
               (dialog-case '(string= (dialog-value "dream-maze-exit" "")
                                      "right")
                            "dream/right-exit")
               (dialog-default "dream/maze-lost"))

(dialog-say "dream/left-exit"
            "the hall"
            "the left exit opens into the same room, but the bed is empty."
            :next "base/awake")

(dialog-say "dream/upper-exit"
            "the hall"
            "the upper exit leads to a ceiling that remembers being a floor."
            :next "base/awake")

(dialog-say "dream/right-exit"
            "the hall"
            "the right exit waits until you cross it, then becomes a door behind you."
            :next "base/awake")

(dialog-text "dream/maze-lost"
             "the corridors fold shut."
             :next "base/awake")
