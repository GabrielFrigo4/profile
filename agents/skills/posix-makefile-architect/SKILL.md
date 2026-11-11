---
name: posix-makefile-architect
description: Arquiteto cognitivo para Makefiles universais, minimalistas e portáteis entre BSD Make (bmake), GNU Make (gmake) e BusyBox make, com conformidade estrita ao cabeçalho .POSIX: .SILENT: e práticas de código limpo.
---

# 🛠️ POSIX Makefile Architect Skill

Esta habilidade orienta o agente de IA na construção, auditoria e modernização de Makefiles em todo o ecossistema. O objetivo é garantir **portabilidade universal** entre **BSD Make (`bmake`)**, **GNU Make (`gmake`)** e **BusyBox/pdpmake**, sem ruído visual no terminal e com estrutura rigorosamente padronizada.

---

## 🎯 O Cabeçalho Universal Mandatório

Todo Makefile no ecossistema DEVE iniciar rigorosamente com o cabeçalho canônico:

```makefile
.POSIX:
.SILENT:

MAKEFLAGS += --no-print-directory -s
```

1. **`.POSIX:`**: Força conformidade com as especificações POSIX, desativando comportamentos proprietários e padronizando execução via `sh`.
2. **`.SILENT:`**: Suprime a exibição de comandos antes da execução (Regra do Silêncio UNIX).
3. **`MAKEFLAGS += --no-print-directory -s`**: Suprime avisos de troca de diretório no GNU Make e força silêncio em subprocessos.

---

## 🌐 Invocação Recursiva Universal: `(cd subdir && $(MAKE) target)`

Ao invocar targets em submódulos ou subdiretórios, use invariavelmente:

```makefile
(cd subdir && $(MAKE) target)
```

> [!IMPORTANT]
> **Substituição da Flag `-C` pelo Padrão POSIX Estrito:**
> Motores minimalistas e conformes como `pdpmake` e `busybox make` desativam ou rejeitam a flag `-C` quando `.POSIX:` está ativo.
> A invocação em subshell `(cd subdir && $(MAKE) target)` combinada com `.POSIX:`, `.SILENT:` e `MAKEFLAGS += --no-print-directory -s` opera com 100% de integridade e portabilidade em todos os motores: `gmake`, `bmake`, `pdpmake` e `busybox make`.

---

## 🚫 Eliminação de `@` Redundante

Com a diretiva `.SILENT:` declarada no topo, **todas as receitas são executadas silenciosamente por padrão**. O prefixo `@` é estritamente redundante e proibido.

```makefile
build:
	rm -rf bin
	mkdir -p bin
	$(CC) $(CFLAGS) -o bin/app src/main.c
```

---

## ⚙️ Comandos Shell em Variáveis (`!=` vs `$(shell)`)

O operador padrão POSIX e universal para captura de saída de shell em variáveis é **`!=`**. A função `$(shell ...)` do GNU Make é incompatível com o `bmake` do FreeBSD.

- **Incorreto:** `SOURCES = $(shell find src -name '*.c')`
- **Correto:** `SOURCES != find src -name '*.c'`

---

## 🛡️ Compiladores e Flags Defensivas

Utilize atribuições condicionais (`?=`) para permitir sobrescrita por empacotamento ou variáveis de ambiente:

```makefile
CC ?= cc
CFLAGS ?= -O2 -Wall -Wextra -pedantic
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
```

---

## 🏗️ Taxonomia de Comentários em Makefiles

1. **Sistema (Permitidos):** Diretivas `.POSIX:`, `.SILENT:` e `MAKEFLAGS`.
2. **Estruturais (Permitidos):** Banners de topo com 64 hífens (`# ---...---`) e seções de 32 colunas (`### ================================` ou `### --------------------------------`).
3. **Narrativos (Proibidos):** Zero comentários explicativos em código, configs ou blocos Markdown.

---

## 🧪 Validação de Portabilidade

Execute a simulação de execução (_dry-run_) em ambos os motores:

```sh
make -n
bmake -n
```

Nenhum aviso, erro de sintaxe ou ruído de diretório pode ser emitido.
