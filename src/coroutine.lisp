;;; -*- mode: lisp; indent-tabs: nil -*-
(in-package :rpd-towerdefense)

(defvar *log* nil)
(defvar *log-lck* (bordeaux-threads:make-lock))

(defun logg (msg &rest args)
  (bordeaux-threads:with-lock-held (*log-lck*)
    (push
     (list (get-universal-time)
	   (bordeaux-threads:current-thread)
	   (apply #'format (append (list nil msg) args)))
     *log*)))


(defmacro make-coroutine ((&key (coroutine-done-value :done))
			  &body body)
  (alexandria:with-gensyms ((yield-cv "there a value ready for pickup")
			    (run-cv "coroutine should run")
			    (lock "lock")
			    (val "shared memory")
			    (yield-result "return value of yield in the corouting")
			    (thrfn "thread function body"))
    `(let* ((,yield-cv (bordeaux-threads:make-condition-variable
			 :name "yield"))
	    (,run-cv (bordeaux-threads:make-condition-variable
			 :name "run"))
	    (,lock (bordeaux-threads:make-lock "coroutine lock"))
	    ,val ,yield-result
	    (,thrfn (lambda ()	  
		      (flet ((yield (&optional n)
			       (setf ,val n)
			       ;;signal that a value is ready for pickup
			       (bordeaux-threads:condition-notify ,yield-cv)
			       ;;wait for a chance to run
			       (bordeaux-threads:condition-wait ,run-cv ,lock)
			       ,yield-result))
			(bordeaux-threads:acquire-lock ,lock)
			,@body
			(yield ,coroutine-done-value)
			(bordeaux-threads:release-lock ,lock)))))

       ;;function to pull values from the coroutine
       (let ((alive-p T) thr)
	 (lambda (&key (send nil send-suppliedp))
	   (when alive-p
	     (bordeaux-threads:with-lock-held (,lock)
	       (if thr
		   (bordeaux-threads:condition-notify ,run-cv)
		   (setf thr (bordeaux-threads:make-thread
			      ,thrfn :name "coroutine")))
	       
	       (bordeaux-threads:condition-wait ,yield-cv ,lock)

	       (setf ,yield-result
		     (if send-suppliedp send ,val))

	       (when (eql ,coroutine-done-value ,val)
		 (setf alive-p nil)
		 (bordeaux-threads:condition-notify ,run-cv))
	       ))
	   ,val)))))

(defun coroutine-test ()
  (let ((cor (make-coroutine (:coroutine-done-value :done)
	       (yield 1)
	       (yield)
	       (yield 4)))
	(cor2 (make-coroutine ()
		(yield (yield (yield 4)))
		)))
    
    (assert (eql 1 (funcall cor)) )
    (assert (null (funcall cor)))
    (assert (eql 4 (funcall cor)))
    (assert (eql :done (funcall cor)))
    (assert (eql :done (funcall cor)))

    (assert (eql 4 (funcall cor2)))
    (assert (eql 4 (funcall cor2 :send 6)))
    (assert (eql 6 (funcall cor2)))
    (assert (eql :done (funcall cor2)))
    
    ))

(defmacro make-coroutine ((&key (coroutine-done-value :done)) &body body)
  (alexandria:with-gensyms ((thrfn "thread body")
			    (c "channel"))
    `(let* ((,c (make-instance 'chanl:bounded-channel))
	    (,thrfn (lambda ()	  
		      (flet ((yield (&optional n)
			       (chanl:send ,c n)))
			,@body
			(yield ,coroutine-done-value)))))
       (let ((alive-p T) val thr)
       (lambda ()
	 (unless thr
	   (setf thr (chanl:pcall ,thrfn :name "coroutine")))
	 (when alive-p 
	   (setf val (chanl:recv ,c))
	   (when (eq ,coroutine-done-value val)
	     (setf alive-p nil)))
	 val)))))