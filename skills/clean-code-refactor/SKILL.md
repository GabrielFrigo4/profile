---
name: clean-code-refactor
description: Runbook cognitivo para auditoria e refatoração de código POSIX, scripts de shell e dotfiles conforme os 18 princípios Clean Code do ecossistema.
---

# 🧹 Clean Code Refactor Skill

Esta habilidade orienta o agente de inteligência artificial na análise estática, auditoria de qualidade, padronização e refatoração de scripts, documentações e configurações do ecossistema.

---

## 🎯 Diretrizes de Engenharia & Invariantes

Ao refatorar ou auditar qualquer arquivo no ecossistema:

1. **Shebang Universal:**
    - Utilize sempre `#!/usr/bin/env sh` para scripts de shell.
    - Evite `#!/bin/sh` ou `#!/bin/bash` rígidos para garantir portabilidade em FreeBSD, Linux e macOS.

2. **Modo Defensivo:**
    - Todo script executável de shell deve iniciar com `set -eu` (ou `set -euo pipefail` quando compatível com o parser).

3. **Orçamento de Linhas (Regra 8 - 128):**
    - **Piso:** 8 linhas úteis. Scripts menores devem ser justificados ou consolidados.
    - **Teto:** 128 linhas úteis. Scripts maiores devem ser modularizados em submódulos temáticos.

4. **Arquitetura de Comentários em Três Camadas (Regra do Não-Vazamento):**
    - **Camada 1 (Header Banner - 64 `-`):** Exclusivo para as linhas 2 a 4 de scripts utilitários e receitas:
        ```sh
        # ----------------------------------------------------------------
        # Recipe: [Nome do Software / Funcionalidade]
        # ----------------------------------------------------------------
        ```
    - **Camada 2 (Delimitadores Estruturais de Corpo - 32 Caracteres):**
        - Seções Principais (32 `=`):
            ```sh
            ### ================================
            ### NOME DA SECAO PRINCIPAL
            ### ================================
            ```
        - Subseções Internas (32 `-`):
            ```sh
            ### --------------------------------
            ### Nome da Subsecao
            ### --------------------------------
            ```
        - **Regra Estrita do Não-Vazamento:** O texto do título DEVE ter no máximo 32 caracteres (total de 36 colunas contando `### `) e JAMAIS vazar além da régua divisora. Títulos puramente semânticos, sem parênteses e sem numerações arbitrárias.
    - **Camada 3 (Zero Comentários Narrativos):** É expressamente proibido o uso de comentários explicativos ou narrativos inline ("faz isso", "executa aquilo") em scripts, dotfiles, blocos de código markdown ou templates. O código deve ser autoexplicativo, utilizando separação lógica por linhas em branco.

5. **Aspas em Variáveis & Quoting Defensivo:**
    - Toda expansão de variável deve estar entre aspas duplas: `"${VAR}"`, `"${HOME}"`.
    - Redirecionamentos para `/dev/null` sempre protegidos por aspas: `> "/dev/null"` e `2> "/dev/null"`.

6. **Nomenclatura Canônica:**
    - Comandos e utilitários públicos: `kebab-case` (`vault-keys`, `update-all`).
    - Helpers internos e variáveis locais: `_snake_case` (`_as_root`, `_repo_root`).
    - Variáveis globais de ambiente e constantes: `SNAKE_CASE` (`PATH`, `SHELL_REPO_DIR`, `VAULT_DIR`).

7. **Elevação Canônica de Privilégios (POSIX):**
    - Sempre utilize a forma compacta e defensiva de checagem do `ELEVATE`:
        ```sh
        ELEVATE="$( [ "$(id -u)" -ne 0 ] && { command -v doas > "/dev/null" 2>&1 && echo "doas" || { command -v sudo > "/dev/null" 2>&1 && echo "sudo"; }; } )"
        ```

8. **Permissões em 4 Dígitos Octais:**
    - Scripts públicos (`Setup`, `Profile`, `Shell`): `chmod 0755`
    - Configurações e documentações públicas: `chmod 0644`
    - Scripts e diretórios restritos (`Vault`): `chmod 0700`
    - Chaves privadas e segredos (`Vault`): `chmod 0600`
    - Arquivos do sistema (`sudoers.d`): `chmod 0440`

---

## 📋 Templates Canônicos de Scripts (Sem Comentários Narrativos)

### 1. Template POSIX Shell (`.sh`)

```sh
#!/usr/bin/env sh
# ----------------------------------------------------------------
# Recipe: [Nome do Software / Funcionalidade]
# ----------------------------------------------------------------
set -eu

echo "📦 [Nome]: Iniciando configuração..."

ELEVATE="$( [ "$(id -u)" -ne 0 ] && { command -v doas > "/dev/null" 2>&1 && echo "doas" || { command -v sudo > "/dev/null" 2>&1 && echo "sudo"; }; } )"

echo "✅ [Nome]: Configurado com sucesso!"
```

### 2. Template PowerShell (`.ps1`)

```powershell
<#
# ----------------------------------------------------------------
# Recipe: [Nome do Software / Funcionalidade]
# ----------------------------------------------------------------
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

Write-Host "📦 [Nome]: Iniciando configuracao..." -ForegroundColor Cyan

Write-Host "✅ [Nome]: Configurado com sucesso!" -ForegroundColor Green
```

### 3. Template Batch (`.cmd`)

```cmd
@echo off
setlocal enabledelayedexpansion
rem ----------------------------------------------------------------
rem Recipe: [Nome do Software / Funcionalidade]
rem ----------------------------------------------------------------

echo [*] [Nome]: Iniciando configuracao...

echo [V] [Nome]: Configurado com sucesso!
endlocal
```

---

## 📚 Templates Canônicos de Documentação (READMEs)

### 1. Template de README Raiz (Portal Institucional)

````markdown
# [Emoji] [Nome do Repositório] — [Subtítulo Conciso]

> [Declaração de missão institucional e invariantes do repositório em uma ou duas frases].

---

## 🏛️ O Quarteto de Produtividade

| Repositório                                             | Visibilidade | Papel Central                              | Escopo & Privilégios                         |
| :------------------------------------------------------ | :----------- | :----------------------------------------- | :------------------------------------------- |
| **[Setup](https://github.com/GabrielFrigo4/setup)**     | Público      | Provisionamento ativo de SO e pacotes      | Nível SO / Privilegiado (`root` / `ELEVATE`) |
| **[Shell](https://github.com/GabrielFrigo4/shell)**     | Público      | Motor interativo de terminal e prompts     | Nível Shell / Sessão do Terminal             |
| **Vault**                                               | Privado      | Cofre criptográfico, chaves SSH e segredos | Usuário Restrito (`0700` / `0600`)           |
| **[Profile](https://github.com/GabrielFrigo4/profile)** | Público      | Dotfiles declarativos, editores e IA       | Nível Usuário (`$HOME`, sem privilégios)     |

---

## 📂 Catálogo de Diretórios

| Diretório          | Descrição                                       |
| :----------------- | :---------------------------------------------- |
| [`pasta/`](pasta/) | Descrição do propósito dos arquivos nesta pasta |

---

## 🚀 Como Usar

[Instruções concisas de clone ou execução].

---

## 🧪 Auditoria & Quality Gates

```sh
python3 scripts/audit/all.py
```
````

### 2. Template de README de Subpasta (Catálogo Tabular)

````markdown
# [Emoji] [Nome da Categoria] — Catálogo de Receitas

> [Descrição concisa do propósito desta subpasta e escopo de ferramentas].

---

## 📂 Catálogo de Arquivos

| Arquivo / Receita          | Descrição                             | Plataforma     |
| :------------------------- | :------------------------------------ | :------------- |
| [`exemplo.sh`](exemplo.sh) | Provisionamento do utilitário exemplo | Linux, FreeBSD |

---

## 🚀 Como Usar

```sh
sh ./exemplo.sh
```
````

---

## 🛡️ Regra da Proatividade e Correção Oportunista (Boy Scout Rule)

O agente de IA **DEVE SER ATIVAMENTE PROATIVO** na manutenção e aplicação dos padrões canônicos.

Se durante a execução de qualquer tarefa (seja criação de features, correções pontuais, refatorações ou investigação) o agente identificar qualquer linha de código, script, Makefile ou documentação fora dos padrões estabelecidos, **NÃO DEVE HESITAR NEM IGNORAR**:

1. **Notificar concisamente** o usuário sobre a divergência encontrada.
2. **Corrigir imediatamente a inconformidade**, aplicando o padrão canônico correspondente:
    - **Comentários Narrativos:** Eliminar imediatamente comentários óbvios que apenas narram código executável.
    - **Banners Estruturais:** Ajustar réguas para exatamente 64 hífens no topo ou 32 caracteres com `### ` no corpo.
    - **Portabilidade POSIX:** Substituir bashismos (`[[ ]]`, `&>`, arrays, `source`) por sintaxe estrita POSIX `/bin/sh`.
    - **Shebang Universal:** Garantir sempre `#!/usr/bin/env sh` ou `#!/usr/bin/env python3`.
    - **Sequências ANSI:** Substituir octais crípticos (`\033`) e `printf` desnecessário por `[ -t 1 ] && echo -n $'\e...'`.
    - **Redirecionamento Seguro:** Envolver destinos em aspas duplas (ex: `> "/dev/null" 2>&1`).
    - **Makefiles:** Assegurar cabeçalho `.POSIX: .SILENT:`, `MAKEFLAGS += --no-print-directory -s`, alinhamento estético de variáveis e zero `@` redundante.
    - **Permissões Canônicas:** Aplicar 4 dígitos octais (`chmod 0755`, `chmod 0644`, `chmod 0700`, `chmod 0600`).

---

## 📚 Literatura de Referência & Leitura Altamente Recomendada

Recomenda-se enfaticamente ao agente de IA e aos operadores o estudo das obras que fundamentam as práticas desta habilidade:

- **Obra Canônica de Clean Code:** _Clean Code: A Handbook of Agile Software Craftsmanship_ (Robert C. Martin "Uncle Bob", 2008, Prentice Hall).
    - Define a Boy Scout Rule ("Deixe a área de acampamento mais limpa do que como você a encontrou"), a refatoração contínua e a premissa de que comentários óbvios representam falhas em expressar intenção diretamente pelo código.
- **Obra Canônica de Filosofia UNIX:** _The Art of UNIX Programming_ (Eric S. Raymond, 2003, Addison-Wesley Professional).
    - Disponível abertamente em: <http://www.catb.org/~esr/writings/taoup/html/>
- **Prática de Programação e Estilo:** _The Practice of Programming_ (Brian W. Kernighan & Rob Pike, 1999, Addison-Wesley).
