(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(setq fill-column 78)
(setq auto-fill-mode t)

(defalias 'perl-mode 'cperl-mode)

(setq cperl-indent-level 2)
(setq cperl-continued-statement-offset 2)
(setq cperl-brace-offset -2)
(setq cperl-label-offset -2)
(setq cperl-indent-parens-as-block t)
(setq cperl-close-paren-offset -2)
(setq cperl-tab-always-indent t)
(setq cperl-highlight-variables-indiscriminately t)

(setq cperl-electric-keywords t) ;; expands for keywords such as
;; foreach, while, etc...

(setq cperl-electric-parens t) ;; auto-parens

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cperl-array-face ((t (:foreground "green" :weight bold))))
 '(cperl-hash-face ((t (:foreground "Red" :slant italic :weight bold)))))

;; Remove trailing whitespace before saving
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(put 'upcase-region 'disabled nil)

(defun perl-boilerplate ()
  (if (not (file-exists-p (buffer-file-name (current-buffer))))
      (cond
       ((string-match "\.pl$" buffer-file-name)
	(insert
	 "#!/usr/bin/perl\n\nuse warnings;\nuse strict;\n\n\n1;\n\n__END__\n")
       	(backward-char 14))
       ((string-match "\\([^/]*\\)\.pm$" buffer-file-name)
	(insert
	 (concat "package " (match-string 1 buffer-file-name)
		 ";\n\nuse warnings;\nuse strict;\n\n1;\n"))
	(backward-char 4)))))

(add-hook 'cperl-mode-hook 'perl-boilerplate)

;; to move around with Shift+arrows
(windmove-default-keybindings)
(setq windmove-wrap-around t)

(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'load-path "~/.emacs.d/org-mode/lisp")
(require 'auto-complete)
(require 'auto-complete-config)
;; (ac-config-default)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (doom-themes pipenv ##))))

;; auto-complete for python
(require 'jedi)
(setq jedi:setup-keys t)
