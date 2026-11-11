# 🎨 Engenharia de Sequências ANSI & Escapes

O ecossistema adota normas estritas para sequências visuais ANSI, eliminando ruído, garantindo portabilidade em terminais heterogêneos e erradicando notações obsoletas.

---

## 🚫 Regra de Escapes: Banimento de Octal para Caracteres e Bytes

Não utilize notação octal (`\033`, `\001`, `\077`) para caracteres de escape ou bytes de controle:

1. **Sequências ANSI & Cores:** Use `_esc=$'\e'` ou `[ -t 1 ] && echo -n $'\e...'`.

    ```sh
    _esc=$'\e'
    ```

    > [!IMPORTANT]
    > **Limitação do `printf` no `sh` do FreeBSD:**
    > O utilitário `printf` builtin do `sh` do FreeBSD segue estritamente a especificação POSIX e **não** suporta a sequência de escape hexadecimal `\xHH` (ele imprime literalmente `x1b` no terminal). Portanto, nunca utilize `printf '\x1b'` para capturar o caractere de escape em `sh`; utilize `_esc=$'\e'`.

2. **Bytes de Controle:** Para delimitadores de prompt ou bytes arbitrários, use notação hexadecimal (`\x01`) apenas onde suportado pelo interpretador.
3. **Exceção Única para Octal:** Octais são aceitos e exigidos **exclusivamente** em utilitários POSIX de arquivos baseados em base 8 (`chmod 0755`, `chmod 0644`, `chmod 0700`, `chmod 0600`, `umask 022`).

---

## 🎯 Emissão Limpa: `echo -n` vs `printf`

- **Sempre prefira `echo -n` a `printf`** para emitir sequências de escape e texto contínuo sem quebra de linha quando não houver formatação posicional.
- Evite chamadas `printf` gratuitas. `printf` deve ser reservado para tabulações e alinhamento de colunas:
    ```sh
    [ -t 1 ] && echo -n $'\e[1;32m'
    echo "Sucesso"
    [ -t 1 ] && echo -n $'\e[0m'

    printf "%-20s %-12s %s\n" "$pacote" "$versao" "$status"
    ```

---

## ⚠️ Armadilha Crítica do OpenBSD `ksh` (PD-KSH)

O `ksh` padrão do OpenBSD (`/bin/ksh` e `oksh`) não suporta expansão ANSI-C `$''`. Ele emite literalmente a string `$\e...`:

- **Captura Dinâmica no OpenBSD ksh:**
    ```sh
    _esc="$(echo | awk '{ printf "%c", 27 }')"
    _bold="${_esc}[1m"
    _reset="${_esc}[0m"
    ```
- **Delimitação de Prompt no `PS1`:** Caracteres invisíveis (largura zero) no `PS1` do OpenBSD ksh **devem** ser delimitados por `\x01`:
    ```sh
    PS1="$(printf '\x01%s\x01' "$_bold")$(whoami)$(printf '\x01%s\x01' "$_reset"):$ "
    ```
    Sem os delimitadores `\x01`, o cursor quebra a linha prematuramente e estraga a navegação no histórico.
