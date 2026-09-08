# 🖥️ Terminals (Perfis Gráficos & Configurações de Shell)

> Perfis de terminal e dotfiles de ambiente para Konsole, Windows Terminal, PowerShell, Nushell e CMD.

---

## 📂 Catálogo de Configurações

| Terminal / Shell     | Plataforma      | Arquivos Declarativos                                                                                                      | Destino                                                           |
| :------------------- | :-------------- | :------------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------- |
| **Konsole (KDE)**    | Linux & FreeBSD | [`Bash.profile`](konsole/Bash.profile), [`Zsh.profile`](konsole/Zsh.profile), [`Shell.profile`](konsole/Shell.profile)     | `~/.local/share/konsole/`                                         |
| **Windows Terminal** | Windows         | [`settings.json`](windows-terminal/settings.json)                                                                          | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_*\LocalState\` |
| **Nushell**          | Multiplataforma | [`config.nu`](nushell/config.nu), [`env.nu`](nushell/env.nu), [`nushell.nu`](nushell/nushell.nu)                           | `~/.config/nushell/` ou `%APPDATA%\nushell\`                      |
| **PowerShell**       | Windows / Multi | [`profile.ps1`](powershell/profile.ps1), [`Microsoft.PowerShell_profile.ps1`](powershell/Microsoft.PowerShell_profile.ps1) | `$HOME\Documents\PowerShell\`                                     |
| **CMD (Clink)**      | Windows         | [`profile.cmd`](cmd/profile.cmd), [`profile.lua`](cmd/profile.lua), [`setup-profile.reg`](cmd/setup-profile.reg)           | `%USERPROFILE%\` e `%PROGRAMFILES(x86)%\clink\`                   |

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

### 3. CMD com Clink & Lua

Injeta suporte a atalhos de readline Unix, histórico persistente e script Lua de completação inteligente no prompt tradicional do Windows.
