;;; rogue delve minigame
;;;
;;; Reusable turn-based crawl. Progress lives in the dialog store under
;;; a config prefix so autosaves can resume a long delve.
;;;
;;; Map glyphs: # wall, . floor, @ spawn, * chalk mark, m hunter,
;;; g monster, ^ trap, % ration, ! potion, ? map scroll,
;;; > stairs down, < stairs up, $ goal.

(defconstant +delve-cell+ 28)
(defconstant +delve-glyph-size+ 24)
(defconstant +delve-sight+ 4)
(defconstant +delve-map-center-y+ 378.0)
(defconstant +delve-hud-height+ 92.0)
(defconstant +delve-hud-gap+ 16.0)

(defparameter *delve-classes*
  '((:id :fighter
     :label "FIGHTER"
     :hp 8
     :sight 4
     :attack 6
     :stealth 1
     :rations 1
     :description "mail, sword-arm, no patience for doors")
    (:id :thief
     :label "THIEF"
     :hp 5
     :sight 4
     :attack 4
     :stealth 4
     :rations 2
     :description "soft steps, trap hands, better exits")
    (:id :seer
     :label "SEER"
     :hp 4
     :sight 6
     :attack 3
     :stealth 2
     :rations 1
     :description "bad knife, long sight, map sense")))

(defparameter *delve-inventory-options*
  #(:return :ration :scroll))

(defparameter *delve-fallback-map*
  '(("#########"
     "#@..*..$#"
     "#########")))

;;; Crawl state

(defclass rogue-delve-session (minigame-session)
  ((floors
    :initform #()
    :accessor delve-floors)))

(defun delve-prefix (session)
  (session-config-value session :save-prefix "delve"))

(defun delve-key (session name)
  (format nil "~a-~a" (delve-prefix session) name))

(defun delve-state (session name &optional default)
  (session-store-value session (delve-key session name) default))

(defun (setf delve-state) (value session name)
  (setf (session-store-value session (delve-key session name)) value))

(defun delve-parse-floor (rows)
  (coerce (mapcar (lambda (row) (coerce row 'vector)) rows) 'vector))

(defun delve-normalize-maps (maps)
  (if (and (listp maps) maps)
      maps
      *delve-fallback-map*))

(defun delve-find-glyph (floor glyph)
  (loop for y below (length floor)
        do (loop for x below (length (aref floor y))
                 when (eql (aref (aref floor y) x) glyph)
                   do (return-from delve-find-glyph (values x y))))
  (values 1 1))

(defun delve-floor-index (session)
  (let ((count (length (delve-floors session))))
    (min (delve-state session "floor" 0)
         (max 0 (1- count)))))

(defun delve-floor-grid (session)
  (aref (delve-floors session) (delve-floor-index session)))

(defun delve-glyph-at (session x y)
  (let ((grid (delve-floor-grid session)))
    (if (and (>= y 0) (< y (length grid))
             (>= x 0) (< x (length (aref grid y))))
        (aref (aref grid y) x)
        #\#)))

(defun delve-position-token (floor x y)
  (list floor x y))

(defun delve-picked-p (session floor x y)
  (member (delve-position-token floor x y)
          (delve-state session "picked")
          :test #'equal))

(defun delve-killed-p (session floor x y)
  (member (delve-position-token floor x y)
          (delve-state session "killed")
          :test #'equal))

(defun delve-mark-picked (session floor x y)
  (pushnew (delve-position-token floor x y)
           (delve-state session "picked")
           :test #'equal))

(defun delve-mark-killed (session floor x y)
  (pushnew (delve-position-token floor x y)
           (delve-state session "killed")
           :test #'equal))

(defun delve-class (session)
  (let ((class-id (delve-state session "class")))
    (or (and class-id
             (find class-id
                   *delve-classes*
                   :key (lambda (entry) (getf entry :id))))
        (first *delve-classes*))))

(defun delve-class-id (class)
  (getf class :id))

(defun delve-class-label (class)
  (getf class :label "ADVENTURER"))

(defun delve-class-value (session key &optional default)
  (getf (delve-class session) key default))

(defun delve-player-sight (session)
  (+ (delve-class-value session :sight +delve-sight+)
     (if (delve-state session "mapped") 1 0)))

(defun delve-player-attack (session)
  (+ (delve-class-value session :attack 4)
     (if (dialog-value "rogue-sword") 1 0)))

(defun delve-max-hp (session)
  (delve-class-value session :hp 5))

(defun delve-current-hp (session)
  (or (delve-state session "hp")
      (delve-max-hp session)))

(defun delve-sound (session key &optional (volume 0.42))
  (let ((path (session-config-value session key)))
    (when path
      (play-story-sound path :volume volume))))


;;; Session setup

(defun delve-place-hunter (session floor-index)
  (let ((grid (aref (delve-floors session) floor-index)))
    (multiple-value-bind (x y) (delve-find-glyph grid #\m)
      (if (eql (aref (aref grid y) x) #\m)
          (setf (delve-state session "hunter-x") x
                (delve-state session "hunter-y") y
                (delve-state session "hunter") t)
          (setf (delve-state session "hunter") nil)))))

(defun delve-initialize-position (session)
  (multiple-value-bind (x y)
      (delve-find-glyph (aref (delve-floors session) 0) #\@)
    (setf (delve-state session "floor") 0
          (delve-state session "x") x
          (delve-state session "y") y)
    (delve-place-hunter session 0)))

(defmethod initialize-instance :after ((session rogue-delve-session) &key)
  (let ((maps (delve-normalize-maps (session-config-value session :maps))))
    (setf (delve-floors session)
          (coerce (mapcar #'delve-parse-floor maps) 'vector))
    (unless (delve-state session "started")
      (with-batched-store-saves ()
        (setf (delve-state session "started") t
              (delve-state session "phase") :class
              (delve-state session "class-index") 0
              (delve-state session "marks") 0
              (delve-state session "xp") 0
              (delve-state session "turns") 0
              (delve-state session "picked") nil
              (delve-state session "killed") nil
              (delve-state session "mapped") nil)
        (delve-initialize-position session)))
    (unless (delve-state session "phase")
      (setf (delve-state session "phase")
            (if (delve-state session "class") :crawl :class)))))

(defun delve-start-class (session class)
  (with-batched-store-saves ()
    (setf (delve-state session "class") (delve-class-id class)
          (delve-state session "phase") :crawl
          (delve-state session "hp") (getf class :hp)
          (delve-state session "rations") (getf class :rations)
          (delve-state session "scrolls") (if (eq (delve-class-id class)
                                                  :seer)
                                              1
                                              0)
          (delve-state session "inventory-index") 0))
  (delve-sound session :class-sound 0.54))


;;; Turn rules

(defun delve-walkable-p (session x y)
  (not (eql (delve-glyph-at session x y) #\#)))

(defun delve-monster-p (glyph)
  (member glyph '(#\g #\b #\o) :test #'eql))

(defun delve-item-p (glyph)
  (member glyph '(#\* #\% #\! #\?) :test #'eql))

(defun delve-hunter-caught-p (session)
  (and (delve-state session "hunter")
       (= (delve-state session "hunter-x") (delve-state session "x"))
       (= (delve-state session "hunter-y") (delve-state session "y"))))

(defun delve-finish (session node outcome-key fallback)
  (setf (delve-state session "started") nil)
  (finish-minigame-node node
                        (or (session-config-value session outcome-key)
                            fallback)))

(defun delve-hurt (session node amount)
  (let ((hp (max 0 (- (delve-current-hp session) amount))))
    (setf (delve-state session "hp") hp)
    (delve-sound session :hit-sound 0.46)
    (if (zerop hp)
        (progn
          (delve-finish session node :caught-target (node-failure-target node))
          nil)
        t)))

(defun delve-switch-floor (session new-floor arrival-glyph)
  (let* ((bounded-floor (min (max 0 new-floor)
                             (1- (length (delve-floors session)))))
         (grid (aref (delve-floors session) bounded-floor)))
    (multiple-value-bind (x y) (delve-find-glyph grid arrival-glyph)
      (setf (delve-state session "floor") bounded-floor
            (delve-state session "x") x
            (delve-state session "y") y
            (delve-state session "mapped") nil)
      (delve-place-hunter session bounded-floor)
      (delve-sound session :stairs-sound 0.48))))

(defun delve-hunter-step (session)
  (when (delve-state session "hunter")
    (let* ((hx (delve-state session "hunter-x"))
           (hy (delve-state session "hunter-y"))
           (px (delve-state session "x"))
           (py (delve-state session "y"))
           (distance (max (abs (- px hx)) (abs (- py hy)))))
      (when (<= distance 6)
        (let* ((step-x (+ hx (cond ((< hx px) 1) ((> hx px) -1) (t 0))))
               (step-y (+ hy (cond ((< hy py) 1) ((> hy py) -1) (t 0)))))
          (cond
            ((and (/= step-x hx)
                  (delve-walkable-p session step-x hy))
             (setf (delve-state session "hunter-x") step-x))
            ((and (/= step-y hy)
                  (delve-walkable-p session hx step-y))
             (setf (delve-state session "hunter-y") step-y))))))))

(defun delve-advance-turn (session node)
  (incf (delve-state session "turns"))
  (when (and (zerop (mod (delve-state session "turns") 26))
             (zerop (delve-state session "rations" 0)))
    (unless (delve-hurt session node 1)
      (return-from delve-advance-turn nil)))
  (delve-hunter-step session)
  (if (delve-hunter-caught-p session)
      (progn
        (delve-finish session node :caught-target (node-failure-target node))
        nil)
      t))

(defun delve-resolve-monster (session node x y glyph floor-index)
  (declare (ignore glyph))
  (let* ((roll (get-random-value 1 10))
         (attack (delve-player-attack session))
         (hit-p (<= roll attack)))
    (if hit-p
        (progn
          (delve-mark-killed session floor-index x y)
          (incf (delve-state session "xp"))
          (setf (delve-state session "x") x
                (delve-state session "y") y)
          (delve-sound session :kill-sound 0.48)
          (delve-advance-turn session node))
        (progn
          (delve-sound session :hit-sound 0.46)
          (when (delve-hurt session node 1)
            (delve-advance-turn session node))))))

(defun delve-trigger-trap (session node floor-index x y)
  (delve-mark-picked session floor-index x y)
  (let ((stealth (delve-class-value session :stealth 1)))
    (if (<= (get-random-value 1 6) stealth)
        (delve-sound session :pickup-sound 0.38)
        (delve-hurt session node 1))))

(defun delve-collect-item (session floor-index x y glyph)
  (unless (delve-picked-p session floor-index x y)
    (delve-mark-picked session floor-index x y)
    (case glyph
      (#\*
       (incf (delve-state session "marks")))
      (#\%
       (incf (delve-state session "rations")))
      (#\!
       (setf (delve-state session "hp")
             (min (delve-max-hp session)
                  (+ (delve-current-hp session) 2))))
      (#\?
       (incf (delve-state session "scrolls"))))
    (delve-sound session :pickup-sound 0.38)))

(defun delve-enter-cell (session node x y)
  (let* ((glyph (delve-glyph-at session x y))
         (floor-index (delve-floor-index session)))
    (cond
      ((not (delve-walkable-p session x y))
       (delve-sound session :bump-sound 0.28)
       t)
      ((and (delve-monster-p glyph)
            (not (delve-killed-p session floor-index x y)))
       (delve-resolve-monster session node x y glyph floor-index))
      ((and (eql glyph #\^)
            (not (delve-picked-p session floor-index x y)))
       (setf (delve-state session "x") x
             (delve-state session "y") y)
       (when (delve-trigger-trap session node floor-index x y)
         (delve-advance-turn session node)))
      (t
       (setf (delve-state session "x") x
             (delve-state session "y") y)
       (when (delve-item-p glyph)
         (delve-collect-item session floor-index x y glyph))
       (cond
         ((eql glyph #\$)
          (delve-finish session node :goal-target
                        (node-success-target node))
          nil)
         ((eql glyph #\>)
          (if (< (1+ floor-index) (length (delve-floors session)))
              (delve-switch-floor session (1+ floor-index) #\<)
              (delve-finish session node :goal-target
                            (node-success-target node)))
          nil)
         ((eql glyph #\<)
          (if (zerop floor-index)
              (progn
                (delve-finish session node :leave-target
                              (node-failure-target node))
                nil)
              (progn
                (delve-switch-floor session (1- floor-index) #\>)
                nil)))
         (t
          (delve-sound session :step-sound 0.30)
          (delve-advance-turn session node)))))))

(defun delve-take-step (session node dx dy)
  (let ((x (+ (delve-state session "x") dx))
        (y (+ (delve-state session "y") dy)))
    (with-batched-store-saves ()
      (delve-enter-cell session node x y))))

(defun delve-step-input ()
  (cond
    ((or (is-key-pressed-p +key-up+) (is-key-pressed-p +key-w+))
     (values 0 -1))
    ((or (is-key-pressed-p +key-down+) (is-key-pressed-p +key-s+))
     (values 0 1))
    ((or (is-key-pressed-p +key-left+) (is-key-pressed-p +key-a+))
     (values -1 0))
    ((or (is-key-pressed-p +key-right+) (is-key-pressed-p +key-d+))
     (values 1 0))
    (t (values nil nil))))


;;; Menus

(defun delve-menu-direction ()
  (cond
    ((or (is-key-pressed-p +key-down+)
         (is-key-pressed-p +key-right+)
         (is-key-pressed-p +key-s+)
         (is-key-pressed-p +key-d+))
     1)
    ((or (is-key-pressed-p +key-up+)
         (is-key-pressed-p +key-left+)
         (is-key-pressed-p +key-w+)
         (is-key-pressed-p +key-a+))
     -1)))

(defun delve-class-count ()
  (length *delve-classes*))

(defun delve-selected-class (session)
  (nth (mod (delve-state session "class-index" 0)
            (delve-class-count))
       *delve-classes*))

(defun update-delve-class-menu (session)
  (let ((direction (delve-menu-direction)))
    (when direction
      (setf (delve-state session "class-index")
            (mod (+ (delve-state session "class-index" 0) direction)
                 (delve-class-count)))
      (delve-sound session :menu-sound 0.28)))
  (when (confirm-pressed-p)
    (delve-start-class session (delve-selected-class session))))

(defun delve-inventory-action-visible-p (session action)
  (case action
    (:ration (plusp (delve-state session "rations" 0)))
    (:scroll (plusp (delve-state session "scrolls" 0)))
    (t t)))

(defun delve-inventory-actions (session)
  (remove-if-not (lambda (action)
                   (delve-inventory-action-visible-p session action))
                 (coerce *delve-inventory-options* 'list)))

(defun delve-selected-inventory-action (session)
  (let ((actions (delve-inventory-actions session)))
    (nth (mod (delve-state session "inventory-index" 0)
              (length actions))
         actions)))

(defun delve-close-inventory (session)
  (setf (delve-state session "phase") :crawl
        (delve-state session "inventory-index") 0)
  (delve-sound session :menu-sound 0.24))

(defun delve-use-inventory-action (session action)
  (case action
    (:ration
     (when (plusp (delve-state session "rations" 0))
       (decf (delve-state session "rations"))
       (setf (delve-state session "hp")
             (min (delve-max-hp session)
                  (+ (delve-current-hp session) 2)))
       (delve-sound session :pickup-sound 0.42)
       (delve-close-inventory session)))
    (:scroll
     (when (plusp (delve-state session "scrolls" 0))
       (decf (delve-state session "scrolls"))
       (setf (delve-state session "mapped") t)
       (delve-sound session :pickup-sound 0.42)
       (delve-close-inventory session)))
    (t
     (delve-close-inventory session))))

(defun update-delve-inventory-menu (session)
  (let ((actions (delve-inventory-actions session))
        (direction (delve-menu-direction)))
    (when direction
      (setf (delve-state session "inventory-index")
            (mod (+ (delve-state session "inventory-index" 0)
                    direction)
                 (length actions)))
      (delve-sound session :menu-sound 0.24))
    (cond
      ((is-key-pressed-p +key-i+)
       (delve-close-inventory session))
      ((confirm-pressed-p)
       (delve-use-inventory-action
        session
        (delve-selected-inventory-action session))))))

(defun update-delve-crawl (session node)
  (cond
    ((or (is-key-pressed-p +key-i+)
         (is-key-pressed-p +key-tab+))
     (setf (delve-state session "phase") :inventory)
     (delve-sound session :menu-sound 0.24))
    (t
     (multiple-value-bind (dx dy) (delve-step-input)
       (when dx
         (delve-take-step session node dx dy))))))

(defmethod minigame-session-update ((session rogue-delve-session) node dt)
  (declare (ignore dt))
  (case (delve-state session "phase" :class)
    (:class
     (update-delve-class-menu session))
    (:inventory
     (update-delve-inventory-menu session))
    (t
     (update-delve-crawl session node))))

(register-minigame-session-kind :rogue-delve 'rogue-delve-session)
