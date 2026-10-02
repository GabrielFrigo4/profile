# 📡 Eglot: LSP Nativo Integrado e Desacoplado

O **Eglot** é o cliente de Language Server Protocol (LSP) oficial do GNU Emacs. Diferente do ecossistema monolítico `lsp-mode`, o Eglot adota a filosofia UNIX: delega UI e navegação às ferramentas já embutidas no Emacs (`xref`, `project.el`, `eldoc`, `flymake`).

---

## 🎯 Configuração Canônica

O Eglot faz parte do core (`:elpaca nil` ou `:ensure nil`):

```elisp
;;; -*- lexical-binding: t -*-

(use-package eglot
  :ensure nil
  :hook
  ((c-ts-mode c++-ts-mode python-ts-mode rust-ts-mode go-ts-mode) . eglot-ensure)
  :custom
  ;; Fechar servidor LSP automaticamente ao encerrar o último buffer do projeto
  (eglot-autoshutdown t)
  ;; Desativar conexões síncronas bloqueantes
  (eglot-sync-connect nil)
  ;; Não reportar eventos internos repetitivos no minibuffer
  (eglot-report-progress nil)
  :config
  ;; Desligar flymake para evitar lentidão se preferir diagnósticos manuais
  (setq eglot-ignored-server-capabilities '(:inlayHintProvider)))
```

---

## 🛠️ Associação de Servidores de Linguagem

Servidores de LSP de alta performance são mapeados via `eglot-server-programs`:

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

Para auto-completar flutuante não-intrusivo e exibição de documentação rápida:

```elisp
;; Corfu para auto-completar na posição do cursor
(use-package corfu
  :elpaca t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 2)
  (corfu-quit-no-match 'separator)
  :init
  (global-corfu-mode))

;; Configuração de Eldoc para documentação sem travar
(setq eldoc-idle-delay 0.2
      eldoc-echo-area-use-multiline-p 3)
```
