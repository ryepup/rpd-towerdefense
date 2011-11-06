;;; -*- mode: lisp; indent-tabs: nil -*-

(defpackage :rpd-towerdefense
  (:use #:cl #:iterate #:alexandria #:rpd-simulation)
  (:shadowing-import-from #:cl-log #:log-message))

(in-package #:rpd-towerdefense)

(cl-log:defcategory :critical)
(cl-log:defcategory :error   (or :error :critical))
(cl-log:defcategory :warning (or :warning :error))
(cl-log:defcategory :notice  (or :notice :warning))
(cl-log:defcategory :info    (or :info :notice))
(cl-log:defcategory :debug   (or :debug :info))

(setf (cl-log:log-manager) (make-instance 'cl-log:log-manager
					  :message-class 'cl-log:formatted-message))
(cl-log:start-messenger 'cl-log:text-stream-messenger
			:name 'rpd-towerdefense :stream *standard-output*)

(log-message :info "Logging initialized")