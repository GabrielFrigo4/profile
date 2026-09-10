# 🎨 Universal Profile — AI Agent Briefing

> Repositório central de dotfiles declarativos de softwares, configurações de editores, perfis de emuladores de terminal, linters globais e catálogo de habilidades portáteis para agentes de IA. Componente de identidade do desenvolvedor do **Quarteto de Produtividade**.

---

## 🧭 Identidade e Papel

O **Profile** é a **identidade de trabalho** do desenvolvedor. Opera estritamente no espaço do usuário (`$HOME`) sem privilégios administrativos. Fornece:

- **Editores:** Antigravity, VS Code, Zed, Emacs (`lite.el`), Vim (`lite.vim`)
- **Terminais:** Konsole, Windows Terminal, PowerShell, NuShell
- **Linters & Formatadores:** `.clang-format`, `.prettierrc`, `.stylua.toml`
- **Skills de IA:** Catálogo de habilidades portáteis para agentes autônomos

---

## ⚠️ Regras Críticas para Agentes de IA

1. **Zero-Sudo:** NUNCA introduza comandos com `sudo` ou `doas`. Tudo opera em `$HOME`.
2. **Pureza declarativa:** JSON/JSONC (2 espaços), TOML, YAML — formatos legíveis e universais.
3. **Conformidade XDG:** Todos os destinos seguem `~/.config/<ferramenta>/`.
4. **Skills de IA:** Frontmatter YAML (`name`, `description`) + `SKILL.md` orientado a ação.
5. **Zero comentários narrativos:** Separação por linhas em branco, nomenclatura semântica.
6. **Limites de script:** Piso de 8, teto de 128 linhas úteis.

---

## 📖 Referências Obrigatórias

- **[ENVIRONMENT.md](ENVIRONMENT.md)**: Arquitetura do Quarteto de Produtividade
- **[PRINCIPLES.md](PRINCIPLES.md)**: Princípios de Engenharia para Dotfiles
- **[.agents/rules/principles.md](.agents/rules/principles.md)**: Regras específicas do Profile
- **[.agents/skills/](.agents/skills/)**: Runbooks operacionais (`universal-profile`, `proactive-guardian`, `deep-investigation`)
