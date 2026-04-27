(setq package-enable-at-startup nil)

;; Keep GC from dominating startup while packages initialize.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Avoid expensive frame resize during initial UI setup.
(setq frame-inhibit-implied-resize t)