(defpackage #:immortal-coil
  (:use #:cl
        #:claylib)
  (:export #:main))

(in-package #:immortal-coil)

(defconstant +virtual-width+ 800)
(defconstant +virtual-height+ 600)
(defconstant +particle-size+ 2)

(defparameter *characters-per-second* 18.0)
(defparameter *fade-seconds* 0.5)
(defparameter *particle-count* 8)

(defvar *nodes* (make-hash-table :test #'equal))
(defvar *state* nil)
(defvar *type-click-assets* nil)
(defvar *type-click-sounds* #())
(defvar *type-click-index* 0)
(defvar *choice-switch-asset* nil)
(defvar *choice-switch-sound* nil)
(defvar *particles* #())

(defstruct choice
  label
  target)

(defstruct node
  id
  kind
  text
  next
  choices)

(defstruct play-state
  current-id
  elapsed
  visible-count
  selected-index)

(defstruct particle
  x
  y
  vx
  vy
  wobble-phase
  wobble-speed
  wobble-strength
  age
  ttl
  alpha)

(defun reset-nodes ()
  (clrhash *nodes*))

(defun add-node (node)
  (setf (gethash (node-id node) *nodes*) node))

(defun find-node (id)
  (or (gethash id *nodes*)
      (error "Unknown story node: ~a" id)))

(defun add-opening-nodes ()
  (reset-nodes)
  (add-node (make-node :id "base/awake"
                       :kind :text
                       :text "you awake in a strange world..."
                       :next "base/feel"))
  (add-node (make-node :id "base/feel"
                       :kind :text
                       :text "or at least that's how you feel..."
                       :next "base/exit-bed"))
  (add-node (make-node :id "base/exit-bed"
                       :kind :choice
                       :text "exit bed?"
                       :choices (vector
                                 (make-choice
                                  :label "yes"
                                  :target "base/exited-bed")
                                 (make-choice
                                  :label "no"
                                  :target "base/sleep"))))
  (add-node (make-node :id "base/exited-bed"
                       :kind :text
                       :text "you exited the bed, nothing of interest happened..."))
  (add-node (make-node :id "base/sleep"
                       :kind :text
                       :text "you rolled over and went back to sleep, nothing of interest happened...")))

(defun reset-play-state (&optional (id "base/awake"))
  (setf *state* (make-play-state :current-id id
                                 :elapsed 0.0
                                 :visible-count 0
                                 :selected-index 0)))

(defun current-node ()
  (find-node (play-state-current-id *state*)))

(defun story-text-visible-p (node)
  (>= (play-state-visible-count *state*)
      (length (node-text node))))

(defun jump-to-node (id)
  (setf (play-state-current-id *state*) id
        (play-state-elapsed *state*) 0.0
        (play-state-visible-count *state*) 0
        (play-state-selected-index *state*) 0))

(defun clamp01 (value)
  (min 1.0 (max 0.0 value)))

(defun cubic-in (value)
  (let ((x (clamp01 value)))
    (* x x x)))

(defun random-float (min max)
  (+ min
     (* (- max min)
        (/ (get-random-value 0 10000) 10000.0))))

(defun current-alpha ()
  (round (* 255 (cubic-in (/ (play-state-elapsed *state*) *fade-seconds*)))))

(defun draw-text-at (text x y size color)
  (claylib/ll:draw-text text
                        (round x)
                        (round y)
                        size
                        (claylib::c-ptr color)))

(defun draw-centered-text (text center-x center-y size color)
  (let* ((width (measure-text text size))
         (x (- center-x (/ width 2)))
         (y (- center-y (/ size 2))))
    (draw-text-at text x y size color)
    (values x y width)))

(defun draw-cursor (x y width size color)
  (when (< (mod (floor (* 60 (get-time))) 70) 35)
    (claylib/ll:draw-rectangle (round (+ x width 6))
                               (round y)
                               (round (/ size 2))
                               size
                               (claylib::c-ptr color))))

(defun reset-particle (particle &key initial-p)
  (let ((ttl (random-float 80.0 120.0)))
    (setf (particle-x particle) (random-float 20.0 780.0)
          (particle-y particle) (if initial-p
                                    (random-float -20.0 700.0)
                                    (random-float 610.0 740.0))
          (particle-vx particle) (random-float -3.0 3.0)
          (particle-vy particle) (random-float -20.0 -12.0)
          (particle-wobble-phase particle) (random-float 0.0 (* 2 pi))
          (particle-wobble-speed particle) (random-float 0.6 1.5)
          (particle-wobble-strength particle) (random-float 8.0 20.0)
          (particle-age particle) (if initial-p
                                      (random-float 0.0 ttl)
                                      0.0)
          (particle-ttl particle) ttl
          (particle-alpha particle) (get-random-value 100 220)))
  particle)

(defun current-particle-count ()
  (max 0 (round *particle-count*)))

(defun resize-particles (count)
  (let ((old-particles *particles*)
        (new-particles (make-array count)))
    (loop for i below count
          do (setf (aref new-particles i)
                   (if (< i (length old-particles))
                       (aref old-particles i)
                       (reset-particle (make-particle) :initial-p t))))
    (setf *particles* new-particles)))

(defun reset-particles ()
  (let ((count (current-particle-count)))
    (setf *particles* (make-array count))
    (loop for i below count
          do (setf (aref *particles* i)
                   (reset-particle (make-particle) :initial-p t)))))

(defun ensure-particle-count ()
  (let ((count (current-particle-count)))
    (unless (= (length *particles*) count)
      (resize-particles count))))

(defun update-particle (particle dt)
  (incf (particle-age particle) dt)
  (if (or (< (particle-y particle) -120)
          (< (particle-x particle) -30)
          (> (particle-x particle) (+ +virtual-width+ 30)))
      (reset-particle particle)
      (progn
        (incf (particle-wobble-phase particle)
              (* (particle-wobble-speed particle) dt))
        (incf (particle-x particle)
              (* (+ (particle-vx particle)
                    (* (particle-wobble-strength particle)
                       (sin (particle-wobble-phase particle))))
                 dt))
        (incf (particle-y particle) (* (particle-vy particle) dt)))))

(defun update-particles (dt)
  (ensure-particle-count)
  (loop for particle across *particles*
        do (update-particle particle dt)))

(defun current-monitor-size ()
  (let ((monitor (get-current-monitor)))
    (values (get-monitor-width monitor)
            (get-monitor-height monitor))))

(defun enter-fullscreen ()
  (multiple-value-bind (width height)
      (current-monitor-size)
    (set-window-size width height)
    (toggle-fullscreen)))

(defun exit-fullscreen ()
  (toggle-fullscreen)
  (set-window-size +virtual-width+ +virtual-height+))

(defun toggle-game-fullscreen ()
  (if (is-window-fullscreen-p)
      (exit-fullscreen)
      (enter-fullscreen)))

(defun update-window-controls ()
  (when (is-key-pressed-p +key-f+)
    (toggle-game-fullscreen)))

(defun particle-visible-alpha (particle)
  (round (* (particle-alpha particle)
            (clamp01 (/ (particle-age particle) 0.8)))))

(defun draw-particle (particle)
  (let ((alpha (particle-visible-alpha particle)))
    (when (plusp alpha)
      (claylib/ll:draw-rectangle (round (particle-x particle))
                                 (round (particle-y particle))
                                 +particle-size+
                                 +particle-size+
                                 (claylib::c-ptr
                                  (make-color 255 255 255 alpha))))))

(defun draw-particles ()
  (loop for particle across *particles*
        do (draw-particle particle)))

(defun visible-node-text (node)
  (subseq (node-text node)
          0
          (min (play-state-visible-count *state*)
               (length (node-text node)))))

(defun type-click-paths ()
  (loop for i from 1 to 8
        for path = (asdf:system-relative-pathname
                    :immortal-coil
                    (format nil "assets/audio/typewriter~d.wav" i))
        when (probe-file path)
          collect path))

(defun load-type-clicks ()
  (setf *type-click-assets*
        (mapcar #'(lambda (path)
                    (make-sound-asset path :load-now t))
                (type-click-paths))
        *type-click-sounds*
        (coerce (mapcar #'asset *type-click-assets*) 'vector)
        *type-click-index*
        0)
  (loop for sound across *type-click-sounds*
        do (setf (volume sound) 0.18)))

(defun load-choice-switch ()
  (let ((path (asdf:system-relative-pathname
               :immortal-coil
               "assets/audio/choice-switch.wav")))
    (when (probe-file path)
      (setf *choice-switch-asset* (make-sound-asset path :load-now t)
            *choice-switch-sound* (asset *choice-switch-asset*))
      (setf (volume *choice-switch-sound*) 0.16))))

(defun next-type-click ()
  (unless (zerop (length *type-click-sounds*))
    (let ((sound (aref *type-click-sounds* *type-click-index*)))
      (setf *type-click-index*
            (mod (1+ *type-click-index*)
                 (length *type-click-sounds*)))
      sound)))

(defun play-type-click (text old-count new-count)
  (when (and (> new-count old-count)
             (find-if-not #'(lambda (char) (member char '(#\Space #\Tab #\Newline)))
                          text
                          :start old-count
                          :end new-count))
    (let ((sound (next-type-click)))
      (when sound
        (setf (pitch sound)
              (+ 0.92 (/ (get-random-value 0 16) 100.0)))
        (claylib/ll:play-sound (claylib::c-ptr sound))))))

(defun play-choice-switch ()
  (when *choice-switch-sound*
    (setf (pitch *choice-switch-sound*)
          (+ 0.98 (/ (get-random-value 0 8) 100.0)))
    (claylib/ll:play-sound (claylib::c-ptr *choice-switch-sound*))))

(defun choice-switch-pressed-p ()
  (or (is-key-pressed-p +key-left+)
      (is-key-pressed-p +key-right+)))

(defun advance-typewriter (node)
  (let* ((old-count (play-state-visible-count *state*))
         (new-count (min (length (node-text node))
                         (floor (* (play-state-elapsed *state*)
                                   *characters-per-second*)))))
    (when (> new-count old-count)
      (setf (play-state-visible-count *state*) new-count)
      (play-type-click (node-text node) old-count new-count))))

(defun skip-typewriter (node)
  (setf (play-state-visible-count *state*) (length (node-text node))))

(defun update-text-node (node)
  (cond
    ((not (story-text-visible-p node))
     (when (is-key-pressed-p +key-space+)
       (skip-typewriter node)))
    ((and (node-next node)
          (is-key-pressed-p +key-space+))
     (jump-to-node (node-next node)))))

(defun update-choice-node (node)
  (cond
    ((not (story-text-visible-p node))
     (when (is-key-pressed-p +key-space+)
       (skip-typewriter node)))
    (t
     (let ((choice-count (length (node-choices node))))
       (when (and (> choice-count 1)
                  (choice-switch-pressed-p))
         (setf (play-state-selected-index *state*)
               (mod (1+ (play-state-selected-index *state*))
                    choice-count))
         (play-choice-switch))
       (when (is-key-pressed-p +key-space+)
         (jump-to-node
          (choice-target (aref (node-choices node)
                               (play-state-selected-index *state*)))))))))

(defun update-game ()
  (let ((dt (get-frame-time)))
    (update-particles dt)
    (incf (play-state-elapsed *state*) dt)
    (let ((node (current-node)))
      (advance-typewriter node)
      (case (node-kind node)
        (:choice (update-choice-node node))
        (t (update-text-node node))))))

(defun draw-opening-text-node (node)
  (let* ((size 20)
         (color (make-color 255 255 255 (current-alpha)))
         (text (visible-node-text node)))
    (multiple-value-bind (x y width)
        (draw-centered-text text 400 300 size color)
      (draw-cursor x y width size color))))

(defun draw-choice-option (choice x y selected-p color)
  (let ((size 20))
    (draw-text-at (choice-label choice) x y size color)
    (when selected-p
      (claylib/ll:draw-rectangle (round x)
                                 (+ y size 3)
                                 (measure-text (choice-label choice) size)
                                 4
                                 (claylib::c-ptr color)))))

(defun draw-choice-node (node)
  (let* ((size 20)
         (color (make-color 255 255 255 (current-alpha)))
         (text (visible-node-text node)))
    (multiple-value-bind (x y width)
        (draw-centered-text text 400 200 size color)
      (draw-cursor x y width size color))
    (loop for choice across (node-choices node)
          for i from 0
          for x in '(200 600)
          do (draw-choice-option choice
                                 x
                                 450
                                 (= i (play-state-selected-index *state*))
                                 color))))

(defun draw-game ()
  (clear-background :color +black+)
  (draw-particles)
  (case (node-kind (current-node))
    (:choice (draw-choice-node (current-node)))
    (t (draw-opening-text-node (current-node)))))

(defun load-crt-shader ()
  (make-shader-asset
   :fspath (asdf:system-relative-pathname
            :immortal-coil
            "assets/shaders/crt.fs")
   :load-now t))

(defun configure-target-texture (target)
  (setf (filter (texture target)) +texture-filter-point+
        (source (texture target))
        (make-instance 'rl-rectangle
                       :x 0
                       :y 0
                       :width (width (texture target))
                       :height (- (height (texture target))))
        (origin (texture target)) (make-vector2 0 0)
        (rot (texture target)) 0.0
        (tint (texture target)) +white+))

(defun configure-target-destination (target)
  (let* ((screen-width (get-screen-width))
         (screen-height (get-screen-height))
         (scale (min (/ (float screen-width 1.0) +virtual-width+)
                     (/ (float screen-height 1.0) +virtual-height+)))
         (target-width (* +virtual-width+ scale))
         (target-height (* +virtual-height+ scale)))
    (setf (dest (texture target))
          (make-instance 'rl-rectangle
                         :x (/ (- screen-width target-width) 2)
                         :y (/ (- screen-height target-height) 2)
                         :width target-width
                         :height target-height))))

(defun draw-target (target shader)
  (with-drawing (:bgcolor +black+)
    (if shader
        (progn
          (claylib/ll:begin-shader-mode (claylib::c-ptr shader))
          (draw-object (texture target))
          (claylib/ll:end-shader-mode))
        (draw-object (texture target)))))

(defun setup-game ()
  (add-opening-nodes)
  (reset-play-state)
  (reset-particles)
  (load-type-clicks)
  (load-choice-switch))

(defun main ()
  (with-window (:width +virtual-width+
                :height +virtual-height+
                :title "mag's Game"
                :fps 60)
    (let ((target (load-render-texture +virtual-width+ +virtual-height+))
          (shader-asset (load-crt-shader)))
      (configure-target-texture target)
      (setup-game)
      (do-game-loop (:livesupport t)
        (update-window-controls)
        (update-game)
        (with-texture-mode (target :clear +black+)
          (draw-game))
        (configure-target-destination target)
        (draw-target target (asset shader-asset))))))
