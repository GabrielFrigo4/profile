# 📐 Geometria de Prompt, Delimitadores de Largura Zero & `wcwidth`

Este documento aborda os fundamentos de cálculo métrico de colunas de terminal, a mecânica de editores de linha de comando (`readline` e `ZLE`) e a aplicação correta de delimitadores de largura zero para prevenir bugs de quebra de linha fantasma (_ghost line wrap_) e desvio de cursor.

---

## 🔍 O Problema Fundamental da Posição do Cursor

Um emulador de terminal opera como uma matriz bidimensional de células (linhas × colunas). Quando o usuário digita comandos interativos:

1. O editor de linha (`readline` no GNU Bash, `ZLE` no Zsh) precisa saber exatamente quantas **colunas visíveis na tela** o prompt ocupa.
2. Com base nessa largura inicial, ele calcula:
    - Onde posicionar o cursor de inserção.
    - Em qual coluna o texto do comando começa.
    - Quando o comando excede a largura da janela (`$COLUMNS`) e precisa quebrar para a linha seguinte.
    - Como redesenhar a linha ao pressionar `BackSpace`, `Ctrl+A`, `Ctrl+E` ou ao navegar no histórico (`Up`/`Down`).

Se o shell acreditar que o prompt tem 40 colunas, mas ele ocupa fisicamente apenas 20 colunas na tela (porque 20 caracteres eram sequências de escape ANSI de cor invisíveis), **o cursor quebrará a linha prematuramente**, 20 colunas antes da borda direita da janela.

---

## 🛑 Delimitadores de Largura Zero por Shell

Para evitar que códigos de controle ANSI sejam contabilizados na largura do prompt, cada shell fornece um mecanismo formal de marcação:

### 1. GNU Bash (`readline`)

O Bash utiliza os marcadores `\[` e `\]` dentro das variáveis `PS1`, `PS2` e afins:

```sh
# Correto: cores encapsuladas em \[ e \]
PS1="\[\x1b[1;34m\][   Linux ]\[\x1b[0m\]─[ \w ] $ "

# Em scripts onde o escape literal é montado dinamicamente:
# \x01 marca o início de sequência de largura zero (Start of Heading - SOH)
# \x02 marca o fim de sequência de largura zero (Start of Text - STX)
_c_blue=$'\x01\x1b[1;34m\x02'
_c_reset=$'\x01\x1b[0m\x02'
PS1="${_c_blue}[   Linux ]${_c_reset}─[ \w ] $ "
```

> **Aviso de Integridade:** Se uma sequência de cor como `\x1b[1;34m` for deixada sem `\[...\]` ou sem `\x01...\x02`, o `readline` adicionará 7 caracteres à contagem do prompt, descalibrando o retorno do cursor e a navegação no histórico.

### 2. Zsh (`Zsh Line Editor - ZLE`)

O Zsh oferece duas abordagens:

1. **Expansões Nativas de Prompt:**
   Sequências como `%F{blue}...%f` e `%B...%b` são calculadas nativamente pelo Zsh com largura zero automática.
2. **Sequências ANSI Manuais (`%{...%}`):**
   Ao utilizar códigos de escape ANSI diretos, envolva-os estritamente entre `%{` e `%}`:

```zsh
# Correto: sequência ANSI pura delimitada por %{ e %}
PROMPT="%{\x1b[1;34m%}[   Linux ]%{\x1b[0m%}─[ %~ ] %# "
```

### 3. POSIX `/bin/sh` e Shells Leves (FreeBSD `sh`, OpenBSD `ksh`, Dash)

- O interpretador padrão `/bin/sh` POSIX não implementa biblioteca complexa de edição de linha multilinha como `readline`.
- Em scripts utilitários e shells básicos de recuperação, mantenha o prompt minimalista, estático e com escape direto sem sobrecarregar com lógicas dependentes de buffer.

---

## 📊 Display Width (`wcwidth`) vs. Contagem de Bytes

Em arquiteturas modernas com UTF-8:

1. **Bytes $\neq$ Caracteres $\neq$ Colunas de Tela:**
    - O caractere ASCII `'A'` = 1 byte = 1 caractere = 1 coluna visual.
    - O glifo Tux `''` (`U+F31A`):
        - **Tamanho em Bytes (UTF-8):** 3 bytes (`0xEF 0x8C 0x9A`).
        - **Tamanho em Caracteres:** 1 caractere Unicode.
        - **Largura Visual (`wcwidth`):** 1 coluna no grid do terminal.
2. **Anti-Padrão:**
   Utilizar `${#string}` ou `expr length` para calcular o tamanho de um prompt contendo glifos multibyte gera contagens infladas em ambientes onde a expansão opera sobre bytes em vez de pontos de código.

---

## 🔤 A Regra do Espaço de Respiro (Trailing Space)

Em fontes monoespaçadas com patch Nerd Fonts:

- Glifos complexos frequentemente encostam ou avançam 1 a 2 pixels além da largura teórica da célula (`1ch`).
- Se um glifo for seguido imediatamente por texto alfanumérico (ex: `Linux`), o glifo colidirá visualmente com a letra `'L'`, tornando o texto ilegível.

**Diretriz de Design:** Sempre adicione um espaço de respiro após o glifo vetorial:

```sh
# Anti-padrão (colisão visual)
PROMPT_OS_ICON=""

# Padrão Canônico (espaçamento equilibrado)
PROMPT_OS_ICON=" "
```
