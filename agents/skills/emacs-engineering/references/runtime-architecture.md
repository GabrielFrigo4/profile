# 🏛️ Runtime, Compilação Nativa e Arquitetura FHS

Em instalações modernas do GNU Emacs, a estabilidade e velocidade de boot dependem de compilação nativa (`libgccjit`), backend gráfico PGTK Wayland, isolamento FHS e testes em batch mode.

---

## ⚡ Redirecionamento da Compilação Nativa (`libgccjit`)

Isole o cache `.eln` em `var/cache/eln-cache/` e ajuste o Garbage Collector durante o boot no `early-init.el`:

```elisp
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

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))
```

---

## 📂 Layout FHS Modular

```text
~/.emacs.d/
├── early-init.el
├── init.el
├── etc/
│   ├── init/
│   ├── editor/
│   ├── lang/
│   └── tools/
├── lib/
└── var/
    ├── cache/
    ├── backup/
    └── run/
```

---

## 🛡️ Programação Defensiva com `condition-case`

```elisp
(condition-case err
    (require 'modulo-opcional)
  (error
   (message "Aviso: falha ao carregar modulo-opcional: %s"
            (error-message-string err))))
```

---

## 🧪 Testabilidade em Modo Batch Hermético

```sh
emacs -Q --batch -l early-init.el -l init.el --eval '(message "Emacs Batch OK")'
```

---

## 📖 Autodocumentação Introspectiva (`C-h f` / `C-h v` / `which-key`)

1. **Primeira Linha Autônoma ($\le 80$ colunas):** Resumo completo sem depender de linhas seguintes.
2. **Parâmetros em `MAIÚSCULAS` e Links `` `simbolo' ``:** Geram hiperlinks clicáveis nos buffers `*Help*`.

```elisp
(defun my/open-file-manager (&optional dir)
  "Abre o gerenciador de arquivos no diretório DIR (ou `default-directory')."
  (interactive "DDirectory: ")
  (when dir
    (dired dir)))
```
