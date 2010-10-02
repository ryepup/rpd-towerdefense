;;; -*- mode: lisp; indent-tabs: nil -*-

(defsystem :rpd-towerdefense
  :author "Ryan Davis <ryan@mokeys.org>"
  :licence "LGPL (or talk to me)"
  :serial t
  ;; add new files to this list:
  :components 
  ((:module
    :src
    :serial t
    :components
    ((:file "package") 
     (:file "rpd-towerdefense"))))
  :depends-on (#:iterate #:alexandria #:lispbuilder-sdl))
