# 🖥️ Virtual Consoles (TTY), Keymaps & Framebuffer Architecture

> Runbook cognitivo com análise técnica comparativa de consoles virtuais de kernel entre **Linux**, **FreeBSD** e **OpenBSD**, cobrindo limites de instâncias, anomalias de sequências de escape (F1-F12), suporte a fontes KMS/UTF-8 e visualizadores headless (PDF).

---

## 🧭 1. Comparativo Arquitetural de Consoles Virtuais

| Atributo                      | Linux (`fbcon` / `vt`)                           | FreeBSD (`vt(4)`)                                  | OpenBSD (`wscons(4)`)               |
| :---------------------------- | :----------------------------------------------- | :------------------------------------------------- | :---------------------------------- |
| **Driver de Kernel**          | `fbcon` / KMS Console (`drivers/video/console/`) | `vt(4)` (substituto do legado `syscons`)           | `wscons(4)` (`/sys/dev/wscons/`)    |
| **Device Nodes**              | `/dev/tty1` até `/dev/tty63`                     | `/dev/ttyv0` até `/dev/ttyvf`                      | `/dev/ttyC0` até `/dev/ttyC7`       |
| **Limite Máximo de Consoles** | **63 consoles** (`MAX_NR_CONSOLES = 63`)         | **16 consoles** (`VT_MAXWINDOWS = 16`)             | **8 consoles** configurados padrão  |
| **Emulador de Terminal**      | Linux console (`TERM=linux`)                     | `teken` VT220 (`TERM=xterm` ou `vt220`)            | `wscons` (`TERM=vt220` ou `wsvt25`) |
| **Gestão de Fontes**          | `setfont` (`/usr/share/consolefonts/`)           | `vidcontrol -f` (`/usr/share/vt/fonts/`)           | `wsconsctl -w font=...`             |
| **Formato de Fontes**         | `.psf`, `.psfu` (PC Screen Font)                 | `.fnt` (FreeBSD VT font format)                    | `.wsf` / raw bitmaps                |
| **Gestão de Teclado**         | `loadkeys` / `kbd_mode -u`                       | `kbdcontrol -l`                                    | `wsconsctl keyboard.encoding=...`   |
| **Suporte a Mouse no Kernel** | Daemon `gpm` (`/dev/input/mice`)                 | Daemon nativo `moused` (`/dev/ums0`, `/dev/psm0`)  | Daemon `wsmoused` (`/dev/wsmouse`)  |
| **Comportamento do Cursor**   | `sysfs` / softcursor (`cursor_blink=0`)          | Estático por padrão (`vt(4)` sem pisque no kernel) | `wsconsctl display.cursor=...`      |
| **Silenciamento de Bell**     | `bind 'set bell-style none'` / `\e[10;0]`        | `kern.vt.enable_bell=0` + `settc bl "$<0>"`        | `wsconsctl keyboard.bell.volume=0`  |

---

## 🔢 2. Limites de TTY no Kernel: Linux (63) vs FreeBSD (16)

### Linux (Até 63 Terminais Virtuais)

No kernel Linux (`include/uapi/linux/vt.h`):

```c
#define MAX_NR_CONSOLES        63    /* Limite máximo absoluto de VTs */
#define MAX_NR_USER_CONSOLES   63
```

- Os consoles são alocados sob demanda pelo kernel ao serem abertos ou pelo comando `openvt`.
- As teclas `Ctrl+Alt+F1` até `F12` cobrem os primeiros 12; `Alt+Seta Direita/Esquerda` ou comandos como `chvt N` alternam entre quaisquer dos 63 consoles.

### FreeBSD (Até 16 Terminais Virtuais)

No kernel FreeBSD (`sys/dev/vt/vt.h`):

```c
#define VT_MAXWINDOWS          16    /* Limite canônico de janelas virtuais */
```

- Os consoles são mapeados em hexadecimal de `0` a `f`: `/dev/ttyv0` (F1) até `/dev/ttyvb` (F12), e `ttyvc` a `ttyvf` acessíveis via rotação cíclica.
- No arquivo canônico `/etc/ttys`, o sistema ativa tradicionalmente de `ttyv0` a `ttyv8` com `getty`.

---

## ⌨️ 3. Anomalia de Escape Keys no Linux TTY (O Caso do F4 -> "D")

### Diagnóstico do Problema

Em ferramentas TUI (como o CLI do `antigravity` / `bubbletea` / `tcell`):

- Ao pressionar `F4` no Linux Console (`/dev/tty1`), a aplicação recebe o caractere literal `'D'`, ignorando o comando.
- **Causa Raiz:** O keymap histórico padrão do kernel Linux envia sequências não-padrão para as 4 primeiras teclas de função:
    - `F1`: `\e[[A`
    - `F2`: `\e[[B`
    - `F3`: `\e[[C`
    - `F4`: `\e[[D` (Escape + `[` + `[` + `D`)
- Parsers ANSI/VT padrão esperam sequências VT100/VT220 (`\eOP`..`\eOS` ou `\e[11~`..`\e[14~`). Ao se depararem com o segundo colchete (`[`), abortam o escape e emitem o caractere seguinte `'D'` diretamente para a entrada padrão da aplicação.

### Comportamento no FreeBSD

- O driver `vt(4)` com emulador `teken` implementa a especificação VT220 estrita, emitindo `\eOS` para `F4`. Por isso, essa anomalia **não ocorre no FreeBSD**.

### Remediação no Linux via `loadkeys`

Para forçar o console Linux a emitir sequências VT padrão compatíveis com todas as TUIs:

```sh
# Injeta sequências VT100 / XTerm canônicas para F1-F4 via escape hexadecimal
printf 'string F1 = "\x1bOP"\nstring F2 = "\x1bOQ"\nstring F3 = "\x1bOR"\nstring F4 = "\x1bOS"\n' | loadkeys -
```

---

## 📄 4. Leitura e Visualização de PDF/Imagens em TTY Puro

Operar sem servidor gráfico (X11/Wayland) preserva o terminal, mas exige drivers diretos de framebuffer (`/dev/fb0` ou DRM/KMS).

### Ferramentas Nativas Disponíveis

1. **`bookokrat` (Rust Moderno):**
    - Leitor de PDF, EPUB e quadrinhos em Rust com renderização direta via DRM/KMS ou Framebuffer.
    - Portável para Linux e FreeBSD (compilável via `cargo`).
2. **`fbpdf` / `fbida` (C / Poppler / Framebuffer):**
    - Utilitário ultra-leve que utiliza a biblioteca Poppler para renderizar páginas PDF diretamente em `/dev/fb0`.
    - Disponível nos pacotes Debian/Arch e no FreeBSD Ports (`graphics/fbida`).
3. **Pipeline Headless com `pdftoppm` + `fbi`:**
    - Converte rapidamente páginas selecionadas em imagens raster e desenha no framebuffer:
    ```sh
    pdftoppm -png -r 150 -f 1 -l 5 documento.pdf /tmp/page
    fbi -d /dev/fb0 -T 1 -a /tmp/page-*.png
    ```
4. **Extração e Leitura Estruturada de Texto:**
    - Para leitura de livros técnicos e código sem renderização de imagem:
    ```sh
    pdftotext -layout documento.pdf - | less
    ```

---

## 🎨 5. Degradação Elegante de Editores no Console TTY

Quando executados em console puro (`RAW_TTY=1` ou `[ -z "$DISPLAY$WAYLAND_DISPLAY" ]`):

- **Vim / NeoVim:** Desative `termguicolors` (`set notermguicolors` / `vim.o.termguicolors = false`) e aplique esquema compatível com ANSI 16 cores (`colorscheme default`).
- **GNU Emacs:** No modo `-nw` (no-window), utilize `(xterm-mouse-mode 1)` para suporte a mouse via `gpm`/`moused` e temas de alto contraste baseados em 16 cores.
- **Helix:** A biblioteca `crossterm` degrada automaticamente para paletas ANSI suportadas pelo console virtual ativo.

---

## 🔍 6. Tipografia Dinâmica & Escalonamento Multi-Monitor (Spleen Bitmap)

### A Tabela Universal de Resoluções Spleen

| Resolução Vertical Detectada  | Categoria do Painel | Fonte Spleen Proporcional         | Geometria no Console                                                         |
| :---------------------------- | :------------------ | :-------------------------------- | :--------------------------------------------------------------------------- |
| **$\le 1080$** (1080p / 720p) | Full HD / Standard  | **`spleen-12x24`**                | $160 \times 45$ caracteres                                                   |
| **$1081$ a $2159$** (1440p)   | 2K / QHD            | **`spleen-16x32`**                | $160 \times 45$ caracteres _(mesma proporção exata!)_                        |
| **$\ge 2160$** (2160p)        | 4K UHD              | **`spleen-32x64`** _(ou `16x32`)_ | $120 \times 33$ _(grande)_ ou $240 \times 67$ _(denso com `SPLEEN_DENSE=1`)_ |

### Algoritmo Multi-Monitor Defensivo

Em arranjos com mais de um monitor conectado (onde o `fbcon` do kernel clona o terminal virtual entre os displays), o escalonador itera por todas as saídas conectadas em `/sys/class/drm/card*-*/status` e adota a **maior altura vertical ativa**. Isso assegura que telas HiDPI/4K nunca sofram com texto ilegível, mantendo conforto visual na tela secundária.

### Implementação na Matriz Quádrupla de Inits

1. **Linux Systemd (Debian, Fedora, Arch):** Invocado como `ExecStartPre` no `systemd-vconsole-setup.service` via drop-in `autofont.conf`, atualizando `/etc/vconsole.conf`.
2. **Linux Não-Systemd (Devuan com SysVinit, Alpine/Gentoo com OpenRC):**
    - **Gatilho de Hardware:** Regra universal `udev`/`eudev` em `/etc/udev/rules.d/90-vconsole-autofont.rules` executando `/usr/local/libexec/vconsole-autofont`.
    - **Inicialização em Boot:** Script `/etc/init.d/vconsole-autofont` integrado ao runlevel (SysVinit LSB via `update-rc.d` e OpenRC via `rc-update`).
    - **Console-Setup:** Sincronização automática de `FONTSIZE` em `/etc/default/console-setup` e recarga via `setupcon`.
3. **FreeBSD (`vt(4)`):** Serviço rc.d canônico `/usr/local/etc/rc.d/vt_autofont`, ativado via `sysrc vt_autofont_enable="YES"`, despachando `vidcontrol -f` e atualizando `allscreens_flags`.
4. **OpenBSD (`wscons(4)`):** Automação nativa **in-kernel** no subsistema raster `rasops(9)`, implementada pelo criador da fonte Spleen (Frédéric Cambus, `fcambus@`), selecionando automaticamente `16x32` ($\ge 1920$px) ou `32x64` ($\ge 3840$px). Trocas manuais são executadas com `wsfontload(8)` e `wsconsctl display.font=...`.
