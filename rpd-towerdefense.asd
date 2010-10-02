;;; -*- mode: lisp; indent-tabs: nil -*-

(defsystem :rpd-towerdefense
  :serial t
  ;; add new files to this list:
  :components ((:file "package") (:file "rpd-towerdefense"))
  :depends-on (#+nil :cl-ppcre))
