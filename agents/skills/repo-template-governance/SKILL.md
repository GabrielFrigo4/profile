---
name: repo-template-governance
description: Runbook cognitivo para scaffold de novos repositórios por stack e bootstrap completo de governança canônica (.agents, .githooks, .github, AGENTS.md, PRINCIPLES.md, Makefile).
---

# 🏛️ Repo Template Governance Skill

Esta habilidade orienta o agente de IA no scaffold integral de novos repositórios e na injeção, auditoria e padronização da governança canônica e engenharia rigorosa no ecossistema de **Gabriel Frigo**.

---

## 🎯 Invariantes & Regras Fundamentais

> [!IMPORTANT]
> **A Regra de Ouro do Agente:** Ao entrar em qualquer repositório, o agente DEVE ler `AGENTS.md`, `PRINCIPLES.md` e a pasta `.agents/` antes de realizar qualquer alteração estrutural ou de código.

1. **Makefile POSIX Silencioso:** Cabeçalho estrito `.POSIX:` e `.SILENT:`, com `MAKEFLAGS += --no-print-directory -s`, alvos ergonômicos e compatibilidade comprovada entre GNU Make (`gmake`) e BSD Make (`bmake`).
2. **Hermeticidade dos Git Hooks:** Hooks em `.githooks/` (`pre-commit`, `commit-msg`) devem ser 100% autônomos em POSIX `/bin/sh` (`chmod 0755`). NUNCA dependem de scripts de skills globais ou caminhos voláteis.
3. **Padrão de Comentários em Três Camadas:** Header banner de 64 hífens, réguas de 32 caracteres para seções estruturais e zero comentários narrativos no corpo.
4. **Permissões Canônicas Octais:** 4 dígitos expressos (`chmod 0755` para executáveis/scripts, `chmod 0644` para dotfiles e documentos).
5. **Invariante Dev-to-Prod:** Modificações ocorrem na bancada de desenvolvimento (`~/Documents/Environment/`) e propagam-se para produção exclusivamente via `git push` no dev e `git pull` na produção.
6. **Orçamento Unificado de Linhas:** Runbooks e constituições respeitam piso de 17 linhas, sweet spot de 80 a 180 linhas e teto de 256 linhas.

---

## 🏛️ Fonte Canônica de Scaffold: Plano A vs. Plano B

O ecossistema mantém um modelo canônico testado em `~/Documents/Environment/Template`.

- **Plano A (Ambiente com `Environment/Template`):**
  Copiar a árvore base (`cp -r ~/Documents/Environment/Template/ <novo-projeto>/`), que já provê `.githooks/`, `.agents/`, `.github/`, `Makefile`, `PRINCIPLES.md`, `AGENTS.md`, `TODO.md`, `.prettierrc` e `VERSION`. Em seguida, customizar os alvos e arquivos-fonte específicos da stack.
- **Plano B (Fallback Autônomo / Ambientes Efêmeros):**
  Gerar a estrutura completa e a governança a partir das receitas canônicas descritas neste runbook.

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
├── .agents/
│   ├── rules/                 # Regras contextuais ativas (clean-code.md, stack-standards.md)
│   └── skills/                # Runbooks cognitivos locais do projeto
├── .githooks/
│   ├── pre-commit             # Quality gate (whitespace, sintaxe, quoting, clean code)
│   └── commit-msg             # Validador de commits semânticos (Conventional Commits)
└── .github/
    └── workflows/ci.yml       # Pipeline de integração contínua multiplataforma
```

---

## 🛠️ Procedimento Operacional Passo a Passo

### 1. Inicialização do Repositório Git

```sh
mkdir -p "<nome-do-projeto>" && cd "<nome-do-projeto>"
git init -b main
git config core.hooksPath .githooks
```

### 2. Orquestrador `Makefile` Canônico (Padrão OptiLaser)

O `Makefile` do projeto deve fornecer interface TUI semântica, auto-documentada e silenciosa:

```makefile
.POSIX:
.SILENT:

MAKEFLAGS += --no-print-directory -s

APP         = app
CMD         = src/main.c
VERSION    != cat VERSION 2> "/dev/null" || echo 0.1.0-dev
CC         ?= cc
CFLAGS     ?= -Wall -Wextra -Werror -pedantic -std=c23 -O2

.PHONY: all help dev build check format clean

all: help

help:
	cmd() { printf "    \x1b[36mmake %-28s\x1b[0m %s\n" "$$1" "$$2"; }; \
	sec() { printf "\n  \x1b[1;33m%s\x1b[0m\n" "$$1"; }; \
	printf "\n  \x1b[1;37m%s — Catálogo de Comandos\x1b[0m (v%s)\n" "$(APP)" "$(VERSION)"; \
	printf "  ============================================================\n"; \
	sec "Desenvolvimento & Compilação:"; \
	cmd "build"             "Compila o binário de produção em bin/"; \
	cmd "dev"               "Compila e executa o binário imediatamente"; \
	sec "Qualidade & Auditoria:"; \
	cmd "check"             "Executa validação estática de sintaxe"; \
	cmd "format"            "Formata código com ferramentas canônicas"; \
	sec "Manutenção:"; \
	cmd "clean"             "Remove artefatos e diretório bin/"; \
	echo ""

dev: build
	./bin/$(APP)

build:
	mkdir -p bin
	$(CC) $(CFLAGS) $(CMD) -o bin/$(APP)

check:
	$(CC) $(CFLAGS) -fsyntax-only $(CMD)

format:
	find . -type f \( -name "*.c" -o -name "*.h" \) -not -path "*/.*" -exec clang-format -i {} +

clean:
	rm -rf bin/
```

### 3. Redação de `AGENTS.md` e `PRINCIPLES.md`

- **`AGENTS.md`:** Estruturado com Identidade, Regras Críticas, Boy Scout Rule, Árvore de Diretórios, Comandos de Verificação e Referências Obrigatórias.
- **`PRINCIPLES.md`:** Contextualização real dos 22 princípios de engenharia UNIX + Clean Code ao domínio da linguagem e da aplicação.

### 4. Quality Gates em `.githooks/`

- **`pre-commit`:** Valida whitespaces (`git diff --check --cached`), rejeita segredos/binários, valida sintaxe (`sh -n`, linters de linguagem) e formatação Markdown via Prettier.
- **`commit-msg`:** Assegura formato semântico rigoroso (`add:`, `fix:`, `refactor:`, `docs:`, `test:`, `chore:`).
- **Permissões:** `chmod 0755 .githooks/*`.

---

## 🧪 Validação de Integridade e Qualidade Contínua

Após scaffold ou bootstrap de governança, execute a suíte de verificação:

```sh
# 1. Validação de portabilidade de Makefiles
make -n && bmake -n

# 2. Verificação de sintaxe de scripts de shell
find . -name "*.sh" -not -path "*/.git/*" -exec sh -n {} +

# 3. Execução dos githooks
./.githooks/pre-commit

# 4. Formatação e linting estrito
prettier --check "**/*.md"
```

A aprovação requer **0 avisos e 0 falhas**, com permissões octais canônicas preservadas.

---

## 📚 Literatura de Referência & Ferramentas Oficiais

- **Git SCM & Githooks:** <https://git-scm.com/docs/githooks>
- **Pro Git Book (Scott Chacon & Ben Straub):** <https://git-scm.com/book/en/v2>
- **Conventional Commits:** <https://www.conventionalcommits.org/>
- **Prettier Code Formatter:** <https://prettier.io/>
- **The Practice of Programming (Kernighan & Pike):** Design limpo de software, interfaces e testes.
