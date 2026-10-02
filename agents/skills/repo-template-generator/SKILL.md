---
name: repo-template-generator
description: Runbook cognitivo para geração e scaffold de novos repositórios completos a partir de templates canônicos por linguagem (C Moderno (C23), Shell, C++23, Go, Python, LaTeX).
---

# 🚀 Repo Template Generator Skill

Esta habilidade orienta o agente de IA na criação do zero de novos repositórios de projetos no ecossistema, gerando estrutura de diretórios completa, governança, Makefiles POSIX silenciosos, githooks defensivos, pipelines de CI e arquivos fundamentais.

---

## 🏛️ Fonte Canônica de Scaffold: `Environment/Template`

O ecossistema mantém um template vivo, canônico e continuamente testado localizado em:
`~/Documents/Environment/Template` (ou `${WORKSPACE_ROOT}/Environment/Template`).

Ao criar ou inicializar um novo repositório, o agente deve seguir a seguinte hierarquia de resolução:

1. **Plano A (Com `Environment/Template` no host):**
    - Copie a estrutura base de `Environment/Template/` para a nova pasta do projeto (`cp -r ~/Documents/Environment/Template/ <novo-projeto>/`).
    - A pasta já contém a governança mais atualizada: `.githooks/` (`pre-commit`, `commit-msg`), `.agents/` (`clean-code.md`, `principles.md`), `.github/workflows/ci.yml`, `Makefile`, `PRINCIPLES.md`, `AGENTS.md`, `TODO.md`, `CONTRIBUTING.md`, `.prettierrc`, `.gitignore` e `VERSION`.
    - Ajuste apenas as diretrizes, alvos e arquivos fontes específicos da linguagem e do negócio conforme os perfis abaixo.

2. **Plano B (Fallback Autônomo / Sem `Environment` no host):**
    - Caso o host seja uma máquina remota, VPS, container efêmero ou ambiente sem o clone de desenvolvimento `Environment`, gere a estrutura do zero utilizando as receitas canônicas embutidas nesta skill.

### 🔄 Invariante Dev-to-Prod (Git Push -> Git Pull)

- **Origem Canônica:** Toda modificação em templates, componentes (`Shell`, `Profile`, `Setup`, `Vault`, editores) ou skills é realizada exclusivamente no clone de desenvolvimento (`~/Documents/Environment/...`).
- **Propagação Soberana:** O tráfego de atualizações para clones de produção (`/usr/local/share/shell`, `~/.local/share/profile`, `~/.emacs.d`, etc.) é feito **estritamente via `git push` no dev e `git pull` na produção** (via `update-all`, `upsh`, etc.).
- **Zero `cp` Manual para Produção:** Evite transferir arquivos manualmente da bancada para os clones de produção via `cp`. Utilize estritamente o ciclo `git push` no dev e `git pull` na produção para manter a árvore de trabalho limpa.
- **Exceção Única para Edição Direta:** Só é admitido editar arquivos diretamente nos clones de runtime se o repositório canônico `Environment` não existir na máquina hospedeira.

---

## 🏗️ Perfis de Repositórios Suportados

Ao solicitar a criação de um novo repositório, o agente deve selecionar o perfil adequado:

1. **`c-posix`**: Utilitários e sistemas Unix em C Moderno (C23 estrito com `-std=c23`), Makefile POSIX, manpage, linters clang-format e sanitizers.
2. **`shell-posix`**: Automações, suítes de scripts ou dotfiles com baseline no `/bin/sh` do FreeBSD, testes e linters.
3. **`cpp-modern`**: Bibliotecas ou softwares de alta performance em C++23, Google Test ou suites nativas, fast I/O e flags de stack.
4. **`go-binary`**: Projetos em Go (single-binary, PocketBase, CGo ou APIs nativas) com testes e embedding estático.
5. **`python-pure`**: Utilitários CLI e ferramentas sem dependências pesadas, `pyproject.toml` ou stdlib pura.
6. **`latex-doc`**: Livros técnicos, monografias ou relatórios acadêmicos com automação LaTeXmk e Makefile silencioso.

---

## 📐 Estrutura Padrão Gerada por Perfil

### Exemplo: Perfil `c-posix`

```
meu-projeto/
├── .agents/
│   ├── rules/
│   │   ├── c-standards.md
│   │   └── clean-code.md
│   └── skills/
│       └── project-audit/SKILL.md
├── .githooks/
│   ├── pre-commit
│   └── commit-msg
├── .github/
│   └── workflows/
│       └── ci.yml
├── docs/
│   └── ARCHITECTURE.md
├── src/
│   ├── main.c
│   └── utils.h
├── .clang-format
├── .gitignore
├── AGENTS.md
├── Makefile
├── PRINCIPLES.md
└── README.md
```

---

## 🛠️ Procedimento Canônico de Inicialização

### 1. Inicialização do Repositório Git

```sh
mkdir -p "<nome-do-projeto>" && cd "<nome-do-projeto>"
git init -b main
git config core.hooksPath .githooks
```

### 2. Criação do `Makefile` Canônico (Padrão Enterprise OptiLaser)

Todo repositório gerado adota a arquitetura de alta ergonomia e TUI do padrão OptiLaser:

```makefile
.POSIX:
.SILENT:

MAKEFLAGS += --no-print-directory -s

# ----------------------------------------------------------------
# Makefile: <Nome do Projeto>
# ----------------------------------------------------------------

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
	sub() { printf "  \x1b[1;34m  ── %s ──\x1b[0m\n" "$$1"; }; \
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

> [!CAUTION]
> **Hermeticidade dos Git Hooks Gerados:**
> Os scripts gerados em `.githooks/` (`pre-commit`, `commit-msg`) devem ser **100% autossuficientes** e escritos em POSIX `/bin/sh`. **NUNCA** gere hooks que dependam de comandos ou pastas de skills externas (`~/.gemini/config/skills/`). Toda checagem deve usar ferramentas padrão do sistema (`git diff --check`, `sh -n`, linters do PATH).

### 3. Criação de `AGENTS.md` e `PRINCIPLES.md`

- Utilize a skill `repo-governance-bootstrap` para popular `AGENTS.md` com a identidade e comandos do projeto.
- Gere o `PRINCIPLES.md` contextualizando os 22 princípios de engenharia UNIX + Clean Code ao domínio específico da linguagem e negócio.

### 4. Permissões Canônicas

```sh
chmod 0755 .githooks/*
chmod 0644 Makefile AGENTS.md PRINCIPLES.md README.md .gitignore
```

```sh
git add .
git commit -m "add: initial repository scaffolding with canonical governance"
```

---

## 📚 Literatura de Referência & Ferramentas Oficiais

Recomenda-se enfaticamente ao agente de IA e aos operadores o estudo das ferramentas oficiais de suporte aos templates:

- **Clang / LLVM Toolchain:** <https://clang.llvm.org/>
- **The Go Programming Language:** <https://go.dev/>
- **Standard C++ Foundation (ISO C++):** <https://isocpp.org/>
- **The LaTeX Project:** <https://www.latex-project.org/>
- **Obra Clássica de Estrutura:** _The Practice of Programming_ (Brian W. Kernighan & Rob Pike, 1999, Addison-Wesley) — design de interfaces, estilo e testes.
