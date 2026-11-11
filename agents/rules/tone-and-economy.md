---
description: Diretrizes universais de tom técnico, economia de contexto e plataforma de terminal.
globs: "**/*"
always_on: true
---

# 🎯 Universal Tone & Platform Constraints

1. **Tom Sóbrio & Densidade de Sinal:**
    - Adote redação técnica, direta e assertiva.
    - Evite adjetivação hiperbólica, retórica dramática, maiúsculas emotivas ou ameaças procedimentais.
    - Estrutura de regras: declare a diretriz, o anti-padrão a evitar e a alternativa recomendada.

2. **Matriz de Shells Suportados:**
    - Shells alvo: `zsh`, `bash`, FreeBSD `sh` e OpenBSD `/bin/ksh`.
    - Interpretadores fora de escopo: Debian `dash` e NetBSD `sh`. Não adapte comandos ou sintaxes para interpretadores restritos de rescue.

3. **Escapes ANSI & Bytes:**
    - Cores e escapes de terminal: use sempre `$'\e'` (em Makefiles: `_e=$$'\e';`) ou hexadecimal (`\x1b`).
    - Notação octal (`\033`): permitida unicamente onde a natureza da informação é octal por definição de sistema de arquivos POSIX (`chmod 0755`, `0644`, `umask 022`).

4. **Comentários Estruturais & Banners:**
    - Cabeçalhos de topo: exatamente 64 hífens nas linhas 2-4 (`# ----------------------------------------------------------------`).
    - Seções e subseções internas: réguas de 32 colunas (`### ================================` e `### --------------------------------`) com títulos estritamente em MAIÚSCULO (máximo 32 caracteres, sem parênteses ou colchetes).
    - Seções em `.gitignore`: réguas de 64 sinais de igualdade (`# ================================================================`) com títulos em MAIÚSCULO.
