(in-package #:rpd-towerdefense-tests)

(define-test refinery
  (let ((sim (new-game 10 10))
	(ref (make-instance 'refinery :location (make-location 5 5))))
    (assert-eq 0 (mass *game-state*))
    (activate sim ref)
    (simulation-step sim)
    (assert-eq (income-rate ref) (mass *game-state*))
    (simulation-step sim)
    (assert-eq (income-rate ref) (mass *game-state*))
    (simulate sim :until (1- (cooldown ref)))
    (assert-eq (* 2 (income-rate ref)) (mass *game-state*))
    ))
  

