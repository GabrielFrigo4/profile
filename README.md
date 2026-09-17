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

---

### 🖥️ Ambientes & Sistemas Homologados

![Linux](https://img.shields.io/badge/Linux-Supported-blue?logo=linux&logoColor=white)
![FreeBSD](https://img.shields.io/badge/FreeBSD-Supported-red?logo=freebsd&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-Supported-purple?logo=gitforwindows&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-Supported-black?logo=apple&logoColor=white)

### 🎨 Editores, Terminais & IA

![Google Gemini & Antigravity](https://img.shields.io/badge/Antigravity_%2F_Gemini-Ready-blue?logo=googlegemini&logoColor=white)
![Visual Studio Code](https://img.shields.io/badge/VS_Code-Ready-007ACC?logo=visualstudiocode&logoColor=white)
![Zed](https://img.shields.io/badge/Zed-Ready-orange?logo=zed&logoColor=white)
![GNU Emacs](https://img.shields.io/badge/GNU_Emacs-Lite-purple?logo=gnuemacs&logoColor=white)
![Vim](https://img.shields.io/badge/Vim-Lite-green?logo=vim&logoColor=white)

```mermaid
flowchart TD
    subgraph HOME ["🏠 Espaço do Usuário ($HOME / ~/.config)"]
        PR_REPO["🎨 Profile (~/.config/profile)"]
        SYNC["⚡ scripts/sync/sync-dotfiles.sh"]
    end

    subgraph TARGETS ["🎯 Alvos Gerenciados"]
        ED["💻 Editores (VSCode, Zed, Antigravity)"]
        TR["📟 Terminais (Konsole, Windows Terminal, NuShell)"]
        TL["🛠️ Linters (.clang-format, prettier, stylua)"]
        SK["🧠 Portable AI Skills (20 Runbooks)"]
    end

    PR_REPO --> SYNC
    SYNC -->|"Symlinks atômicos (ln -sf)"| TARGETS
```

---

## 🧠 Filosofia: A Identidade Residente & Zero-Sudo

Diferente do **Setup** (que exige `sudo`/`root` para instalar pacotes no sistema operacional) ou do **Vault** (que guarda segredos criptografados privados), o **Profile** é a sua **identidade de trabalho pública e residente no `$HOME`**:

1. **Zero Privilégios Administrativos (Zero-Sudo):** Todos os arquivos e scripts operam estritamente no espaço do usuário comum (`$HOME` / `~/.config/`).
2. **Formatos Declarativos Puros:** Configurações escritas em formatos universais e legíveis (`.json`, `.toml`, `.yaml`, `.el`, `.vim`), fáceis de inspecionar, auditar e versionar.
3. **Dual-Mode de Sincronização:**
    - **Modo Residente (Recomendado):** Clone o repositório em `~/.config/profile` e execute `./scripts/sync/sync-dotfiles.sh` para criar links simbólicos atômicos (`ln -sf`). Qualquer `git pull` futuro atualiza seus editores instantaneamente!
    - **Modo Estático / RAW:** Copie arquivos avulsos diretamente pela interface do GitHub para máquinas temporárias.

---

## 📂 Estrutura do Repositório

- **[`editors/`](editors/README.md)** — **Configurações de Editores & IDEs Modernos:** Antigravity, VS Code, VSCodium e Zed (os editores modais Emacs, NeoVim, Vim e Helix operam como repositórios autônomos independentes).
- **[`terminals/`](terminals/README.md)** — **Perfis de Terminal:** Konsole (KDE), Windows Terminal, CMD (Clink), PowerShell e NuShell.
- **[`tools/`](tools/README.md)** — **Formatadores & Linters Globais:** `.clang-format`, `.prettierrc`, `.stylua.toml`, `clangd.yaml`.
- **[`browsers/`](browsers/README.md)** — **Navegadores:** Ajustes e perfis de navegadores (Firefox).
- **[`skills/`](skills/README.md)** — **Habilidades & Runbooks Portáteis para IA:** Catálogo de skills cognitivas para Google Antigravity/Gemini com ativação contínua via link de diretório unificado.
- **[`scripts/`](scripts/README.md)** — Utilitários de sincronização (`sync/`) e validação estática (`audit/`).
- **[`docs/`](docs/README.md)** — Documentação técnica completa da estação de trabalho e arquitetura.

---

## 🚀 Instalação & Sincronização Rápida

### 🐧 Unix (Linux, FreeBSD, macOS)

```sh
git clone "https://github.com/GabrielFrigo4/profile" "${HOME}/.config/profile"
sh "${HOME}/.config/profile/install.sh"
```

### 🪟 Windows (PowerShell)

```powershell
git clone "https://github.com/GabrielFrigo4/profile" "$HOME\.config\profile"
& "$HOME\.config\profile\install.ps1"
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
python3 scripts/audit/all.py
```

---

## 🔗 Integração com o Quarteto de Produtividade

- 📦 **[Setup](https://github.com/GabrielFrigo4/setup)**: Provisiona a máquina hospedeira e pacotes base com privilégios de sistema.
- 🐚 **[Shell](https://github.com/GabrielFrigo4/shell)**: Fornece prompts rápidos e o motor da linha de comando.
- 🔐 **[Vault](https://github.com/GabrielFrigo4/vault)**: Fornece chaves SSH e segredos privados.
- 🎨 **[Profile](https://github.com/GabrielFrigo4/profile)**: Personaliza os aplicativos gráficos, linters e inteligência artificial no `$HOME`.
