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
            "past the left exit, you recognize the empty bed from the room you thought you left."
            :next "base/awake")

(dialog-say "dream/upper-exit"
            "the hall"
            "past the upper exit, the ceiling has the same cracks you ignored above the bed."
            :next "base/awake")

(dialog-say "dream/right-exit"
            "the hall"
            "past the right exit, the handle matches the door that was behind you."
            :next "base/awake")

(dialog-text "dream/maze-lost"
             "you lose the thread of which corridor came first."
             :next "base/awake")
