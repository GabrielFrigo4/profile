# 🖥️ Tipografia em Consoles Virtuais TTY & Cursor Estático

Este documento técnico detalha os fundamentos da arquitetura de consoles virtuais de texto (**Linux VT** e **FreeBSD `vt(4)`**), a mecânica de fontes bitmap PSF/FNT de 256 vs 512 glifos, o bug histórico de deslocamento de atributos no kernel Linux e a parametrização matemática para cursor estático em bloco sólido imune a distorções cromáticas.

---

## 🏛️ Consoles Virtuais vs Emuladores Gráficos PTY

Emuladores de terminal gráficos modernos (como Alacritty, Kitty, Foot e WezTerm) operam sobre pseudo-terminais (PTY) e renderizam glifos vetoriais através de shaders OpenGL/Vulkan com suporte pleno a 24-bit TrueColor, fontes OpenType/TrueType e Nerd Fonts v3 completas.

Em contrapartida, os consoles virtuais nativos do kernel (`/dev/tty[1-6]` no Linux com driver VT/fbcon, ou `ttyv0` a `ttyv7` no FreeBSD sob `vt(4)`) são drivers de framebuffer de baixo nível operando diretamente no hardware de vídeo com tabelas de glifos em bitmap matricial.

---

## 📐 Fontes Matriciais & A Arquitetura de 512 Glifos

### 1. Limitações de Resolução em Telas Modernas

Em telas de alta densidade (Full HD 1080p, 2K e 4K), as fontes padrão de console VGA (`8x16`) resultam em caracteres minúsculos, gerando fadiga visual e dificultando a leitura em situações de recuperação do sistema.

A família de fontes bitmap **Spleen** (criada por Frederic Cambus) provê tipografia límpida para ambientes de console:

- **`spleen-8x16`:** Legado VGA, útil apenas em monitores antigos ou resolução 640x480.
- **`spleen-16x32`:** Excelente em telas 4K, porém consome espaço horizontal excessivo em telas 1080p (resultando em apenas 60 colunas em painéis Full HD).
- **`spleen-12x24`:** O **ponto de equilíbrio ideal (_sweet spot_)** para telas 1080p a 4K, oferecendo 80 a 160 colunas perfeitamente legíveis.

### 2. O Trade-Off de 256 vs 512 Glifos

Nos adaptadores de vídeo compatíveis com VGA e nos drivers de framebuffer:

- **Modo 256 Glifos:** O mapa de caracteres armazena 256 glifos. O byte de atributo de cor utiliza 4 bits para o primeiro plano (_foreground_ - 16 cores) e 4 bits para o fundo (_background_ - 16 cores ou 8 cores + atributo blink).
- **Modo 512 Glifos (Spleen 12x24):** Para exibir conjuntos completos de caracteres internacionais, caixas de desenho ANSI e símbolos Unicode, o console aloca 512 glifos. O kernel Linux ativa o bit de alta ordem `vc_hi_font_mask = 0x0100` (`drivers/tty/vt/vt.c`), "roubando" 1 bit do atributo de cor para selecionar a segunda página de caracteres.

---

## 🐛 O Bug Histórico de Deslocamento de Cor no Linux VT

### 1. Reorganização dos Bits de Atributo

Quando `vc_hi_font_mask` está ativo (512 glifos):

- O bit 8 é reservado para a seleção do glifo 256-511.
- **Primeiro Plano (Foreground):** Ocupa os bits 9, 10 e 11 (3 bits = 8 cores básicas).
- **Intensidade / Negrito:** Ocupa o bit 12.
- **Fundo (Background):** Ocupa os bits 13, 14 e 15 (3 bits = 8 cores básicas).

### 2. A Macro Incompatível em `drivers/tty/vt/vt.c`

No código do driver de console virtual do kernel Linux (`drivers/tty/vt/vt.c`), a função `add_softcursor()` contém definições herdadas do padrão VGA arcaico:

```c
#define CUR_DEFAULT 0
#define CUR_NONE    1
#define CUR_UNDERLINE 2
#define CUR_LOWER_THIRD 3
#define CUR_LOWER_HALF 4
#define CUR_TWO_THIRDS 5
#define CUR_BLOCK   6
#define CUR_HWMASK  0x0f
#define CUR_SWMASK  0xfff0

#define CUR_SW      16
#define CUR_ALWAYS_BG 32
#define CUR_INVERT_FG_BG 64
#define CUR_FG      0x0700
#define CUR_BG      0x7000  /* <-- BUG: Assume bits 12 a 14! */
```

Note que `#define CUR_BG 0x7000` (`0111 0000 0000 0000b`) atinge os bits 12, 13 e 14.
Em consoles de 512 glifos:

- O bit 12 é a intensidade do primeiro plano.
- Os bits 13 e 14 correspondem apenas aos canais **Azul** e **Verde** do fundo! O canal **Vermelho** do fundo reside no bit 15 (`0x8000`).

Quando o usuário emprega a sequência genérica de cursor de software:

```sh
\e[?112c    # 112 = 16 (CUR_SW) + 32 (CUR_ALWAYS_BG) + 64 (CUR_INVERT_FG_BG)
```

O kernel aciona as macros `CUR_ALWAYS_BG` e `CUR_INVERT_FG_BG`, aplicando a máscara defeituosa `0x7000`. Isso inverte o bit 12 (deixando o texto em intensidade alterada) e os bits 13 e 14 (azul + verde = ciano), enquanto o bit 15 (vermelho) permanece intocado. **Resultado visual: o cursor adquire um fundo ciano brilhante em vez de branco!**

---

## 🎯 A Solução Matemática: Máscara XOR Exata (`0xee`)

Para obter um bloco de cursor sólido, estático e puramente branco com texto preto sobre ele, elimina-se o uso das macros automáticas quebradas do kernel, utilizando exclusivamente a máscara XOR de software.

### 1. Parâmetros da Sequência de Controle VT

A sequência `\e[?p1;p2;p3c` aceita três argumentos:

- **`p1` (Flags de Tipo):**
    - Deve ser estritamente `16` (`CUR_SW`).
    - **NÃO** incluir `32` (`CUR_ALWAYS_BG`) nem `64` (`CUR_INVERT_FG_BG`).
- **`p2` (Máscara XOR):**
    - Define quais bits de atributo devem ser invertidos na célula sob o cursor.
    - Bits a inverter:
        - Fundo (bits 13 a 15): `0xe000` $\rightarrow$ no byte correspondente de cor: `0xe0` (`1110 0000b` = 224).
        - Primeiro plano (bits 9 a 11): `0x0e00` $\rightarrow$ no byte de cor: `0x0e` (`0000 1110b` = 14).
        - Máscara combinada: `0xe0 | 0x0e = 0xee` (`1110 1110b` = **238** em decimal).
- **`p3` (Máscara SET):**
    - Deve ser `0` (nenhum bit forçado estaticamente).

### 2. O Inteiro de Kernel para Parâmetro de Boot

No kernel Linux, o macro `CUR_MAKE` empacota os parâmetros em um inteiro de 16 bits:

$$\text{cur\_default} = \text{CUR\_MAKE}(p1, p2, p3) = (p1 \ \& \ \text{CUR\_SWMASK}) \mid (p2 \ll 8) \mid (p1 \ \& \ \text{CUR\_HWMASK})$$

Com $p1 = 16$ (`0x10`), $p2 = 238$ (`0xee`) e $p3 = 0$:
$$\text{cur\_default} = 0x0010 \mid (0xee \ll 8) = 0xee10 = 60944 \text{ (decimal)}$$

---

## 🚀 Implementação nos Sistemas Operacionais

### 1. 🐧 Linux (Infraestrutura & Boot)

#### A. Parâmetro de Kernel (GRUB / systemd-boot)

Em `/etc/default/grub` ou entradas do loader:

```text
vt.cur_default=0xee10
```

#### B. Desativação do Pisque via Systemd Tmpfiles

Em `/etc/tmpfiles.d/console-cursor.conf`:

```text
w /sys/module/vt/parameters/cur_default - - - - 60944
w /sys/devices/virtual/graphics/fbcon/cursor_blink - - - - 0
w /sys/class/graphics/fbcon/cursor_blink - - - - 0
```

#### C. Tela Pré-Login (`/etc/issue`)

Injeção no topo de `/etc/issue` para garantir terminal limpo e decodificador UTF-8 sincronizado:

```text
\x1b%G\x1b[?16;238;0c
```

#### D. Sanitização UTF-8 (`\e%G`)

Se um comando acidental despejar caracteres binários no terminal, o decodificador do console Linux pode desviar para ISO-8859-1 ou modo de gráficos de linha DEC. O comando `\e%G` (Select UTF-8) força o retorno imediato ao parser UTF-8 nativo.

---

### 2. 😈 FreeBSD (Driver `vt(4)`)

No FreeBSD, o subsistema `vt(4)` não sofre da anomalia de cor do Linux e expõe controles limpos via utilitários da base:

#### A. Configuração Persistente (`/etc/rc.conf`)

```sh
font12x24="spleen-12x24"
allscreens_flags="-c normal,noblink"
```

#### B. Aplicação Imediata em Runtime

```sh
vidcontrol -c normal,noblink
```

---

## 🐚 O Contrato de Auto-Cura no Shell Interativo

Emuladores de terminal ou editores de texto modais (Helix, Vim) utilizam a sequência DEC `\e[?1 q` (bloco piscante) ao entrar em modos de inserção ou navegação. Ao sair, se a aplicação for abortada ou não restaurar o terminal, o console permanece piscando.

O Universal Shell aplica **auto-cura resiliente**:

1. No boot do shell (`core/environment.sh`), emite `\e%G\e[?16;238;0c` quando `_is_raw_tty` for verdadeiro.
2. Em prompts interativos (`theme/bash.sh`, `theme/zsh.sh`), reemite a sequência canônica.
3. No wrapper de editores (`hx()` em `context/desktop/common.sh`), intercepta o encerramento do processo e restaura o bloco estático:

```sh
if [ -t 1 ]; then
    if _is_raw_tty; then
        echo -n $'\e%G\e[?16;238;0c'
    else
        echo -n $'\e[0 q'
    fi
fi
```

---

## 📝 Integração com a Suíte de Editores (Vim, NeoVim, Emacs & Helix)

Enquanto emuladores gráficos PTY suportam as sequências DECSCUSR (`\e[1 q` a `\e[6 q`), os consoles virtuais puros do Linux VT suportam **5 formatos nativos de hardware** via sequências privativas CSI (`\e[?2c` a `\e[?6c`).

A Suíte de Editores do ecossistema aproveita essa arquitetura para entregar ergonomia modal mesmo em consoles seriais e de emergência:

### Matriz Universal de Cursores Modais

| Modo Operacional           | Formato Linux TTY         | Sequência de Controle | Vim (`vimrc`)          | NeoVim (`autocmds.lua`) | Emacs (`editor.el`)                       | Helix (`config.toml`)        |
| :------------------------- | :------------------------ | :-------------------- | :--------------------- | :---------------------- | :---------------------------------------- | :--------------------------- |
| **Normal / Navegação**     | Full Block (100%)         | `\e[?6c`              | `*:n*`                 | `*:n*`                  | `evil-normal-state`                       | `normal = "block"`           |
| **Inserção (Insert)**      | Underline (base)          | `\e[?2c`              | `*:i*`                 | `*:i*`                  | `evil-insert-state`                       | `insert = "bar"` (PTY)       |
| **Comando / Minibuffer**   | Lower Third (1/3)         | `\e[?3c`              | `*:c*`                 | `*:c*`                  | `minibuffer-setup-hook` / `evil-operator` | Modo comando `:`             |
| **Substituição (Replace)** | Lower Half (1/2)          | `\e[?4c`              | `*:[rR]*`              | `*:[rR]*`               | `evil-replace-state`                      | Modo replace                 |
| **Visual / Seleção**       | Two Thirds (2/3)          | `\e[?5c`              | `*:[vV\x16sS\x13]*`    | `*:[vV\22sS\19]*`       | `evil-visual-state`                       | `select = "underline"` (PTY) |
| **Saída / Suspensão**      | Bloco Softcursor Estático | `\e%G\e[?16;238;0c`   | `VimLeave, VimSuspend` | `VimLeave, VimSuspend`  | `kill-emacs-hook`                         | Wrapper `hx()` no Shell      |

### Resumo dos Comportamentos por Editor:

1. **Vim (`vimrc`):** No Linux VT (`$TERM == 'linux'`), ativa `augroup LinuxTTYCursor` com `autocmd ModeChanged` disparando `echoraw()` para alternar entre os 5 formatos, sanitiza `t_ve=\e[?25h`, `t_vi=\e[?25l` e `t_VS=\e[?25h` (prevenindo que o `cnorm` do terminfo `linux` com `\e[?0c` reset o cursor a cada redraw), define `ttimeoutlen=50` e restaura `\e%G\e[?16;238;0c` no `t_te` e `VimLeave`.

2. **NeoVim (`lua/etc/autocmds.lua`):** Emprega `autocmd ModeChanged`, `CmdlineEnter` e `CmdlineLeave` gravando diretamente no `io.stdout` (com `io.stdout:flush()`). No `$TERM == 'linux'`, desativa `vim.opt.guicursor = ''` para impedir que o driver embutido de `linuxvt` do NeoVim (`src/nvim/tui/tui.c`) colida com as sequências e resete o comando para bloco em redraws da linha 24. No modo visual (`\e[?5c` — Two Thirds), o `fbcon` aplica `ROP_XOR` nos 16 pixels inferiores; sobre a célula já invertida pelo highlight do editor, os 2/3 inferiores retornam ao fundo escuro e o 1/3 superior permanece destacado, criando a percepção ótica de um bloco de 1/3 no topo da célula.

3. **GNU Emacs (`etc/editor/editor.el`):** Quando `(string-equal (getenv "TERM") "linux")`, registra hooks nas transições de estado do Evil-mode e no `minibuffer-setup-hook`/`minibuffer-exit-hook` via `send-string-to-terminal`, restaurando `\e%G\e[?16;238;0c` no `kill-emacs-hook`.
4. **Helix (`config.toml`):** Configurado declarativamente via `[editor.cursor-shape]` (`normal = "block"`, `insert = "bar"`, `select = "underline"`). Opera com bloco sólido no Linux TTY e é auto-curado na saída pelo wrapper `hx()` do Shell.
