(in-package #:immortal-coil)

(defun title-particle-trunk-position (particle phase)
  (let* ((u (/ phase 0.30))
         (eased (smoothstep u))
         (start-y (+ +virtual-height+ 60.0))
         (entry-angle (title-particle-entry-angle particle))
         (radius (title-particle-orbit-radius particle))
         (start-x (+ +menu-start-x+
                     (title-particle-entry-offset particle)))
         (end-x (+ +menu-start-x+ (* (cos entry-angle) radius)))
         (end-y (+ +menu-start-y+ (* (sin entry-angle) radius)))
         (wobble (+ (* 20.0
                       (sin (+ (title-particle-seed particle)
                               (* u 10.0)))
                       (sin (* pi u)))
                    (* (title-particle-branch-side particle)
                       13.0
                       (sin (* pi u))))))
    (values (+ start-x
               (* (- end-x start-x) eased)
               wobble)
            (+ start-y (* (- end-y start-y) eased)))))

(defun title-particle-orbit-delta (particle)
  (+ (- (title-particle-exit-angle particle)
        (title-particle-entry-angle particle))
     (* 2.0 pi (title-particle-orbit-turns particle))))

(defun title-particle-orbit-position (particle phase)
  (let* ((u (/ (- phase 0.30) 0.56))
         (endpoint-fade (sin (* pi u)))
         (angle (+ (title-particle-entry-angle particle)
                   (* (title-particle-orbit-delta particle)
                      (smoothstep u))
                   (* 0.26
                      endpoint-fade
                      (sin (+ (title-particle-seed particle)
                              (* 11.0 pi u))))
                   (* 0.11
                      endpoint-fade
                      (sin (+ (* 1.4 (title-particle-seed particle))
                              (* 21.0 pi u))))))
         (radius (+ (title-particle-orbit-radius particle)
                    (* 24.0
                       endpoint-fade
                       (sin (+ (title-particle-seed particle)
                               (* 9.0 pi u))))
                    (* 13.0
                       endpoint-fade
                       (sin (+ (* 1.7 (title-particle-seed particle))
                               (* 17.0 pi u)))))))
    (values (+ +menu-start-x+
               (* (cos angle) radius))
            (+ +menu-start-y+
               (* (sin angle) radius)))))

(defun title-particle-exit-position (particle)
  (let ((angle (title-particle-exit-angle particle))
        (radius (title-particle-orbit-radius particle)))
    (values (+ +menu-start-x+ (* (cos angle) radius))
            (+ +menu-start-y+ (* (sin angle) radius)))))

(defun title-particle-branch-position (particle phase)
  (multiple-value-bind (start-x start-y)
      (title-particle-exit-position particle)
    (let* ((u (/ (- phase 0.86) 0.14))
           (eased (smoothstep u))
           (side (title-particle-branch-side particle))
           (spread (title-particle-branch-spread particle))
           (curve (title-particle-branch-curve particle))
           (x (+ start-x
                 (* side spread (expt eased 1.18))
                 (* curve eased (- 1.0 eased))
                 (* 12.0
                    (sin (+ (title-particle-seed particle)
                            (* u 11.0))))))
           (y (- start-y (* 470.0 eased))))
      (values x y))))

(defun title-particle-position (particle)
  (let ((phase (title-particle-phase particle)))
    (cond
      ((< phase 0.30)
       (title-particle-trunk-position particle phase))
      ((< phase 0.86)
       (title-particle-orbit-position particle phase))
      (t
       (title-particle-branch-position particle phase)))))
