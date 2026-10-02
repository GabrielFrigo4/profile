---
name: clean-code-refactor
description: Runbook cognitivo para auditoria e refatoração de código POSIX, scripts de shell e dotfiles conforme os 22 princípios de engenharia UNIX + Clean Code do ecossistema.
---

# 🧹 Clean Code Refactor Skill

Esta habilidade orienta o agente de inteligência artificial na análise estática, auditoria de qualidade, padronização e refatoração de scripts, documentações e configurações do ecossistema.

---

## 🎯 Diretrizes de Engenharia & Invariantes

Ao refatorar ou auditar qualquer arquivo no ecossistema:

1. **Shebang Universal:**
    - Utilize sempre `#!/usr/bin/env sh` para scripts de shell e `#!/usr/bin/env python3` para Python.
    - Evite `#!/bin/sh` ou `#!/bin/bash` rígidos para garantir portabilidade em FreeBSD, Linux e macOS.
2. **Modo Defensivo:**
    - Todo script executável de shell deve iniciar com `set -eu` (ou `set -euo pipefail` quando compatível com o parser).
3. **Orçamento de Linhas (Regra 8 - 128):**
    - **Piso:** 8 linhas úteis. Scripts menores devem ser justificados ou consolidados.
    - **Teto:** 128 linhas úteis. Scripts maiores devem ser modularizados em submódulos temáticos.
4. **Arquitetura de Comentários em Três Camadas (Regra do Não-Vazamento):**
    - **Camada 1 (Header Banner - 64 `-`):** Linhas 2 a 4 de scripts utilitários e receitas:
        ```sh
        # ----------------------------------------------------------------
        # Recipe: [Nome do Software / Funcionalidade]
        # ----------------------------------------------------------------
        ```
    - **Camada 2 (Delimitadores Estruturais de Corpo - 32 Caracteres):**
        - Seções Principais (32 `=`): `### ================================`
        - Subseções Internas (32 `-`): `### --------------------------------`
        - _Regra do Não-Vazamento:_ O título tem no máximo 32 caracteres (36 colunas com `### `) e não vaza a régua. Títulos semânticos, sem parênteses e sem números avulsos.
    - **Camada 3 (Zero Comentários Narrativos):** Evite o uso de comentários óbvios que apenas narram o código. O código deve ser autoexplicativo, usando separação lógica por linhas em branco.
5. **Aspas em Variáveis & Quoting Defensivo:**
    - Toda expansão de variável entre aspas duplas: `"${VAR}"`, `"${HOME}"`.
    - Redirecionamentos sempre protegidos por aspas: `> "/dev/null" 2>&1`.
6. **Nomenclatura Canônica:**
    - Comandos e utilitários públicos: `kebab-case` (`vault-keys`, `update-all`).
    - Helpers internos e variáveis locais: `_snake_case` (`_as_root`, `_repo_root`).
    - Variáveis globais de ambiente e constantes: `SNAKE_CASE` (`PATH`, `SHELL_REPO_DIR`, `VAULT_DIR`).
7. **Elevação Canônica de Privilégios (POSIX):**
    ```sh
    ELEVATE="$( [ "$(id -u)" -ne 0 ] && { command -v doas > "/dev/null" 2>&1 && echo "doas" || { command -v sudo > "/dev/null" 2>&1 && echo "sudo"; }; } )"
    ```
8. **Permissões em 4 Dígitos Octais:**
    - Scripts públicos (`Setup`, `Profile`, `Shell`): `chmod 0755`
    - Configurações e documentações públicas: `chmod 0644`
    - Scripts e diretórios restritos (`Vault`): `chmod 0700`
    - Chaves privadas e segredos (`Vault`): `chmod 0600`
    - Arquivos do sistema (`sudoers.d`): `chmod 0440`
9. **Auditoria Estática de Comentários & Banners:**
    - Utilize o utilitário integrado: `python3 scripts/audit_comments.py [caminho]`.
10. **Emissão Semântica de UI:**
    - Em utilitários e interfaces CLI (`update-*`), adote a biblioteca semântica `_ui_*` (`_ui_step`, `_ui_ok`, `_ui_warn`, `_ui_err`, `_ui_banner`) com detecção segura de TTY (`_ui_has_color`).
    - Saídas simples (`echo "📦 ..."` e `echo "✅ ..."`) são reservadas a receitas de provisionamento do sistema operacional (`Setup`).
11. **Padrão de Sincronização Resiliente & Auto-Cura de Repositórios:**
    - Rotinas de atualização e `git pull` adotam a estratégia em 4 etapas:
        1. _Auto-cura Cirúrgica de Atributos:_ Inspecionar `git diff --numstat`. Arquivos com `0 0 <arquivo>` (alteração pura de permissão POSIX/filemode) são restaurados via `git checkout -- <arquivo>` imediatamente, sem criar stashes supérfluos.
        2. _Isolamento Defensivo:_ Auto-stash com timestamp apenas para alterações reais em arquivos de código.
        3. _Cascata de Sincronização:_ `--ff-only` $\rightarrow$ `--rebase` $\rightarrow$ `pull`.
        4. _Restauração:_ Restaurar alterações locais via `stash pop` e assegurar `chmod 0755` nos hooks de `.githooks/`.

---

## 📋 Modelos Canônicos Estruturados (`resources/templates/`)

Os templates oficiais de código e documentação residem modularmente na pasta [`resources/templates/`](./resources/templates/):

| Domínio / Formato      | Tipo de Template                                               | Arquivo Canônico                                                                       |
| :--------------------- | :------------------------------------------------------------- | :------------------------------------------------------------------------------------- |
| **POSIX Shell (`sh`)** | Receita de provisionamento atômica (`set -eu`, `ELEVATE`)      | [`resources/templates/recipe.sh`](./resources/templates/recipe.sh)                     |
| **POSIX Shell (`sh`)** | Utilitário CLI com interface semântica (`_ui_*`)               | [`resources/templates/utility.sh`](./resources/templates/utility.sh)                   |
| **PowerShell (`ps1`)** | Script defensivo com `$ErrorActionPreference = 'Stop'`         | [`resources/templates/recipe.ps1`](./resources/templates/recipe.ps1)                   |
| **Batch (`cmd`)**      | Script Batch encapsulado com `setlocal enabledelayedexpansion` | [`resources/templates/recipe.cmd`](./resources/templates/recipe.cmd)                   |
| **Markdown (`md`)**    | Portal institucional raiz de repositório                       | [`resources/templates/readme-root.md`](./resources/templates/readme-root.md)           |
| **Markdown (`md`)**    | Catálogo tabular de receitas em subpastas                      | [`resources/templates/readme-subfolder.md`](./resources/templates/readme-subfolder.md) |

---

## 🛡️ Regra da Proatividade e Correção Oportunista (Boy Scout Rule)

O agente de IA **DEVE SER ATIVAMENTE PROATIVO** na manutenção e aplicação dos padrões canônicos.

Se durante a execução de qualquer tarefa o agente identificar qualquer linha fora dos padrões:

1. **Notificar concisamente** o usuário sobre a divergência encontrada.
2. **Corrigir imediatamente a inconformidade**: eliminar comentários narrativos, ajustar banners (64 no header / 32 no corpo), remover bashismos, garantir `#!/usr/bin/env sh`, eliminar octais (`\033`) para ANSI/bytes, cotar caminhos e garantir modos de 4 dígitos.

---

## 📚 Literatura de Referência & Leitura Altamente Recomendada

- **Obra Canônica de Clean Code:** _Clean Code: A Handbook of Agile Software Craftsmanship_ (Robert C. Martin "Uncle Bob", 2008, Prentice Hall).
- **Obra Canônica de Filosofia UNIX:** _The Art of UNIX Programming_ (Eric S. Raymond, 2003, Addison-Wesley Professional).
    - Portal da obra: <http://www.catb.org/~esr/writings/taoup/> | Texto integral: <http://www.catb.org/~esr/writings/taoup/html/>
- **Prática de Programação e Estilo:** _The Practice of Programming_ (Brian W. Kernighan & Rob Pike, 1999, Addison-Wesley).
