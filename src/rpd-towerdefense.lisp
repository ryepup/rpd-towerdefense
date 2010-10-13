;;; -*- mode: lisp; indent-tabs: nil -*-

(in-package :rpd-towerdefense)

(defun simulate (board turns)
  (iterate
   (for turn from 0 to turns)
   (iterate
     (for piece in (pieces board))
     (when-let ((plan (plan piece)))
       (collect (list piece plan) into plans))
     (finally (dolist (pp plans)
		(apply #'act pp))))))

(defun test (&optional (turns 1))
  (let ((b (parse-map *simple-map*)))
    (simulate b turns)
    b))
