# 📝 Editors (Dotfiles Declarativos & Configurações de Editores)

> Configurações declarativas, listas de extensões e dotfiles estáticos para editores de código no Host.

---

## 🎯 Finalidade

Esta pasta reúne exclusivamente os **arquivos declarativos de configuração** (`settings.json`, `extensions.txt`, configs standalone) dos editores de código utilizados no Host, organizados de forma **autocontida por editor**.

> ℹ️ **Sincronização de Extensões:** Utilize `sh profile.sh extensions` (ou `sh profile.sh sync --extensions`) via [`core/extensions.sh`](../core/extensions.sh) para instalar, exportar ou auditar extensões declaradas. Em instalações zero-clone, utilize o script complementar em **[Setup](https://github.com/GabrielFrigo4/setup)**.

---

## 📂 Catálogo de Configurações

| Editor                          | Arquivos Declarativos             | Destino (Linux / FreeBSD)                            | Destino (Windows)             |
| :------------------------------ | :-------------------------------- | :--------------------------------------------------- | :---------------------------- |
| **[Antigravity](antigravity/)** | `settings.json`, `extensions.txt` | `~/.config/Antigravity/User/`                        | `%APPDATA%\Antigravity\User\` |
| **[VS Code](vscode/)**          | `settings.json`, `extensions.txt` | `~/.config/Code/User/`, `~/.config/Code - OSS/User/` | `%APPDATA%\Code\User\`        |
| **[VS Codium](vscodium/)**      | `settings.json`, `extensions.txt` | `~/.config/VSCodium/User/`                           | `%APPDATA%\VSCodium\User\`    |
| **[Zed](zed/)**                 | `settings.json`                   | `~/.config/zed/`                                     | `%APPDATA%\Zed\`              |
| **[Emacs](emacs/)**             | `lite.el` (standalone)            | `~/.emacs`                                           | `%USERPROFILE%\.emacs`        |
| **[Vim](vim/)**                 | `lite.vim` (standalone)           | `~/.vimrc`                                           | `%USERPROFILE%\_vimrc`        |

---

## 🚀 Como Usar

### 1. Sincronizar Extensões Declaradas

```sh
sh profile.sh extensions status
sh profile.sh extensions install
```

### 2. Configurações de Editores GUI

Copie o conteúdo do `settings.json` desejado diretamente para o diretório correspondente do seu sistema operacional.

### 3. Configurações Standalone de Terminal (Emacs & Vim)

Copie [`lite.el`](emacs/lite.el) para `~/.emacs` ou [`lite.vim`](vim/lite.vim) para `~/.vimrc` em ambientes onde você deseja um editor leve sem dependências de plugins externos.
