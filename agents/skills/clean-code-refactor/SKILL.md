---
name: clean-code-refactor
description: >-
    Auditoria e refatoração de código POSIX, dotfiles e scripts, aplicando princípios
    UNIX, Clean Code, taxonomia tripartite de comentários, refatoração Clean-Break
    sem legado e custódia proativa Boy Scout Rule contra desvios adjacentes.
---

# 🧹 Clean Code Refactor & Proactive Quality

Diretrizes para análise estática, padronização POSIX, remoção de resíduos legados (_Clean-Break_) e correção proativa de desvios adjacentes (_Boy Scout Rule_).

---

## 🎯 1. Invariantes de Código & Portabilidade POSIX

1. **Shebang Universal:** Use `#!/usr/bin/env sh` ou `#!/usr/bin/env python3`. Não use caminhos rígidos como `#!/bin/sh` ou `#!/bin/bash`.
2. **Modo Defensivo & Quoting:** Inicie scripts com `set -eu`, proteja variáveis com aspas duplas (`"$var"`) e redirecionamentos com aspas (`> "/dev/null" 2>&1`).
3. **Orçamento de Linhas:** Scripts entre `8` e `256` linhas (sweet spot `16`–`128`); arquivos `SKILL.md` entre `17` e `128` linhas.
4. **Taxonomia Tripartite de Comentários:**
    - _Sistema (Permitido):_ shebangs, pragmas, diretivas de linter (`shellcheck`, `noqa`, `lexical-binding`).
    - _Estrutural (Permitido):_ cabeçalho de `64` hífens nas linhas `2–4`, seções internas com réguas de `32` (`### ================================` / `### --------------------------------`) e títulos MAIÚSCULOS sem parênteses/colchetes, e seções de `64` `=` em `.gitignore`.
    - _Narrativo (Proibido):_ qualquer comentário explicativo em código, configs ou blocos de código dentro de Markdown.
5. **Nomenclatura & Escapes ANSI:** `kebab-case` público, `_snake_case` privado, `SNAKE_CASE` global. Escapes ANSI via `$'\e'` ou `\x1b` (nunca octais `\033`/`\001` para caracteres).
6. **Elevação Segura & Shift Protegido:**
    ```sh
    ELEVATE=""
    if [ "$(id -u)" -ne 0 ]; then
        if command -v doas > "/dev/null" 2>&1; then
            ELEVATE="doas"
        elif command -v sudo > "/dev/null" 2>&1; then
            ELEVATE="sudo"
        fi
    fi
    [ "$#" -ge 1 ] && shift 1
    ```
7. **Permissões Octais em 4 Dígitos:** `0755` para executáveis/hooks/diretórios, `0644` para configs/docs, `0700`/`0600` para cofres/chaves, `0440` para `sudoers.d`.

---

## ⚡ 2. Refatoração Clean-Break (Zero-Cruft)

Em repositórios sob controle direto, não mantenha shims transitórios, aliases de compatibilidade (`alias antigo=novo`) ou fallbacks encadeados (`${VAR_NOVA:-${VAR_ANTIGA}}`):

- Substitua símbolos, variáveis e caminhos atomicamente em todos os consumidores.
- Use exclusivamente `${VAR_NOVA:-default}` sem comentários históricos no código (`git log` preserva o histórico).
- Valide ausência de menções antigas com `rg` e rode as auditorias do projeto.

---

## 🛡️ 3. Custódia Proativa (Boy Scout Rule)

Ao inspecionar ou editar qualquer módulo, corrija imediatamente desvios objetivos adjacentes e notifique concisamente o usuário:

| Dimensão             | Ação Corretiva Imediata                                        |
| :------------------- | :------------------------------------------------------------- |
| **Formatação & EOL** | Rodar formatadores canônicos (`prettier`, `stylua`) e fixar LF |
| **Documentação**     | Garantir `README.md` tabular em pastas e validar links         |
| **Permissões**       | Aplicar `chmod 0755` / `0644` no disco e no Git Index          |
| **Comentários**      | Expurgar comentários narrativos e ajustar réguas `64`/`32`     |
| **Segurança**        | Remover caminhos pessoais hardcoded, IPs ou segredos expostos  |

---

## 📋 4. Templates Base (`resources/templates/`)

| Tipo                | Arquivo                                                                              |
| :------------------ | :----------------------------------------------------------------------------------- |
| **POSIX Recipe**    | [`resources/templates/recipe.sh`](resources/templates/recipe.sh)                     |
| **POSIX CLI Util**  | [`resources/templates/utility.sh`](resources/templates/utility.sh)                   |
| **PowerShell**      | [`resources/templates/recipe.ps1`](resources/templates/recipe.ps1)                   |
| **Batch (CMD)**     | [`resources/templates/recipe.cmd`](resources/templates/recipe.cmd)                   |
| **README Raiz**     | [`resources/templates/readme-root.md`](resources/templates/readme-root.md)           |
| **README Subpasta** | [`resources/templates/readme-subfolder.md`](resources/templates/readme-subfolder.md) |
