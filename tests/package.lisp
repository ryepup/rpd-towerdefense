
(defpackage #:rpd-towerdefense-tests
    (:use #:cl #:lisp-unit #:iterate #:rpd-towerdefense
	  #:rpd-simulation))

;; import ALL :rpd-towerdefense symbols
(with-package-iterator (sym '(:rpd-towerdefense) :internal)
  (iter (multiple-value-bind (more? symbol accessibility pkg) (sym)
          (declare (ignore accessibility))
          (when (eql (find-package :rpd-towerdefense) pkg)
            (ignore-errors
	      (unintern symbol :rpd-towerdefense-tests)
	      (import (list symbol) :rpd-towerdefense-tests)))
          (while more?))))