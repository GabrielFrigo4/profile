---
name: terminal-typography-tty
description: >-
    Tipografia de terminal, seleção de glifos Nerd Fonts, delimitadores de largura
    zero em prompts, cálculo de display width (wcwidth), máscaras XOR de softcursor
    Linux VT, sequências DECSCUSR e subsistemas de mouse em TTY puro.
---

# 🔤 Terminal Typography & Kernel TTY Subsystems

Diretrizes para seleção, posicionamento e cálculo métrico de glifos vetoriais, geometria de prompts sem quebras fantasma e calibração de cursores, paletas e mouse em PTY e TTY de kernel.

---

## 🏛️ 1. Princípios de Tipografia & Geometria de Prompt

1. **Fonte Monoespaçada de Referência:** Utilize fontes com métricas calibradas para Box-Drawing e Powerline (como `JetBrainsMono Nerd Font`) como baseline de alinhamento em emuladores e prompts.
2. **Escala Vetorial (Font Logos):** Priorize glifos da família **Font Logos** (`nf-linux-*`), desenhados para ocupar `100%` da célula, evitando coleções antigas subdimensionadas (Devicons/FontAwesome legados).
3. **Espaço de Respiro:** Todo glifo _single-width_ em prompts deve ser seguido de espaço simples (`" "` em vez de `""`) para evitar colisão visual com o caractere adjacente.
4. **Delimitadores de Largura Zero:** Envolva escapes ANSI não-imprimíveis em `\[...\]` (ou `\x01...\x02`) no Bash `readline` e `%{...%}` no Zsh `ZLE`, prevenindo contagem incorreta de colunas e quebras prematuras de linha.
5. **Display Width (`wcwidth`) vs. Bytes:** Não use contagem de bytes (`${#var}`) para largura visual UTF-8; glifos multibyte ocupam 3–4 bytes para `1` ou `2` colunas de tela.
6. **Degradação Graciosa:** Em consoles sem UTF-8 ou fontes vetoriais (`TERM=linux`, TTY serial, `vt(4)`), degrade automaticamente para ASCII puro.

---

## 🗂️ 2. Módulos de Referência Especializados

| Subdomínio                     | Conteúdo Coberto                                                                                   | Referência                                                                                       |
| :----------------------------- | :------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------- |
| **Taxonomia Nerd Fonts**       | Escala entre famílias, faixas PUA e variantes Mono / Padrão / Propo                                | [`references/nerd-fonts-taxonomy.md`](references/nerd-fonts-taxonomy.md)                         |
| **Geometria & Delimitadores**  | Mecânica `readline` / `ZLE`, `\x01`/`\x02`, `wcwidth` e prevenção de _ghost wrap_                  | [`references/prompt-geometry-delimiters.md`](references/prompt-geometry-delimiters.md)           |
| **Matriz Canônica de Glifos**  | Codepoints Unicode, glifos por SO/distro, VCS e fallbacks ASCII                                    | [`references/canonical-os-glyphs.md`](references/canonical-os-glyphs.md)                         |
| **Consoles TTY & Máscara XOR** | Fontes 256 vs 512 glifos, bug VGA Linux VT, máscara `0xee` (`0xee10`), DECSCUSR e auto-cura        | [`references/tty-console-typography.md`](references/tty-console-typography.md)                   |
| **Mouse, Cursores & Paletas**  | FreeBSD `vt(4)`+`moused` vs Linux GPM, bug `cnorm`, Alpha Blending, paleta 16 cores e blink 1200ms | [`references/tty-mouse-and-cursor-subsystems.md`](references/tty-mouse-and-cursor-subsystems.md) |

---

## 🛠️ 3. Checklist Rápido de Implementação

- [ ] Ícone selecionado da família balanceada (` `, ` `, ` `, ` `, ` `, ` `) com espaço separador?
- [ ] Escapes ANSI encapsulados em `\[...\]` / `\x01...\x02` (Bash) ou `%{...%}` (Zsh)?
- [ ] Fallback ASCII garantido quando Nerd Fonts estiverem desativadas ou em Raw TTY?
- [ ] Softcursor Linux VT restaurado via `\e%G\e[?16;238;0c` e PTY via `\e[0 q`?
