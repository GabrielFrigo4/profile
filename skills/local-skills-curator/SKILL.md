---
name: local-skills-curator
description: Runbook cognitivo para curadoria proativa, extração de conhecimento tácito, criação, atualização, refatoração e expurgo de skills locais em .agents/skills/, assegurando relevância estrutural perene e hermetismo de produção (rm -rf .agents).
---

# 🧭 Curadoria Proativa de Conhecimento Tácito & Skills Locais

Este runbook orienta o agente de IA a atuar como um curador ativo da memória arquitetural do repositório, capturando decisões de design e regras tácitas em skills locais compactas (`<repo>/.agents/skills/`), mantendo-as enxutas e expurgando contexto obsoleto.

---

## 🎯 Filtro de Sinal vs. Ruído: O Que Registrar

Nem toda informação merece se tornar uma skill local. A proliferação desordenada gera débito cognitivo e consome tokens preciosos da janela de contexto:

### 🟢 O Que DEVE ser Registrado (Conhecimento Estrutural Perene):

- **Idiossincrasias de Build & Ambiente:** Ordem estrita de compilação, flags necessárias, variáveis de ambiente obrigatórias não óbvias.
- **Invariantes e Decisões de Arquitetura:** Decisões de design tomadas com o desenvolvedor que orientam futuras implementações.
- **Padrões de Teste e Quality Gates:** Como disparar suites parciais, testes de estresse ou ferramentas de profiling locais.
- **Armadilhas Conhecidas (Gotchas):** Comportamentos inesperados de dependências ou peculiaridades de plataformas específicas.

### 🔴 O Que NUNCA Deve ser Registrado (Ruído Efêmero & Volatilidade):

- **Tarefas de Backlog ou Épicos Transitórios (`TODO.md`):** É expressamente proibido converter skills em espelhos de tarefas a fazer, refatorações pontuais ou sprints. O `TODO.md` é o repositório exclusivo de pendências e dívidas técnicas; skills capturam exclusivamente o _método, os contratos e as invariantes perenes_.
- **O Teste dos 5 Anos:** Antes de registrar uma instrução em uma skill, pergunte-se: _"Quando o `TODO.md` for zerado e as tarefas forem concluídas, este conhecimento ainda será útil, verdadeiro e acionável daqui a 5 anos?"_ Se depender de tarefas em aberto, descarte da skill.
- **Tarefas de Curto Prazo e Debug Pontual:** Logs temporários, anotações de sessão única ou investigações pontuais.
- **Conceitos Universais Já Cobertos:** Manuais gerais de linguagens ou regras POSIX que pertencem a skills globais.
- **Duplicação de Código:** Trechos de código que já estão no repositório ou no `Makefile`.

---

## 🔄 Ciclo de Vida de uma Skill Local (C.A.R.P.)

O agente deve gerenciar o ciclo de vida completo das skills locais:

1. **Criar (Create):** Ao identificar uma regra tácita recorrente, padrão ou contrato estrutural consolidado, crie um novo runbook em `.agents/skills/<nome>/SKILL.md`.
2. **Atualizar (Update):** Quando a arquitetura evoluir (ex: nova flag de build, novo alvo de teste), atualize a skill local para manter paridade com a realidade.
3. **Refatorar (Refactor):** Se uma skill local crescer além do _sweet spot_ de 128 linhas, sintetize os pontos centrais e mova tabelas ou dados densos para `references/`.
4. **Purgar (Prune / Delete):** Quando uma ferramenta ou subsistema for removido, ou quando uma skill contiver resquícios de tarefas já superadas do `TODO.md`, **delete imediatamente o ruído obsoleto** para não acumular alucinações.

---

## 🛡️ A Invariante Sagrada: Hermetismo de Produção (`rm -rf .agents`)

Toda skill local deve obedecer rigorosamente ao princípio do hermetismo:

- **Dependência Estritamente Unidirecional:** A IA lê a skill local para entender como agir. O código de produção (Makefiles, scripts, CI/CD, hooks) **NUNCA** referencia ou consome `.agents/`.
- **Teste de Fogo:** Se o comando `rm -rf .agents` for executado, o repositório deve continuar compilando, testando e operando com 100% de integridade.

---

## 📐 Orçamento de Linhas da Camada Cognitiva

Toda skill local ou global deve respeitar a disciplina de linhas:

| Faixa de Linhas                | Classificação             | Diretriz Operacional                                          |
| :----------------------------- | :------------------------ | :------------------------------------------------------------ |
| **$\ge 17$ linhas**            | Mínimo Substancial        | Previne micro-runbooks sem contexto ou valor acionável        |
| **$17\text{ a } 128$ linhas**  | **Sweet Spot Canônico**   | Meta áurea para runbooks executivos; preserva a janela        |
| **$129\text{ a } 256$ linhas** | Faixa de Densidade        | Permitido para matrizes complexas e fluxos multi-etapas       |
| **$> 256$ linhas**             | **Erro Fatal (Monólito)** | Proibido; obriga modularização em `references/` ou `scripts/` |

---

## 🔗 Links Oficiais & Fontes Canônicas

- **Anthropic (Prompt Engineering):** <https://www.anthropic.com/> | Documentação: <https://docs.anthropic.com/>
- **Google DeepMind (Gemini API):** <https://deepmind.google/> | Documentação: <https://ai.google.dev/>
- **The Open Group (POSIX Base Specifications):** <https://www.opengroup.org/> | Directory Structure: <https://pubs.opengroup.org/onlinepubs/9699919799/>
