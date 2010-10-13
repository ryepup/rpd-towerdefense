;;; -*- mode: lisp; indent-tabs: nil -*-

(in-package :rpd-towerdefense)

(defun simulate (board turns)
  (iterate
   (for turn from 0 to turns)
   (when *renderer* (render-turn *renderer* turn))
   (iterate
     (for piece in (pieces board))
     (when-let ((plan (plan piece)))
       (collect (list piece plan) into plans))
     (finally (dolist (pp plans)
		(when *renderer*
		  (apply #'render-plan *renderer* pp))
		(apply #'act pp))))))

(defun test (&optional (turns 1000))
  (let ((b (parse-map *simple-map*)))
    (with-renderer ('sdl-renderer :width 400 :height 400
				  :board b)
      (simulate b turns))
    b))
