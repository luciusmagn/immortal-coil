(in-package #:immortal-coil)

;;; The story tree: a pannable overlay (T) that visualizes the sprawling
;;; shape of the graph. It shows the nodes you have entered (bright),
;;; joined by dotted threads and growing upward from the root. Where your
;;; path split, the off-main branches are revealed (dim) as whole subtrees,
;;; fanning out at every sub-split, one depth-level deeper per move elapsed
;;; since the split. A straight line ahead of the player is never revealed.
;;; A node whose real next is indeterminate because it is computed at
;;; runtime is capped with a dim "?". The whole tree shrinks toward a floor
;;; as it gathers more nodes.

(defvar *tree-open-p* nil)
(defvar *tree-pan-x* 0.0)
(defvar *tree-pan-y* 0.0)
(defvar *tree-model* nil)

(defconstant +tree-x-gap+ 44.0)
(defconstant +tree-y-gap+ 52.0)
(defconstant +tree-base-x+ 140.0)
(defconstant +tree-base-y+ 632.0)
(defconstant +tree-pan-step+ 13.0)
(defconstant +tree-max-nodes+ 2000)
(defconstant +tree-scale-ref+ 45)
(defconstant +tree-min-scale+ 0.4)
(defconstant +tree-bead-visited-radius+ 5.0)
(defconstant +tree-bead-current-radius+ 7.0)

(defparameter *yellow-crown-prefixes*
  '("jrpg/" "carcosa/")
  "Node id prefixes on the King-in-Yellow path. Their tree beads render as a
yellow #ffff00 crown — the one colour in the black-and-white game — so the
path stands out. Game scripts and mods may push their own prefixes here.")

(defun yellow-crown-node-p (id)
  (and (stringp id)
       (some (lambda (prefix)
               (and (<= (length prefix) (length id))
                    (string= id prefix :end1 (length prefix))))
             *yellow-crown-prefixes*)))


;;; Model

(defstruct tree-model
  (root      nil)
  (scale     1.0)
  (ids       nil :type list)
  (children  (make-hash-table :test #'equal))
  (parent    (make-hash-table :test #'equal))
  (depth     (make-hash-table :test #'equal))
  (x         (make-hash-table :test #'equal))
  (size      (make-hash-table :test #'equal))
  (visited   (make-hash-table :test #'equal))
  (questions (make-hash-table :test #'equal)))

(defun tree-node-static-children (id)
  "The static (string) outgoing targets of node ID that exist as nodes.
Function-valued targets are deliberately omitted: their subtree only
appears once it is actually taken and recorded as visited."
  (let ((node (gethash id *nodes*)))
    (when node
      (remove-duplicates
       (loop for target in (append (list (node-next node)
                                         (node-target node)
                                         (node-success-target node)
                                         (node-failure-target node))
                                   (node-minigame-outcomes node)
                                   (map 'list #'choice-target
                                        (node-choices node)))
             when (and (stringp target) (node-exists-p target))
               collect target)
       :test #'equal :from-end t))))

(defun tree-visited-pairs ()
  "Visited (node-id . parent-id) pairs in first-visit order, with a
fallback so old saves and fresh states still render a root."
  (let ((pairs (reverse (and *state* (play-state-visited *state*)))))
    (or pairs
        (let ((id (and *state* (play-state-current-id *state*))))
          (when id (list (cons id nil)))))))

(defun tree-compute-depths (model)
  "BFS from the root over the trunk (visited) children to set the depth
of every visited node."
  (let ((root (tree-model-root model))
        (depth (tree-model-depth model))
        (children (tree-model-children model)))
    (when root
      (setf (gethash root depth) 0)
      (let ((queue (list root)))
        (loop while queue
              for id = (pop queue)
              do (dolist (child (gethash id children))
                   (unless (gethash child depth)
                     (setf (gethash child depth) (1+ (gethash id depth)))
                     (setf queue (nconc queue (list child))))))))))

(defun tree-node-outgoing (node)
  (append (list (node-next node)
                (node-target node)
                (node-success-target node)
                (node-failure-target node))
          (node-minigame-outcomes node)
          (map 'list #'choice-target (node-choices node))))

(defun tree-scale (count)
  "Shrink the tree toward a floor as it gathers more nodes."
  (max +tree-min-scale+
       (min 1.0 (sqrt (/ +tree-scale-ref+ (float (max +tree-scale-ref+ count)))))))

(defun tree-add-question (model id)
  "Cap ID's branch with a dim ? terminator (its next is computed)."
  (let ((q (format nil "?~a" id)))
    (setf (gethash q (tree-model-questions model)) t
          (gethash q (tree-model-parent model)) id
          (gethash q (tree-model-depth model))
          (1+ (gethash id (tree-model-depth model) 0)))
    (push q (gethash id (tree-model-children model)))
    q))

(defun tree-reveal-subtree (model start parent budget revealed count)
  "Grow an off-main branch as a whole SUBTREE, not a single thread: from
START, follow every static continuation, fanning out at each sub-split, to
depth BUDGET (the moves elapsed since the split). Each revealed node whose
real next is computed at runtime is capped with a dim ?. A breadth-first
frontier means every branch advances one level per move. Returns the new
node count."
  (let ((children (tree-model-children model))
        (parents (tree-model-parent model))
        (depth (tree-model-depth model))
        ;; frontier of (node prev steps); steps is depth from the split
        (queue (list (list start parent 1))))
    (loop
      (when (or (null queue) (>= count +tree-max-nodes+))
        (return))
      (destructuring-bind (node prev steps) (pop queue)
        (unless (or (null node)
                    (> steps budget)
                    (gethash node revealed))
          (setf (gethash node revealed) t
                (gethash node parents) prev
                (gethash node depth) (1+ (gethash prev depth 0)))
          (push node (gethash prev children))
          (incf count)
          (let* ((n (gethash node *nodes*))
                 (targets (and n (remove nil (tree-node-outgoing n))))
                 (statics (remove-duplicates (remove-if-not #'stringp targets)
                                             :test #'equal))
                 (dynamic-p (some (lambda (target) (not (stringp target)))
                                  targets)))
            ;; a node with a computed next shows its ? straight away
            (when (and dynamic-p (< count +tree-max-nodes+))
              (tree-add-question model node)
              (incf count))
            ;; expand every static child until the depth budget is spent;
            ;; the frontier left over grows another level next move
            (when (< steps budget)
              (dolist (s statics)
                (unless (gethash s revealed)
                  (setf queue (nconc queue (list (list s node (1+ steps))))))))))))
    count))

(defun tree-compute-sizes (model)
  "Subtree node counts, so the main path (the largest subtree) can be
placed to keep the spine centred."
  (let ((size (tree-model-size model))
        (children (tree-model-children model)))
    (labels ((sz (id)
               (or (gethash id size)
                   (setf (gethash id size)
                         (1+ (loop for child in (gethash id children)
                                   sum (sz child)))))))
      (when (tree-model-root model)
        (sz (tree-model-root model))))))

(defun tree-order-children (model kids depth)
  "Put the largest-subtree child (the main path) at the left end on even
depths and the right end on odd depths, so the spine zig-zags around the
centre instead of drifting to one side."
  (if (<= (length kids) 1)
      kids
      (let* ((size (tree-model-size model))
             (primary (reduce (lambda (a b)
                                (if (>= (gethash a size 0) (gethash b size 0)) a b))
                              kids))
             (rest (remove primary kids :count 1 :test #'equal)))
        (if (evenp depth)
            (cons primary rest)
            (append rest (list primary))))))

(defun tree-layout-x (model id depth counter)
  "Assign each node an x-slot (leaves sequential, parents centred over
their children) and collect ids. DEPTH drives the centring alternation."
  (push id (tree-model-ids model))
  (let ((kids (gethash id (tree-model-children model))))
    (if (null kids)
        (progn
          (setf (gethash id (tree-model-x model)) (car counter))
          (incf (car counter)))
        (let ((ordered (tree-order-children model kids depth)))
          (dolist (child ordered)
            (tree-layout-x model child (1+ depth) counter))
          (setf (gethash id (tree-model-x model))
                (/ (loop for child in ordered
                         sum (gethash child (tree-model-x model)))
                   (length ordered)))))))

(defun build-tree-model ()
  (let* ((model (make-tree-model))
         (pairs (tree-visited-pairs))
         (placed (tree-model-visited model))
         (children (tree-model-children model))
         (parent (tree-model-parent model))
         (index (make-hash-table :test #'equal)))
    ;; trunk: the nodes you entered, parented to where you came from, with
    ;; each one's first-visit order (its "turn") recorded
    (loop for pair in pairs
          for i from 0
          for id = (car pair)
          for par = (cdr pair)
          do (setf (gethash id placed) t
                   (gethash id parent) par
                   (gethash id index) i)
             (when (and par (gethash par placed))
               (push id (gethash par children))))
    (setf (tree-model-root model)
          (or (loop for pair in pairs when (null (cdr pair)) return (car pair))
              (caar pairs)
              *story-start-node*))
    (tree-compute-depths model)
    ;; off-main branches grow one depth-level per turn elapsed since their
    ;; split, fanning out at every sub-split, with computed nexts capped by
    ;; a "?"; a visited node whose own next is computed gets a "?" too
    (let ((revealed (make-hash-table :test #'equal))
          (latest (1- (length pairs)))
          (count (hash-table-count placed)))
      (maphash (lambda (id present)
                 (declare (ignore present))
                 (setf (gethash id revealed) t))
               placed)
      (loop for id being the hash-keys of placed
            for node = (gethash id *nodes*)
            when node
              do (let* ((targets (remove nil (tree-node-outgoing node)))
                        (statics (remove-duplicates
                                  (remove-if-not #'stringp targets)
                                  :test #'equal))
                        (dynamic-p (some (lambda (target) (not (stringp target)))
                                         targets))
                        (directions (+ (length statics) (if dynamic-p 1 0)))
                        (vchildren (gethash id children))
                        (budget (min 40 (1+ (- latest (gethash id index 0))))))
                   (when (>= directions 2)
                     (dolist (target statics)
                       (unless (gethash target revealed)
                         (setf count (tree-reveal-subtree model target id
                                                          budget revealed count)))))
                   (when (and dynamic-p
                              (< count +tree-max-nodes+)
                              (every (lambda (child)
                                       (member child statics :test #'equal))
                                     vchildren))
                     (tree-add-question model id)
                     (incf count)))))
    (maphash (lambda (id kids) (setf (gethash id children) (reverse kids)))
             children)
    (tree-compute-sizes model)
    (let ((root (tree-model-root model)))
      (when root
        (tree-layout-x model root 0 (list 0.0))))
    (setf (tree-model-scale model) (tree-scale (length (tree-model-ids model))))
    model))


;;; Geometry

(defun tree-node-x (model id)
  (+ +tree-base-x+
     (* (gethash id (tree-model-x model) 0.0)
        +tree-x-gap+
        (tree-model-scale model))))

(defun tree-node-y (model id)
  (- +tree-base-y+
     (* (gethash id (tree-model-depth model) 0)
        +tree-y-gap+
        (tree-model-scale model))))

(defun tree-on-screen-p (x y)
  (and (<= -60.0 x (+ +virtual-width+ 60.0))
       (<= -60.0 y (+ +virtual-height+ 60.0))))

(defun center-tree-on-current (model)
  (let ((id (and *state* (play-state-current-id *state*))))
    (if (and id (gethash id (tree-model-x model)))
        (setf *tree-pan-x* (- +virtual-center-x+ (tree-node-x model id))
              *tree-pan-y* (- +virtual-center-y+ (tree-node-y model id)))
        (setf *tree-pan-x* 0.0 *tree-pan-y* 0.0))))


;;; Input

(defun tree-toggle-pressed-p ()
  (and (is-key-pressed-p +key-t+)
       (not (input-node-capturing-text-p))
       (not (journal-open-p))))

(defun open-tree ()
  (setf *tree-open-p* t
        *tree-model* (build-tree-model))
  (center-tree-on-current *tree-model*)
  (play-choice-switch)
  t)

(defun close-tree ()
  (setf *tree-open-p* nil
        *tree-model* nil)
  (play-choice-switch)
  t)

(defun tree-pan ()
  (when (or (is-key-down-p +key-left+) (is-key-down-p +key-a+))
    (incf *tree-pan-x* +tree-pan-step+))
  (when (or (is-key-down-p +key-right+) (is-key-down-p +key-d+))
    (decf *tree-pan-x* +tree-pan-step+))
  (when (or (is-key-down-p +key-up+) (is-key-down-p +key-w+))
    (incf *tree-pan-y* +tree-pan-step+))
  (when (or (is-key-down-p +key-down+) (is-key-down-p +key-s+))
    (decf *tree-pan-y* +tree-pan-step+)))

(defun update-tree-controls ()
  (cond
    (*tree-open-p*
     (cond
       ((or (is-key-pressed-p +key-escape+) (is-key-pressed-p +key-t+))
        (close-tree))
       (t (tree-pan)))
     t)
    ((tree-toggle-pressed-p)
     (open-tree)
     t)
    (t nil)))


;;; Rendering

(defun tree-draw-dotted (x1 y1 x2 y2 alpha)
  (let* ((dx (- x2 x1))
         (dy (- y2 y1))
         (dist (max 1.0 (sqrt (+ (* dx dx) (* dy dy)))))
         (steps (max 1 (floor dist 9.0)))
         (color (make-color 255 255 255 alpha)))
    (loop for i from 1 below steps
          for frac = (/ i (float steps))
          do (claylib/ll:draw-circle (round (+ x1 (* dx frac)))
                                     (round (+ y1 (* dy frac)))
                                     1.5
                                     (claylib::c-ptr color)))))

(defun tree-draw-connectors (model)
  (dolist (id (tree-model-ids model))
    (let ((par (gethash id (tree-model-parent model))))
      (when (and par (gethash par (tree-model-x model)))
        (let ((cx (+ (tree-node-x model id) *tree-pan-x*))
              (cy (+ (tree-node-y model id) *tree-pan-y*))
              (px (+ (tree-node-x model par) *tree-pan-x*))
              (py (+ (tree-node-y model par) *tree-pan-y*)))
          (when (or (tree-on-screen-p cx cy) (tree-on-screen-p px py))
            (tree-draw-dotted px py cx cy
                              (if (gethash id (tree-model-visited model))
                                  150
                                  60))))))))

(defun tree-draw-crown (sx sy r alpha)
  "A small #ffff00 crown centred at SX,SY: a base band and three spikes,
the centre tallest. Drawn with rectangles so it renders reliably at any
tree scale. Marks the King-in-Yellow path, the one colour in the game."
  ;; snap every position to whole pixels off ONE shared integer grid (left, w,
  ;; sw), so the spikes stay flush with the band at any scale — at the big entry
  ;; flash, independent rounding used to leave the prongs a pixel off.
  (let* ((w        (max 4 (round (* r 2.6))))
         (sw       (max 1 (round (/ w 5.0))))
         (left     (round (- sx (/ w 2.0))))
         (bar-top  (round (+ sy (* r 0.2))))
         (bar-h    (max 1 (round (* r 0.85))))
         (spike    (max 1 (round (* r 1.15))))
         (tall     (max 1 (round (* spike 1.3))))
         (cx       (+ left (floor w 2)))
         (color    (yellow-sign-color alpha)))
    (flet ((rect (x y rw rh)
             (claylib/ll:draw-rectangle x y (max 1 rw) (max 1 rh)
                                        (claylib::c-ptr color))))
      (rect left bar-top w bar-h)                            ; base band
      (rect left (- bar-top spike) sw spike)                 ; left point, flush left
      (rect (- cx (floor sw 2)) (- bar-top tall) sw tall)    ; centre point
      (rect (- (+ left w) sw) (- bar-top spike) sw spike)))) ; right point, flush right

(defun tree-draw-beads (model)
  (let ((current (and *state* (play-state-current-id *state*)))
        (scale (tree-model-scale model)))
    (dolist (id (tree-model-ids model))
      (let ((sx      (+ (tree-node-x model id) *tree-pan-x*))
            (sy      (+ (tree-node-y model id) *tree-pan-y*))
            (yellowp (yellow-crown-node-p id)))
        (when (tree-on-screen-p sx sy)
          (cond
            ((gethash id (tree-model-questions model))
             (draw-centered-text "?" sx sy
                                 (max 9 (round (* 17 scale)))
                                 (make-color 255 255 255 95)))
            ((gethash id (tree-model-visited model))
             (let* ((current-p (equal id current))
                    (radius (max 2.0
                                 (* (if current-p
                                        +tree-bead-current-radius+
                                        +tree-bead-visited-radius+)
                                    scale))))
               (cond
                 (yellowp
                  (tree-draw-crown sx sy (* radius 1.15) 255)
                  (when current-p
                    (claylib/ll:draw-circle-lines (round sx) (round sy)
                                                  (max 5.0 (* 11.0 scale))
                                                  (claylib::c-ptr
                                                   (yellow-sign-color 235)))))
                 (t
                  (claylib/ll:draw-circle (round sx) (round sy) radius
                                          (claylib::c-ptr
                                           (make-color 255 255 255 255)))
                  (when current-p
                    (claylib/ll:draw-circle-lines (round sx) (round sy)
                                                  (max 5.0 (* 11.0 scale))
                                                  (claylib::c-ptr
                                                   (make-color 255 255 255 235))))))))
            (t
             ;; an off-main branch you have not taken
             (if yellowp
                 (tree-draw-crown sx sy
                                  (max 2.0 (* +tree-bead-visited-radius+ scale 0.82))
                                  120)
                 (claylib/ll:draw-circle (round sx) (round sy)
                                         (max 2.0 (* +tree-bead-visited-radius+ scale 0.82))
                                         (claylib::c-ptr
                                          (make-color 255 255 255 80)))))))))))

(defun draw-tree-overlay ()
  (when *tree-open-p*
    (let ((model (or *tree-model* (build-tree-model))))
      (claylib/ll:draw-rectangle 0 0 +virtual-width+ +virtual-height+
                                 (claylib::c-ptr (make-color 0 0 0 234)))
      (tree-draw-connectors model)
      (tree-draw-beads model)
      (draw-centered-text "THE COIL"
                          +virtual-center-x+
                          34.0
                          22
                          (make-color 255 255 255 235))
      (draw-text-at "T/ESC CLOSE   WASD/ARROWS PAN   DIM = BRANCH NOT TAKEN   ? = COMPUTED NEXT   CROWN = THE KING"
                    40.0
                    (- +virtual-height+ 34.0)
                    14
                    (make-color 255 255 255 170)))))
