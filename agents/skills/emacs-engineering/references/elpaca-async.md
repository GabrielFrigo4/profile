# ⚡ Gestão Assíncrona e Declarativa de Pacotes: Elpaca

O gerenciador síncrono legado `package.el` bloqueia o loop de eventos durante downloads e compilação. Em configurações modernas, adota-se o **Elpaca** como gerenciador assíncrono declarativo.

---

## 🚀 Desativação de Pacotes Legados

No arquivo `early-init.el`, desative a inicialização síncrona do `package.el`:

```elisp
;;; -*- lexical-binding: t -*-

(setq package-enable-at-startup nil)
```

---

## 📦 Bootstrap Hermético do Elpaca

Mantenha o bootstrap isolado (ex.: `etc/init/init-elpaca.el`), redirecionando caches para `var/cache/elpaca/` com auto-cura na primeira execução:

```elisp
;;; -*- lexical-binding: t -*-

(defvar elpaca-directory (expand-file-name "var/cache/elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))

(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo t))))
  (let ((reserved (plist-get order :build)))
    (unless (file-exists-p build)
      (make-directory build t)
      (elpaca--queue-build repo build reserved)))
  (require 'elpaca)
  (elpaca-post-init))
```

---

## 🎯 Integração Declarativa com `use-package`

```elisp
(elpaca elpaca-use-package
  (elpaca-use-package-mode))

(use-package modus-themes
  :ensure t
  :config
  (load-theme 'modus-vivendi t))

(use-package eglot
  :ensure nil
  :hook ((c-ts-mode . eglot-ensure)))
```

---

## 🛡️ Sincronização Controlada em Modo Batch

Em scripts de CI ou batch que precisem aguardar a fila antes de prosseguir:

```elisp
(elpaca-wait)
```
