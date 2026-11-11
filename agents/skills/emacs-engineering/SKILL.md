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
4. **Isolamento de Estado (FHS) & Modos Vendor In-Tree:** Separação estrita entre código imutável (`etc/`, `lib/`), extensões locais vendorizadas diretamente in-tree no repositório Git (`usr/local/`, não como submódulos) e estado volátil (`var/cache/`, `var/run/`).
5. **Autonomia em Batch Mode:** Validação sintática e integridade de carregamento via `emacs -Q --batch` em CI e testes locais.
6. **Arquitetura Quádrupla de Terminais (`aweshell`, `eat`, `vterm`, `term`):** A suíte de terminal oferece 4 motores complementares. O `aweshell` (`usr/local/aweshell`) é o terminal primário (Eshell com Ghost Completion Zsh-style, parada em match exato, biblioteca semântica `_ui_*` com paridade 1:1 com `Shell/library/ui.sh` e 3 temas canônicos). O `eat` (`Emulate A Terminal`) opera de forma dual: como 4º terminal standalone (`M-x eat`) com cascata defensiva (`zsh -> bash -> sh`) e integração modal Evil (`eat-semi-char-mode` em Evil Insert e `eat-emacs-mode` em Evil Normal), e acoplado ao `aweshell` via `eat-eshell-mode` e `eat-eshell-visual-command-mode`, interceptando `eshell-exec-visual` para executar TUIs (`agy`, `btop`, `nvim`, `tmux`, etc.) _in-place_ no próprio buffer sem corrupção gráfica, com fallback para `aweshell-exec-visual` (`vterm`/`term`). O `vterm` opera via `emacsmirror/vterm` (branch `master`) e `term`/`ansi-term` atua como retaguarda POSIX.
7. **Autodocumentação Integral em Elisp (GNU Emacs Self-Documenting Standard):** 100% de cobertura de docstrings em `defun`, `defmacro`, `defvar`, `defcustom` e `defface`. Devem ter 1ª linha autônoma de até 80 colunas ($\le 80$ cols), parâmetros formais em `MAIÚSCULAS` e referências a símbolos entre acento grave e apóstrofo (` `simbolo' `). Comentários explicativos inline (`;;`) são proibidos; seções estruturais usam réguas de 32 colunas (`;;; ================================`e`;;; --------------------------------`) com títulos em MAIÚSCULO.
8. **Dual-Realm no EXWM / EWM:** Detecção contextual inteligente que preserva atalhos nativos em terminais (`aweshell`, `vterm`, `eat`) e delega atalhos ergonômicos para apps gráficos X11/Wayland, com sincronização bidirecional de Clipboard e Primary Selection.
9. **Supressão Incondicional de Tool-Bar:** Aplicação de `interface/apply-tool-bar` garantindo `tool-bar-lines 0` e `tool-bar-mode -1` em todos os contextos (GUI, EWM, consoles TTY), preservando `menu-bar-mode` exclusivamente em quadros gráficos.
10. **Estabilidade Global de Cursor & Seleção:** Preservação estrita de `track-mouse nil` em todos os buffers e modos (incluindo o Dashboard e Aweshell), evitando que rotinas de interceptação de movimento de ponteiro corrompam a máquina de estados de `mouse-drag-track` e causem seleção indesejada contínua pós-clique.
11. **Correção Ortográfica Bilíngue sem /usr/bin/look:** Desativação de `text-mode-ispell-word-completion` e `ispell-look-p` (`nil`) para impedir forks de `/usr/bin/look`, operando com dicionários simultâneos Inglês + Português (`hunspell` com `en_US,pt_BR`) via `ispell-hunspell-add-multi-dic`.
12. **Política Canônica de Pacotes & EmacsMirror:** Pacotes de terceiros disponíveis no `emacsmirror` devem usar `:ensure (:type git :host github :repo "emacsmirror/<pkg>" :branch "master")` (evitando a branch `main` órfã no mirror). A paridade de commits deve ser validada via `git ls-remote --symref` contra o upstream antes da inclusão. Pacotes fora do GitHub (ex: Codeberg, SourceHut) apontam diretamente para suas instâncias canônicas upstream (ex: `:host codeberg :repo "akib/emacs-eat"`).

---

## 📚 Módulos Especializados da Subpasta references/

Consulte as especificações aprofundadas nos arquivos dedicados:

- **[aweshell-parity.md](references/aweshell-parity.md):** Governança de paridade 1:1 entre o Universal Shell e o Aweshell (aliases do Quarteto, temas multi/pill/micro, navegação e integração de buffers).
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
| **Atualizar Modos Locais**  | `make upmodes` (modos vendor in-tree em `usr/local/*`)                                                              |
| **Indentação Automática**   | `make indent` ou `sh bin/indent-all.sh`                                                                             |
| **Diagnóstico de Recursos** | `emacs -Q --batch --eval '(message "Treesit: %s, NativeComp: %s" (treesit-available-p) (native-comp-available-p))'` |

---

## 🔗 Referências Oficiais & Manuais

- [GNU Emacs Manual (Development / 31+)](https://www.gnu.org/software/emacs/manual/html_node/emacs/index.html)
- [GNU Emacs Lisp Reference Manual](https://www.gnu.org/software/emacs/manual/html_node/elisp/index.html)
- [Elpaca Asynchronous Package Manager](https://github.com/progfolio/elpaca)
- [Tree-sitter Starter Guide for Emacs](https://git.savannah.gnu.org/cgit/emacs.git/tree/admin/notes/tree-sitter/starter-guide)
- [Eglot: The Emacs LSP Client](https://www.gnu.org/software/emacs/manual/html_node/eglot/index.html)
