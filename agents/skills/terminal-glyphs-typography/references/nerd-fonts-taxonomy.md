# 🏛️ Taxonomia das Famílias Nerd Fonts & Escala Vetorial

Este documento detalha a arquitetura interna do projeto Nerd Fonts, a distribuição de codepoints na Área de Uso Privado (PUA - _Private Use Area_) do Unicode, a origem histórica das nomenclaturas de glifos e as diferenças métricas de renderização entre famílias.

---

## 📜 Histórico e Origem do Prefixo `nf-linux-*`

Uma dúvida frequente de engenharia é por que ícones de sistemas não-Linux (como FreeBSD ` `, macOS ` `, OpenBSD ` ` ou Windows ` `) aparecem catalogados com prefixo `nf-linux-*` no Nerd Fonts:

1. **A Fonte Original `font-linux`:**
    - Criada por Lukasz Fiszer, a `font-linux` nasceu como uma fonte de ícones vetoriais dedicada exclusivamente a distribuições GNU/Linux (Tux, Debian, Arch, Ubuntu, Fedora).
2. **Expansão para Outros Sistemas Operacionais:**
    - Conforme a comunidade adotou o projeto, desenvolvedores solicitaram a inclusão de logos de outros sistemas UNIX-like (FreeBSD, OpenBSD, illumos) e sistemas proprietários (Apple, Windows).
    - O autor adicionou esses logos diretamente ao conjunto `font-linux` para manter um repositório centralizado de sistemas operacionais.
3. **Mapeamento Automatizado pelo Nerd Fonts:**
    - Quando Ryan McIntyre desenvolveu o `font-patcher` do Nerd Fonts, cada fonte upstream integrada recebeu um prefixo de namespace padronizado para evitar colisões na PUA.
    - O pacote `font-linux` foi mapeado integralmente para a faixa `U+F300` - `U+F32F`, gerando nomes canônicos como `nf-linux-freebsd`, `nf-linux-apple`, `nf-linux-openbsd` e `nf-linux-illumos`.

---

## 📐 Comparativo Métrico entre Famílias

O ecossistema Nerd Fonts combina múltiplas fontes de ícones distintas, cada uma com sua própria grade de desenho original (_viewBox_ e _bounding box_):

| Família Original            | Namespace Nerd Fonts | Faixa PUA Unicode     | Escala Visual | Comportamento no Terminal                                |
| :-------------------------- | :------------------- | :-------------------- | :------------ | :------------------------------------------------------- |
| **Font Logos (font-linux)** | `nf-linux-*`         | `U+F300` – `U+F32F`   | **100%**      | **Padrão de Ouro.** Desenhado na altura cheia da célula. |
| **Devicons**                | `nf-dev-*`           | `U+E700` – `U+E7C5`   | 55% – 65%     | Reduzido. Deixa grandes vazios verticais e horizontais.  |
| **Material Design (MDI)**   | `nf-md-*`            | `U+F0001` – `U+F1AF0` | 85% – 95%     | Grade 24×24 balanceada. Excelente para utilitários.      |
| **FontAwesome**             | `nf-fa-*`            | `U+F000` – `U+F2E0`   | 70% – 80%     | Média. Alguns glifos possuem proporções assimétricas.    |
| **Octicons**                | `nf-oct-*`           | `U+F400` – `U+F4A9`   | 80% – 90%     | Otimizado para densidade de código e VCS (Git).          |
| **Powerline Symbols**       | `nf-ple-*`           | `U+E0A0` – `U+E0D4`   | 100%          | Encaixe exato para setas, separadores e triângulos.      |

### O Contraste entre Font Logos e Devicons

Um exemplo prático e recorrente de contraste ocorre no logo do Linux e da Apple:

- **Linux no Devicons:** `\uE712` ` ` (`nf-dev-linux`) renderiza em escala diminuta (~60%), parecendo desproporcional quando comparado a outros ícones de prompt.
- **Linux no Font Logos:** `\uF31A` ` ` (`nf-linux-tux`) preenche a célula com volume equivalente aos glifos de FreeBSD (` `) e Arch (` `).
- **Apple no FontAwesome:** `\uF179` ` ` (`nf-fa-apple`) é menor do que `\uF302` ` ` (`nf-linux-apple`).

**Diretriz Canônica:** Sempre prefira a família `Font Logos` para representação de sistemas operacionais.

---

## 🧩 Variantes de Fontes: Mono vs. Padrão vs. Propo

Ao instalar pacotes patched do Nerd Fonts (ex: JetBrainsMono Nerd Font), três variantes são geradas pelo patcher:

1. **`* Nerd Font Mono` (Monoespaçamento Rígido):**
    - Todos os glifos adicionados são forçados a ter largura exata de 1 célula (`1ch`).
    - Ícones complexos podem parecer comprimidos ou visualmente estreitos.
    - **Recomendação:** Ideal para editores de código e terminais que não suportam glifos de largura dupla.
2. **`* Nerd Font` (Padrão / Duas Células quando Necessário):**
    - Glifos que necessitam de mais espaço horizontal mantêm largura proporcional de 2 células (`2ch`).
    - Renderização mais harmoniosa e sem distorção dos logos.
    - **Recomendação:** Configuração recomendada para emuladores modernos (Kitty, WezTerm, Alacritty, Ghostty, Foot).
3. **`* Nerd Font Propo` (Proporcional):**
    - Variação não-monoespaçada destinada a interfaces gráficas, títulos ou barras de status onde a largura fixa da célula não é obrigatória.
