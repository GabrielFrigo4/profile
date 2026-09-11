---
name: posix-makefile-architect
description: Arquiteto cognitivo para Makefiles universais, minimalistas e portáteis entre BSD Make (bmake) e GNU Make (gmake), com conformidade estrita ao cabeçalho .POSIX: .SILENT: e práticas de código limpo.
---

# 🛠️ POSIX Makefile Architect Skill

Esta habilidade orienta o agente de IA na construção, auditoria e modernização de Makefiles em todo o ecossistema. O objetivo é garantir **portabilidade universal** entre **BSD Make (`bmake`)** (padrão no FreeBSD, OpenBSD e NetBSD) e **GNU Make (`gmake`)** (padrão em distribuições Linux), sem ruído visual no terminal e com estrutura rigorosamente padronizada.

---

## 🎯 O Cabeçalho Universal Mandatório

Todo Makefile no ecossistema DEVE iniciar rigorosamente com o seguinte cabeçalho canônico:

```makefile
.POSIX:
.SILENT:

MAKEFLAGS += --no-print-directory -s
```

### Justificativas Técnicas:

1. **`.POSIX:`**: Força o Make a operar em conformidade com as especificações POSIX, desativando comportamentos proprietários arriscados e padronizando a execução de comandos via `/bin/sh`.
2. **`.SILENT:`**: Suprime a exibição padrão de linhas de comando antes da execução. Permite que o Makefile opere sob a **Regra do Silêncio** do UNIX, emitindo saída apenas quando houver erro ou quando explicitamente solicitado.
3. **`MAKEFLAGS += --no-print-directory -s`**: Garante que o GNU Make não polua o terminal com avisos de troca de diretório (`Entering/Leaving directory`) e força a execução silenciosa em subprocessos aninhados.

---

## ⚡ A Exceção Pragmática: `$(MAKE) -C subdir target`

> [!IMPORTANT]
> **Exceção Deliberada ao POSIX Estrito:**
> Embora a flag `-C` não esteja formalmente no padrão POSIX IEEE 1003.1 para o comando `make`, ela é **nativamente suportada por ambos os motores principais: `bmake` (BSD) e `gmake` (GNU)**.
>
> Portanto, o ecossistema **EXIGE** o uso de:
>
> ```makefile
> $(MAKE) -C subdir target
> ```
>
> em vez da forma burocrática em subshell:
>
> ```makefile
> # Evitar quando não houver necessidade:
> (cd subdir && $(MAKE) target)
> ```
>
> IAs e ferramentas automatizadas **NÃO DEVEM** "refatorar" chamadas `-C` para `cd && make`.

---

## 🚫 Eliminação de `@` Redundante

Com a diretiva `.SILENT:` declarada no topo do arquivo, **TODAS as receitas de comandos já são executadas silenciosamente por padrão**.

**Anti-padrão (Redundância Visual):**

```makefile
build:
	@rm -rf bin
	@mkdir -p bin
	@$(CC) $(CFLAGS) -o bin/app src/main.c
```

**Padrão Canônico Limpo:**

```makefile
build:
	rm -rf bin
	mkdir -p bin
	$(CC) $(CFLAGS) -o bin/app src/main.c
```

---

## ⚙️ Execução de Comandos de Shell em Variáveis (`!=` vs `$(shell)`)

No GNU Make, comandos dinâmicos frequentemente usam `$(shell cmd)`. No entanto, **o `bmake` do FreeBSD NÃO reconhece a função `$(shell ...)` por padrão**, resultando em falha crítica de sintaxe.

Ambos os motores modernos (`bmake` e `gmake 4.0+`) suportam o operador padrão POSIX de atribuição de shell: **`!=`**.

- **Incorreto (Incompatível com `bmake`):**
    ```makefile
    SOURCES = $(shell find src -name '*.c')
    ```
- **Correto (Universal e Portátil):**
    ```makefile
    SOURCES != find src -name '*.c'
    ```

---

## 🛡️ Compiladores e Flags Defensivas

Sempre utilize atribuições condicionais (`?=`) para permitir sobrescrita por variáveis de ambiente ou pelo empacotamento de distribuições:

```makefile
CC ?= cc
CXX ?= c++
CFLAGS ?= -O2 -Wall -Wextra -pedantic
CXXFLAGS ?= -O2 -Wall -Wextra -std=c++23
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man
```

- NUNCA force `gcc` ou `g++` diretamente, pois no FreeBSD, macOS e OpenBSD o compilador padrão do sistema é o Clang (`cc` e `c++`).

---

## 🏗️ Estrutura de Banners em Makefiles

Makefiles complexos devem seguir o padrão estrutural de 2 camadas de comentários:

```makefile
# ----------------------------------------------------------------
# COMPILER CONFIGURATION & FLAGS
# ----------------------------------------------------------------

CC ?= cc
CFLAGS ?= -O2 -Wall

### ================================
### BUILD TARGETS
### ================================

all: build

build:
	mkdir -p bin
	$(CC) $(CFLAGS) -o bin/app src/main.c

### ================================
### CLEANUP
### ================================

clean:
	rm -rf bin
```

---

## 🧪 Validação de Portabilidade Obrigatória

Antes de finalizar qualquer alteração em um Makefile, o agente DEVE executar a simulação de execução (_dry-run_) em ambos os motores:

```sh
# 1. Testar no GNU Make
make -n

# 2. Testar no BSD Make (quando bmake estiver instalado)
bmake -n
```

Nenhum aviso, erro de sintaxe ou ruído de diretório pode ser emitido.
