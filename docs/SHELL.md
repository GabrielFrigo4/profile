# 🐚 Universal Shell Ecosystem

O repositório **[Universal Shell Environment](https://github.com/GabrielFrigo4/shell)** é o "motor dinâmico" do ecossistema. Ele contém a lógica interativa da linha de comando, prompts otimizados, aliases globais, funções utilitárias e gerenciamento de contexto para todos os ambientes.

Enquanto o **Setup** cuida do provisionamento do sistema e o **Profile** dos dotfiles do usuário, o **Shell** provê agilidade e ergonomia ao terminal no dia a dia.

---

## 📂 Instalação e Caminhos Padrão

O repositório Shell é clonado globalmente ou localmente por usuário (contextos válidos: `desktop`, `server`, `container`, `wsl`):

```sh
sudo git clone "https://github.com/GabrielFrigo4/shell" "/usr/local/share/shell"
sh "/usr/local/share/shell/install.sh" --context desktop
```

---

## 🗂️ Arquitetura Modular do Shell

O repositório Shell foi projetado seguindo estritamente os princípios de modularidade e separação de interesses:

```text
Shell/
├── core/
├── context/
├── target/
├── library/
├── theme/
└── install.sh
```

- **`core/` (9 módulos):** Núcleo de boot e runtime (`detect.sh`, `ui.sh`, `elevate.sh`, `perms.sh`, `path.sh`, `environment.sh`, `userland.sh`, `vault.sh`, `deploy.sh`).
- **`library/` (5 dispatchers + subpastas):** Bibliotecas de domínio organizadas em `desktop.sh` (`desktop/`), `system.sh` (`system/`), `functions.sh` (`functions/`), `ecosystem.sh` (`ecosystem/`) e `hypervisor.sh` (`hypervisor/`).
- **`context/`:** Especializações por tipo de máquina (`desktop`, `server`, `container`, `wsl`).
- **`target/`:** Especializações por sistema operacional (`linux`, `freebsd`, `openbsd`, `netbsd`, `illumos`, `macos`, `windows`, `common`).
- **`theme/`:** Temas visuais e prompts rápidos (`bash.sh`, `zsh.sh`, `sh.sh`, `ksh.sh`).
- **`install.sh`:** Instalador idempotente.

---

## 🛠️ A Matriz de Shells Suportados

Para garantir consistência e performance sem adicionar complexidade desnecessária, focamos nos interpretadores homologados:

### Ambientes UNIX (Linux, FreeBSD, OpenBSD, NetBSD, illumos, macOS, WSL2)

- **`sh` / `ksh`:** POSIX puro (`sh` nativo do FreeBSD com `libedit` e `/bin/ksh` no OpenBSD; `dash` e NetBSD `/bin/sh` não são suportados interativamente).
- **`bash`**: Presente nativamente na maioria das distribuições Linux e servidores.
- **`zsh`**: Shell interativo padrão diário, altamente configurado com autocompletion e navegação eficiente.
- **`fish`**: Suporte completo via módulo dedicado em `target/common/fish/`.

### Ambientes Windows Nativo

- **`pwsh` (PowerShell Core)**: Automação moderna de scripts e manipulação de objetos.
- **`cmd`**: Prompt clássico do Windows com suporte a `clink` para readline.
- **`nushell`**: Shell moderno com dados estruturados para pipelines avançados.
