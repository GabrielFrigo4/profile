---
name: repo-template-governance
description: Runbook cognitivo para scaffold de novos repositórios por stack e bootstrap completo de governança canônica (.agents, .githooks, .github, AGENTS.md, PRINCIPLES.md, Makefile).
---

# 🏛️ Repo Template Governance Skill

Esta habilidade orienta o agente de IA no scaffold integral de novos repositórios e na injeção, auditoria e padronização da governança canônica e engenharia rigorosa no ecossistema.

---

## 🎯 Invariantes & Regras Fundamentais

> [!IMPORTANT]
> **A Regra de Ouro do Agente:** Ao entrar em qualquer repositório, o agente DEVE ler `AGENTS.md`, `PRINCIPLES.md` e a pasta `.agents/` antes de realizar qualquer alteração estrutural ou de código.

1. **Makefile POSIX Silencioso:** Cabeçalho `.POSIX:` e `.SILENT:`, com `MAKEFLAGS += --no-print-directory -s`, invocação universal `(cd dir && $(MAKE) target)` e compatibilidade dual (`gmake`/`bmake`).
2. **Self-Healing Git Hooks:** Hooks em `.githooks/` (`pre-commit`, `commit-msg`) 100% autônomos em `/bin/sh` (`chmod 0755`), com auto-cura de modos octais (`0755`/`0644`), whitespace, prettier e banners com `git add` automático.
3. **Padrão de Comentários em Três Camadas:** Header de 64 hífens, réguas de 32 colunas para seções e zero comentários narrativos.
4. **Permissões Canônicas Octais:** 4 dígitos expressos (`chmod 0755` para executáveis, `chmod 0644` para dotfiles e documentos).
5. **Invariante Dev-to-Prod:** Bancada exclusiva de edição no `Environment`, propagação via `git push` e pull em produção.
6. **Orçamento Unificado de Linhas:** Runbooks respeitam piso de 17, sweet spot $\le 128$ e teto de 256 linhas.

---

## 🏛️ Fonte Canônica de Scaffold: Plano A vs. Plano B

- **Plano A (Ambiente com `Environment/Template`):**
  Copiar a árvore base (`cp -r ~/Documents/Environment/Template/ <novo-projeto>/`), que já provê `.githooks/`, `.agents/`, `.github/`, `Makefile`, `PRINCIPLES.md`, `AGENTS.md`, `TODO.md`, `.prettierrc` e `VERSION`.
- **Plano B (Fallback Autônomo / Ambientes Efêmeros):**
  Gerar a estrutura completa a partir das receitas canônicas em [`references/governance-lifecycle.md`](./references/governance-lifecycle.md).

---

## 🏗️ Perfis de Repositórios Suportados

| Perfil        | Stack Principal | Foco & Ferramentas                                             |
| :------------ | :-------------- | :------------------------------------------------------------- |
| `c-posix`     | C Moderno (C23) | `-std=c23`, sanitizers, `clang-format`, manpages POSIX         |
| `shell-posix` | POSIX `/bin/sh` | Baseline FreeBSD `/bin/sh`, shellcheck, testes e portabilidade |
| `cpp-modern`  | C++23 Moderno   | Concepts, ranges, monádico `std::expected`, Google Test/Catch2 |
| `go-binary`   | Go Moderno      | Binário único estático, PocketBase, CGo, CLI ergonômico        |
| `python-pure` | Python 3.12+    | Stdlib pura ou minimalista, `pyproject.toml`, type hints       |
| `latex-doc`   | LaTeX / TeX     | Editoração científica, automação `latexmk`, Makefile limpo     |

---

## 📋 Arquitetura Canônica de Diretórios

```
<repo-root>/
├── AGENTS.md                  # Identidade, briefing do agente e regras críticas (<= 256 linhas)
├── PRINCIPLES.md              # 22 Princípios UNIX + Soberania contextualizados ao domínio
├── Makefile                   # Orquestrador POSIX silencioso compatível com bmake e gmake
├── README.md                  # Apresentação institucional, arquitetura e quickstart
├── .agents/                   # Regras e skills cognitivas locais
├── .githooks/                 # Hooks com auto-cura (pre-commit, commit-msg)
└── .github/                   # Workflows GitHub Actions multiplataforma
```

---

## 🛠️ Procedimento Operacional Passo a Passo

1. **Inicialização do Repositório Git:**
    ```sh
    mkdir -p "<nome-do-projeto>" && cd "<nome-do-projeto>"
    git init -b main
    git config core.hooksPath .githooks
    ```
2. **Quality Gates & Hooks com Auto-Cura:**
    - Detalhes de implementação, regex com ponto e tipos `sec`/`init`: [`references/governance-lifecycle.md`](./references/governance-lifecycle.md).
3. **Busca Recursiva Topológica (`upgit`):**
    - Varredura com poda `-prune` ordenada por profundidade para múltiplos repositórios e submódulos.

---

## 🧪 Validação de Integridade

```sh
make -n && bmake -n
find . -name "*.sh" -not -path "*/.git/*" -exec sh -n {} +
./.githooks/pre-commit
prettier --check "**/*.md"
```

A aprovação requer **0 avisos e 0 falhas**, com permissões octais canônicas preservadas.
