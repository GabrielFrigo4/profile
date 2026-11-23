# 🏛️ Governance Lifecycle & Scaffold Reference

> Padrões estruturais de diretórios, Makefile POSIX portátil e ciclo de inicialização de repositórios.

---

## 1. Estrutura Canônica de Repositório

```text
<repo-root>/
├── AGENTS.md
├── PRINCIPLES.md
├── CONTRIBUTING.md
├── TODO.md
├── Makefile
├── README.md
├── .gitattributes
├── .gitignore
├── .editorconfig
├── .prettierrc
├── .agents/
│   ├── rules/
│   └── skills/
├── .githooks/
│   ├── commit-msg
│   └── pre-commit
├── .scripts/audit/
└── .github/workflows/
```

---

## 2. Perfis de Stack Suportados

| Perfil        | Stack Principal | Convenções Base                                              |
| :------------ | :-------------- | :----------------------------------------------------------- |
| `c-modern`    | C23             | `-std=c23`, sanitizers, `clang-format`, manpages POSIX       |
| `shell-posix` | POSIX `sh`      | Baseline FreeBSD `sh`, `shellcheck`, quoting defensivo       |
| `cpp-modern`  | C++23           | Concepts, ranges, `std::expected`, wrappers RAII             |
| `go-binary`   | Go              | Binário único estático, embed de assets, SQLite WAL          |
| `python-pure` | Python          | Stdlib ou dependências mínimas, `pyproject.toml`, type hints |
| `latex-doc`   | LaTeX / TeX     | Compilação isolada `-outdir=build`, Makefile POSIX limpo     |

---

## 3. Makefile Base Portátil (`bmake` & `gmake`)

```makefile
.POSIX:
.SILENT:

MAKEFLAGS += --no-print-directory -s

APP      = app
CMD      = src/main.c
VERSION != cat VERSION 2> "/dev/null" || echo 0.1.0-dev
CC      ?= cc
CFLAGS  ?= -Wall -Wextra -Werror -pedantic -std=c23 -O2

.PHONY: all help dev build check format clean

all: help

help:
	_e=$$'\e'; \
	cmd() { printf "    $${_e}[36mmake %-24s$${_e}[0m %s\n" "$$1" "$$2"; }; \
	sec() { printf "\n  $${_e}[1;33m%s$${_e}[0m\n" "$$1"; }; \
	printf "\n  $${_e}[1;37m%s — Catálogo de Comandos$${_e}[0m (v%s)\n" "$(APP)" "$(VERSION)"; \
	printf "  ============================================================\n"; \
	sec "Desenvolvimento & Build:"; \
	cmd "build"  "Compila o binário em bin/"; \
	cmd "dev"    "Compila e executa o binário"; \
	sec "Qualidade & Limpeza:"; \
	cmd "check"  "Executa validação estática"; \
	cmd "format" "Formata código com ferramentas declaradas"; \
	cmd "clean"  "Remove artefatos temporários em bin/"; \
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

---

## 4. Inicialização & Validação Pós-Scaffold

```sh
git init -b main
git config core.hooksPath .githooks
chmod 0755 .githooks/*
make -n && bmake -n
find . -name "*.sh" -not -path "*/.git/*" -exec sh -n {} +
./.githooks/pre-commit
```
