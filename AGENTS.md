# 🎨 Universal Profile — AI Agent Briefing

> Repositório central de dotfiles declarativos de softwares, configurações de editores, perfis de emuladores de terminal, linters globais e catálogo de habilidades portáteis para agentes de IA. Componente de identidade do desenvolvedor do **Quarteto de Produtividade**.

---

## 🧭 Identidade e Papel

O **Profile** é a **identidade de trabalho** do desenvolvedor. Opera estritamente no espaço do usuário (`$HOME`) sem privilégios administrativos. Fornece:

- **Editores:** Antigravity, VS Code, Zed, Emacs (`lite.el`), Vim (`lite.vim`)
- **Terminais & Multiplexadores:** Konsole, Windows Terminal, Tmux, Zellij
- **Linters & Formatadores:** `.clang-format`, `.prettierrc`, `.stylua.toml`
- **Skills de IA:** Catálogo de habilidades portáteis para agentes autônomos

---

## ⚠️ Regras Críticas para Agentes de IA

1. **Zero-Sudo:** NUNCA introduza comandos com `sudo` ou `doas`. Tudo opera em `$HOME`.
2. **Pureza declarativa:** JSON/JSONC (2 espaços), TOML, YAML — formatos legíveis e universais.
3. **Conformidade XDG:** Todos os destinos seguem `~/.config/<ferramenta>/`.
4. **Skills de IA:** Frontmatter YAML (`name`, `description`) + `SKILL.md` orientado a ação.
5. **Taxonomia Tripartite de Comentários:** O código adota estritamente três categorias: 1. Comentários de Sistema = PERMITIDOS (shebangs, pragmas, YAML frontmatter); 2. Comentários Estruturais de 64/32 colunas = PERMITIDOS (cabeçalhos de 64 `-`, seções de 32 caracteres `### ===`, réguas de 64 `=` em `.gitignore`, sem vazamento); 3. Comentários Explicativos/Narrativos = PROIBIDOS em código, configs E blocos de código dentro de Markdowns.
6. **Orçamento de linhas:** Piso < 8 proibido, aviso <= 16, sweet spot 17-128, aviso 129-255, teto > 256 proibido (salvo Whitelist).
7. **Hermetismo de Produção & Invariante `rm -rf .agents`:** Repositório 100% autônomo. Zero acoplamento de código de produção, dotfiles ou loaders a `.agents/` ou `skills/` (o Profile funciona plenamente se `.agents/` for deletado).
8. **Bancada de Desenvolvimento vs. Runtimes de Produção:** Em produção, o Universal Profile reside e opera soberanamente em `~/.config/profile`. NUNCA aponte symlinks de dotfiles para o diretório de desenvolvimento (`~/Documents/Environment/Profile`). A sincronização de dotfiles para os destinos XDG deve ser executada exclusivamente a partir do clone soberano via `~/.config/profile/profile.sh sync` (ou via `make install` no Environment).
9. **Ciclo Canônico de Propagação & Banimento de Cópia Manual:** Toda alteração é testada na bancada (`make test`, `make audit`), comitada e enviada via Git. Clones de produção recebem atualizações exclusivamente via `git pull` (ou `uprc`), mantendo a árvore limpa (Invariante Zero-Dirty).
10. **Atenção Crítica aos Links de IA (`~/.gemini/config/`):** Os caminhos `~/.gemini/config/skills` e `~/.gemini/config/rules` são symlinks apontando diretamente para `~/.local/share/profile/agents/` (produção). Não edite arquivos nesses caminhos virtuais; qualquer alteração deve ser feita exclusivamente na bancada (`Environment/Profile/agents/skills/` e `.../rules/`).
11. **Invariante de Clonagem "Out-of-the-Box" (Zero-Tweaks Git Invariant):** O Profile deve funcionar imediatamente após um simples `git clone`. Modos octais no Git Index DEVEM ser rigorosamente `0755` para scripts executáveis (`profile.sh`, hooks, scripts de automação) e `0644` para dotfiles e documentações. Scripts devem conter rotinas defensivas de self-healing para re-aplicar permissões se clonados sob NTFS ou montagens WSL.
12. **Emissão Semântica de UI (`_ui_*`):** Rotinas de sincronização e automação consomem a taxonomia `_ui_*` (`_ui_step`, `_ui_sub`, `_ui_ok`, `_ui_warn`, `_ui_err`, `_ui_info`, `_ui_banner`), sendo proibido `echo` com emojis soltos.
13. **Governança de Roadmap (TODO.md):** O repositório mantém seu [TODO.md](TODO.md) atualizado com a Matriz de Status e Backlog de Grandes Épicos, sincronizado com o badge no `README.md`.
14. **Refatoração Sem Legado (Clean-Break / Zero-Cruft Invariant):** O ecossistema é monousuário soberano. Não mantenha shims temporários, wrappers obsoletos ou aliases de transição ao renomear variáveis, comandos ou caminhos. Toda refatoração deve ser direta, atômica e limpa (_clean break_).
15. **Ambiente Híbrido Host/Guest (FreeBSD Workstation + Bhyve Linux Runtime):** Em estações FreeBSD, o agente de IA (`agy`) opera isolado dentro de uma máquina virtual Debian no Bhyve (`192.168.8.2`), conectada via NFSv3 à `/home/gabrielf` do host com paridade de UID/GID 1001. O agente executa comandos em ambiente Linux nativo (kernel 6.12/GNU), porém seus arquivos de trabalho residem fisicamente no ZFS do FreeBSD. Ao despachar comandos no terminal, utilize ferramentas Linux disponíveis no guest ou faça a demarcação correta ao editar scripts específicos de cada sistema operacional.
16. **Simetria de Escopo & Não-Assimetria de Subgrupo na Documentação:** Se um comportamento, protocolo ou invariante pertence a todo um grupo de componentes, documente-o no nível do grupo (documento de arquitetura, README do módulo pai ou especificação geral), evitando a criação de falsas assimetrias. Um sub-membro só deve receber documentação específica se implementar o comportamento de forma mais especializada, detalhada ou otimizada.

---

## 🛡️ Regra da Proatividade e Correção Contínua (Boy Scout Rule)

O agente de IA atua de forma proativa na manutenção e aplicação dos padrões canônicos deste repositório.

Ao identificar linhas ou artefatos fora dos padrões estabelecidos:

1. **Notificar concisamente** o usuário sobre o ajuste realizado.
2. **Corrigir a inconformidade**, aplicando o padrão correspondente:
    - **Taxonomia Tripartite de Comentários:** Eliminar comentários explicativos óbvios em código, configs e blocos de código em Markdowns, preservando exclusivamente comentários de sistema e delimitadores estruturais (64/32 colunas).
    - **Banners Estruturais:** Ajustar réguas para exatamente 64 hífens no topo ou 32 caracteres com `### ` no corpo (ou 64 `=` em `.gitignore`).
    - **Portabilidade POSIX:** Substituir bashismos (`[[ ]]`, `&>`, arrays, `source`) por sintaxe estrita POSIX `/bin/sh`.
    - **Shebang Universal:** Garantir sempre `#!/usr/bin/env sh` ou `#!/usr/bin/env python3`.
    - **Sequências ANSI & Escapes:** Não use octais (`\033`, `\001`) para caracteres ou escapes. Use `[ -t 1 ] && echo -n $'\e...'` ou notação hexadecimal (`\x01`, `\x1b`). Octal é exclusivo para permissões POSIX (`chmod 0755`, `chmod 0644`, `umask`).
    - **Redirecionamento Seguro:** Envolver destinos em aspas duplas (ex: `> "/dev/null" 2>&1`).
    - **Makefiles:** Assegurar cabeçalho `.POSIX: .SILENT:`, `MAKEFLAGS += --no-print-directory -s`, alinhamento estético de variáveis e zero `@` redundante.
    - **Permissões Canônicas:** Aplicar 4 dígitos octais (`chmod 0755`, `chmod 0644`, `chmod 0700`, `chmod 0600`).
    - **Invariante Out-of-the-Box:** Garantir modos octais corretos no Git Index e auto-cura em tempo de execução sem requerer intervenção manual pós-clone.
    - **Emissão Semântica de UI:** Substituir `echo` avulsos com emojis pelas rotinas canônicas `_ui_*`.
    - **Antifragilidade & Resiliência:** Resolução ativa de caminhos em cascata, auto-cura de permissões (0600 em chaves/segredos) e validação defensiva de pré-requisitos.
    - **Curadoria Cognitiva:** Capturar decisões estruturais e regras tácitas em skills locais compactas (`.agents/skills/`), mantendo-as atualizadas e expurgando ruído obsoleto.
    - **Refatoração Sem Legado:** Expurgar aliases obsoletos, variáveis mortas e shims de compatibilidade em renomeações.
    - **Elevação Antifrágil & Shift Seguro:** Usar o bloco explícito `if [ "$(id -u)" -ne 0 ]` para resolução de `ELEVATE` (evitando término fatal sob `set -e` como root) e proteger todo comando `shift` com validação prévia de parâmetros (`[ "$#" -ge N ] && shift N`).
    - **Simetria de Documentação:** Mover regras ou invariantes universais documentadas erroneamente em sub-membros específicos para o documento de arquitetura do grupo correspondente, eliminando falsas assimetrias.

---

## 🚀 Comandos de Verificação Rápida (Quality Gates)

| Comando            | Finalidade Operacional                                             |
| :----------------- | :----------------------------------------------------------------- |
| `make help`        | Exibe o catálogo interativo de comandos disponíveis                |
| `make test`        | Valida a integridade e sintaxe de dotfiles e configurações         |
| `make audit`       | Executa suite completa de auditoria (skills, banners, links, tone) |
| `make sync`        | Sincroniza dotfiles declarativos para os destinos XDG do usuário   |
| `make format`      | Formata dotfiles e documentações com Prettier                      |
| `make prettier`    | Formata arquivos Markdown com Prettier                             |
| `make fix-banners` | Corrige automaticamente a geometria de réguas e banners            |
| `make hooks`       | Configura permissão `0755` nos ganchos de `.githooks/`             |
| `make ci`          | Executa validação completa de integração contínua (`test audit`)   |

---

## 📖 Referências Obrigatórias

Antes de qualquer modificação neste ecossistema, consulte:

- **[ENVIRONMENT.md](ENVIRONMENT.md)**: Arquitetura do Quarteto de Produtividade
- **[PRINCIPLES.md](PRINCIPLES.md)**: Os 22 Princípios de Engenharia UNIX + Clean Code
- **[TODO.md](TODO.md)**: Planejamento estratégico e matriz de status operacional
- **[.agents/rules/principles.md](.agents/rules/principles.md)**: Regras específicas do Profile
- **[.agents/skills/](.agents/skills/)**: Runbook operacional local (`universal-profile`)
