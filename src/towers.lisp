(in-package :rpd-towerdefense)

(defclass tower (game-piece)
  ())

(defclass refinery (tower) ())
(defmethod parse-map-square ((obj (eql :r)))
  (make-instance 'refinery))