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

### 🖥️ Ambientes & Editores Suportados

![Linux](https://img.shields.io/badge/🐧_Linux-Supported-blue)
![FreeBSD](https://img.shields.io/badge/😈_FreeBSD-Supported-red)
![Windows](https://img.shields.io/badge/🪟_Windows-Supported-purple)
![macOS](https://img.shields.io/badge/🍎_macOS-Supported-lightgrey)

![Antigravity](https://img.shields.io/badge/✨_Antigravity-Ready-blue)
![VS Code](https://img.shields.io/badge/💻_VS_Code-Ready-007ACC)
![Zed](https://img.shields.io/badge/⚡_Zed-Ready-orange)
![Emacs](https://img.shields.io/badge/🐂_Emacs-Lite-purple)
![Vim](https://img.shields.io/badge/🟢_Vim-Lite-green)

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

- **[`software/`](software/README.md)** — **Dotfiles e Configurações Declarativas de Usuário:**
  - **`editors/`** — Antigravity, VS Code, VSCodium, Zed, Emacs (`lite.el`) e Vim (`lite.vim`).
  - **`terminals/`** — Konsole (KDE), Windows Terminal, CMD (Clink), PowerShell e NuShell.
  - **`tools/`** — Formatadores e linters globais (`.clang-format`, `.prettierrc`, `.stylua.toml`, `clangd.yaml`).
  - **`browsers/`** — Ajustes e perfis de navegadores (Firefox).
- **[`skills/`](skills/README.md)** — **Habilidades & Runbooks Portáteis para IA:** Catálogo de skills cognitivas para Google Antigravity/Gemini, Claude e OpenAI com ativação sob demanda.
- **[`scripts/`](scripts/README.md)** — Utilitários de sincronização (`sync/`) e validação estática (`audit/`).
- **[`docs/`](docs/README.md)** — Documentação técnica completa da estação de trabalho e arquitetura.

---

## 🚀 Instalação & Sincronização Rápida

```sh
# 1. Clonar o Profile no seu diretório de configurações do usuário
git clone "https://github.com/GabrielFrigo4/profile" "${HOME}/.config/profile"
cd "${HOME}/.config/profile"

# 2. Criar links simbólicos automáticos para todos os seus editores e formatadores
./scripts/sync/sync-dotfiles.sh

# 3. Sincronizar as skills de inteligência artificial para o agente
./scripts/sync/sync-skills.sh
```

---

## 🔗 Integração com o Quarteto de Produtividade

- 📦 **[Setup](https://github.com/GabrielFrigo4/setup)**: Provisiona a máquina hospedeira e pacotes base com privilégios de sistema.
- 🐚 **[Shell](https://github.com/GabrielFrigo4/shell)**: Fornece prompts rápidos e o motor da linha de comando.
- 🔐 **[Vault](https://github.com/GabrielFrigo4/vault)**: Fornece chaves SSH e segredos privados.
- 🎨 **[Profile](https://github.com/GabrielFrigo4/profile)**: Personaliza os aplicativos gráficos, linters e inteligência artificial no `$HOME`.
