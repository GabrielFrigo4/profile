# 🌳 Tree-sitter Nativo Integrado

Em versões modernas do GNU Emacs, o parser sintático Tree-sitter integra-se diretamente no núcleo C via `treesit.c`, eliminando dependências externas legadas e gargalos de regex backtracking.

---

## 🔍 Verificação de Suporte do Runtime

```elisp
(when (and (fboundp 'treesit-available-p)
           (treesit-available-p))
  (message "Tree-sitter nativo ativo. ABI: %s" (treesit-library-abi-version)))
```

---

## 🗺️ Fontes de Gramáticas e Instalação Automatizada

Declare as gramáticas compartilhadas via `treesit-language-source-alist`:

```elisp
(setq treesit-language-source-alist
      '((c          . ("https://github.com/tree-sitter/tree-sitter-c"))
        (cpp        . ("https://github.com/tree-sitter/tree-sitter-cpp"))
        (python     . ("https://github.com/tree-sitter/tree-sitter-python"))
        (bash       . ("https://github.com/tree-sitter/tree-sitter-bash"))
        (json       . ("https://github.com/tree-sitter/tree-sitter-json"))
        (yaml       . ("https://github.com/ikatyang/tree-sitter-yaml"))
        (toml       . ("https://github.com/tree-sitter/tree-sitter-toml"))
        (go         . ("https://github.com/tree-sitter/tree-sitter-go"))
        (rust       . ("https://github.com/tree-sitter/tree-sitter-rust"))
        (elisp      . ("https://github.com/Wilfred/tree-sitter-elisp"))))

(defun my/treesit-install-all-grammars ()
  "Instala todas as gramáticas declaradas quando ausentes no runtime."
  (interactive)
  (dolist (lang (mapcar #'car treesit-language-source-alist))
    (unless (treesit-language-available-p lang)
      (treesit-install-language-grammar lang))))
```

---

## 🔄 Remapeamento Universal de Modos Principais

Redirecione os modos clássicos para variantes `-ts-mode` usando `major-mode-remap-alist`:

```elisp
(when (and (fboundp 'treesit-available-p) (treesit-available-p))
  (setq major-mode-remap-alist
        '((c-mode          . c-ts-mode)
          (c++-mode        . c++-ts-mode)
          (python-mode     . python-ts-mode)
          (bash-mode       . bash-ts-mode)
          (sh-mode         . bash-ts-mode)
          (json-mode       . json-ts-mode)
          (yaml-mode       . yaml-ts-mode)
          (toml-mode       . toml-ts-mode)
          (go-mode         . go-ts-mode)
          (rust-mode       . rust-ts-mode))))
```

---

## ⚡ Níveis de Font-Lock

Configure o nível máximo (`4`) para destaque semântico completo de tipos, operadores e atributos:

```elisp
(setq treesit-font-lock-level 4)
```
