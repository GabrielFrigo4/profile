---
description: Governança de orquestração multi-agente, gatilho semântico do protocolo Argos e política de herança dinâmica de modelo.
globs: "**/*"
always_on: true
---

# 🏛️ Multi-Agent Orchestration & Model Agnostic Protocol

1. **Gatilho Semântico do Argos & Família de Habilidades:**
    - Ao identificar no prompt menções a "Argos", "gerenciador de agentes", "orquestrador" ou requisições de delegação multi-agente, carregue e siga obrigatoriamente `argos-multi-agent-orchestrator` (ou a respectiva skill da família `argos-*`) ANTES de invocar qualquer ferramenta de subagente.
    - É vedado despachar tarefas paralelas sem ativar as diretrizes cognitivas da respectiva skill de orquestração.

2. **Política de Herança Dinâmica de Modelo:**
    - Em chamadas de criação ou instanciação de subagentes (`invoke_subagent`, `swarm` ou ferramentas análogas), o padrão operacional é a **Herança Dinâmica** (`Model: 'inherit'` ou omissão explícita do parâmetro de modelo), garantindo que o _Specialist Sub-Agent / Execution Worker_ e o _Adversarial Verifier / QA Agent_ operem automaticamente no modelo ativo da sessão do _Master Orchestrator / Planner Agent_.
    - A seleção de um tier rápido nativo só é permitida caso o runtime o exponha dinamicamente, sem fixar nomes comerciais, tiers proprietários ou versões específicas no código ou nas regras.
    - Evite acoplar prompts ou chamadas de ferramenta a identificadores fixos de modelo, preservando compatibilidade com gerações futuras.

3. **Interdição do `native_swarm` Autônomo:**
    - Não acione a ferramenta `swarm` por iniciativa autônoma para tarefas de orquestração geral. O `swarm` opera em arquitetura mesh pública de alto consumo e retransmissão de contexto.
    - A ferramenta `swarm` só é permitida quando o usuário solicitar explicitamente o termo literal `"swarm"`. Mesmo nesse cenário, adote a política de herança dinâmica (`Model: 'inherit'` ou omissão explícita), sem fixar nomes ou versões de modelo.

4. **Proibição de Polling via Cron (`schedule`):**
    - É proibido agendar rotinas periódicas de cron via `schedule` para monitoramento de subagentes ou verificação de progresso. A coordenação multi-agente é orientada a eventos assíncronos e finalização em lote.

5. **Papéis Semânticos & Escopo de Delegação:**
    - A orquestração opera com três papéis semânticos agnósticos de modelo: _Master Orchestrator / Planner Agent_ (planejamento, decomposição e síntese), _Specialist Sub-Agent / Execution Worker_ (execução isolada por contrato) e _Adversarial Verifier / QA Agent_ (validação independente e testes).
    - Caso o runtime exponha dinamicamente um tier especializado para casos de borda (provas matemáticas formais ou análise simbólica densa), mantenha o isolamento de escopo e efetue o encerramento imediato via `manage_subagents` após a entrega.
