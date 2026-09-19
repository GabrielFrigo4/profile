# 🗺️ Roadmap & Backlog

> Planejamento estratégico, status operacional e visão de futuro para a evolução do **Universal Profile**.

---

## 📊 Status do Projeto

| Área                             |      Status       | Cobertura / Estado                                                           |
| :------------------------------- | :---------------: | :--------------------------------------------------------------------------- |
| **🪟 Terminais Windows**         |    🟢 Estável     | PowerShell, NuShell e CMD/Clink padronizados com `_ui_*` e família `up*`     |
| **🐧 Terminais UNIX**            |    🟢 Estável     | Konsole, Windows Terminal e integrações de terminal XDG                      |
| **📝 Configurações de Editores** |    🟢 Estável     | VS Code, Antigravity e Zed sincronizados via links declarativos              |
| **🛠️ Linters & Formatadores**    |    🟢 Estável     | `.clang-format`, `.prettierrc`, `.stylua.toml`, `.editorconfig`              |
| **🤖 Portable AI Skills**        |    🟢 Estável     | Catálogo de skills portáteis orientadas a ação e compatíveis com agentes     |
| **🔄 Sincronização & Links**     | 🟡 Em Refinamento | Scripts `profile.sh` (UNIX) e `install.ps1` (Windows) em constante polimento |
| **🧪 Suite de Auditoria**        |      🟢 100%      | 100% de conformidade com linters de monólitos, nanos, banners e formatos     |

---

## 🎯 Grandes Épicos & Backlog

### 1. 🎨 Lapidação e Organização dos Dotfiles

- [x] Padronização dos comandos de atualização `up*` nos terminais Windows (PowerShell, NuShell, CMD/Clink).
- [x] Integração da biblioteca semântica `_ui_*` nos perfis de terminal do Windows.
- [ ] Revisão geral e expurgo de configurações legadas ou redundantes em dotfiles.
- [ ] Otimização dos esquemas de temas para consistência visual entre terminais e editores.

### 2. 🛡️ Resiliência e Auto-Cura de Symlinks

- [ ] Reforçar a auto-detecção de links quebrados ou sobrescritos em `profile.sh`.
- [ ] Aprimorar o tratamento de backups automáticos antes de reescrever links em `install.ps1`.
- [ ] Garantir que o Profile possa ser restaurado e sincronizado de forma estritamente idempotente.

### 3. 🌐 Governança XDG e Multiplataforma

- [ ] Auditar e garantir paridade total entre Linux, FreeBSD, macOS e Windows.
- [ ] Manter sincronizados os READMEs de cada módulo de terminal e ferramenta.

---

> [!TIP]
> Para detalhes sobre convenções de código e diretrizes de engenharia, consulte o [PRINCIPLES.md](PRINCIPLES.md).
