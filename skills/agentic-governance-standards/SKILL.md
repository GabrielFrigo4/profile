---
name: agentic-governance-standards
description: >-
    Runbook cognitivo definitivo para governança agentic no ecossistema soberano, definindo
    normas para a tríade AGENTS.md, .agents/rules/, ciclo de contexto em 2 estágios,
    arquitetura de skills em 2 tiers (Lean vs Extended) e simetria técnica.
---

# 🧠 Governança Agentic & Padrões Canônicos de IA

Esta habilidade orienta o desenvolvedor e o agente de IA na concepção, estruturação, consolidação e governança de artefatos agentic (`AGENTS.md`, `.agents/rules/` e `skills/`) no ecossistema soberano.

---

## 🏛️ Os Três Pilares da Governança Agentic

Todo repositório no ecossistema estrutura sua inteligência em 3 camadas complementares e desacopladas:

1. **`AGENTS.md` (A Constituição do Repositório):**
    - Lida passivamente na inicialização de qualquer sessão do agente.
    - Define identidade, papel no ecossistema, regras invioláveis de conduta e referências canônicas (`ENVIRONMENT.md`, `PRINCIPLES.md`, `TODO.md`).
    - Orçamento estrito: **Sweet Spot de 17 a 128 linhas** (teto máximo de 256 linhas). Zero tutoriais ou manuais procedimentais.
2. **`.agents/rules/` (As Cláusulas Pétreas):**
    - Regras técnicas granulares, filtros de linting estritos e restrições sintáticas invariantes (ex: shebangs, quoting, buffers, modos POSIX).
    - Injetadas de forma imperativa por contexto/extensão. Orçamento estrito: **$\le 128$ linhas**.
3. **`.agents/skills/` (Os Runbooks Operacionais sob Demanda):**
    - Procedimentos mentais, fluxos de engenharia e conhecimentos de domínio ativados dinamicamente via Progressive Disclosure.

---

## ⚡ A Dinâmica de Contexto em 2 Estágios

As skills operam sob um ciclo de carregamento em duas etapas distintas:

1. **Estágio 1: Em Repouso (Sempre Ativo no System Prompt):**
    - O modelo recebe apenas a tabela de `name` e `description`.
    - **O Imposto de Contexto:** Cada skill consome entre **40 e 80 tokens por turno** mesmo sem ser chamada.
    - **Diretriz de Design:** Manter o número total de skills sob controle rigoroso via **Consolidação Horizontal** para poupar a janela de contexto.
2. **Estágio 2: Sob Demanda (Ativação via `view_file`):**
    - O modelo lê o `SKILL.md` apenas quando o trigger na `description` é disparado pela intenção do usuário.
    - Se a skill for Tier 2, navega pontualmente nos subarquivos em `references/` conforme o subdomínio exato da tarefa.

---

## 🗂️ A Arquitetura em 2 Tiers: Fusão Horizontal vs. Expansão Vertical

Evite os extremos da fragmentação caótica (dezenas de micro-skills) e do monólito impenetrável (> 256 linhas):

### Tier 1: Lean Skill (Padrão de Ouro — Modelos Mentais Heurísticos)

- **Estrutura:** Exclusivamente um único arquivo `SKILL.md` autocontido ($\le 128$ linhas).
- **Quando usar:** Filosofias de engenharia, modelos mentais atemporais e guardiões comportamentais que devem ser lidos num único relance (ex: `antifragile-engineering`, `clean-break-refactoring`, `proactive-guardian`, `unix-philosophy-auditor`).
- **Vantagem:** Zero chamadas extras de ferramentas (`view_file`), velocidade de execução instantânea e foco conceitual.

### Tier 2: Extended Skill (Domínios Densos & Simetria Técnica)

- **Estrutura:** `SKILL.md` conciso no sweet spot ($\le 128$ linhas) atuando como manifesto e roteador + subpastas funcionais:
    - `references/`: Manuais densos, manpages e subdomínios técnicos particionados (ex: `references/<topico>.md`).
    - `scripts/`: Utilitários executáveis (`.py`, `.sh`) invocados diretamente via shell para tarefas determinísticas (zero gasto de tokens computando).
    - `examples/` ou `resources/`: Boilerplates completos e templates de configuração.
- **Padrão da Consolidação Horizontal:** Fundir múltiplos tópicos afins ou matrizes de sistemas operacionais em uma única skill (ex: 4 nuvens $\rightarrow$ `cloud-sovereignty`; 8 shells $\rightarrow$ `os-shell-targets`) para reduzir o imposto do Estágio 1.
- **Padrão da Expansão Vertical (Simetria de Domínio):** Em stacks complexas (como `c-engineering` e `cpp-engineering`), manter espelhamento temático sob `references/` (`language-modern.md`, `systems-os.md`, `io-multiplexing.md`, `concurrency.md`) para garantir paridade conceitual entre ecossistemas irmãos.

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
