# 🏛️ Runtime, Compilação Nativa e Arquitetura FHS

No GNU Emacs 31+, a integridade do runtime baseia-se na compilação nativa Ahead-of-Time (`libgccjit`), backend PGTK nativo Wayland, conformidade FHS estrita e execução isolada de testes em batch mode.

---

## ⚡ Redirecionamento da Compilação Nativa (`libgccjit`)

O cache `.eln` não deve poluir a raiz do `user-emacs-directory`. O isolamento deve ocorrer no `early-init.el`:

```elisp
;; early-init.el
;;; -*- lexical-binding: t -*-

(let ((eln-cache-dir (expand-file-name "var/cache/eln-cache/" user-emacs-directory)))
  (unless (file-exists-p eln-cache-dir)
    (make-directory eln-cache-dir t))
  (when (boundp 'startup-redirect-eln-cache)
    (startup-redirect-eln-cache eln-cache-dir))
  (when (boundp 'native-comp-eln-load-path)
    (setq native-comp-eln-load-path
          (cons eln-cache-dir
                (delete (expand-file-name "eln-cache/" user-emacs-directory)
                        native-comp-eln-load-path)))))

;; Otimização de Garbage Collector durante o boot (< 50ms)
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))
```

---

## 📂 Layout FHS Soberano do Repositório

```text
~/.emacs.d/
├── early-init.el         # Inicialização crítica e pré-gráfica
├── init.el               # Orquestrador do ambiente
├── etc/                  # Configurações declarativas modulares
│   ├── init/             # Bootstraps (Elpaca, fontes, temas)
│   ├── editor/           # Comportamentos do buffer e janelas
│   ├── lang/             # Modos de linguagens de programação
│   └── tools/            # Ferramentas auxiliares (git, terminal)
├── lib/                  # Bibliotecas Elisp puras reutilizáveis
├── usr/local/            # Submódulos Git de pacotes e extensões locais
└── var/                  # Estado efêmero e de runtime (.gitignore)
    ├── cache/            # Caches (eln-cache, elpaca, lsp)
    ├── backup/           # Autosaves e backups de buffers
    └── run/              # Sockets e PIDs de emacsclient
```

---

## 🛡️ Programação Defensiva com `condition-case`

Erros de um pacote ou ausência de binários externos não devem interromper o ciclo de vida do editor:

```elisp
(condition-case err
    (require 'modulo-opcional)
  (error
   (message "Aviso: falha ao carregar modulo-opcional: %s"
            (error-message-string err))))
```

---

## 🧪 Testabilidade em Modo Batch Hermético

Todo pipeline de CI ou Makefile de desenvolvimento deve conter um target para validar a inicialização limpa:

```sh
emacs -Q --batch -l early-init.el -l init.el --eval '(message "Emacs 31+ Batch OK")'
```

Se qualquer função estiver indefinida ou a sintaxe incorreta, o processo sai com código diferente de 0.
