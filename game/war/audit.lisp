;;; war manifest audit minigame
;;;
;;; Two columns of figures: what was loaded and what arrived. One line
;;; does not match. Flag it. Missing it only marks the player as too
;;; tired to catch it; Brandt catches it either way.

(defconstant +war-audit-rows+ 6)
(defconstant +war-audit-duration+ 40.0)

(defvar *war-audit* nil)

(defstruct war-audit
  (node-id  *runtime-fallback-node-id* :type dialog-id)
  (elapsed  0.0 :type seconds)
  (cursor   0 :type nonnegative-integer)
  (bad-row  0 :type nonnegative-integer)
  (loaded   #() :type vector)
  (arrived  #() :type vector))

(defun make-fresh-war-audit (node)
  (let* ((bad-row (get-random-value 0 (1- +war-audit-rows+)))
         (loaded (make-array +war-audit-rows+))
         (arrived (make-array +war-audit-rows+)))
    (loop for i below +war-audit-rows+
          for amount = (* 10 (get-random-value 12 96))
          do (setf (aref loaded i) amount
                   (aref arrived i)
                   (if (= i bad-row)
                       (- amount (* 10 (get-random-value 4 22)))
                       amount)))
    (make-war-audit :node-id (node-id node)
                    :elapsed 0.0
                    :cursor 0
                    :bad-row bad-row
                    :loaded loaded
                    :arrived arrived)))

(defun ensure-war-audit (node)
  (unless (and *war-audit*
               (equal (war-audit-node-id *war-audit*)
                      (node-id node)))
    (setf *war-audit* (make-fresh-war-audit node)))
  *war-audit*)

(defun finish-war-audit (target)
  (setf *war-audit* nil)
  (jump-to-dialog-target target))

(defun war-audit-move (game direction)
  (setf (war-audit-cursor game)
        (mod (+ (war-audit-cursor game) direction) +war-audit-rows+)))

(defun update-war-audit-node (node dt)
  (let ((game (ensure-war-audit node)))
    (incf (war-audit-elapsed game) dt)
    (cond
      ((or (is-key-pressed-p +key-down+) (is-key-pressed-p +key-s+))
       (war-audit-move game 1))
      ((or (is-key-pressed-p +key-up+) (is-key-pressed-p +key-w+))
       (war-audit-move game -1))
      ((or (is-key-pressed-p +key-space+)
           (is-key-pressed-p +key-enter+))
       (if (= (war-audit-cursor game) (war-audit-bad-row game))
           (progn
             (setf (dialog-value "war-audit-missed") nil)
             (finish-war-audit (node-success-target node)))
           (progn
             (setf (dialog-value "war-audit-missed") t)
             (finish-war-audit (node-failure-target node))))))
    (when (and *war-audit*
               (>= (war-audit-elapsed game) +war-audit-duration+))
      (setf (dialog-value "war-audit-missed") t)
      (finish-war-audit (node-failure-target node)))))

(defun draw-war-audit-row (game index y)
  (let* ((selected-p (= index (war-audit-cursor game)))
         (color (make-color 255 255 255 (if selected-p 235 130))))
    (when selected-p
      (draw-text-at ">" (- +virtual-center-x+ 250) y 17 color))
    (draw-text-at (format nil "car ~d" (1+ index))
                  (- +virtual-center-x+ 220) y 17 color)
    (draw-text-at (format nil "~d" (aref (war-audit-loaded game) index))
                  (- +virtual-center-x+ 40) y 17 color)
    (draw-text-at (format nil "~d" (aref (war-audit-arrived game) index))
                  (+ +virtual-center-x+ 140) y 17 color)))

(defun draw-war-audit-node (node color)
  (let ((game (ensure-war-audit node)))
    (draw-text-at "LOADED" (- +virtual-center-x+ 40) 240 13
                  (make-color 255 255 255 110))
    (draw-text-at "ARRIVED" (+ +virtual-center-x+ 140) 240 13
                  (make-color 255 255 255 110))
    (loop for i below +war-audit-rows+
          do (draw-war-audit-row game i (+ 280 (* i 34))))
    (draw-centered-text (format nil "~d"
                                (ceiling (max 0.0 (- +war-audit-duration+
                                                     (war-audit-elapsed game)))))
                        +virtual-center-x+ 180 20 color)
    (draw-centered-text "w/s or arrows move. space flags the line that does not match."
                        +virtual-center-x+
                        (- +virtual-height+ 42)
                        16
                        (make-color 255 255 255 170))))

(dialog-minigame-kind :war-audit
                      :update #'update-war-audit-node
                      :draw #'draw-war-audit-node)
