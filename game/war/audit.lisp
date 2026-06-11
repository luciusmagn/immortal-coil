;;; war manifest audit minigame
;;;
;;; Two columns of figures: what was loaded and what arrived. One line
;;; does not match. Flag it. Missing it only marks the player as too
;;; tired to catch it; Brandt catches it either way.

(defconstant +war-audit-rows+ 6)
(defconstant +war-audit-duration+ 40.0)

(defclass war-audit-session (minigame-session)
  ((elapsed
    :initform 0.0
    :accessor war-audit-elapsed)
   (cursor
    :initform 0
    :accessor war-audit-cursor)
   (bad-row
    :initform 0
    :accessor war-audit-bad-row)
   (loaded
    :initform #()
    :accessor war-audit-loaded)
   (arrived
    :initform #()
    :accessor war-audit-arrived)))

(defmethod initialize-instance :after ((session war-audit-session) &key)
  (let ((bad-row (get-random-value 0 (1- +war-audit-rows+)))
        (loaded (make-array +war-audit-rows+))
        (arrived (make-array +war-audit-rows+)))
    (loop for i below +war-audit-rows+
          for amount = (* 10 (get-random-value 12 96))
          do (setf (aref loaded i) amount
                   (aref arrived i)
                   (if (= i bad-row)
                       (- amount (* 10 (get-random-value 4 22)))
                       amount)))
    (setf (war-audit-bad-row session) bad-row
          (war-audit-loaded session) loaded
          (war-audit-arrived session) arrived)))

(defun war-audit-move (session direction)
  (setf (war-audit-cursor session)
        (mod (+ (war-audit-cursor session) direction) +war-audit-rows+)))

(defmethod minigame-session-update ((session war-audit-session) node dt)
  (incf (war-audit-elapsed session) dt)
  (cond
    ((or (is-key-pressed-p +key-down+) (is-key-pressed-p +key-s+))
     (war-audit-move session 1))
    ((or (is-key-pressed-p +key-up+) (is-key-pressed-p +key-w+))
     (war-audit-move session -1))
    ((or (is-key-pressed-p +key-space+)
         (is-key-pressed-p +key-enter+))
     (let ((caught-p (= (war-audit-cursor session)
                        (war-audit-bad-row session))))
       (setf (session-store-value session "war-audit-missed") (not caught-p))
       (finish-minigame-node node
                             (if caught-p
                                 (node-success-target node)
                                 (node-failure-target node)))))
    ((>= (war-audit-elapsed session) +war-audit-duration+)
     (setf (session-store-value session "war-audit-missed") t)
     (finish-minigame-node node (node-failure-target node)))))

(defun draw-war-audit-row (session index y)
  (let* ((selected-p (= index (war-audit-cursor session)))
         (color (make-color 255 255 255 (if selected-p 235 130))))
    (when selected-p
      (draw-text-at ">" (- +virtual-center-x+ 250) y 17 color))
    (draw-text-at (format nil "car ~d" (1+ index))
                  (- +virtual-center-x+ 220) y 17 color)
    (draw-text-at (format nil "~d" (aref (war-audit-loaded session) index))
                  (- +virtual-center-x+ 40) y 17 color)
    (draw-text-at (format nil "~d" (aref (war-audit-arrived session) index))
                  (+ +virtual-center-x+ 140) y 17 color)))

(defmethod minigame-session-draw ((session war-audit-session) node color)
  (declare (ignore node))
  (draw-text-at "LOADED" (- +virtual-center-x+ 40) 240 13
                (make-color 255 255 255 110))
  (draw-text-at "ARRIVED" (+ +virtual-center-x+ 140) 240 13
                (make-color 255 255 255 110))
  (loop for i below +war-audit-rows+
        do (draw-war-audit-row session i (+ 280 (* i 34))))
  (draw-centered-text (format nil "~d"
                              (ceiling (max 0.0 (- +war-audit-duration+
                                                   (war-audit-elapsed
                                                    session)))))
                      +virtual-center-x+ 180 20 color)
  (draw-centered-text "w/s or arrows move. space flags the line that does not match."
                      +virtual-center-x+
                      (- +virtual-height+ 42)
                      16
                      (make-color 255 255 255 170)))

(register-minigame-session-kind :war-audit 'war-audit-session)
