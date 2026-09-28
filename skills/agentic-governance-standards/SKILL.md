---
name: agentic-governance-standards
description: >-
    Runbook cognitivo para governança agentic unificada no ecossistema soberano, definindo
    normas para a tríade AGENTS.md (Constituição), .agents/rules/ (Cláusulas Pétreas) e a
    Arquitetura em 2 Tiers de skills (Lean vs Extended).
---

# 🧠 Governança Agentic & Padrões Canônicos de IA

Esta habilidade orienta o desenvolvedor e o agente de IA na concepção, estruturação e governança de artefatos agentic (`AGENTS.md`, `.agents/rules/` e `skills/`) no ecossistema soberano.

---

## 🏛️ Os Três Pilares da Governança Agentic

Todo repositório no ecossistema estrutura sua inteligência em 3 camadas complementares e desacopladas:

1. **`AGENTS.md` (A Constituição do Repositório):**
    - Lida passivamente na inicialização de qualquer sessão do agente.
    - Define identidade, papel no ecossistema, regras invioláveis de conduta e referências canônicas (`ENVIRONMENT.md`, `PRINCIPLES.md`, `TODO.md`).
    - Orçamento estrito: **Sweet Spot de 17 a 128 linhas** (teto máximo de 256 linhas). Zero tutoriais ou manuais procedimentais.
2. **`.agents/rules/` (As Cláusulas Pétreas):**
    - Regras técnicas granulares, filtros de linting estritos e restrições sintáticas invariantes (ex: shebangs, quoting, buffers, modos POSIX).
    - Injetadas de forma imperativa. Orçamento estrito: **$\le 128$ linhas**.
3. **`.agents/skills/` (Os Runbooks Operacionais sob Demanda):**
    - Procedimentos mentais, fluxos de engenharia e conhecimentos de domínio ativados dinamicamente via Progressive Disclosure.

---

## 🗂️ A Arquitetura de Skills em 2 Tiers (Lean vs. Extended)

Evite o anti-padrão de fragmentar skills sem necessidade ou criar monólitos impenetráveis:

### Tier 1: Lean Skill (Padrão de Ouro — 80% das Skills)

- **Estrutura:** Exclusivamente um único arquivo `SKILL.md` autocontido ($\le 128$ linhas).
- **Quando usar:** Diretrizes conceituais, heurísticas de auditoria, filosofias de design e workflows atômicos (ex: `deep-investigation`, `proactive-guardian`, `clean-break-refactoring`).
- **Vantagem:** Zero sobrecarga de I/O de ferramentas (`list_dir`, `view_file` extra), máxima velocidade e mínimo consumo de tokens de contexto.

### Tier 2: Extended Skill (Composta sob Demanda)

- **Estrutura:** `SKILL.md` conciso no sweet spot ($\le 128$ linhas) + subpastas funcionais:
    - `scripts/`: Utilitários executáveis (`.py`, `.sh`) invocados diretamente via bash para automações determinísticas (não gasta tokens computando).
    - `references/`: Manuais densos, tabelas de compatibilidade e manpages de baixa frequência (5% dos casos).
    - `resources/templates/` ou `examples/`: Boilerplates completos prontos para cópia sem poluir o fluxo de raciocínio.
- **Quando usar:** Domínios extensos ou ferramentas complexas que explodiriam o teto de 256 linhas (ex: `posix-shell`, `clean-code-refactor`).

---

## 🎯 Engenharia de Trigger & Precedência UNIX

A `description` no frontmatter YAML é o **único metadado lido pelo modelo em repouso**:

1. **Voz e Perspectiva:** Terceira pessoa com verbos de ação (_"Runbook cognitivo para...", "Ativar ao...", "Usar quando..."_).
2. **Orçamento de Vocábulos:** Manter a descrição entre **25 e 45 palavras**, incluindo termos técnicos de busca.
3. **Precedência UNIX (Local > Global > Built-in):**
    - `<repo>/.agents/skills/` (Local) $\rightarrow$ Sobrescreve tudo com regras específicas daquele projeto.
    - `Profile/skills/` (Global do Usuário) $\rightarrow$ Padrões perenes de engenharia, sistemas e ferramentas.
    - `builtin/skills` (Built-in da IDE) $\rightarrow$ Habilidades base fornecidas pela plataforma.
4. **Globals Passivas vs. Locals Imperativas:** O escopo global (`~/.gemini/config/`) contém exclusivamente SKILLS passivas. Regras imperativas (`RULES`) pertencem estritamente aos repositórios locais (`AGENTS.md` e `.agents/rules/`), prevenindo contaminação de contexto (_Context Poisoning_).

---

## 📐 Orçamento Unificado de Linhas & Invariantes

Tanto `SKILL.md`, `AGENTS.md` quanto arquivos em `.agents/rules/` compartilham o mesmo orçamento:

| Faixa de Linhas                 | Classificação             | Diretriz Operacional                                        |
| :------------------------------ | :------------------------ | :---------------------------------------------------------- |
| **$\ge 17$ linhas**             | Mínimo Substancial        | Previne micro-arquivos vazios ou sem valor prático.         |
| **$17 \text{ a } 128$ linhas**  | **Sweet Spot Executivo**  | Meta áurea de design para leitura rápida e baixo custo.     |
| **$129 \text{ a } 256$ linhas** | Faixa de Densidade        | Permitido para matrizes multi-OS, tabelas e regras densas.  |
| **$> 256$ linhas**              | **Erro Fatal (Monólito)** | **Terminantemente proibido.** Exige modularização imediata. |

- **Hermetismo de Produção (`rm -rf .agents` — Regra 20):** O repositório é 100% soberano. Se `.agents/` for deletado, todo o código executável, Makefiles e pipelines continuam operando com perfeição.
- **Bancada vs. Runtime (Regra 21):** Alterações de engenharia são realizadas prioritariamente na bancada (`~/Documents/Environment/Profile`), nunca em clones de runtime.
- **Auditoria Contínua:** Validado pelo quality gate estático [`Profile/audit/skills.py`](../../audit/skills.py).
