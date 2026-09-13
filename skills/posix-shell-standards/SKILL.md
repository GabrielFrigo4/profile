---
name: posix-shell-standards
description: Manual cognitivo e validador de padrões de shell POSIX, baseline FreeBSD /bin/sh, taxonomia de emissão (echo vs echo -n $'\e...' vs printf), quoting rigoroso e programação defensiva.
---

# 🐚 POSIX Shell Standards & Portability Skill

Esta habilidade orienta o agente de IA na escrita, revisão e refatoração de scripts de shell no ecossistema, garantindo que o código seja **estritamente portátil**, limpo, defensivo e compatível com **FreeBSD `/bin/sh`**, Linux (Bash/Dash), macOS (Zsh) e Windows (MSYS2).

---

## 🧭 Linha de Base (Baseline): FreeBSD `/bin/sh`

1. O shell nativo do FreeBSD (`/bin/sh`) é a nossa régua máxima de portabilidade para scripts compartilhados de sistema.
2. Todo script portátil DEVE usar o shebang:
    ```sh
    #!/usr/bin/env sh
    ```
3. NUNCA use `#!/bin/sh` ou `#!/bin/bash` diretamente (o caminho absoluto de executáveis varia entre Linux `/bin`, FreeBSD `/usr/local/bin` e macOS).
4. Evite extensões exclusivas do Bash (`[[ ... ]]`, arrays indexados `arr=(...)`, `<<<` herestrings, `&>`).

---

## 📢 Taxonomia Canônica de Emissão

Adotamos uma taxonomia estrita e semântica para emissão de dados no terminal:

| Ferramenta             | Cenário de Uso Exclusivo                               | Exemplo Canônico                        | Justificativa Técnica                                                                                            |
| :--------------------- | :----------------------------------------------------- | :-------------------------------------- | :--------------------------------------------------------------------------------------------------------------- |
| **`echo "${msg}"`**    | Texto simples, quebras de linha e escrita em arquivos. | `echo "${val}" > "${file}"`             | Simples, atômico, rápido e universal.                                                                            |
| **`echo -n $'\e...'`** | **Padrão Canônico para sequências ANSI interativas.**  | `[ -t 1 ] && echo -n $'\e[2J\e[H'`      | Suportado em Zsh, Bash, FreeBSD `/bin/sh` e padronizado no **POSIX Issue 8**. Elimina octais crípticos (`\033`). |
| **`printf`**           | Tabelas, colunas formatadas e alinhamento com padding. | `printf "%-16s %s\n" "${key}" "${val}"` | Controle preciso de espaçamento e largura de campo.                                                              |

> [!CAUTION]
> **Proibição de Octais Obscuros:** Evite notação octal do tipo `\033` ou `\077` em scripts quando o formato legível `$'\e...'` estiver disponível e for a solução mais elegante.

> [!NOTE]
> **Peculiaridade Crítica do OpenBSD `ksh` (PD-KSH):**
> O `ksh` nativo do OpenBSD (`/bin/ksh` e seu port portátil `oksh`) não implementa expansão ANSI-C `$''`. Ele interpreta `$'\e...'` literalmente como texto bruto `$\e[...]`.
>
> - Para sequências ANSI no OpenBSD `ksh`, capture o caractere escape dinamicamente via `_esc="$(printf '\033')"` e utilize `"${_esc}[32m"`.
> - No `PS1` do OpenBSD `ksh`, qualquer sequência ANSI invisível (largura zero) **DEVE** ser delimitada pelo caractere de controle `\001` (ex: `\001${_esc}[32m\001`). Sem essa delimitação, o editor de linha do `ksh` calcula incorretamente o comprimento do prompt, corrompendo a rolagem de histórico e a quebra de linha.

---

## 🔒 Quoting Defensivo & Variáveis

1. **Sempre use chaves:** Escreva `${var}` em vez de `$var`.
2. **Sempre use aspas duplas:** Escreva `"${var}"` para prevenir divisão indesejada de palavras (_word-splitting_) e expansão de caminhos (_globbing_), exceto quando a divisão for explicitamente intencional.
3. **Caminhos e Redirecionamentos:**
    ```sh
    # Correto:
    command > "/dev/null" 2>&1

    # Proibido:
    command > /dev/null 2>&1
    ```
4. **Verificação de Executáveis:** NUNCA use `which`. Use sempre `command -v`:
    ```sh
    command -v doas > "/dev/null" 2>&1 && ELEVATE="doas"
    ```

---

## 🔐 Permissões Canônicas em 4 Dígitos Octais

Sempre utilize a notação octal de 4 dígitos nos comandos `chmod`:

- `chmod 0755`: Diretórios e scripts de shell executáveis.
- `chmod 0644`: Arquivos de configuração, dotfiles estáticos e documentações Markdown.
- `chmod 0700`: Diretórios privados e scripts com acesso a segredos (Vault).
- `chmod 0600`: Chaves privadas SSH, tokens de autenticação e arquivos `.env`.
- `chmod 0440`: Arquivos de sistema de privilégios (`/etc/sudoers.d/*`, `/etc/doas.conf`).
- `chmod 4750`: Utilitários SUID com grupo restrito a `wheel` (Core POSIX).

---

## 🧱 Arquitetura de Comentários em Três Camadas (Regra do Não-Vazamento)

1. **Camada 1 (Header Banner - Linhas 2-4):** Delimitado por exatamente **64 hífens**:
    ```sh
    #!/usr/bin/env sh
    # ----------------------------------------------------------------
    # Utility: Nome da Ferramenta ou Receita
    # ----------------------------------------------------------------
    ```
2. **Camada 2 (Delimitadores Estruturais de 32 Caracteres):**
    - Seções Principais (32 `=`):
        ```sh
        ### ================================
        ### SECAO PRINCIPAL
        ### ================================
        ```
    - Subseções (32 `-`):
        ```sh
        ### --------------------------------
        ### Subsecao Interna
        ### --------------------------------
        ```
    - **Regra do Não-Vazamento:** O título deve ter no máximo 32 caracteres (total de 36 colunas com `### `).
3. **Camada 3 (Zero Comentários Narrativos):** O código deve ser autoexplicativo por funções pequenas, nomes claros e separação por linhas em branco. Comentários explicativos inline são proibidos.

---

## 🛡️ Heredocs e Guards Interativos

1. **Heredocs Indentados (`cat <<- 'EOF'`):**
   O hífen descarta tabulações iniciais, permitindo alinhar o bloco dentro de funções sem poluir a coluna zero.
2. **Interactive Guard:**
   Para scripts carregados em novos terminais (`.bashrc`, `.zshrc`, `.shrc`):
    ```sh
    case "$-" in
        *i*) ;;
        *) return ;;
    esac
    ```

---

## 👑 Ordem Canônica de Prevalência & Enumeração de Shells

Em qualquer enumeração, checklist, pipeline de CI/CD, Makefile, script de benchmark ou documentação, a ordem DEVE SEMPRE respeitar a hierarquia canônica de ergonomia e conveniência:

1. **`zsh`** (topo da cadeia de ergonomia, autocompletion visual e produtividade interativa)
2. **`bash`** (padrão corporativo universal e compatibilidade retroativa)
3. **`sh`** (FreeBSD `/bin/sh` como base system exclusivo) ou **`ksh`** (OpenBSD `/bin/ksh` como base system exclusivo)

---

## 📚 Literatura de Referência & Ferramentas Oficiais

Recomenda-se enfaticamente ao agente de IA e aos operadores o estudo das fontes oficiais de portabilidade:

- **The Open Group Base Specifications (POSIX IEEE 1003.1):** <https://pubs.opengroup.org/onlinepubs/9699919799/> | Shell (`sh`): <https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sh.html>
- **ShellCheck (Linter Estático de Shell):** <https://www.shellcheck.net/> | GitHub: <https://github.com/koalaman/shellcheck>
- **The FreeBSD Project:** <https://www.freebsd.org/> | Manual Pages: <https://man.freebsd.org/> | Shell (`sh`): <https://man.freebsd.org/sh>
- **Obra Clássica de Referência:** _The UNIX Programming Environment_ (Brian W. Kernighan & Rob Pike, 1984, Prentice Hall) — o clássico fundamental sobre composição de comandos, pipes e scripts de shell idiomáticos.
