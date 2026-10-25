# 🖱️ Subsistemas de Mouse, Formatos de Cursor & Paletas em TTY

> Este documento canônico estabelece os fundamentos técnicos da arquitetura de mouse, controle de cursores e padronização cromática em consoles virtuais de texto puro (**FreeBSD `vt(4)`** e **Linux VT**), detalhando os mecanismos de emulação xterm, o protocolo GPM, o PTY Mouse Bridge e a calibração de paletas.

---

## 🏛️ 1. O Mouse em Consoles Puros: FreeBSD vs Linux

### 1.1 A Arquitetura do FreeBSD `vt(4)` + `moused`

No FreeBSD, a integração de mouse em consoles puros (`ttyv0` a `ttyv7`) opera no **nível de driver de kernel**:

```
[Hardware Mouse] ──> [/dev/ums0 ou /dev/psm0]
                           │
                           ▼
                       [moused] ──> [/dev/sysmouse]
                                         │
                                         ▼
                            [Kernel FreeBSD: vt(4)]
                                         │
     ┌───────────────────────────────────┴───────────────────────────────────┐
     │ Detecta sequências xterm: \e[?1000h, \e[?1002h, \e[?1006h             │
     │ Converte coordenadas e botões em sequências SGR 1006 (\e[<btn;col;linM)│
     │ Injeta sequências diretamente no buffer de leitura do TTY (stdin)     │
     └───────────────────────────────────┬───────────────────────────────────┘
                                         │
                                         ▼
                   [Aplicações TUI: Vim, NeoVim, Helix, Micro, Emacs]
                   (Recebem mouse padrão xterm sem precisar de libs externas)
```

Por essa razão, editores modernos como NeoVim, Helix e Micro funcionam nativamente no console do FreeBSD sem qualquer camada de compatibilidade.

---

### 1.2 A Arquitetura do Linux VT & O Protocolo GPM

No Linux, o driver de terminal virtual do kernel (`drivers/tty/vt/`) **NÃO** implementa emulação de sequências xterm de mouse. O suporte a apontadores em modo texto foi delegado ao daemon de espaço de usuário **GPM** (_General Purpose Mouse_):

1. **Comunicação por Socket:** O GPM abre `/dev/input/mice` e disponibiliza um socket UNIX em `/dev/gpmctl`.
2. **Aplicações Clássicas (Vim e Emacs):** Conectam-se ao socket via `libgpm.so.2` usando as estruturas binárias `Gpm_Connect` e `Gpm_Event`.
3. **O Repetidor `-R` do GPM:** A flag `-R` apenas repete pacotes binários brutos de mouse (PS/2 ou IntelliMouse) para `/dev/gpmdata` (para servidores X11 legados); ela **NÃO** injeta sequências de escape ANSI no `stdin` dos processos.
4. **Editores Modernos (NeoVim, Helix, Micro):** Não linkam com `libgpm` e esperam exclusivamente sequências xterm SGR (`\e[<0;x;yM`) em seu `stdin`. Por isso, falham por padrão no Linux VT.

---

## 🛠️ 2. Diagnóstico e Resolução por Editor

### 2.1 Vim (`+mouse_gpm`)

- **Problema:** O Vim possui suporte nativo ao GPM, mas a diretiva incondicional `set ttymouse=sgr` força o Vim a esperar sequências SGR no `stdin`, desabilitando o backend GPM.
- **Solução:** Condicionar a configuração para ignorar `sgr` quando `$TERM == 'linux'`:
    ```vim
    if has('mouse_sgr') && $TERM !=# 'linux'
        set ttymouse=sgr
    endif
    ```

### 2.2 GNU Emacs (`gpm-mouse-mode`)

- **Problema:** O Emacs inclui o pacote embutido `t-mouse.el`, mas ele não é ativado por padrão.
- **Solução:** Ativar `gpm-mouse-mode` automaticamente no arranque em consoles Linux:
    ```elisp
    (if (and (string-equal (or (getenv "TERM") "") "linux") (fboundp 'gpm-mouse-mode))
        (ignore-errors (gpm-mouse-mode 1))
      (when (fboundp 'xterm-mouse-mode)
        (xterm-mouse-mode 1)))
    ```

### 2.3 NeoVim, Helix e Micro: Diretriz Soberana de I/O Direto

- **Problema:** Nem NeoVim, nem Helix (Rust/crossterm), nem Micro (Go/tcell) possuem clientes GPM.
- **Diretriz Arquitetural:** O ecossistema rejeita a criação de wrappers artificiais de PTY (`pty.fork`) em Python na frente dos binários interativos. Tais intermediários geram latência de bufferização, falhas de sincronismo em redimensionamentos (`SIGWINCH`), quebra de suspensão (`Ctrl-Z`) e ruído de eventos de hover. Os editores rodam de forma direta (`direct stdio`), priorizando soberania e estabilidade no TTY.

---

## 📐 3. Formatos de Cursor no Linux VT & Bug de Terminfo

### 3.1 Registradores de Hardware do Linux VT

O driver de console do Linux implementa sequências de escape privadas para configurar as linhas de varredura do cursor de hardware VGA:

| Sequência | Formato do Cursor              | Estado do Editor               |
| :-------- | :----------------------------- | :----------------------------- |
| `\e[?1c`  | Cursor invisível               | Ocultação temporária           |
| `\e[?2c`  | Sublinhado fino inferior (20%) | Modo Insert (`i`)              |
| `\e[?3c`  | Sublinhado médio (35%)         | Linha de comando (`:`)         |
| `\e[?4c`  | Meio bloco inferior (50%)      | Modo Replace (`r`, `R`)        |
| `\e[?5c`  | Três quartos de bloco (75%)    | Modo Visual (`v`, `V`, `\x16`) |
| `\e[?6c`  | Bloco sólido completo (100%)   | Modo Normal (`n`)              |

Para restaurar o cursor estático do shell sem pisque no retorno ao prompt:

```sh
\e%G\e[?16;238;0c
```

### 3.2 O Bug Histórico de Terminfo (`cnorm=\E[?25h\E[?0c`)

Na base de terminfo upstream das distribuições Linux (`/usr/share/terminfo/l/linux`), as entradas de visibilidade do cursor contêm:

```
cnorm=\E[?25h\E[?0c
cvvis=\E[?25h\E[?8c
```

A sequência `\E[?0c` reseta o hardware VGA para as linhas de varredura padrão do kernel. Toda vez que uma aplicação TUI (como NeoVim ou Emacs) realiza um redesenho de tela, a biblioteca interna de tela emite `cnorm`, destruindo a forma do cursor definida pelo `ModeChanged`.

#### Mitigação Canônica:

1. **Terminfo Sanitizado Local (`~/.terminfo/l/linux`):** Gerar via `tic` uma definição onde `cnorm=\E[?25h`, `cvvis=\E[?25h`, `civis=\E[?25l`.
2. **Despacho Assíncrono com `schedule` e `defer_fn`:** No NeoVim, disparar `set_cur()` imediatamente e agendar nova emissão via `vim.schedule()` e `vim.defer_fn(emit, 15)` para sobrescrever qualquer emissão de `cnorm` gerada pelo redraw de transição de modo.

---

## 🔀 4. Substituição de Caractere Único (`r`)

Ao pressionar `r` em modo normal ou `<C-o>r` em modo insert, o Vim e o Emacs Evil não entram em um modo formal contínuo; eles bloqueiam esperando o caractere de substituição sem disparar `ModeChanged`.

- **No Vim:** Mapeamento expression (`nnoremap <expr> r` e `inoremap <expr> <C-o>r`) invocando `s:replace_single_char()`, chamando `redraw` explícito antes e depois de `getcharstr()`.
- **No Emacs:** Interceptação via advice em `evil-refresh-cursor` capturando `evil-force-cursor == 'replace'` da especificação `interactive` de `evil-replace`.
- **No NeoVim:** Interceptação por `vim.on_key`, identificando a transição de tecla `r` em modo `n` e `<C-o>r` em `niI`.

---

## 🎨 5. Alpha Blending Real & Simetria de Plataformas

Para garantir paridade com as diretrizes de design de temas e imunidade à inversão Dark/Light:

1. **Proibição de Cores Fixas:** Nunca fixe valores literais como `#ffffff` ou `#a8a8a8` para modos de edição.
2. **Alpha Blending Matemático:** Interpolação linear da cor do cursor ($C_{\text{cur}}$) em direção à cor de fundo do tema ($C_{\text{bg}}$) pelo fator $\alpha \in [0.0, 1.0]$:
   $$C_{\text{final}} = \text{round}(C_{\text{cur}} \times \alpha + C_{\text{bg}} \times (1 - \alpha))$$
    - **Normal:** 100% ($\alpha = 1.0$)
    - **Insert:** 85% ($\alpha = 0.85$, levemente translúcido)
    - **Replace:** 70% ($\alpha = 0.70$, moderado)
    - **Visual:** 55% ($\alpha = 0.55$, translúcido atenuado)
3. **Simetria Técnica (FreeBSD vs Linux):**
    - **FreeBSD `vt(4)`:** Suporta **OSC 12** (`\e]12;#hex\7`) para redefinir a cor do cursor em tempo de execução, mas não possui scanlines VGA. Alpha Blending via OSC 12 é o mecanismo primário.
    - **Linux VT:** Não suporta OSC 12, mas possui **scanlines de hardware (`\e[?c`)**, tornando a indicação por forma física o padrão canônico no Linux.

---

## 🌈 6. Padronização da Paleta de 16 Cores do Linux TTY com FreeBSD `vt(4)`

Para assegurar consistência visual idêntica entre o FreeBSD e o Linux VT, a tabela DAC de 16 cores do Linux é reprogramada com os valores canônicos do FreeBSD `vt(4)` (`sys/dev/vt/vt.h`):

| Índice | Nome da Cor   | Código Hexadecimal | RGB Decimal     |
| :----: | :------------ | :----------------- | :-------------- |
| **0**  | Black         | `#000000`          | `0, 0, 0`       |
| **1**  | Dark Red      | `#7f0000`          | `127, 0, 0`     |
| **2**  | Dark Green    | `#007f00`          | `0, 127, 0`     |
| **3**  | Dark Yellow   | `#c4a100`          | `196, 161, 0`   |
| **4**  | Dark Blue     | `#3366a3`          | `51, 102, 163`  |
| **5**  | Dark Magenta  | `#7f007f`          | `127, 0, 127`   |
| **6**  | Dark Cyan     | `#007f7f`          | `0, 127, 127`   |
| **7**  | Light Gray    | `#bfbfbf`          | `191, 191, 191` |
| **8**  | Dark Gray     | `#73828a`          | `115, 130, 138` |
| **9**  | Light Red     | `#ff0000`          | `255, 0, 0`     |
| **10** | Light Green   | `#00ff00`          | `0, 255, 0`     |
| **11** | Light Yellow  | `#ffff00`          | `255, 255, 0`   |
| **12** | Light Blue    | `#739ecf`          | `115, 158, 207` |
| **13** | Light Magenta | `#ff00ff`          | `255, 0, 255`   |
| **14** | Light Cyan    | `#00ffff`          | `0, 255, 255`   |
| **15** | White         | `#ffffff`          | `255, 255, 255` |

### Aplicação no Ecossistema:

- **Runtime (`Shell/core/environment.sh`):** Injeta via escape OSC `\e]P<idx><hex>` no boot interativo de consoles Linux.
- **Kernel Sysfs (`Setup/linux/common/system/console.sh`):** Configura `/etc/tmpfiles.d/console-cursor.conf` escrevendo os arrays em `/sys/module/vt/parameters/default_{red,grn,blu}`.
