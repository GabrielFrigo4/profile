---
name: terminal-glyphs-typography
description: >-
    Runbook cognitivo definitivo para tipografia de terminal, Nerd Fonts, glifos vetoriais,
    delimitadores de largura zero, geometria de prompts, cálculo de display width (wcwidth)
    e prevenção de quebras de linha e mojibake.
---

# 🔤 Tipografia de Terminal & Geometria de Glifos

Esta habilidade orienta a seleção, posicionamento, renderização e cálculo métrico de glifos vetoriais, símbolos Nerd Fonts e sequências de escape em prompts de shell, scripts de interface e emuladores de terminal multiplataforma.

---

## 🏛️ Princípios de Tipografia em Terminal

1. **Escala Vetorial e Famílias Nerd Fonts:**
    - Priorize glifos da família **Font Logos** (`nf-linux-*`), desenhados para ocupar 100% da caixa delimitadora (_bounding box_), mantendo leitura nítida e proporção equilibrada.
    - Evite ícones herdados de coleções reduzidas (_Devicons_ antigos como `\uE712` ` ` ou _FontAwesome_ descalibrados), que renderizam com escala visual de 50-60%.
2. **Espaçamento e Margem de Segurança:**
    - Todo glifo de largura simples (_single-width_) em prompts interativos **DEVE** ser sucedido por um espaço em branco (`" "` em vez de `""`).
    - Fontes monoespaçadas com _patching_ PUA frequentemente extrapolam ligeiramente os limites da célula do terminal; sem o espaço de respiro, o glifo sobrepõe o caractere alfanumérico adjacente.
3. **Imunidade a Desalinhamento (Geometria de Largura Zero):**
    - Todo código de controle ANSI (cores, estilos, resets) deve ser rigidamente envolvido por delimitadores de largura zero específicos do shell (`\[...\]` no Bash, `%{...%}` no Zsh).
    - Falha no encapsulamento corrompe a contagem de colunas do `readline`/`ZLE`, causando quebras prematuras de linha e deriva destrutiva do cursor.
4. **Display Width vs. Contagem de Bytes:**
    - Nunca use contagem de bytes (`${#var}` em sh restrito) para inferir largura visual de strings com UTF-8.
    - Caracteres multibyte ocupam de 2 a 4 bytes, mas preenchem 1 coluna (`wcwidth = 1`) ou 2 colunas no grid de texto.
5. **Degradação Graciosa (TTY e Ambientes Headless):**
    - Em consoles virtuais sem suporte a UTF-8/Nerd Fonts (`TERM=linux`, TTY serial, FreeBSD `syscons`/`vt`), forneça fallbacks limpos em ASCII puro ou desative glifos estendidos.

---

## 🗂️ Arquitetura de Referências

Para especificações detalhadas, consulte os manuais canônicos sob `references/`:

- **[Taxonomia de Famílias Nerd Fonts](references/nerd-fonts-taxonomy.md):** Diferenças métricas entre Font Logos, Devicons, Material Design Icons, Octicons e histórico dos prefixos de upstream.
- **[Geometria de Prompt & Delimitadores](references/prompt-geometry-delimiters.md):** Mecânica interna do Bash `readline`, Zsh `ZLE`, escapes `\x01`/`\x02`, cálculo de colunas e prevenção de bugs de _line wrap_.
- **[Matriz Canônica de Glifos de SO](references/canonical-os-glyphs.md):** Tabela de codepoints Unicode, glifos canônicos por sistema operacional/distro, nomes Nerd Fonts e contratos de fallback.

---

## 🛠️ Checklist Rápido de Implementação

Ao adicionar ou revisar ícones em temas ou prompts:

- [ ] O ícone provém da família visualmente balanceada (ex: ` ` para Linux, ` ` para macOS, ` ` para illumos, ` ` para OpenBSD, ` ` para Windows)?
- [ ] Há um espaço separador após o glifo para evitar colisões tipográficas no terminal?
- [ ] No Bash, todas as sequências de escape ANSI estão encapsuladas em `\[` e `\]` (ou `\x01` e `\x02`)?
- [ ] No Zsh, sequências ANSI puras estão encapsuladas em `%{` e `%}`?
- [ ] Existe fallback gracioso quando `PROMPT_USE_NERD_FONTS` estiver desativado ou o terminal for TTY básico?
