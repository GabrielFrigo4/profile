# 📡 Eglot: LSP Nativo Integrado e Desacoplado

O **Eglot** é o cliente de Language Server Protocol (LSP) embutido no GNU Emacs, delegando navegação e diagnósticos às primitivas nativas (`xref`, `project.el`, `eldoc`, `flymake`).

---

## 🎯 Configuração Canônica

```elisp
;;; -*- lexical-binding: t -*-

(use-package eglot
  :ensure nil
  :hook
  ((c-ts-mode c++-ts-mode python-ts-mode rust-ts-mode go-ts-mode) . eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-sync-connect nil)
  (eglot-report-progress nil)
  :config
  (setq eglot-ignored-server-capabilities '(:inlayHintProvider)))
```

---

## 🛠️ Associação de Servidores de Linguagem

```elisp
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((c-ts-mode c++-ts-mode)
                 . ("clangd"
                    "--background-index"
                    "--clang-tidy"
                    "--completion-style=detailed"
                    "--header-insertion=iwyu"
                    "--pch-storage=memory")))

  (add-to-list 'eglot-server-programs
               '(rust-ts-mode . ("rust-analyzer" :initializationOptions
                                 (:check (:command "clippy")))))

  (add-to-list 'eglot-server-programs
               '(go-ts-mode . ("gopls"))))
```

---

## 🚀 Integração com Corfu & Eldoc

```elisp
(use-package corfu
  :ensure t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 2)
  (corfu-quit-no-match 'separator)
  :init
  (global-corfu-mode))

(setq eldoc-idle-delay 0.2
      eldoc-echo-area-use-multiline-p 3)
```
