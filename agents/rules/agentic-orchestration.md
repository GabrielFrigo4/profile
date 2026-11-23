---
description: Governança de orquestração multi-agente, ativação de workflow e política de herança dinâmica de modelo.
globs: "**/*"
always_on: true
---

# 🏛️ Multi-Agent Orchestration & Model-Agnostic Protocol

1. **Gatilho Semântico de Orquestração:**
    - Ao identificar requisições de delegação multi-agente, coordenação de subagentes ou paralelização de execução, carregue e siga obrigatoriamente a skill `multi-agent-orchestration` ANTES de invocar qualquer ferramenta de subagente.
    - Não despache tarefas paralelas sem ativar as diretrizes de isolamento de escopo da skill de orquestração.

2. **Política de Herança Dinâmica de Modelo:**
    - Em chamadas de criação ou instanciação de subagentes (ex.: `invoke_subagent`, `swarm` ou ferramenta equivalente do runtime), adote a **Herança Dinâmica** (`Model: 'inherit'` ou omissão explícita do parâmetro de modelo), garantindo que Workers e Verifiers operem automaticamente no modelo ativo da sessão do Master.
    - Seleção de tier rápido nativo só é permitida se exposta dinamicamente pelo runtime, sem fixar nomes comerciais, tiers proprietários ou versões específicas.

3. **Interdição de Mesh Autônomo (`swarm`) & Polling via Cron (`schedule`):**
    - Não acione ferramentas de enxame (`swarm`) por iniciativa própria para orquestração geral; reserve seu uso estritamente a pedidos com o termo literal `"swarm"` mantendo herança dinâmica.
    - Não agende rotinas periódicas de cron (`schedule`) para monitorar subagentes; a coordenação é orientada a eventos assíncronos.

4. **Papéis Semânticos & Escopo de Delegação:**
    - A orquestração opera com três papéis agnósticos de modelo: _Master Orchestrator / Planner Agent_ (decomposição e síntese), _Specialist Sub-Agent / Execution Worker_ (execução isolada por contrato) e _Adversarial Verifier / QA Agent_ (auditoria e testes).
    - Mantenha isolamento rigoroso de arquivos por Worker e efetue encerramento imediato após a entrega do lote.
