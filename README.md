# 🎨 Universal Profile Environment

> Repositório central de dotfiles declarativos de softwares, configurações de editores, perfis de emuladores de terminal, linters globais e catálogo de habilidades portáteis para agentes de IA. Componente de identidade do desenvolvedor do **Quarteto de Produtividade**.

---

### 🏛️ O Quarteto de Produtividade

[![Setup](https://img.shields.io/badge/📦_Setup-Sistema_%26_Cookbook-blue)](https://github.com/GabrielFrigo4/setup)
[![Shell](https://img.shields.io/badge/🐚_Shell-Terminal_Runtime-purple)](https://github.com/GabrielFrigo4/shell)
[![Vault](https://img.shields.io/badge/🔐_Vault-Cofre_Privado-red)](https://github.com/GabrielFrigo4/vault)
[![Profile](https://img.shields.io/badge/🎨_Profile-Dotfiles_%26_IA-green)](https://github.com/GabrielFrigo4/profile)

> 📖 **Arquitetura Unificada do Ecossistema:** Conheça a matriz completa de responsabilidades, ciclo de boot e segregação de privilégios em [ENVIRONMENT.md](ENVIRONMENT.md).
> 📜 **Princípios de Engenharia & Dotfiles:** Conheça os 18 princípios e diretrizes Clean Code em [PRINCIPLES.md](PRINCIPLES.md).
> 🗺️ **Roadmap & Status do Projeto:** Acompanhe o planejamento e a matriz de status em [TODO.md](TODO.md).

---

### 🖥️ Ambientes & Sistemas Homologados

![FreeBSD](https://img.shields.io/badge/FreeBSD-Supported-red?logo=freebsd&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Supported-blue?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-Supported-black?logo=apple&logoColor=white)
![Windows](<https://img.shields.io/badge/Windows_(Native_%26_MSYS2)-Supported-purple?logo=gitforwindows&logoColor=white>)
![OpenBSD](https://img.shields.io/badge/OpenBSD-Supported-yellow?logo=openbsd&logoColor=white)
![NetBSD](https://img.shields.io/badge/NetBSD-Supported-orange?logo=netbsd&logoColor=white)
![illumos](https://img.shields.io/badge/illumos-Supported-orange?logo=openzfs&logoColor=white)
[![Roadmap](https://img.shields.io/badge/🗺️_Roadmap-TODO.md-teal)](TODO.md)

O **Universal Profile** opera com paridade multiplataforma absoluta em **FreeBSD**, **Linux**, **macOS**, **OpenBSD**, **NetBSD**, **illumos** e **Windows** (nativo via PowerShell e sob MSYS2 via POSIX). Todas as configurações e links simbólicos são orquestrados de forma declarativa e atômica (`ln -sf`) sem necessidade de privilégios de superusuário (`sudo`).

### 🎨 Editores, Terminais & IA

![Google Gemini & Antigravity](https://img.shields.io/badge/Antigravity_%2F_Gemini-Ready-blue?logo=googlegemini&logoColor=white)
![Visual Studio Code](https://img.shields.io/badge/VS_Code-Ready-007ACC?logo=visualstudiocode&logoColor=white)
![Zed](https://img.shields.io/badge/Zed-Ready-orange?logo=zed&logoColor=white)
![GNU Emacs](https://img.shields.io/badge/GNU_Emacs-Lite-purple?logo=gnuemacs&logoColor=white)
![Vim](https://img.shields.io/badge/Vim-Lite-green?logo=vim&logoColor=white)

```mermaid
flowchart TD
    subgraph HOME ["🏠 Espaço do Usuário ($HOME / ~/.config)"]
        PR_REPO["🎨 Profile (~/.local/share/profile)"]
        SYNC["⚡ profile.sh sync"]
    end

    subgraph TARGETS ["🎯 Alvos Gerenciados"]
        ED["💻 Editores (VSCode, Zed, Antigravity)"]
        TR["📟 Terminais (Konsole, Windows Terminal, NuShell)"]
        TL["🛠️ Linters (.clang-format, prettier, stylua)"]
        SK["🧠 Portable AI Skills (26 Runbooks)"]
    end

    PR_REPO --> SYNC
    SYNC -->|"Symlinks atômicos (ln -sf)"| TARGETS
```

---

## 🧠 Filosofia: A Identidade Residente & Zero-Sudo

Diferente do **Setup** (que exige `sudo`/`root` para instalar pacotes no sistema operacional) ou do **Vault** (que guarda segredos criptografados privados), o **Profile** é a sua **identidade de trabalho pública e residente no `$HOME`**:

1. **Zero Privilégios Administrativos (Zero-Sudo):** Todos os arquivos e scripts operam estritamente no espaço do usuário comum (`$HOME` / `~/.local/share/`).
2. **Formatos Declarativos Puros:** Configurações escritas em formatos universais e legíveis (`.json`, `.toml`, `.yaml`, `.el`, `.vim`), fáceis de inspecionar, auditar e versionar.
3. **Dual-Mode de Sincronização:**
    - **Modo Residente (Recomendado):** Clone o repositório em `~/.local/share/profile` e execute `sh profile.sh sync` para criar links simbólicos atômicos (`ln -sf`). Qualquer `git pull` futuro atualiza seus editores instantaneamente!
    - **Modo Estático / RAW:** Copie arquivos avulsos diretamente pela interface do GitHub para máquinas temporárias.

---

## 📂 Estrutura do Repositório

- **[`profile.sh`](profile.sh)** — **Interface Unificada de Componente:** Entrypoint CLI para `sync`, `update`, `test`, `audit` e exportação de ambiente.
- **[`editors/`](editors/README.md)** — **Configurações de Editores & IDEs Modernos:** Antigravity, VS Code, VSCodium e Zed (os editores modais Emacs, NeoVim, Vim e Helix operam como repositórios autônomos independentes).
- **[`terminals/`](terminals/README.md)** — **Perfis de Terminal:** Konsole (KDE), Windows Terminal, CMD (Clink), PowerShell e NuShell.
- **[`tools/`](tools/README.md)** — **Formatadores & Linters Globais:** `.clang-format`, `.prettierrc`, `.stylua.toml`, `clangd.yaml`.
- **[`browsers/`](browsers/README.md)** — **Navegadores:** Ajustes e perfis de navegadores (Firefox).
- **[`skills/`](skills/README.md)** — **Habilidades & Runbooks Portáteis para IA:** Catálogo de skills cognitivas para Google Antigravity/Gemini com ativação contínua via link de diretório unificado.
- **[`audit/`](audit/README.md)** — Suíte de validação estática de integridade, formatos e links.
- **[`docs/`](docs/README.md)** — Documentação técnica completa da estação de trabalho e arquitetura.

---

## 🚀 Instalação & Sincronização Rápida

### 🗺️ Matriz de Caminhos de Instalação do Profile

| Localização Canônica           | Escopo / Privilégios           | Status & Recomendação  | Casos de Uso & Contexto                                                                             |
| :----------------------------- | :----------------------------- | :--------------------: | :-------------------------------------------------------------------------------------------------- |
| **`~/.local/share/profile`**   | XDG Data (Rootless)            |   ⭐ **Recomendado**   | Padrão soberano moderno em Linux, FreeBSD, macOS e MSYS2 com isolamento limpo de dotfiles.          |
| **`~/.config/profile`**        | XDG Config (Rootless)          | 🔵 **Alternativa XDG** | Instalações unificadas onde o profile reside diretamente dentro do diretório de configurações.      |
| **`~/.profile`**               | Home Direta (Clássico UNIX)    | ⚪ **Fallback Legado** | Sistemas UNIX clássicos, ambientes mínimos sem suporte a XDG ou preferência por dotdirs no `$HOME`. |
| **`/usr/local/share/profile`** | Global / FHS (`root` / `sudo`) | ⚠️ **Não Recomendado** | Apenas para imagens base multiusuário imutáveis; desaconselhado por quebrar autonomia do usuário.   |

---

### 🐧 Unix & 🪟 MSYS2 (Modo Rootless — Recomendado)

#### Opção A: XDG Data (Canônico Rootless — Recomendado)

```sh
git clone "https://github.com/GabrielFrigo4/profile" "${HOME}/.local/share/profile"
sh "${HOME}/.local/share/profile/profile.sh" sync
```

#### Opção B: XDG Config (Ergonomia unificada sob ~/.config)

```sh
git clone "https://github.com/GabrielFrigo4/profile" "${HOME}/.config/profile"
sh "${HOME}/.config/profile/profile.sh" sync
```

#### Opção C: Home Direta (Fallback Clássico UNIX / Ambientes Legados)

```sh
git clone "https://github.com/GabrielFrigo4/profile" "${HOME}/.profile"
sh "${HOME}/.profile/profile.sh" sync
```

---

### 🪟 Windows (Nativo via PowerShell)

```powershell
git clone "https://github.com/GabrielFrigo4/profile" "$HOME\.local\share\profile"
& "$HOME\.local\share\profile\install.ps1"
```

---

## 🧪 Quality Gates & Ganchos Git (.githooks)

Para habilitar a validação de dotfiles, Markdown e linters antes de cada commit:

```sh
chmod 0755 .githooks/pre-commit
git config core.hooksPath .githooks
```

Para executar a validação estática de formatos e links manualmente:

```sh
python3 audit/all.py
```

---

## 🔗 Integração com o Quarteto de Produtividade

- 📦 **[Setup](https://github.com/GabrielFrigo4/setup)**: Provisiona a máquina hospedeira e pacotes base com privilégios de sistema.
- 🐚 **[Shell](https://github.com/GabrielFrigo4/shell)**: Fornece prompts rápidos e o motor da linha de comando.
- 🔐 **[Vault](https://github.com/GabrielFrigo4/vault)**: Fornece chaves SSH e segredos privados.
- 🎨 **[Profile](https://github.com/GabrielFrigo4/profile)**: Personaliza os aplicativos gráficos, linters e inteligência artificial no `$HOME`.
