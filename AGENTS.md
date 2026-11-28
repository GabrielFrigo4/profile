<!-- template:sync -->

# 🤖 AI Agent Briefing

> Diretrizes canônicas, invariantes de engenharia e protocolo operacional para agentes de IA nos repositórios do ecossistema.

---

## 🧭 Identidade & Fonte de Contexto

Ancore toda decisão na documentação canônica local, consultando nesta ordem:

1. [README.md](README.md) — Arquitetura, stack técnica, topologia e comandos do repositório.
2. [TODO.md](TODO.md) — Status operacional, matriz de cobertura e roadmap.
3. [PRINCIPLES.md](PRINCIPLES.md) — Os 22 Princípios de Engenharia UNIX e Clean Code.
4. [CONTRIBUTING.md](CONTRIBUTING.md) — Fluxo Git, commits semânticos e quality gates.
5. `ENVIRONMENT.md` — Arquitetura federada do ecossistema (quando presente na raiz).

---

## 🤝 Protocolo Bidirecional de Esclarecimento

- **Master -> User:** Toda ambiguidade de escopo, trade-off arquitetural crítico ou risco colateral DEVE ser esclarecido proativamente via `ask_question` antes da execução.
- **Worker -> Master:** Subagentes devem interromper mutações e escalonar ao orquestrador pai via `send_message` diante de divergência entre plano e código real.

---

## ⚠️ Regras Críticas & Invariantes Soberanas

1. **Isolamento Open Source (`**/Open Source/**`):** Projetos de terceiros sob `Open Source/` (ou `OSS/`) são estritamente somente-leitura para automações globais, formatação, auditoria e templates.
2. **Bancada vs. Produção, Fallback & Zero-Dirty:**
    - **Resolução da Bancada:** Considere `$XDG_DOCUMENTS_DIR`, `~/Documents/`, `~/Documentos/` ou o próprio repositório autônomo quando não houver clone de runtime separado.
    - **Proibição de Runtime Sujo:** Nunca edite clones de produção diretamente (`~/.local/share/*`, `/usr/local/share/*`, `~/.config/*`, `~/.emacs.d`, `~/.vim`) nem os symlinks `~/.gemini/config/skills` e `~/.gemini/config/rules` (edite fisicamente na bancada do `Profile`).
    - **Cascata de Fallback:** (a) Existindo bancada local para o componente, edite/valide/comite/envie lá e propague à produção exclusivamente via `git pull` mantendo `git status` 100% limpo (_Zero-Dirty_); (b) Repositórios de projeto independentes já são a própria bancada; (c) Em servidores/containers sem bancada local, edite/comite/envie no clone isolado mantendo o repo limpo; (d) Em caso de dúvida sobre a topologia, pergunte ao usuário via `ask_question` antes de alterar o runtime.
3. **Hermetismo (`rm -rf .agents`):** Código de produção não depende de `.agents/` nem `skills/`; se removidos, tudo opera com 100% de integridade.
4. **Invariante Out-of-the-Box (`0755`/`0644`/`0700`/`0600`):** O repo deve funcionar logo após `git clone`, com modos corretos no Git Index e self-healing de permissões em runtime (`0700`/`0600` em cofres e chaves).
5. **Taxonomia Tripartite de Comentários:** Permitidos apenas _Sistema_ (shebangs, pragmas, linters) e _Estruturais 64/32_ (64 `-`, `### ===`/`### ---` 32 cols e `.gitignore` 64 `=` em MAIÚSCULO). Comentários explicativos/narrativos são PROIBIDOS em código, configs e blocos de código dentro de Markdowns.
6. **Portabilidade, VCS & Boy Scout Rule:**
    - **SO & Transporte VCS:** Execute nativamente com detecção dinâmica de SO (`uname -s`, diferenças BSD/GNU). Prefira `gh` com fallback SSH no GitHub, SSH (ou `glab`) no GitLab e SSH no `got`, mantendo paridade Git/Got.
    - **Padrões de Código (quando aplicável ao stack):** POSIX `sh` (`#!/usr/bin/env sh`); Makefiles com `.POSIX: .SILENT:`, `MAKEFLAGS += --no-print-directory -s`, `(cd dir && $(MAKE))` e zero `@`; ANSI via `$'\e'` ou `\x1b` (nunca `\033`); redirecionamentos entre aspas (`> "/dev/null" 2>&1`); `if [ "$(id -u)" -ne 0 ]` para `ELEVATE` e `[ "$#" -ge N ] && shift N`; UI via `_ui_*`; refatoração Clean-Break sem legado; simetria de documentação por grupo.
    - **Boy Scout Rule:** Notifique concisamente e corrija desvios proativamente ao detectá-los.
7. **`AGENTS.md` Uniforme (`<!-- template:sync -->`):** Repos padrão compartilham este `AGENTS.md` via `make sync-template`; remover o marcador do topo congela customizações locais.
8. **Governança Multi-Agente:** Carregue `multi-agent-orchestration` antes de delegar; proibido acionar `swarm` sem pedido literal `"swarm"` ou polling com `schedule`; use `Model: 'inherit'` (ou tier rápido nativo) com papéis _Master / Worker / Verifier_.

---

## 🚀 Comandos Canônicos (Quality Gates)

| Comando       | Finalidade Operacional                                    |
| :------------ | :-------------------------------------------------------- |
| `make help`   | Exibe o catálogo interativo de comandos disponíveis       |
| `make test`   | Executa a suíte automatizada de testes locais             |
| `make audit`  | Executa auditoria estática de padrões e integridade       |
| `make format` | Formata código-fonte e documentações com Prettier/linters |
| `make ci`     | Executa a pipeline local completa de validação integrada  |
| `make hooks`  | Configura os ganchos Git com permissões canônicas (0755)  |

---

## 📖 Referências

- [README.md](README.md) · [TODO.md](TODO.md) · [PRINCIPLES.md](PRINCIPLES.md) · [CONTRIBUTING.md](CONTRIBUTING.md)
