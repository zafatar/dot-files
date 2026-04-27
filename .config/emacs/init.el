;;; -*- lexical-binding: t; -*-
(require 'org)
(org-babel-load-file
 (expand-file-name "config.org" user-emacs-directory))

(defconst zafatar/default-gc-cons-threshold (* 16 1024 1024)
  "GC threshold restored after startup.")

;; Startup timer
(add-hook 'emacs-startup-hook
          (lambda ()
            ;; Restore conservative GC settings after init for steadier runtime.
            (setq gc-cons-threshold zafatar/default-gc-cons-threshold
                  gc-cons-percentage 0.1)
            (message "Emacs ready in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Check if system is Darwin/macOS
(defun zafatar/macos-p ()
  "Return non-nil when running on macOS."
  (eq system-type 'darwin))

;; -----------
;; USE PACKAGE

;; (require 'package)
;; (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;; (package-initialize)
