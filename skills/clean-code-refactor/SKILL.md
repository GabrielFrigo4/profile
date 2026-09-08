---
name: clean-code-refactor
description: Runbook cognitivo para auditoria e refatoração de código POSIX, scripts de shell e dotfiles conforme os 18 princípios Clean Code do ecossistema.
---

# 🧹 Clean Code Refactor Skill

Esta habilidade orienta o agente de inteligência artificial na análise estática, auditoria de qualidade e refatoração de scripts e configurações do ecossistema.

---

## 🎯 Diretrizes de Engenharia & Invariantes

Ao refatorar qualquer script ou configuração:

1. **Shebang Universal:**
   - Utilize sempre `#!/usr/bin/env sh` para scripts de shell.
   - Evite `#!/bin/sh` ou `#!/bin/bash` rígidos para garantir portabilidade em FreeBSD e macOS.

2. **Modo Defensivo:**
   - Todo script executável deve iniciar com `set -eu` (ou `set -euo pipefail` quando compatível com o parser).

3. **Orçamento de Linhas (Regra 8 - 128):**
   - Scripts não devem ultrapassar 128 linhas úteis. Se uma receita estiver crescendo além desse limite, decomponha em módulos ou invoque submódulos em pastas específicas.
   - Scripts com menos de 8 linhas devem ser avaliados quanto à real necessidade de existência ou consolidados.

4. **Regra de Comentários Estruturais (32 Caracteres):**
   - **Seções Principais:** Exatamente 32 caracteres de `=`
     ```sh
     ### ================================
     ### TITULO DA SECAO PRINCIPAL
     ### ================================
     ```
   - **Subseções:** Exatamente 32 caracteres de `-`
     ```sh
     ### --------------------------------
     ### Nome da Subsecao
     ### --------------------------------
     ```
   - Nenhum título pode vazar ou exceder as 32 colunas da régua.

5. **Aspas em Variáveis:**
   - Toda expansão de variável deve estar entre aspas duplas: `"${VAR}"`, `"${HOME}"`.

6. **Nomenclatura Canônica:**
   - Comandos públicos: `kebab-case` (`vault-keys`, `update-all`).
   - Helpers e variáveis locais: `_snake_case` (`_repo_root`, `_as_root`).
   - Variáveis globais: `SNAKE_CASE` (`PATH`, `SHELL_REPO_DIR`).
