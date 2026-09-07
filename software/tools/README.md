# 🛠️ Tools & Linters (Dotfiles Declarativos de Formatadores)

> Configurações declarativas de formatadores, linters e LSP do sistema.

---

## 📁 Arquivos e Destinos

| Arquivo                      | Ferramenta                        | Destino (Linux / FreeBSD)          | Destino (Windows)                              |
| :--------------------------- | :-------------------------------- | :--------------------------------- | :--------------------------------------------- |
| **`clangd.yaml`**            | Clangd (LSP C/C++)                | `~/.config/clangd/config.yaml`     | `%LOCALAPPDATA%\clangd\config.yaml`            |
| **`.clang-format`**          | Clang Format                      | `~/.clang-format`                  | `%USERPROFILE%\.clang-format`                  |
| **`.prettierrc`**            | Prettier (JS/TS/HTML/CSS/MD/JSON) | `~/.prettierrc`                    | `%USERPROFILE%\.prettierrc`                    |
| **`.stylua.toml`**           | StyLua (Lua)                      | `~/.stylua.toml`                   | `%USERPROFILE%\.stylua.toml`                   |
| **`mermaid-puppeteer.json`** | Mermaid CLI (Puppeteer)           | `~/.mermaid-puppeteer-config.json` | `%USERPROFILE%\.mermaid-puppeteer-config.json` |
| **`mermaid-theme.json`**     | Mermaid CLI (Tema)                | `~/.mermaid-theme-config.json`     | `%USERPROFILE%\.mermaid-theme-config.json`     |

---

## 📦 Como Instalar as Ferramentas (CLI Global)

Se você precisa rodar os formatadores diretamente no terminal fora da IDE:

### 1. Prettier

- **Receita Automática:** `curl -fsSL https://raw.githubusercontent.com/GabrielFrigo4/Configuration/main/bootstrap/common/linters/prettier.sh | sh`
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

---

## 📐 Regras Globais de Estilo

Todas as ferramentas estão padronizadas para respeitar as mesmas diretrizes:

- **Limite de Colunas:** 96 caracteres
- **Hard Tabs (4):** Go, Assembly, Makefiles
- **Soft Tabs (2 espaços):** JS, TS, HTML, CSS, JSON, Lua, YAML, Markdown
- **Soft Tabs (4 espaços):** C, C++, Rust, Python, Java

---

## 🚀 Implantação Rápida dos Dotfiles (Zero-Clone)

Execute a receita canônica do repositório:

```sh
# UNIX (Linux / FreeBSD / WSL)
curl -fsSL https://raw.githubusercontent.com/GabrielFrigo4/Configuration/main/bootstrap/common/linters/linters.sh | sh
```
