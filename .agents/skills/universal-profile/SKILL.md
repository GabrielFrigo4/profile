---
name: universal-profile
description: >-
  Comprehensive guide and operational runbook for extending, refactoring, and auditing the Universal Profile repository.
  Use when adding new editor settings (VS Code, Zed, Antigravity, Emacs, Vim), terminal profiles (Konsole, NuShell, PowerShell),
  global formatters (.clang-format, prettier, stylua), creating portable AI skills, and managing dotfile symlinks.
---

# Universal Profile — Development & Dotfiles Runbook

Este guia detalha o fluxo operacional para estender, refatorar e auditar o repositório **Universal Profile Environment** (`Profile`), garantindo aderência rigorosa aos 18 Princípios de Engenharia e às normas de Clean Code para dotfiles e inteligência artificial.

---

## 1. Mapeamento de Camadas (Onde colocar cada arquivo)

Antes de criar qualquer arquivo, posicione-o na pasta correta:

| Camada | Diretório | Papel & Responsabilidade | Exemplos |
| :--- | :--- | :--- | :--- |
| **Editores** | `software/editors/` | Configurações declarativas autocontidas por editor. | Antigravity, VS Code, Zed, Emacs, Vim |
| **Terminais** | `software/terminals/` | Perfis gráficos e scripts de inicialização de terminais. | Konsole, Windows Terminal, NuShell, PowerShell |
| **Linters & Tools** | `software/tools/` | Arquivos de configuração globais de formatação e LSP. | `.clang-format`, `.prettierrc`, `.stylua.toml` |
| **Navegadores** | `software/browsers/` | Ajustes de navegadores no host. | Firefox Wayland e clipboard |
| **Habilidades de IA** | `skills/` | Pacotes autocontidos de procedimentos para agentes autônomos. | `SKILL.md` com YAML Frontmatter |
| **Sincronização** | `scripts/sync/` | Scripts em shell para criar symlinks no `$HOME`. | `sync-dotfiles.sh`, `sync-skills.sh` |
| **Documentação** | `docs/` | Manuais de arquitetura e filosofia do ecossistema. | `ARCHITECTURE.md`, `PHILOSOPHY.md` |

---

## 2. Invariantes Arquiteturais Inegociáveis

1. **Zero Privilégios Administrativos (`zero-sudo`):**
   - NUNCA introduza comandos que necessitem de elevação de privilégios (`sudo`/`doas`). O Profile atua estritamente no espaço do usuário comum (`$HOME`).
2. **Pureza Declarativa:**
   - Preferência absoluta por JSON, TOML e YAML formatados.
3. **Conformidade XDG:**
   - Todos os destinos devem seguir a especificação XDG Base Directory (`~/.config/`).
4. **README em Todas as Pastas:**
   - Todo subdiretório DEVE conter um `README.md` conciso com catálogo de arquivos e instruções de sincronização.

---

## 3. Checklist de Validação Obrigatório

```sh
git diff --check

python3 scripts/audit/all.py

./.githooks/pre-commit
```
