
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
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

(add-to-list 'load-path "$HOME/.emacs.d/lisp")
(add-to-list 'load-path "$HOME/.emacs.d/org-mode/lisp")
(require 'auto-complete-config)
;; (ac-config-default)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (##))))
