# 🎨 Engenharia de Sequências ANSI & Escapes

O ecossistema adota normas estritas para sequências visuais ANSI, eliminando ruído, garantindo portabilidade em terminais heterogêneos e erradicando notações obsoletas.

---

## 🚫 Proibição Absoluta de Octais para Bytes e Caracteres

É terminantemente proibido utilizar notação octal (`\033`, `\001`, `\077`) para caracteres de escape ou bytes de controle:

1. **Sequências ANSI & Cores:** Use `[ -t 1 ] && echo -n $'\e...'` ou capture a variável de escape via hexadecimal:
    ```sh
    _esc="$(printf '\x1b' 2>"/dev/null" || echo -n $'\x1b')"
    ```
2. **Bytes de Controle:** Para delimitadores de prompt ou bytes arbitrários, use hexadecimal (`\x01`, `\x1b`).
3. **Exceção Única para Octal:** Octais são aceitos e exigidos **exclusivamente** em utilitários POSIX de arquivos baseados em base 8 (`chmod 0755`, `chmod 0644`, `chmod 0700`, `chmod 0600`, `umask 022`).

---

## 🎯 Emissão Limpa: `echo -n` vs `printf`

- **Sempre prefira `echo -n` a `printf`** para emitir sequências de escape e texto contínuo sem quebra de linha quando não houver formatação posicional.
- Evite chamadas `printf` gratuitas. `printf` deve ser reservado para tabulações e alinhamento de colunas:
    ```sh
    # Recomendado:
    [ -t 1 ] && echo -n $'\e[1;32m'
    echo "Sucesso"
    [ -t 1 ] && echo -n $'\e[0m'

    # Formatação tabular com printf (justificado):
    printf "%-20s %-12s %s\n" "$pacote" "$versao" "$status"
    ```

---

## ⚠️ Armadilha Crítica do OpenBSD `ksh` (PD-KSH)

O `ksh` padrão do OpenBSD (`/bin/ksh` e `oksh`) não suporta expansão ANSI-C `$''`. Ele emite literalmente a string `$\e...`:

- **Captura Dinâmica:**
    ```sh
    _esc="$(printf '\x1b' 2>"/dev/null" || echo -n $'\x1b')"
    _bold="${_esc}[1m"
    _reset="${_esc}[0m"
    ```
- **Delimitação de Prompt no `PS1`:** Caracteres invisíveis (largura zero) no `PS1` do OpenBSD ksh **devem** ser delimitados por `\x01`:
    ```sh
    PS1="$(printf '\x01%s\x01' "$_bold")$(whoami)$(printf '\x01%s\x01' "$_reset"):$ "
    ```
    Sem os delimitadores `\x01`, o cursor quebra a linha prematuramente e estraga a navegação no histórico.
