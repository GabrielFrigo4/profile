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

---

## 🛡️ Regra da Proatividade e Correção Contínua (Boy Scout Rule)

O agente de IA **DEVE SER ATIVAMENTE PROATIVO** na manutenção e aplicação dos padrões canônicos deste repositório.

Se durante a execução de qualquer tarefa (seja criação de novas features, correções pontuais, refatorações ou investigação) o agente identificar qualquer linha de código, script, Makefile ou documentação fora dos padrões estabelecidos, **NÃO DEVE HESITAR NEM IGNORAR**:

1. **Notificar concisamente** o usuário sobre a divergência encontrada.
2. **Corrigir imediatamente a inconformidade**, aplicando o padrão canônico correspondente:
    - **Comentários Narrativos:** Eliminar imediatamente comentários óbvios que apenas narram código executável.
    - **Banners Estruturais:** Ajustar réguas para exatamente 64 hífens no topo ou 32 caracteres com `### ` no corpo.
    - **Portabilidade POSIX:** Substituir bashismos (`[[ ]]`, `&>`, arrays, `source`) por sintaxe estrita POSIX `/bin/sh`.
    - **Shebang Universal:** Garantir sempre `#!/usr/bin/env sh` ou `#!/usr/bin/env python3`.
    - **Sequências ANSI:** Substituir octais crípticos (``) e `printf` desnecessário por `[ -t 1 ] && echo -n $'\e...'`.
    - **Redirecionamento Seguro:** Envolver destinos em aspas duplas (ex: `> "/dev/null" 2>&1`).
    - **Makefiles:** Assegurar cabeçalho `.POSIX: .SILENT:`, `MAKEFLAGS += --no-print-directory -s`, alinhamento estético de variáveis e zero `@` redundante.
    - **Permissões Canônicas:** Aplicar 4 dígitos octais (`chmod 0755`, `chmod 0644`, `chmod 0700`, `chmod 0600`).

## 📖 Referências Obrigatórias

- **[ENVIRONMENT.md](ENVIRONMENT.md)**: Arquitetura do Quarteto de Produtividade
- **[PRINCIPLES.md](PRINCIPLES.md)**: Princípios de Engenharia para Dotfiles
- **[.agents/rules/principles.md](.agents/rules/principles.md)**: Regras específicas do Profile
- **[.agents/skills/](.agents/skills/)**: Runbooks operacionais (`universal-profile`, `proactive-guardian`, `deep-investigation`)
