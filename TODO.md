# 🗺️ Roadmap & Backlog

> Planejamento estratégico, status operacional e visão de futuro para a evolução do **Universal Profile**.

---

## 📊 Status do Projeto

| Área                                |   Status   | Cobertura / Estado                                                                |
| :---------------------------------- | :--------: | :-------------------------------------------------------------------------------- |
| **🖥️ Emuladores & Multiplexadores** | 🟢 Estável | Konsole, Windows Terminal, Tmux e Zellij sincronizados via links declarativos     |
| **📝 Configurações de Editores**    | 🟢 Estável | VS Code, Antigravity e Zed sincronizados via links declarativos                   |
| **🛠️ Linters & Formatadores**       | 🟢 Estável | `.clang-format`, `.prettierrc`, `.stylua.toml`, `.editorconfig`                   |
| **🤖 Portable AI Skills**           | 🟢 Estável | Catálogo de skills portáteis orientadas a ação e compatíveis com agentes          |
| **🔄 Sincronização & Links**        | 🟢 Estável | Motor unificado `profile.sh` (UNIX & MSYS2 Soberano) com auto-cura e idempotência |
| **🧪 Suite de Auditoria**           |  🟢 100%   | 100% de conformidade com linters de monólitos, nanos, banners e formatos          |

---

## 🎯 Grandes Épicos & Backlog

### 1. 🎨 Lapidação e Organização dos Dotfiles

- [x] Padronização dos comandos de atualização `up*` e biblioteca semântica `_ui_*`.
- [x] Revisão geral e expurgo de configurações legadas ou redundantes em dotfiles.
- [x] Otimização dos esquemas de temas para consistência visual entre terminais e editores.

### 2. 🛡️ Resiliência e Auto-Cura de Symlinks

- [x] Reforçar a auto-detecção de links quebrados ou sobrescritos em `profile.sh` com idempotência ativa (`[OK]`).
- [x] Unificação do motor em `profile.sh` com suporte a MSYS2, expurgo limpo de `install.ps1`, cascata de links e reconciliação bidirecional (`--pull` / `--status`).
- [x] Garantir que o Profile possa ser restaurado e sincronizado de forma estritamente idempotente.

### 3. 🌐 Governança XDG e Multiplataforma

- [x] Auditar e garantir paridade total entre Linux, FreeBSD, macOS e Windows com resolução XDG (`$XDG_CONFIG_HOME`, `$XDG_DATA_HOME`).

### 4. 📝 Alinhamento de Extensões IDE (Open VSX / FreeBSD Code OSS)

- [x] Motor declarativo `core/extensions.sh` mapeando Code OSS no FreeBSD diretamente para o catálogo VSCodium.
- [x] Expurgada extensão proprietária `ms-python.vscode-pylance` do manifesto do VSCodium em favor da engine aberta `ms-pyright.pyright`.

### 5. 🐚 Desacoplamento Profile ➔ Shell (Épico 10)

- [x] Migração dos runtimes de shells alternativos (PowerShell, NuShell, CMD com Clink) para o repositório canônico `Shell/`.
- [x] Expurgo limpo de `terminals/powershell/`, `terminals/nushell/`, `terminals/cmd/` e atualização de `core/sync.sh` (233 linhas, <= 256).
- [x] Redefinição de fronteira: Profile foca exclusivamente em emuladores gráficos de terminal e multiplexadores.

---

> [!TIP]
> Para detalhes sobre convenções de código e diretrizes de engenharia, consulte o [PRINCIPLES.md](PRINCIPLES.md).
