---
name: emacs-engineering
description: Runbook cognitivo definitivo para engenharia de software em GNU Emacs 31+ moderno e Emacs Lisp (Elisp), cobrindo runtime nativo PGTK Wayland, compilação AOT/JIT (libgccjit), Tree-sitter nativo (ABI ≥ 14), arquitetura assíncrona com Elpaca, Eglot LSP e testes em batch mode.
---

# 🔮 Engenharia de Software em GNU Emacs 31+ & Emacs Lisp (Elisp)

Esta habilidade orienta a concepção, escrita, refatoração e manutenção de configurações e pacotes em **GNU Emacs Moderno (31+)** e **Emacs Lisp Contemporâneo**, estruturado sob a arquitetura de **Tier 2 (Extended)**.

---

## 🏛️ Os Pilares Fundamentais do Emacs 31+

1. **Baseline Emacs 31+:** Utilização de recursos contemporâneos (PGTK nativo Wayland, suporte avançado a child frames, libgccjit AOT/JIT e Tree-sitter em nível de C core).
2. **Hermetismo no Early-Init:** Configuração de cache e GC antes do carregamento da interface gráfica (`early-init.el` < 50ms).
3. **Lexical Binding Universal:** Todo arquivo `.el` deve conter `;;; -*- lexical-binding: t -*-` obrigatoriamente na linha 1.
4. **Isolamento de Estado (FHS):** Separação estrita entre código imutável (`etc/`, `lib/`), extensões locais (`usr/local/`) e estado volátil (`var/cache/`, `var/run/`).
5. **Autonomia em Batch Mode:** Validação sintática e integridade de carregamento via `emacs -Q --batch` em CI e testes locais.

---

## 📚 Módulos Especializados da Subpasta references/

Consulte as especificações aprofundadas nos arquivos dedicados:

- **[elpaca-async.md](references/elpaca-async.md):** Gestão assíncrona de pacotes com Elpaca, receitas declarativas, lockfiles, ordenação de filas e eliminação do `package.el` legado.
- **[treesitter-native.md](references/treesitter-native.md):** Integração nativa de Tree-sitter (ABI ≥ 14), gramáticas C nativas, fontes de linguagens e remapeamento universal com `major-mode-remap-alist`.
- **[eglot-lsp.md](references/eglot-lsp.md):** Configuração cirúrgica do cliente LSP Eglot nativo, hooks sob demanda, integração com `project.el`, `flymake` e servidores externos (`clangd`, `rust-analyzer`, `gopls`).
- **[runtime-architecture.md](references/runtime-architecture.md):** Arquitetura de runtime FHS, compilação AOT/JIT com `libgccjit`, PGTK Wayland, tratamento defensivo com `condition-case` e harness de teste em batch mode.

---

## 🛠️ Comandos Canônicos de Operação & Diagnóstico

| Ação Operacional            | Comando Canônico                                                                                                    |
| :-------------------------- | :------------------------------------------------------------------------------------------------------------------ |
| **Teste de Boot em Batch**  | `emacs -Q --batch -l early-init.el -l init.el --eval '(message "Boot OK")'`                                         |
| **Compilar Tree-sitter**    | `make treesit` ou `./emacs.sh treesit`                                                                              |
| **Atualizar Submódulos**    | `make upmodes` ou `git submodule update --init --recursive --remote --merge`                                        |
| **Indentação Automática**   | `make indent` ou `sh bin/indent-all.sh`                                                                             |
| **Diagnóstico de Recursos** | `emacs -Q --batch --eval '(message "Treesit: %s, NativeComp: %s" (treesit-available-p) (native-comp-available-p))'` |

---

## 🔗 Referências Oficiais & Manuais

- [GNU Emacs Manual (Development / 31+)](https://www.gnu.org/software/emacs/manual/html_node/emacs/index.html)
- [GNU Emacs Lisp Reference Manual](https://www.gnu.org/software/emacs/manual/html_node/elisp/index.html)
- [Elpaca Asynchronous Package Manager](https://github.com/progfolio/elpaca)
- [Tree-sitter Starter Guide for Emacs](https://git.savannah.gnu.org/cgit/emacs.git/tree/admin/notes/tree-sitter/starter-guide)
- [Eglot: The Emacs LSP Client](https://www.gnu.org/software/emacs/manual/html_node/eglot/index.html)
