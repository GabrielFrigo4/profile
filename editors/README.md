# 📝 Editors (Dotfiles Declarativos & Configurações de Editores)

> Configurações declarativas, listas de extensões e dotfiles estáticos para editores de código no Host.

---

## 🎯 Finalidade

Esta pasta reúne exclusivamente os **arquivos declarativos de configuração** (`settings.json`, `extensions.txt`, configs standalone) dos editores de código utilizados no Host, organizados de forma **autocontida por editor**.

> ℹ️ **Scripts de Instalação, Frameworks e Sincronização:** Os scripts para sincronizar extensões (`sync-extensions.sh`), clonar repositórios de editores ou instalar frameworks residem no repositório **[Setup](https://github.com/GabrielFrigo4/setup)**.

---

## 📂 Catálogo de Configurações

| Editor                          | Arquivos Declarativos             | Destino (Linux / FreeBSD)     | Destino (Windows)             |
| :------------------------------ | :-------------------------------- | :---------------------------- | :---------------------------- |
| **[Antigravity](antigravity/)** | `settings.json`, `extensions.txt` | `~/.config/Antigravity/User/` | `%APPDATA%\Antigravity\User\` |
| **[VS Code](vscode/)**          | `settings.json`, `extensions.txt` | `~/.config/Code/User/`        | `%APPDATA%\Code\User\`        |
| **[VS Codium](vscodium/)**      | `settings.json`, `extensions.txt` | `~/.config/VSCodium/User/`    | `%APPDATA%\VSCodium\User\`    |
| **[Zed](zed/)**                 | `settings.json`                   | `~/.config/zed/`              | `%APPDATA%\Zed\`              |
| **[Emacs](emacs/)**             | `lite.el` (standalone)            | `~/.emacs`                    | `%USERPROFILE%\.emacs`        |
| **[Vim](vim/)**                 | `lite.vim` (standalone)           | `~/.vimrc`                    | `%USERPROFILE%\_vimrc`        |

---

## 🚀 Como Usar via GitHub (Zero-Clone)

### 1. Sincronizar Extensões com o Setup

```sh
curl -fsSL https://raw.githubusercontent.com/GabrielFrigo4/setup/main/bootstrap/common/editors/sync-extensions.sh | sh
```

### 2. Configurações de Editores GUI

Copie o conteúdo do `settings.json` desejado diretamente para o diretório correspondente do seu sistema operacional.

### 3. Configurações Standalone de Terminal (Emacs & Vim)

Copie [`lite.el`](emacs/lite.el) para `~/.emacs` ou [`lite.vim`](vim/lite.vim) para `~/.vimrc` em ambientes onde você deseja um editor leve sem dependências de plugins externos.
