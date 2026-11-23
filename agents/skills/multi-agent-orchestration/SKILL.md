---
name: multi-agent-orchestration
description: >-
    Runbook para orquestração multi-agente Master-Worker agnóstica de modelo, com
    herança dinâmica (Model: 'inherit'), pools limitados (2 a 8 workers), isolamento
    de escopo, verificação adversarial, torneios especulativos e propagação de contratos ABI.
---

# 🏛️ Orquestração Multi-Agente Master-Worker

Diretrizes operacionais para decomposição paralela com subagentes efêmeros, isolamento estrito de arquivos, herança dinâmica de modelo e validação independente de qualidade.

---

## 👑 1. Papéis Arquiteturais & Profundidade

- **Master Orchestrator / Planner:** Decompõe o problema, emite contratos isolados, gerencia o pool de concorrência e sintetiza entregas.
- **Specialist Sub-Agent / Execution Worker:** Executa uma tarefa atômica no escopo delimitado (`EnableSubagentTools: false`, profundidade máxima `1`).
- **Adversarial Verifier / QA Agent:** Audita entregas contra critérios de aceite, casos de borda e regressões de forma independente.

---

## ⚡ 2. Política de Modelos, Swarm & Polling

- **Herança Dinâmica (`Model: 'inherit'`):** Declare explicitamente `"Model": "inherit"` nas chamadas de delegação (ou utilize tier rápido apenas se exposto dinamicamente pelo runtime). Não fixe nomes comerciais ou versões de modelos.
- **Interdição de Mesh (`swarm`):** Não invoque ferramentas `swarm` por iniciativa própria; restrinja seu uso a pedidos literais por `"swarm"`.
- **Proibição de Polling (`schedule`):** Não agende crons periódicos para monitorar subagentes; utilize conclusão reativa baseada em eventos.

---

## 🚦 3. Pool de Concorrência & Isolamento de Escopo

- **Limites do Pool:** `MIN_ACTIVE = 2`, `AVERAGE_ACTIVE = 4`, `MAX_ACTIVE = 8`. Planos maiores são particionados em lotes sequenciais com encerramento formal (`kill`) entre lotes.
- **Zero Colisão de Escrita:** Dois Workers ativos nunca recebem permissão para editar o mesmo arquivo simultaneamente.
- **Soberania de Terceiros:** Vede mutações e aplicação de templates internos em diretórios `**/Open Source/**` (e legados `**/OSS/**`).
- **Canal de Esclarecimento:** Em caso de ambiguidade ou conflito, o Worker interrompe mutações e envia `### [CLARIFICATION REQUEST]` ao Master via mensageria (`send_message`).

---

## 🔄 4. Ciclo de Vida & Sub-Protocolos Especializados

1. **Decomposição:** Defina `TASK_ID`, caminhos autorizados, regras e critérios objetivos de aceite.
2. **Despacho:** Invoque o lote com contexto mínimo e `"Model": "inherit"`.
3. **Auditoria & Retry:** Valide retornos com testes reais (máximo `2` ciclos corretivos antes de assumir diretamente).
4. **Teardown:** Encerre os subagentes ativos após validar o lote e consolide o resultado final.

| Sub-Protocolo                         | Quando Ativar                                            | Referência                                                                         |
| :------------------------------------ | :------------------------------------------------------- | :--------------------------------------------------------------------------------- |
| **Templates de Delegação & Retorno**  | Despacho padrão Master-Worker e relatórios de entrega    | [`references/delegation-templates.md`](references/delegation-templates.md)         |
| **Tecelagem de Contratos & ABI**      | Propagação atômica de esquemas em stacks poliglotas      | [`references/abi-contract-weaving.md`](references/abi-contract-weaving.md)         |
| **Verificação Adversarial Red/Blue**  | Testes cegos de estresse, parsers e hardening com ASan   | [`references/adversarial-verification.md`](references/adversarial-verification.md) |
| **Torneio Especulativo em Worktrees** | Comparação empírica de N algoritmos em branches isoladas | [`references/speculative-tournament.md`](references/speculative-tournament.md)     |
