;;; -*- mode: lisp; indent-tabs: nil -*-

(defsystem #:rpd-towerdefense
  :author "Ryan Davis <ryan@mokeys.org>"
  :licence "LGPL (or talk to me)"
  :serial t
  ;; add new files to this list:
  :components ((:module
		:src
		:serial t
		:components
		((:file "package")
;		 (:file "coroutine")
;		 (:file "map")
		 (:file "towers")
;		 (:file "render")
		 (:file "rpd-towerdefense")
		 )))
  :depends-on (#:iterate #:alexandria #:lispbuilder-sdl
			 #:rpd-simulation))

(asdf:defsystem #:rpd-towerdefense-tests
  :serial t
  :depends-on (#:rpd-towerdefense #:lisp-unit #:cl-log)
  :components ((:module
		:tests
		:serial t
		:components ((:file "package")))))