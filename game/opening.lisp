(dialog-start "base/awake")

(dialog-text "base/awake"
             "you awake in a strange world..."
             :next "base/feel")

(dialog-text "base/feel"
             "or at least that's how you feel..."
             :next "base/exit-bed")

(dialog-choice "base/exit-bed"
               "exit bed?"
               (dialog-option "yes" "base/exited-bed")
               (dialog-option "no" "base/sleep"))

(dialog-text "base/exited-bed"
             "you exited the bed, nothing of interest happened...")

(dialog-text "base/sleep"
             "you rolled over and went back to sleep, nothing of interest happened...")
