(in-package #:immortal-coil)

(-> register-minigame-definition (minigame-id runtime-function runtime-function)
    minigame-definition)
(defun register-minigame-definition (id update-function draw-function)
  (let ((definition (make-minigame-definition
                     :id id
                     :update-function update-function
                     :draw-function draw-function
                     :source (current-dialog-source-name))))
    (setf (gethash id *minigame-definitions*) definition)))

(-> dialog-minigame-kind (t &key (:update t) (:draw t)) minigame-id)
(defun dialog-minigame-kind (id &key update draw)
  (let ((minigame-id (normalize-minigame-id id))
        (update-function (minigame-handler-function update "update handler"))
        (draw-function (minigame-handler-function draw "draw handler")))
    (if (and update-function draw-function)
        (register-minigame-definition minigame-id
                                      update-function
                                      draw-function)
        (runtime-warn "Could not register minigame: ~a" minigame-id))
    minigame-id))

(-> find-minigame-definition (t &key (:warn-p boolean))
    (option minigame-definition))
(defun find-minigame-definition (id &key (warn-p t))
  (let* ((minigame-id (normalize-minigame-id id))
         (definition (gethash minigame-id *minigame-definitions*)))
    (when (and warn-p
               (not definition))
      (runtime-warn "Unknown minigame: ~a" minigame-id))
    definition))
