(require 'treesit)
(require 'eglot)
(require 'project)

;; --- Regras de Indentação Específicas (Hooks) ---
(dolist (mode '(js-ts-mode-hook typescript-ts-mode-hook html-mode-hook lua-mode-hook json-ts-mode-hook))
  (add-hook mode (lambda () (setq-local tab-width 2 indent-tabs-mode nil))))

(dolist (mode '(go-ts-mode-hook makefile-mode-hook))
  (add-hook mode (lambda () (setq-local tab-width 4 indent-tabs-mode t))))

(custom-set-variables
 ;; --- Core & Encoding ---
 '(current-language-environment "UTF-8")
 '(inhibit-startup-screen t)
 '(initial-scratch-message nil)
 '(ring-bell-function 'ignore)
 '(vc-follow-symlinks t)
 ;; --- UI Limpa ---
 '(menu-bar-mode nil)
 '(tool-bar-mode nil)
 '(scroll-bar-mode nil)
 '(use-short-answers t)
 '(global-display-line-numbers-mode t)
 '(display-line-numbers-type 'relative)
 ;; --- Segurança & Arquivos ---
 '(make-backup-files nil)
 '(create-lockfiles nil)
 ;; --- Visual ---
 '(custom-enabled-themes '(wombat))
 '(default-frame-alist '((width . 87) (height . 29)))
 '(font-lock-maximum-decoration t)
 '(column-number-mode t)
 ;; --- Indentação Global ---
 '(c-default-style "user")
 '(indent-tabs-mode nil)
 '(tab-width 4)
 ;; --- UX & Navegação ---
 '(fido-vertical-mode t)
 '(which-key-mode t)
 '(pixel-scroll-precision-mode t)
 '(touch-screen-mode t)
 '(context-menu-mode t)
 '(winner-mode t)
 '(electric-pair-mode t)
 '(xterm-mouse-mode t)
 '(editorconfig-mode t)
 ;; --- Histórico ---
 '(savehist-mode t)
 '(recentf-mode t)
 '(save-place-mode t)
 ;; --- Dired ---
 '(dired-listing-switches "-agho --group-directories-first")
 '(dired-dwim-target t)
 '(dired-kill-when-opening-new-dired-buffer t)
 ;; --- IDE Settings ---
 '(eglot-autoshutdown t)
 '(eglot-stay-out-of '(font-lock))
 '(treesit-font-lock-level 4)
 '(tab-always-indent 'complete)
 '(major-mode-remap-alist
   '((c-mode . c-ts-mode)
     (python-mode . python-ts-mode)
     (js-mode . js-ts-mode)
     (typescript-mode . typescript-ts-mode)
     (json-mode . json-ts-mode)
     (go-mode . go-ts-mode)
     (rust-mode . rust-ts-mode)
     (sh-mode . bash-ts-mode)
     (yaml-mode . yaml-ts-mode))))

(custom-set-faces
 '(default ((t (:family "JetBrainsMono NF" :foundry "outline" :slant normal :weight regular :height 120 :width normal))))
 '(variable-pitch ((t (:family "Sans Serif" :height 120)))))

(windmove-default-keybindings)
