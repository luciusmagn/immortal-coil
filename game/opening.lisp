(dialog-start "base/awake")

(dialog-particles "base/awake" :rising :immediate t)
(dialog-particles "ship/wake" :stars :fade-seconds 6.5)

(dialog-minigame-kind :wire-flight
                      :update #'update-flight-minigame-node
                      :draw #'draw-flight-minigame)

(dialog-minigame-kind :dream-maze
                      :update #'update-dream-maze-minigame-node
                      :draw #'draw-dream-maze-minigame)
