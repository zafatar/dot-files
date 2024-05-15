(require 'org)
(org-babel-load-file
    (expand-file-name "config.org" 
                      user-emacs-directory))


;;; -*- lexical-binding: t -*-
(setq gc-cons-threshold (* 50 1000 1000))

;; Startup timer
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Check if system is Darwin/macOS
(defun is-macos ()
  "Return true if system is darwin-based (Mac OS X)"
  (string-equal system-type "darwin"))

;; -----------
;; USE PACKAGE

;; (require 'package)
;; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;; (package-initialize)
