;;; init.el --- Configuração Leve e Portável -*- lexical-binding: t; -*-

;; ----------------------------------------------------------------
;; 1. Higiene e Ambiente
;; ----------------------------------------------------------------

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror 'nomessage)

(set-language-environment "UTF-8")

(setopt
 ring-bell-function #'ignore
 use-short-answers t
 vc-follow-symlinks t
 make-backup-files nil
 create-lockfiles nil)

;; ----------------------------------------------------------------
;; 2. Visual, Tipografia e Navegação
;; ----------------------------------------------------------------

(setopt
 display-line-numbers-type 'relative
 column-number-mode t
 pixel-scroll-precision-mode t
 touch-screen-mode t
 context-menu-mode t
 winner-mode t
 xterm-mouse-mode t)

(global-display-line-numbers-mode 1)
(windmove-default-keybindings)

(when (display-graphic-p)
  (set-face-attribute 'default nil :family "JetBrainsMono NF" :height 120 :weight 'regular)
  (set-face-attribute 'variable-pitch nil :family "Sans Serif" :height 120))

(load-theme 'wombat t)

;; ----------------------------------------------------------------
;; 3. Minibuffer, Histórico e Usabilidade
;; ----------------------------------------------------------------

(setopt
 fido-vertical-mode t
 which-key-mode t
 savehist-mode t
 recentf-mode t
 save-place-mode t
 electric-pair-mode t
 editorconfig-mode t)

(setopt
 dired-listing-switches "-agho --group-directories-first"
 dired-dwim-target t
 dired-kill-when-opening-new-dired-buffer t)

;; ----------------------------------------------------------------
;; 4. Edição, Indentação e Estilos
;; ----------------------------------------------------------------

(setopt
 indent-tabs-mode nil
 tab-width 4
 tab-always-indent 'complete
 c-default-style "user")

(dolist (hook '(js-ts-mode-hook
                typescript-ts-mode-hook
                html-mode-hook
                lua-mode-hook
                json-ts-mode-hook))
  (add-hook hook (lambda ()
                   (setq-local tab-width 2
                               indent-tabs-mode nil))))

(dolist (hook '(go-ts-mode-hook makefile-mode-hook))
  (add-hook hook (lambda ()
                   (setq-local tab-width 4
                               indent-tabs-mode t))))

;; ----------------------------------------------------------------
;; 5. Tree-sitter & LSP (Eglot)
;; ----------------------------------------------------------------

(setopt
 treesit-font-lock-level 4
 eglot-autoshutdown t
 eglot-stay-out-of '(font-lock)
 major-mode-remap-alist
 '((c-mode          . c-ts-mode)
   (python-mode     . python-ts-mode)
   (js-mode         . js-ts-mode)
   (typescript-mode . typescript-ts-mode)
   (json-mode       . json-ts-mode)
   (go-mode         . go-ts-mode)
   (rust-mode       . rust-ts-mode)
   (sh-mode         . bash-ts-mode)
   (yaml-mode       . yaml-ts-mode)))
