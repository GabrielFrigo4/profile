# 💻 Software (Dotfiles & Configurações Declarativas de Aplicativos)

> Configurações declarativas ("dotfiles") e perfis de usuário para aplicações de interface gráfica, editores e ferramentas no Host.

---

## 🎯 A Fronteira: `Profile` vs `Setup`

Para manter o ecossistema estritamente desacoplado, este repositório divide o sistema em duas camadas bem delimitadas:

| Camada                                     | Papel Central                        | Tipo de Conteúdo                                                                                               | Escopo                                                                                                        |
| :----------------------------------------- | :----------------------------------- | :------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------ |
| **`software/`** _(esta pasta)_             | **O "O QUÊ" (Estado Declarativo)**   | Arquivos estáticos puros (`.json`, `.toml`, `.yaml`, `.el`, `.vim`, `.profile`, `.txt`) e dotfiles do usuário. | Espaço do usuário (`$HOME` / `~/.config` / `%APPDATA%`). **Zero sudo** / Zero gerenciadores de pacotes de SO. |
| **[Setup](https://github.com/GabrielFrigo4/setup)** | **O "COMO" (Provisionamento Ativo)** | Receitas atômicas de automação e scripts de sistema (`.sh`, `.cmd` e `.ps1`).                                  | Nível de sistema/máquina (`dnf`, `apt`, `pkg`, `winget`, drivers, containers, fontes do sistema).             |

---

## 📂 Catálogo de Configurações

- **[`editors/`](editors/README.md)**: Configurações declarativas (`settings.json`, `extensions.txt`, configs standalone `lite.el` e `lite.vim`) para Antigravity, VS Code, VSCodium, Zed, Emacs e Vim.
- **[`terminals/`](terminals/README.md)**: Perfis gráficos e dotfiles de inicialização para Konsole (KDE), Windows Terminal, CMD (Clink), PowerShell e NuShell.
- **[`tools/`](tools/README.md)**: Configurações declarativas globais de formatadores e LSP (`.clang-format`, `.prettierrc`, `.stylua.toml`, `clangd.yaml`, configs Mermaid).
- **[`browsers/`](browsers/README.md)**: Ajustes de navegadores no Host (Mozilla Firefox, aceleração Wayland e clipboard assíncrono).

> ℹ️ **Instaladores Manuais e Softwares Portáteis:** Consulte o guia em [`../docs/EXTERNAL.md`](../docs/EXTERNAL.md).

---

## 🚫 O Que NÃO Deve Ficar Aqui

- **Scripts de Instalação e Frameworks**: Scripts de setup de editores, frameworks e controle de versão pertencem ao repositório **[Setup](https://github.com/GabrielFrigo4/setup)**.
- **Provisionamento de SO e Pacotes**: Instalação de binários via `apt`, `dnf`, `pkg` ou `winget`. Pertencem ao repositório **[Setup](https://github.com/GabrielFrigo4/setup)**.
- **Comportamento Dinâmico de Shell**: Scripts de inicialização interativa (`.zshrc`, `.bashrc`, aliases, prompts). Pertencem ao repositório **[Shell](https://github.com/GabrielFrigo4/shell)**.
- **Segredos e Credenciais**: Chaves SSH, senhas de redes Wi-Fi, credenciais e tokens. Pertencem ao repositório privado **[Vault](https://github.com/GabrielFrigo4/vault)**.
- **Ambientes de Desenvolvimento de Projetos**: Compiladores pesados e runtimes de projetos não poluem o host; rodam isolados em Containers ou Jails.

---

## 📜 Princípios e Padrões da Camada de Software

Conforme estabelecido em [`../PRINCIPLES.md`](../PRINCIPLES.md):

1. **Permissões em 4 Dígitos:** Todos os arquivos de configuração declarativos nesta pasta devem ter permissão `chmod 0644`.
2. **Aderência ao Padrão XDG Base Directory:** Configurações de ferramentas do usuário devem residir em `~/.config/` (ou `%LOCALAPPDATA%` no Windows).
3. **Idempotência & Pureza Declarativa:** Prefira symlinks atômicos (`ln -sf`) ou cópias limpas para dotfiles de uso contínuo. Zero dependência de gerenciadores externos de dotfiles.
