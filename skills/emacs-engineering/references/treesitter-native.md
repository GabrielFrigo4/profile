# 🌳 Tree-sitter Nativo Integrado (ABI ≥ 14)

A partir do Emacs 29 e consolidado no Emacs 30 e 31+, o parser sintático Tree-sitter está integrado diretamente no código C do editor via `treesit.c`. Isto elimina completamente o overhead de pacotes Elisp externos legados e regex backtracking.

---

## 🔍 Verificação de Suporte do Runtime

Antes de aplicar modos Tree-sitter, verifique a compilação nativa da biblioteca:

```elisp
(when (and (fboundp 'treesit-available-p)
           (treesit-available-p))
  (message "Tree-sitter nativo ativo. ABI: %s" (treesit-library-abi-version)))
```

---

## 🗺️ Fontes de Gramáticas e Instalação Automatizada

As gramáticas compartilhadas (`libtree-sitter-<lang>.so` no Linux, `.dylib` no macOS, `.dll` no Windows) podem ser declaradas via `treesit-language-source-alist`:

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

;; Função utilitária para instalar gramáticas ausentes
(defun my/treesit-install-all-grammars ()
  "Instala todas as gramáticas declaradas caso não existam em tree-sitter/."
  (interactive)
  (dolist (lang (mapcar #'car treesit-language-source-alist))
    (unless (treesit-language-available-p lang)
      (treesit-install-language-grammar lang))))
```

---

## 🔄 Remapeamento Universal de Modos Principais

Emacs 31+ fornece modos dedicados terminados em `-ts-mode`. O redirecionamento canônico sem alterar atalhos de buffer se dá com `major-mode-remap-alist`:

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

## ⚡ Níveis de Font-Lock (Destaque Sintático)

O Tree-sitter no Emacs organiza o realce em 4 níveis (1 = básico, 4 = máximo com tipos, operadores e atributos):

```elisp
;; Nível 4: coloração semântica completa e detalhada
(setq treesit-font-lock-level 4)
```
