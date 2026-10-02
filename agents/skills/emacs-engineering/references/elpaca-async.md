# ⚡ Gestão Assíncrona e Declarativa de Pacotes: Elpaca

O gerenciador embutido clássico `package.el` opera de forma síncrona, bloqueando a interface e o loop de eventos principal durante compilação de bytecode, downloads de rede e clonagem Git. No Emacs 31+, adota-se o **Elpaca** como gerenciador declarativo e totalmente assíncrono.

---

## 🚀 Desativação de Pacotes Legados

No arquivo `early-init.el`, a infraestrutura síncrona legada deve ser sumariamente desativada:

```elisp
;; early-init.el
;;; -*- lexical-binding: t -*-

(setq package-enable-at-startup nil)
```

---

## 📦 Bootstrap Hermético do Elpaca

O instalador do Elpaca deve residir em arquivo isolado (ex: `etc/init/init-elpaca.el`), garantindo self-healing na primeira execução e congelamento estrito de lockfiles:

```elisp
;;; -*- lexical-binding: t -*-

(defvar elpaca-installer-version 0.10)
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
    (when (<= emacs-major-version 28) (require 'subr-x))
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

O Elpaca suporta nativamente a macro `use-package` por meio da palavra-chave `:elpaca`:

```elisp
;; Habilitar suporte declarativo
(elpaca elpaca-use-package
  (elpaca-use-package-mode))

;; Instalação e configuração de pacote assíncrono
(use-package kanagawa-theme
  :elpaca t
  :config
  (load-theme 'kanagawa-wave t))

;; Pacotes integrados do core NÃO devem ser instalados pelo Elpaca
(use-package eglot
  :elpaca nil
  :hook ((c-ts-mode . eglot-ensure)))
```

---

## 🛡️ Bloqueio e Sincronização Síncrona Controlada

Quando da execução de rotinas em modo batch ou testes de CI, podemos forçar a conclusão de toda a fila de downloads antes de prosseguir:

```elisp
;; Forçar resolução completa das filas antes de operações críticas
(elpaca-wait (elpaca-process-queues))
```
