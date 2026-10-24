# 🖥️ Terminals (Emuladores Gráficos & Multiplexadores)

> Perfis visuais e dotfiles para emuladores de janela gráfica (Konsole, Windows Terminal) e multiplexadores de sessão (Tmux, Zellij). O gerenciamento de runtimes e prompts interativos de shells pertence canonicamente ao Universal Shell.

---

## 📂 Catálogo de Configurações

| Emulador / Multiplexador | Plataforma      | Arquivos Declarativos                                                                                                  | Destino                                                           |
| :----------------------- | :-------------- | :--------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------- |
| **Foot (Wayland)**       | Linux & FreeBSD | [`foot.ini`](foot/foot.ini)                                                                                            | `~/.config/foot/foot.ini`                                         |
| **Konsole (KDE)**        | Linux & FreeBSD | [`Bash.profile`](konsole/Bash.profile), [`Zsh.profile`](konsole/Zsh.profile), [`Shell.profile`](konsole/Shell.profile) | `~/.local/share/konsole/`                                         |
| **Windows Terminal**     | Windows         | [`settings.json`](windows-terminal/settings.json)                                                                      | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_*\LocalState\` |
| **Tmux**                 | Multiplataforma | [`tmux.conf`](tmux/tmux.conf)                                                                                          | `~/.config/tmux/` e `~/.tmux.conf`                                |
| **Zellij**               | Multiplataforma | [`config.kdl`](zellij/config.kdl)                                                                                      | `~/.config/zellij/` ou `%APPDATA%\zellij\`                        |

---

## 🎯 Destaques de Arquitetura

### 1. Konsole Unificado (Linux & FreeBSD via `/usr/bin/env`)

Os perfis do Konsole utilizam `/usr/bin/env` para resolução dinâmica do caminho dos shells:

- `Command=/usr/bin/env bash`
- `Command=/usr/bin/env zsh`
- `Command=/usr/bin/env sh`

Isso elimina a necessidade de perfis separados para Linux (`/bin/`) e FreeBSD (`/usr/local/bin/`), garantindo **100% de reuso e portabilidade**. Todos os perfis utilizam a fonte **JetBrainsMono Nerd Font 12**, tema **Breeze** e cursor piscante.

### 2. Windows Terminal

Configura esquema de cores e inicialização integrada com PowerShell 7, MSYS2 UCRT64 e distros WSL2.

### 3. Multiplexadores de Terminal (Tmux & Zellij)

Sessões persistentes e divisão de janelas multiplataforma com keybindings padronizados em ambientes locais e remotos.

### 4. Desacoplamento Arquitetural (Profile ➔ Shell)

Em conformidade com a arquitetura do **Quarteto de Produtividade**:

- O **Universal Profile** gerencia exclusivamente emuladores gráficos de janela e multiplexadores visuais.
- Todos os runtimes, prompts, aliases e inicializadores de shells alternativos (**PowerShell**, **NuShell**, **Fish** e **CMD com Clink**) pertencem canonicamente ao repositório **Universal Shell** (`Shell/target/windows/` e `Shell/target/common/fish/`).
