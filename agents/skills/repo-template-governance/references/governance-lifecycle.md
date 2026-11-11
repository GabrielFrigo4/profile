# 🏛️ Governance Lifecycle & Scaffold Reference

> Padrões arquiteturais para scaffold, governança de templates e automação de repositórios no ecossistema.

---

## 1. Padrão de Self-Healing Hooks

Os hooks em `.githooks/` devem ser 100% autônomos em POSIX `sh` (`chmod 0755`) e implementar auto-cura:

- **`pre-commit`:**
    - Auto-cura de permissões octais: executáveis (`.sh`, scripts com `#!`) recebem `chmod 0755` e `git update-index --chmod=+x`; arquivos regulares recebem `0644` e `--chmod=-x`.
    - Auto-cura de formatação: remoção de trailing whitespace e execução do Prettier em arquivos staged.
    - Auto-cura de banners estruturais: execução de `banners.py --fix` para réguas de 32 e 64 colunas.
    - Re-estagiamento automático via `git add` dos arquivos corrigidos antes de finalizar a validação.
- **`commit-msg`:**
    - Suporte a ponto (`.`) no escopo semântico (`feat(sync.sh): ...`).
    - Catálogo de tipos autorizados: `add`, `update`, `fix`, `docs`, `feat`, `chore`, `refactor`, `style`, `ci`, `test`, `sec`, `init`.
    - Auto-normalização para minúsculas, ajuste de espaçamento e prefixo `chore: ` automático para mensagens sem prefixo.

---

## 2. Busca Recursiva Topológica (`upgit`)

Para varredura de árvores Git com múltiplos repositórios e submódulos, utilize o padrão com poda `-prune` e ordenação por profundidade:

```sh
find . \( -type d -name ".git" -print -prune \) -o \( -type f -name ".git" -print \) 2> "/dev/null" | \
	awk '{ n=split($0, a, "/"); print n, $0 }' | \
	sort -n -k1,1 | \
	cut -d' ' -f2-
```

---

## 3. Makefile Canônico Enterprise (Padrão OptiLaser)

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
