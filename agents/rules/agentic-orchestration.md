---
description: Governança de orquestração multi-agente, gatilho semântico do Argos e invariante de modelo explícito.
globs: "**/*"
always_on: true
---

# 🏛️ Multi-Agent Orchestration & Model Binding Protocol

1. **Gatilho Semântico do Argos & Família de Habilidades:**
    - Ao identificar no prompt menções a "Argos", "GM Argos", "gerenciador de agentes", "orquestrador" ou requisições de delegação multi-agente, carregue e siga obrigatoriamente `argos-multi-agent-orchestrator` (ou a respectiva skill da família Argos) ANTES de invocar qualquer ferramenta de subagente.
    - É vedado despachar tarefas paralelas sem ativar as diretrizes cognitivas da respectiva skill de orquestração.

2. **Invariante do Argumento Explícito de Modelo:**
    - Em toda e qualquer chamada de ferramenta que crie ou instancie subagentes (`invoke_subagent`, `swarm` ou ferramentas análogas em runtimes Google Antigravity), é obrigatório declarar explicitamente o argumento de modelo (`Model` / `model`).
    - É proibido omitir o parâmetro de modelo na chamada da tool. A omissão aciona o valor padrão (`inherit`), propagando modelos pesados (Argon/Pro) para toda a frota de execução.
    - O padrão operacional mandatório para 95%+ das tarefas táticas é `"Model": "flash"` ou `"Model": "flash_lite"`.
    - Escrever `- **Modelo Alocado:** flash` no texto ou markdown do prompt não altera a engine; o bind deve ser passado no payload da tool.

3. **Interdição do `native_swarm` Autônomo:**
    - Não acione a ferramenta `swarm` por iniciativa autônoma para tarefas de orquestração geral. O `swarm` opera em arquitetura mesh pública de alto consumo e retransmissão de contexto.
    - A ferramenta `swarm` só é permitida quando o usuário solicitar explicitamente o termo literal `"swarm"`. Mesmo nesse cenário, o argumento de modelo deve ser preenchido explicitamente sem herança cega.

4. **Proibição de Polling via Cron (`schedule`):**
    - É proibido agendar rotinas periódicas de cron via `schedule` para monitoramento de subagentes ou verificação de progresso. A coordenação multi-agente é orientada a eventos assíncronos e finalização em lote.

5. **Exceção Cirúrgica de Modelo Avançado (Escalação Invertida):**
    - A alocação de um Worker em modelo avançado (`"Model": "pro"`) é permitida unicamente em casos de borda extremos (provas matemáticas formais, análise simbólica densa ou algoritmos de alta complexidade).
    - Regras da exceção: manter o parâmetro explícito na tool, limitar a no máximo 1 Worker pesado ativo por lote e efetuar o encerramento imediato via `manage_subagents` após a entrega.
