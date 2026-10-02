# 🎨 Universal Profile — AI Agent Briefing

> Repositório central de dotfiles declarativos de softwares, configurações de editores, perfis de emuladores de terminal, linters globais e catálogo de habilidades portáteis para agentes de IA. Componente de identidade do desenvolvedor do **Quarteto de Produtividade**.

---

## 🧭 Identidade e Papel

O **Profile** é a **identidade de trabalho** do desenvolvedor. Opera estritamente no espaço do usuário (`$HOME`) sem privilégios administrativos. Fornece:

- **Editores:** Antigravity, VS Code, Zed, Emacs (`lite.el`), Vim (`lite.vim`)
- **Terminais:** Konsole, Windows Terminal, PowerShell, NuShell, CMD (com Clink)
- **Linters & Formatadores:** `.clang-format`, `.prettierrc`, `.stylua.toml`
- **Skills de IA:** Catálogo de habilidades portáteis para agentes autônomos
- **Comandos de Atualização Windows:** Família `up*` (`upgit`, `uped`, `uprc`, `upvt`, `upsh`, `upall`, `upwin`, `upsys`, `upget`, `upscp`, `upcho`)

---

## ⚠️ Regras Críticas para Agentes de IA

1. **Zero-Sudo:** NUNCA introduza comandos com `sudo` ou `doas`. Tudo opera em `$HOME`.
2. **Pureza declarativa:** JSON/JSONC (2 espaços), TOML, YAML — formatos legíveis e universais.
3. **Conformidade XDG:** Todos os destinos seguem `~/.config/<ferramenta>/`.
4. **Skills de IA:** Frontmatter YAML (`name`, `description`) + `SKILL.md` orientado a ação.
5. **Zero comentários narrativos:** Separação por linhas em branco, nomenclatura semântica.
6. **Orçamento de linhas:** Piso < 8 proibido, aviso <= 16, sweet spot 17-128, aviso 129-255, teto > 256 proibido (salvo Whitelist).
7. **Hermetismo de Produção & Invariante `rm -rf .agents`:** Repositório 100% autônomo. Zero acoplamento de código de produção, dotfiles ou loaders a `.agents/` ou `skills/` (o Profile funciona plenamente se `.agents/` for deletado).
8. **Bancada de Desenvolvimento vs. Runtimes de Produção:** Em produção, o Universal Profile reside e opera soberanamente em `~/.config/profile`. NUNCA aponte symlinks de dotfiles para o diretório de desenvolvimento (`~/Documents/Environment/Profile`). A sincronização de dotfiles para os destinos XDG deve ser executada exclusivamente a partir do clone soberano via `~/.config/profile/profile.sh sync` (ou via `make install` no Environment).
9. **Invariante de Clonagem "Out-of-the-Box" (Zero-Tweaks Git Invariant):** O Profile deve funcionar imediatamente após um simples `git clone`. Modos octais no Git Index DEVEM ser rigorosamente `0755` para scripts executáveis (`profile.sh`, hooks, scripts de automação) e `0644` para dotfiles e documentações. Scripts devem conter rotinas defensivas de self-healing para re-aplicar permissões se clonados sob NTFS ou montagens WSL.
10. **Emissão Semântica de UI (`_ui_*`):** Todos os perfis de terminais Windows (PowerShell `profile.ps1`, NuShell `config.nu`, CMD/Clink `profile.lua`) e rotinas de sincronização consomem a taxonomia `_ui_*` (`_ui_step`, `_ui_sub`, `_ui_ok`, `_ui_warn`, `_ui_err`, `_ui_info`, `_ui_banner`), sendo proibido `echo` ou `Write-Host` com emojis soltos.
11. **Governança de Roadmap (Opção C):** O repositório mantém seu [TODO.md](TODO.md) atualizado com a Matriz de Status e Backlog de Grandes Épicos, sincronizado com o badge no `README.md`.
12. **A Regra Áurea da Fonte Canônica para Edição (Bancada vs. Clones de Runtime):** Toda modificação em dotfiles, scripts de perfil, terminais ou skills globais DEVE ser realizada prioritariamente na bancada de desenvolvimento do **Environment** (`~/Documents/Environment/Profile` ou `~/Documentos/Environment/Profile`).
    **Condição Estrita para Editar em Clones de Runtime:** Apenas se o repositório canônico no Environment **NÃO existir** E o agente **NÃO estiver nele** (ambas as condições estritamente negadas simultaneamente) é que se admite editar diretamente no clone de runtime (`~/.local/share/profile` ou links simbólicos de `~/.gemini/config/skills/`). Isso previne sujar árvores de trabalho de runtime (`unstaged changes`), preserva os atualizadores automáticos (`uprc`, `git pull --ff-only`) e garante versionamento canônico dos commits.
13. **Refatoração Sem Legado (Clean-Break / Zero-Cruft Invariant):** O ecossistema é monousuário soberano. Não mantenha shims temporários, wrappers obsoletos ou aliases de transição ao renomear variáveis, comandos ou caminhos. Toda refatoração deve ser direta, atômica e limpa (_clean break_).

---

## 🛡️ Regra da Proatividade e Correção Contínua (Boy Scout Rule)

O agente de IA atua de forma proativa na manutenção e aplicação dos padrões canônicos deste repositório.

Ao identificar linhas ou artefatos fora dos padrões estabelecidos:

1. **Notificar concisamente** o usuário sobre o ajuste realizado.
2. **Corrigir a inconformidade**, aplicando o padrão correspondente:
    - **Comentários Narrativos:** Eliminar comentários óbvios que apenas narram código executável.
    - **Banners Estruturais:** Ajustar réguas para exatamente 64 hífens no topo ou 32 caracteres com `### ` no corpo.
    - **Portabilidade POSIX:** Substituir bashismos (`[[ ]]`, `&>`, arrays, `source`) por sintaxe estrita POSIX `/bin/sh`.
    - **Shebang Universal:** Garantir sempre `#!/usr/bin/env sh` ou `#!/usr/bin/env python3`.
    - **Sequências ANSI & Escapes:** Não use octais (`\033`, `\001`) para caracteres ou escapes. Use `[ -t 1 ] && echo -n $'\e...'` ou notação hexadecimal (`\x01`, `\x1b`). Octal é exclusivo para permissões POSIX (`chmod 0755`, `chmod 0644`, `umask`).
    - **Redirecionamento Seguro:** Envolver destinos em aspas duplas (ex: `> "/dev/null" 2>&1`).
    - **Makefiles:** Assegurar cabeçalho `.POSIX: .SILENT:`, `MAKEFLAGS += --no-print-directory -s`, alinhamento estético de variáveis e zero `@` redundante.
    - **Permissões Canônicas:** Aplicar 4 dígitos octais (`chmod 0755`, `chmod 0644`, `chmod 0700`, `chmod 0600`).
    - **Invariante Out-of-the-Box:** Garantir modos octais corretos no Git Index e auto-cura em tempo de execução sem requerer intervenção manual pós-clone.
    - **Emissão Semântica de UI:** Substituir imediatamente `echo` avulsos com emojis ou texto ad-hoc pelas rotinas canônicas `_ui_*`.
    - **Curadoria Cognitiva:** Capturar decisões estruturais e regras tácitas em skills locais compactas (`.agents/skills/`), mantendo-as atualizadas e expurgando runbooks obsoletos para evitar débito cognitivo, preservando sempre o hermetismo de produção (`rm -rf .agents`).
    - **Refatoração Sem Legado:** Expurgar sumariamente aliases obsoletos, variáveis mortas e shims de compatibilidade deixados para trás em renomeações passadas, mantendo o código puro e direto.

## 📖 Referências Obrigatórias

Antes de qualquer modificação neste ecossistema, consulte:

- **[ENVIRONMENT.md](ENVIRONMENT.md)**: Arquitetura do Quarteto de Produtividade
- **[PRINCIPLES.md](PRINCIPLES.md)**: Os 22 Princípios de Engenharia UNIX + Clean Code
- **[TODO.md](TODO.md)**: Planejamento estratégico e matriz de status operacional
- **[.agents/rules/principles.md](.agents/rules/principles.md)**: Regras específicas do Profile
- **[.agents/skills/](.agents/skills/)**: Runbooks operacionais (`universal-profile`, `proactive-guardian`, `deep-investigation`)
