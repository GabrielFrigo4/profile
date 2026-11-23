---
name: emacs-engineering
description: >-
    Engenharia de software em GNU Emacs moderno e Emacs Lisp (Elisp), cobrindo
    runtime nativo PGTK Wayland, compilação nativa libgccjit, Tree-sitter integrado,
    Elpaca assíncrono, Eglot LSP, isolamento per-frame e testes em batch mode.
---

# 🔮 Engenharia em GNU Emacs & Emacs Lisp (Elisp)

Diretrizes para concepção, refatoração e manutenção de configurações e pacotes em GNU Emacs contemporâneo e Elisp lexicalmente vinculado.

---

## 🏛️ 1. Pilares Arquiteturais

1. **Runtime Moderno:** Aproveite recursos integrados ao núcleo C do GNU Emacs (Tree-sitter nativo, cliente LSP `eglot`, backend gráfico PGTK Wayland e compilação nativa `libgccjit`).
2. **Hermetismo no Early-Init:** Configure redirecionamento de cache `.eln`, otimização de GC e desativação de `package.el` antes da criação do frame gráfico (`early-init.el`).
3. **Lexical Binding Obrigatório:** Todo arquivo `.el` deve iniciar na Linha 1 com `;;; -*- lexical-binding: t -*-`, evitando vazamento de escopo dinâmico e otimizando compilação `.eln`.
4. **Arquitetura Modular FHS:** Separe inicialização (`early-init.el`, `init.el`), configuração declarativa (`etc/`), bibliotecas puras (`lib/`) e estado mutável ignorado no Git (`var/cache/`, `var/run/`).
5. **Isolamento Per-Frame & TTY:** Use `after-make-frame-functions` e `server-after-make-frame-hook` para adaptar faces e cursores por frame (`(tty-type frame)` em vez de `(getenv "TERM")`).
6. **Autodocumentação Integral:** Cubra 100% de `defun`, `defmacro`, `defvar`, `defcustom` e `defface` com docstrings (1ª linha $\le 80$ cols, parâmetros formais em `MAIÚSCULAS`, símbolos como `` `simbolo' ``), réguas estruturais de 32 colunas (`;;; ================================` / `;;; --------------------------------`) e zero comentários narrativos `;;`.
7. **Defensividade & Batch Testing:** Proteja dependências opcionais com `condition-case` e `executable-find`, validando carregamento limpo em CI via `emacs -Q --batch`.

---

## 📚 2. Módulos Especializados (`references/`)

| Subdomínio             | Conteúdo Coberto                                                                      | Referência                                                                 |
| :--------------------- | :------------------------------------------------------------------------------------ | :------------------------------------------------------------------------- |
| **Elpaca Assíncrono**  | Desativação de `package.el`, bootstrap isolado, `use-package` e `elpaca-wait`         | [`references/elpaca-async.md`](references/elpaca-async.md)                 |
| **Tree-sitter Nativo** | Checagem de runtime, `treesit-language-source-alist` e `major-mode-remap-alist`       | [`references/treesitter-native.md`](references/treesitter-native.md)       |
| **Eglot LSP**          | Configuração built-in, servidores `clangd`/`rust-analyzer`/`gopls`, `corfu` e `eldoc` | [`references/eglot-lsp.md`](references/eglot-lsp.md)                       |
| **Runtime & FHS**      | Redirecionamento `eln-cache`, GC no boot, layout FHS, `condition-case` e modo batch   | [`references/runtime-architecture.md`](references/runtime-architecture.md) |

---

## 🛠️ 3. Validação em Modo Batch

```sh
emacs -Q --batch -l early-init.el -l init.el --eval '(message "Boot OK")'
emacs -Q --batch --eval '(message "Treesit: %s, NativeComp: %s" (treesit-available-p) (native-comp-available-p))'
```

---

## 🔗 4. Referências Oficiais

- [GNU Emacs Manual](https://www.gnu.org/software/emacs/manual/html_node/emacs/index.html) | [GNU Elisp Reference Manual](https://www.gnu.org/software/emacs/manual/html_node/elisp/index.html)
- [Elpaca Package Manager](https://github.com/progfolio/elpaca) | [Eglot Manual](https://www.gnu.org/software/emacs/manual/html_node/eglot/index.html)
