---
name: repo-template-generator
description: Runbook cognitivo para geração e scaffold de novos repositórios completos a partir de templates canônicos por linguagem (C99/POSIX, Shell, C++23, Go, Python, LaTeX).
---

# 🚀 Repo Template Generator Skill

Esta habilidade orienta o agente de IA na criação do zero de novos repositórios de projetos no ecossistema, gerando estrutura de diretórios completa, governança, Makefiles POSIX silenciosos, githooks defensivos, pipelines de CI e arquivos fundamentais.

---

## 🏗️ Perfis de Repositórios Suportados

Ao solicitar a criação de um novo repositório, o agente deve selecionar o perfil adequado:

1. **`c-posix`**: Utilitários e sistemas Unix em C99 estrito, Makefile POSIX, manpage, linters clang-format e sanitizers.
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

### 2. Criação do `Makefile` Canônico

Todo repositório gerado inicia obrigatoriamente com:

```makefile
.POSIX:
.SILENT:

MAKEFLAGS += --no-print-directory -s

# ----------------------------------------------------------------
# Makefile: <Nome do Projeto>
# ----------------------------------------------------------------

CC      ?= cc
CFLAGS  ?= -Wall -Wextra -Werror -pedantic -std=c99 -O2

.PHONY: all check format clean help

all: build

help:
	echo "Comandos disponíveis:"
	echo "  make all     - Compila os binários do projeto"
	echo "  make check   - Executa testes estáticos e validações"
	echo "  make format  - Formata código com ferramentas canônicas"
	echo "  make clean   - Remove artefatos de compilação"

build:
	$(CC) $(CFLAGS) src/main.c -o bin/app

check:
	$(CC) $(CFLAGS) -fsyntax-only src/main.c

format:
	find . -type f \( -name "*.c" -o -name "*.h" \) -exec clang-format -i {} +

clean:
	rm -rf bin/
```

### 3. Criação de `AGENTS.md` e `PRINCIPLES.md`

- Utilize a skill `repo-governance-bootstrap` para popular `AGENTS.md` com a identidade e comandos do projeto.
- Gere o `PRINCIPLES.md` contextualizando os 18 princípios ao domínio específico da linguagem e negócio.

### 4. Permissões Canônicas

```sh
chmod 0755 .githooks/*
chmod 0644 Makefile AGENTS.md PRINCIPLES.md README.md .gitignore
```

### 5. Commit Inicial Canônico

```sh
git add .
git commit -m "add: initial repository scaffolding with canonical governance"
```
