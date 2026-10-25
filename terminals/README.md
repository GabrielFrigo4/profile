# 🖥️ Terminals (Emuladores Gráficos & Multiplexadores)

> Perfis visuais e dotfiles para emuladores de janela gráfica (Konsole, Windows Terminal) e multiplexadores de sessão (Tmux, Zellij). O gerenciamento de runtimes e prompts interativos de shells pertence canonicamente ao Universal Shell.

---

## 📂 Catálogo de Configurações

| Emulador / Multiplexador | Plataforma      | Arquivos Declarativos                                                                                                  | Destino                                                           |
| :----------------------- | :-------------- | :--------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------- |
| **Foot (Wayland)**       | Linux & FreeBSD | [`foot.ini`](foot/foot.ini)                                                                                            | `~/.config/foot/foot.ini`                                         |
| **XTerm (X11)**          | Linux & FreeBSD | [`Xresources`](xterm/Xresources)                                                                                       | `~/.Xresources`                                                   |
| **Konsole (KDE)**        | Linux & FreeBSD | [`Bash.profile`](konsole/Bash.profile), [`Zsh.profile`](konsole/Zsh.profile), [`Shell.profile`](konsole/Shell.profile) | `~/.local/share/konsole/`                                         |
| **Windows Terminal**     | Windows         | [`settings.json`](windows-terminal/settings.json)                                                                      | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_*\LocalState\` |
| **Tmux**                 | Multiplataforma | [`tmux.conf`](tmux/tmux.conf)                                                                                          | `~/.config/tmux/` e `~/.tmux.conf`                                |
| **Zellij**               | Multiplataforma | [`config.kdl`](zellij/config.kdl)                                                                                      | `~/.config/zellij/` ou `%APPDATA%\zellij\`                        |

---

## 🎯 Destaques de Arquitetura

### 1. Paridade Visual & Ergonômica: Foot (Wayland) e XTerm (X11)

Para garantir uma experiência de terminal de alto nível nos lançadores gráficos efêmeros (`wgui` e `xgui`), o **Foot** e o **XTerm** compartilham a mesma identidade visual:

- **Paleta Cromática:** Adwaita Dark (fundo `#1e1e1e`, texto `#deddda`, destaque `#3584e4`, 16 cores ANSI calibradas).
- **Tipografia:** Hierarquia universal com `JetBrainsMono Nerd Font` prioritária e fallbacks defensivos (`Hack`, `Noto Sans Mono`, `Adwaita Mono`, `DejaVu Sans Mono`).
- **Geometria:** Margem interna (_padding_) de 16px, cursor bloco piscante e eliminação de barras de rolagem arcaicas.

### 2. Konsole Unificado (Linux & FreeBSD via `/usr/bin/env`)

Os perfis do Konsole utilizam `/usr/bin/env` para resolução dinâmica do caminho dos shells:

- `Command=/usr/bin/env bash`
- `Command=/usr/bin/env zsh`
- `Command=/usr/bin/env sh`

Isso elimina a necessidade de perfis separados para Linux (`/bin/`) e FreeBSD (`/usr/local/bin/`), garantindo **100% de reuso e portabilidade**. Todos os perfis utilizam a fonte **JetBrainsMono Nerd Font 12**, tema **Breeze** e cursor piscante.

### 3. Windows Terminal

Configura esquema de cores e inicialização integrada com PowerShell 7, MSYS2 UCRT64 e distros WSL2.

### 4. Multiplexadores de Terminal (Tmux & Zellij)

Sessões persistentes e divisão de janelas multiplataforma com keybindings padronizados em ambientes locais e remotos.

### 5. Desacoplamento Arquitetural (Profile ➔ Shell)

Em conformidade com a arquitetura do **Quarteto de Produtividade**:

- O **Universal Profile** gerencia exclusivamente emuladores gráficos de janela e multiplexadores visuais.
- Todos os runtimes, prompts, aliases e inicializadores de shells alternativos (**PowerShell**, **NuShell**, **Fish** e **CMD com Clink**) pertencem canonicamente ao repositório **Universal Shell** (`Shell/target/windows/` e `Shell/target/common/fish/`).
