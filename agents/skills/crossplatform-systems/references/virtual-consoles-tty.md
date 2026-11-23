# 🖥️ Virtual Consoles (TTY), Keymaps & Framebuffer Architecture

> Comparativo arquitetural de consoles virtuais de kernel entre **Linux**, **FreeBSD** e **OpenBSD**, anomalias de sequências de escape (F1–F4), fontes bitmap KMS e leitores framebuffer.

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

## 🔢 2. Limites de TTY no Kernel: Linux (63) vs. FreeBSD (16)

- **Linux (`include/uapi/linux/vt.h`):** `MAX_NR_CONSOLES = 63`, alocados sob demanda via `openvt` e alternáveis via `Ctrl+Alt+F1..F12` ou `chvt N`.
- **FreeBSD (`sys/dev/vt/vt.h`):** `VT_MAXWINDOWS = 16`, mapeados em hexadecimal (`/dev/ttyv0` a `/dev/ttyvf`), configurados em `/etc/ttys` com `getty`.

---

## ⌨️ 3. Anomalia de Escape Keys no Linux TTY (F1–F4)

Em aplicações TUI modernas, pressionar `F4` no Linux Console pode emitir `'D'` literal porque o keymap padrão legado envia `\e[[A`..`\e[[D`, enquanto parsers VT100/VT220 esperam `\eOP`..`\eOS` (comportamento já nativo no `vt(4)` / `teken` do FreeBSD).

```sh
printf 'string F1 = "\x1bOP"\nstring F2 = "\x1bOQ"\nstring F3 = "\x1bOR"\nstring F4 = "\x1bOS"\n' | loadkeys -
```

---

## 📄 4. Leitura e Visualização de Documentos em TTY Puro

- **`fbpdf` / `fbida`:** Renderizadores leves sobre Poppler/Framebuffer diretamente em `/dev/fb0`.
- **Pipeline Headless (`pdftoppm` + `fbi`):**
    ```sh
    pdftoppm -png -r 150 -f 1 -l 5 documento.pdf /tmp/page
    fbi -d /dev/fb0 -T 1 -a /tmp/page-*.png
    ```
- **Extração Textual:**
    ```sh
    pdftotext -layout documento.pdf - | less
    ```

---

## 🎨 5. Degradação de Editores & Fontes Bitmap Spleen

Quando sem servidor gráfico (`RAW_TTY=1` ou `[ -z "$DISPLAY$WAYLAND_DISPLAY" ]`):

- **Vim / NeoVim:** Desative `termguicolors` e aplique esquema compatível com ANSI 16 cores.
- **GNU Emacs (`-nw`):** Use `(xterm-mouse-mode 1)` ou `gpm-mouse-mode` e paletas 16 cores.
- **Helix:** `crossterm` adapta automaticamente para paletas ANSI do console ativo.

| Resolução Vertical      | Categoria | Fonte Spleen   | Geometria Típica         |
| :---------------------- | :-------- | :------------- | :----------------------- |
| `< 1080` (720p)         | HD        | `spleen-8x16`  | `160 x 45` colunas       |
| `1080` a `1439` (1080p) | FHD       | `spleen-12x24` | `160 x 45` colunas       |
| `1440` a `2159` (1440p) | QHD       | `spleen-16x32` | `160 x 45` colunas       |
| `>= 2160` (4K)          | UHD       | `spleen-32x64` | `120 x 33` ou `240 x 67` |

- Em sistemas multi-monitor (`fbcon` espelhado), itere por `/sys/class/drm/card*-*/status` e selecione a maior altura vertical ativa para preservar legibilidade em painéis HiDPI.
- Aplique via drop-in do `systemd-vconsole-setup` / `udev` + `setupcon` no Linux, `rc.d` (`vidcontrol -f` + `allscreens_flags`) no FreeBSD e `rasops(9)` / `wsfontload(8)` no OpenBSD.
