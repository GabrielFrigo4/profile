---
name: clean-code-refactor
description: >-
    Runbook cognitivo para auditoria e refatoração de código POSIX, scripts de shell,
    dotfiles e execução de Clean-Break (Zero-Cruft) conforme os princípios de engenharia
    UNIX e Clean Code do ecossistema soberano.
---

# 🧹 Clean Code Refactor Skill

Esta habilidade orienta o agente de inteligência artificial na análise estática, auditoria de qualidade, padronização e refatoração de scripts, documentações e configurações do ecossistema.

---

## 🎯 Diretrizes de Engenharia & Invariantes

Ao refatorar ou auditar qualquer arquivo no ecossistema:

1. **Shebang Universal:**
    - O script DEVE utilizar sempre `#!/usr/bin/env sh` para scripts de shell e `#!/usr/bin/env python3` para Python.
    - É VEDADO o uso de `#!/bin/sh` ou `#!/bin/bash` rígidos para assegurar portabilidade entre FreeBSD, Linux e macOS.
2. **Modo Defensivo:**
    - Todo script executável de shell DEVE iniciar com `set -eu` (ou `set -euo pipefail` quando compatível com o interpretador).
3. **Orçamento de Linhas (Regra 8 - 128):**
    - **Piso:** 8 linhas úteis. Scripts menores DEVEM ser justificados ou consolidados.
    - **Teto:** 128 linhas úteis. Scripts maiores DEVEM ser modularizados em submódulos temáticos.
4. **Arquitetura de Comentários em Três Camadas (Regra do Não-Vazamento):**
    - **Camada 1 (Header Banner - 64 `-`):** Linhas 2 a 4 de scripts utilitários e receitas DEVEM conter:
        ```sh
        # ----------------------------------------------------------------
        # Recipe: [Nome do Software / Funcionalidade]
        # ----------------------------------------------------------------
        ```
    - **Camada 2 (Delimitadores Estruturais de Corpo - 32 Caracteres):**
        - Seções Principais (32 `=`): `### ================================`
        - Subseções Internas (32 `-`): `### --------------------------------`
        - _Regra do Não-Vazamento:_ O título DEVE ter no máximo 32 caracteres (36 colunas com `### `) e NÃO DEVE vazar a régua. Títulos semânticos, sem parênteses e sem números avulsos.
    - **Camada 3 (Zero Comentários Narrativos):** É VEDADO o uso de comentários redundantes que apenas narram o código executável. O código DEVE ser autoexplicativo, utilizando separação lógica por linhas em branco.
5. **Aspas em Variáveis & Quoting Defensivo:**
    - Toda expansão de variável DEVE ser encapsulada em aspas duplas: `"${VAR}"`, `"${HOME}"`.
    - Redirecionamentos DEVEM ser protegidos por aspas duplas: `> "/dev/null" 2>&1`.
6. **Nomenclatura Canônica:**
    - Comandos e utilitários públicos DEVEM adotar `kebab-case` (`vault-keys`, `update-all`).
    - Helpers internos e variáveis locais DEVEM adotar `_snake_case` (`_as_root`, `_repo_root`).
    - Variáveis globais de ambiente e constantes DEVEM adotar `SNAKE_CASE` (`PATH`, `SHELL_REPO_DIR`, `VAULT_DIR`).
7. **Elevação Canônica de Privilégios (POSIX) & Shift Seguro:**
    ```sh
    ELEVATE=""
    if [ "$(id -u)" -ne 0 ]; then
        if command -v doas > "/dev/null" 2>&1; then
            ELEVATE="doas"
        elif command -v sudo > "/dev/null" 2>&1; then
            ELEVATE="sudo"
        fi
    fi
    ```
    - O comando `shift` em POSIX DEVE sempre ser precedido de validação de parâmetros (`[ "$#" -ge N ] && shift N`), evitando quebra fatal sob `set -e` quando executado com menos argumentos.
8. **Permissões em 4 Dígitos Octais:**
    - Scripts públicos (`Setup`, `Profile`, `Shell`): `chmod 0755`
    - Configurações e documentações públicas: `chmod 0644`
    - Scripts e diretórios restritos (`Vault`): `chmod 0700`
    - Chaves privadas e segredos (`Vault`): `chmod 0600`
    - Arquivos do sistema (`sudoers.d`): `chmod 0440`
9. **Auditoria Estática de Comentários & Banners:**
    - O agente DEVE utilizar o utilitário integrado para auditoria: `python3 scripts/audit_comments.py [caminho]`.
10. **Emissão Semântica de UI:**
    - Em utilitários e interfaces CLI (`update-*`), o agente DEVE adotar exclusivamente a biblioteca semântica `_ui_*` (`_ui_step`, `_ui_ok`, `_ui_warn`, `_ui_err`, `_ui_banner`) com detecção segura de TTY (`_ui_has_color`).
    - Saídas simples com emojis soltos (`echo "📦 ..."` e `echo "✅ ..."`) são reservadas a receitas de provisionamento do sistema operacional (`Setup`).
11. **Padrão de Sincronização Resiliente & Auto-Cura de Repositórios:**
    - Rotinas de atualização e `git pull` DEVEM adotar a estratégia em 4 etapas:
        1. _Auto-cura Cirúrgica de Atributos:_ Inspecionar `git diff --numstat`. Arquivos com `0 0 <arquivo>` (alteração pura de permissão POSIX/filemode) DEVEM ser restaurados via `git checkout -- <arquivo>` imediatamente, sem criar stashes supérfluos.
        2. _Isolamento Defensivo:_ Auto-stash com timestamp apenas para alterações reais em arquivos de código.
        3. _Cascata de Sincronização:_ `--ff-only` $\rightarrow$ `--rebase` $\rightarrow$ `pull`.
        4. _Restauração:_ Restaurar alterações locais via `stash pop` e assegurar `chmod 0755` nos hooks de `.githooks/`.

---

## ⚡ Refatoração Sem Legado (Clean-Break & Zero-Cruft)

Por operar em um ecossistema estritamente monousuário governado pelo desenvolvedor soberano, introduzir shims de retrocompatibilidade, aliases de transição ou fallbacks de variáveis obsoletas constitui débito técnico injustificado e poluição de código.

Toda refatoração DEVE ser atômica, direta e definitiva:

1. **Substituição Atômica Global:**
    - Ao renomear comandos, funções, arquivos ou variáveis, o agente DEVE aplicar a alteração em todos os pontos de consumo em um único commit atômico.
    - É VEDADO criar shims transitórios, aliases de equivalência (`alias antigo=novo`) ou pontes de legado.
2. **Eliminação de Fallbacks Encadeados:**
    - É VEDADO encadear variáveis legadas para compatibilidade (ex: `${VAR_NOVA:-${VAR_ANTIGA}}`).
    - Utilize estritamente a variável canônica com seu valor padrão: `${VAR_NOVA:-default}`.
3. **Zero Comentários de Descontinuação:**
    - O código NÃO DEVE conter marcadores históricos como `# antigo nome`, `# legado` ou `# deprecated`.
    - O histórico de evolução DEVE residir exclusivamente no controle de versão (`git log`).
4. **Matriz de Decisão: Manutenção vs. Expurgo:**

| Dimensão                  | Software Público / SemVer           | Ecossistema Soberano (Clean-Break)          |
| :------------------------ | :---------------------------------- | :------------------------------------------ |
| **Público-Alvo**          | Múltiplos consumidores externos     | Usuário único soberano                      |
| **Compatibilidade**       | Ciclo gradual de depreciação        | Substituição atômica e imediata             |
| **Aliases & Wrappers**    | Mantidos temporariamente            | **Proibidos:** eliminados sumariamente      |
| **Variáveis Antigas**     | Fallback em cascata                 | **Proibidas:** removidas de imediato        |
| **Comentários de Código** | Marcadores de descontinuação        | **Vedados:** zero ruído histórico no código |
| **Postura do Agente**     | Manter suporte a versões anteriores | **Executar clean-break direto e completo**  |

5. **Protocolo Operacional de Execução:**
    - **Variáveis de Ambiente:** Atualize diretamente os arquivos canônicos (`hosts.env`, configs, loaders) sem criar variáveis espelho (`VAR_ANTIGA="${VAR_NOVA}"`).
    - **Aliases & Funções de Terminal:** Declare exclusivamente o comando novo nos shells suportados (POSIX `sh`, Bash, Zsh, PowerShell, NuShell, Clink).
    - **Chaves & Artefatos:** Mova artefatos via `git mv` no repositório canônico (`Vault/keys/`), atualizando rotinas de busca e expurgando arquivos residuais.
    - **Infraestrutura & Diretórios:** Renomeie diretórios com `git mv` e ajuste chamadas de provisionamento sem deixar wrappers de transição.
    - **Auditoria de Conclusão:** Realize varredura completa via `rg` para garantir zero menções ao termo antigo e execute `make audit` para atestar conformidade estática.

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

O agente de IA DEVE ser ativamente proativo na manutenção e aplicação dos padrões canônicos.

Ao identificar qualquer linha ou artefato fora dos padrões estabelecidos:

1. **Notificar concisamente** o usuário sobre a divergência encontrada.
2. **Corrigir imediatamente a inconformidade**, aplicando os padrões correspondentes: eliminar comentários narrativos, ajustar banners (64 no header / 32 no corpo), remover bashismos, garantir `#!/usr/bin/env sh`, eliminar octais (`\033`) para sequências ANSI, cotar caminhos e aplicar permissões em 4 dígitos octais.

---

## 📚 Literatura de Referência & Leitura Altamente Recomendada

- **Obra Canônica de Clean Code:** _Clean Code: A Handbook of Agile Software Craftsmanship_ (Robert C. Martin "Uncle Bob", 2008, Prentice Hall).
- **Obra Canônica de Filosofia UNIX:** _The Art of UNIX Programming_ (Eric S. Raymond, 2003, Addison-Wesley Professional).
    - Portal da obra: <http://www.catb.org/~esr/writings/taoup/> | Texto integral: <http://www.catb.org/~esr/writings/taoup/html/>
- **Prática de Programação e Estilo:** _The Practice of Programming_ (Brian W. Kernighan & Rob Pike, 1999, Addison-Wesley).
