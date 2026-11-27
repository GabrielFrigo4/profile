# 🛠️ Tools & Linters (Dotfiles Declarativos de Formatadores)

> Configurações declarativas de formatadores, linters e LSP do sistema.

---

## 📁 Arquivos e Destinos

| Arquivo                      | Ferramenta                        | Destino (Linux / FreeBSD)          | Destino (Windows)                              |
| :--------------------------- | :-------------------------------- | :--------------------------------- | :--------------------------------------------- |
| **`clangd.yaml`**            | Clangd (LSP C/C++)                | `~/.config/clangd/config.yaml`     | `%LOCALAPPDATA%\clangd\config.yaml`            |
| **`.clang-format`**          | Clang Format                      | `~/.clang-format`                  | `%USERPROFILE%\.clang-format`                  |
| **`.editorconfig`**          | EditorConfig                      | `~/.editorconfig`                  | `%USERPROFILE%\.editorconfig`                  |
| **`.prettierrc`**            | Prettier (JS/TS/HTML/CSS/MD/JSON) | `~/.prettierrc`                    | `%USERPROFILE%\.prettierrc`                    |
| **`.stylua.toml`**           | StyLua (Lua)                      | `~/.stylua.toml`                   | `%USERPROFILE%\.stylua.toml`                   |
| **`ruff.toml`**              | Ruff (Linter & Formatter Python)  | `~/.config/ruff/ruff.toml`         | `%APPDATA%\ruff\ruff.toml`                     |
| **`mermaid-puppeteer.json`** | Mermaid CLI (Puppeteer)           | `~/.mermaid-puppeteer-config.json` | `%USERPROFILE%\.mermaid-puppeteer-config.json` |
| **`mermaid-theme.json`**     | Mermaid CLI (Tema)                | `~/.mermaid-theme-config.json`     | `%USERPROFILE%\.mermaid-theme-config.json`     |

---

## 📦 Como Instalar as Ferramentas (CLI Global)

Se você precisa rodar os formatadores diretamente no terminal fora da IDE:

### 1. Prettier

- **Receita Automática (Clone Soberano):** `sh "${XDG_DATA_HOME:-${HOME}/.local/share}/setup/common/linters/prettier.sh"`
- **FreeBSD:** `doas pkg install node npm && npm install --global prettier`
- **Fedora:** `sudo dnf install --assumeyes nodejs npm && sudo npm install --global prettier`
- **Arch Linux:** `sudo pacman -S prettier`

### 2. Clang-Format & Clangd

- **FreeBSD:** `doas pkg install llvm`
- **Fedora:** `sudo dnf install --assumeyes clang-tools-extra`
- **Arch Linux:** `sudo pacman -S clang`
- **Debian:** `sudo apt install --yes clang-format clangd`

### 3. StyLua

- **FreeBSD:** `doas pkg install stylua`
- **Linux:** `cargo install stylua` ou via releases oficiais no GitHub.

### 4. Ruff

- **Receita Automática (Clone Soberano):** `sh "${XDG_DATA_HOME:-${HOME}/.local/share}/setup/common/linters/ruff.sh"`
- **FreeBSD:** `doas pkg install py311-ruff` (ou `devel/py-ruff`)
- **Fedora:** `sudo dnf install --assumeyes ruff`
- **Arch Linux:** `sudo pacman -S ruff`
- **Debian:** `sudo apt install --yes ruff` (ou `pipx install ruff`)
- **Windows:** `winget install AstralSoftware.Ruff`

---

## 📐 Regras Globais de Estilo

Todas as ferramentas estão padronizadas para respeitar as mesmas diretrizes:

- **Limite de Colunas:** 96 caracteres
- **Hard Tabs (4):** C, C++, Lua, JS, TS, HTML, CSS, JSON, Markdown, Go, Shell, Makefiles
- **Soft Tabs (2 espaços):** YAML (`*.yml`, `*.yaml`)
- **Soft Tabs (4 espaços):** Python (`ruff.toml`)

---

## 🚀 Implantação Rápida dos Dotfiles & Linters (Clone Soberano)

Sincronize os dotfiles no `$HOME` pelo `profile.sh` e instale os binários CLI pelas receitas individuais do **Setup** (`common/linters/{prettier,ruff,mermaid}.sh`):

```sh
sh "${XDG_DATA_HOME:-${HOME}/.local/share}/profile/profile.sh" sync
sh "${XDG_DATA_HOME:-${HOME}/.local/share}/setup/common/linters/prettier.sh"
sh "${XDG_DATA_HOME:-${HOME}/.local/share}/setup/common/linters/ruff.sh"
sh "${XDG_DATA_HOME:-${HOME}/.local/share}/setup/common/linters/mermaid.sh"
```
