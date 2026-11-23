---
name: vcs-and-ci-governance
description: >-
    Governança de controle de versão distribuído com Git e Game of Trees (Got/tog),
    commits atômicos Conventional Commits, hooks POSIX com auto-cura (.githooks),
    sincronização resiliente de repositórios e pipelines portáteis de CI/CD.
---

# 🌳 VCS & CI Governance — Git, Got, Hooks & Pipelines

Diretrizes operacionais para operação soberana de DVCS (Git e Game of Trees), qualidade local com hooks autônomos e pipelines de integração contínua portáteis entre UNIX e Windows.

---

## 🎯 1. Coexistência Git & Game of Trees (`got` / `tog`)

O formato de objetos `.git` é o padrão de armazenamento compartilhado; a interface de usuário pode alternar livremente entre **Git** e **Got/tog**:

- **Got (`got`):** Interface minimalista estilo OpenBSD (`pledge`/`unveil`) operando sobre bare repos e worktrees (`got clone`, `got checkout`, `got commit`, `got update`, `got send`).
- **Tog (`tog`):** Navegador TUI instantâneo (`tog log`, `tog diff`, `tog blame`, `tog tree`).
- **Git (`git`):** Automação, submódulos, plumbing, ganchos locais e sincronização com remotos.

---

## 🐙 2. Commits Atômicos, `.gitattributes` & Hooks Locais

1. **Conventional Commits:** Uma unidade lógica indivisível por commit (`add`, `update`, `fix`, `docs`, `feat`, `chore`, `refactor`, `style`, `ci`, `test`, `sec`, `init`, `build`, `perf`, `revert`) usando `<tipo>(<escopo>): <descrição>`.
2. **Normalização de Finais de Linha:** Defina `.gitattributes` na raiz garantindo `eol=lf` para código/Markdown/Makefiles e `eol=crlf` apenas para scripts Windows (`.bat`, `.cmd`, `.ps1`).
3. **Hooks Self-Healing (`.githooks/`):**
    - Shebang `#!/usr/bin/env sh`, permissão `chmod 0755` e `git config core.hooksPath .githooks`.
    - Totalmente herméticos: sem dependência de diretórios externos de IA (`.agents/`).
    - `pre-commit` auto-cura modos octais (`0755`/`0644`), trailing whitespace, formatação Prettier e banners antes de re-estagiar e validar.
    - `commit-msg` normaliza capitalização e valida comprimento/prefixo semântico.

---

## 🔄 3. Sincronização Resiliente, Travessia & CI Portátil

- **Sync em 4 Fases:** (1) restaurar drift puro de `filemode` (`0 0 <file>` no `git diff --numstat`), (2) `stash push -u` defensivo para código sujo, (3) cascata `pull --ff-only` $\rightarrow$ `--rebase` $\rightarrow$ `pull`, (4) `stash pop` + `chmod 0755 .githooks/*`.
- **Travessia Topológica:** Use `find . \( -type d -name ".git" -print -prune \) -o \( -type f -name ".git" -print \)` ordenado por profundidade com `awk`/`sort` para varrer árvores com submódulos sem invadir objetos internos.
- **CI Multiplataforma & CLI:** Valide modos no índice Git, EOL, ausência de conflitos, sintaxe `sh`/`bash`/`zsh`/`ksh`, formatação e suítes locais em Linux, BSD, macOS e MSYS2 UCRT64; inspecione execuções com `gh run list`, `gh run view --log-failed` e `gh pr checks`.

---

## 📚 4. Referências Detalhadas

| Subdomínio                     | Conteúdo Coberto                                                                      | Referência                                                 |
| :----------------------------- | :------------------------------------------------------------------------------------ | :--------------------------------------------------------- |
| **Got, Tog & Sync Resiliente** | Fluxo completo `got`/`tog`, `.gitattributes` e implementação POSIX do sync em 4 fases | [`references/got-interop.md`](references/got-interop.md)   |
| **Hooks & CI Multiplataforma** | Arquitetura `pre-commit`/`commit-msg`, travessia `-prune` e matriz portátil de CI     | [`references/hooks-and-ci.md`](references/hooks-and-ci.md) |
