---
name: argos-multi-agent-orchestrator
description: >-
    Runbook cognitivo para orquestração multi-agente Master-Worker agnóstica de
    modelo, gerenciando frotas efêmeras com herança dinâmica, pool de 2 a 8
    agentes (média 4), isolamento de escopo e validação de qualidade assíncrona.
---

# 🏛️ Orquestração Multi-Agente Master-Worker

Diretrizes operacionais para orquestração de frotas efêmeras de sub-agentes com paralelismo seguro, isolamento de escopo, herança dinâmica de modelo e validação de qualidade (QA).

---

## 👑 1. Hierarquia e Papéis Arquiteturais

O modelo operacional baseia-se na separação estrita entre governança estratégica, execução tática e verificação independente:

1. **Master Orchestrator / Planner Agent:**
    - Decomposição de problemas em subtarefas atômicas, emissão de contratos de delegação, controle de concorrência, síntese de entregas e supervisão da sessão.
    - Não executa alterações manuais triviais quando a tarefa pode ser paralelizada.
2. **Specialist Sub-Agent / Execution Worker:**
    - Instanciado para executar uma única tarefa atômica, isolada e verificável (ex.: refatorar um arquivo, implementar testes, validar esquemas), operando estritamente no escopo delimitado.
3. **Adversarial Verifier / QA Agent:**
    - Papel dedicado à auditoria independente de entregas, verificação de critérios de aceite, detecção de regressões e conformidade técnica antes da consolidação.
4. **Profundidade Máxima = 1 (`Max Depth = 1`):**
    - Workers e Verifiers não têm permissão para instanciar sub-agentes (`EnableSubagentTools: false`). Toda criação, supervisão e encerramento é prerrogativa exclusiva do Master.

---

## ⚡ 2. Política de Modelos & Herança Dinâmica

A alocação de modelos opera de forma 100% agnóstica de provedor, versão ou tier:

- **Herança Dinâmica (`Model: 'inherit'`):** Por padrão, toda delegação utiliza `"Model": "inherit"` para que os sub-agentes herdem automaticamente o modelo ativo da sessão (ou o tier rápido nativo do runtime atual quando aplicável, sem fixar nomes ou versões).
- **Invariante do Argumento Explícito:** O parâmetro `"Model"` deve ser sempre preenchido explicitamente na chamada da tool de delegação (`"Model": "inherit"`), evitando dependências implícitas ou omissões de schema.
- **Portabilidade de Runtime:** Não fixe identificadores de modelos, versões numéricas ou nomes de tiers em contratos, prompts ou payloads JSON.

---

## 🚦 3. Limite de Concorrência & Fila em Lotes (Pool 2/4/8)

Para evitar sobrecarga de contexto, contenção de I/O e limites de taxa de API, o Master gerencia um pool elástico de Workers:

- `MIN_ACTIVE_SLAVES = 2`: Piso de paralelismo concorrente para tarefas decomponíveis.
- `AVERAGE_ACTIVE_SLAVES = 4`: Faixa de operação padrão para a maioria das orquestrações.
- `MAX_ACTIVE_SLAVES = 8`: Teto rígido de concorrência simultânea.
- **Fila em Lotes (Batch Queueing):** Quando um plano demandar mais de 8 subtarefas:
    1. Particione o plano em lotes (_batches_) de 2 a 8 subtarefas (média 4).
    2. Dispare o lote atual e aguarde as conclusões assíncronas.
    3. Execute a auditoria QA do lote e encerre as instâncias ativas (`manage_subagents` kill).
    4. Somente após a liberação do pool, instancie o lote seguinte.

---

## 🔒 4. Protocolo de Comunicação & Isolamento de Contexto

- **Princípio do Contexto Mínimo:** O Master não repassa o histórico completo da sessão; cada Worker recebe apenas os dados necessários ao seu contrato.
- **Prevenção de Race Conditions:** Dois Workers ativos nunca recebem permissão para editar o mesmo arquivo simultaneamente. Componentes com acoplamento forte devem ficar no mesmo Worker ou em lotes sequenciais.
- **Canal Bidirecional (`send_message`):** Workers que identificarem divergências de escopo ou ambiguidades devem acionar o Master via `send_message` antes de alterar arquivos.

---

## 🔄 5. Ciclo de Vida e Validação de Qualidade (QA)

1. **Decomposição:** Subtarefas atômicas com identificadores unívocos (`TASK-01`, `TASK-02`) e escopos de arquivos restritos.
2. **Spawn (Sequência Canônica de Tools):**
    - Preencha explicitamente `"Model": "inherit"` no argumento JSON da tool de delegação (`invoke_subagent` ou equivalente).
    - Não invoque `swarm` (salvo solicitação literal) e não use `schedule` (cron) para monitorar agentes; a governança é orientada a eventos reativos.

### Passo A — Definição do Subagente

```json
{
	"name": "define_subagent",
	"args": {
		"Name": "worker-task",
		"Description": "Especialista em refatoração no escopo restrito",
		"SystemPrompt": "Atue estritamente nos arquivos autorizados. Siga AGENTS.md e PRINCIPLES.md.",
		"EnableWriteTools": true,
		"EnableSubagentTools": false,
		"EnableMCPTools": false
	}
}
```

### Passo B — Invocação com Herança Dinâmica

```json
{
	"name": "invoke_subagent",
	"args": {
		"TypeName": "worker-task",
		"Role": "Specialist Sub-Agent / Execution Worker",
		"Model": "inherit",
		"Prompt": "### CONTRATO DE TAREFA [TASK-01]\n..."
	}
}
```

3. **Coleta e Auditoria:** Recebimento assíncrono dos relatórios de entrega. O Master (ou um _Adversarial Verifier / QA Agent_) valida critérios de aceite e conformidade.
4. **Retry / Correção (Máx. 2 tentativas):** Persistindo a falha após 2 retries, o Master encerra o Worker e assume o reparo diretamente.
5. **Consolidação e Teardown:** O Master encerra todos os Workers ativos (`manage_subagents` kill), sintetiza as entregas e responde com métricas e links.

---

## ⚖️ 6. Diretrizes Imperativas (DOs & DON'Ts)

| Prática   | Diretiva Operacional                                                                                  |
| :-------- | :---------------------------------------------------------------------------------------------------- |
| **DO**    | Declare explicitamente `"Model": "inherit"` no payload JSON de `invoke_subagent`.                     |
| **DO**    | Mantenha concorrência ativa entre 2 e 8 Workers simultâneos (média 4); use lotes para planos maiores. |
| **DO**    | Particione caminhos de arquivos para eliminar risco de escrita simultânea.                            |
| **DO**    | Encerre formalmente os Workers (`manage_subagents` kill) após validar cada lote.                      |
| **DO**    | Instrua Workers a enviar dúvidas via `send_message` ao Master antes de alterar arquivos em conflito.  |
| **DON'T** | Não fixe nomes, versões ou tiers de modelos nos prompts ou payloads de delegação.                     |
| **DON'T** | Não use a ferramenta `swarm` para orquestração padrão (salvo solicitação literal do usuário).         |
| **DON'T** | Não utilize `schedule` (cron) para monitoramento de sub-agentes ou polling periódico.                 |
| **DON'T** | Não permita que Workers criem sub-agentes (`depth > 1` é incompatível).                               |
| **DON'T** | Não transmita históricos de chat desnecessários nos briefings.                                        |
| **DON'T** | Não autorize dois Workers concorrentes a modificar o mesmo arquivo no mesmo lote.                     |
| **DON'T** | Não autorize alterações ou aplicação de templates internos em repositórios sob `**/OSS/**`.           |

---

## 📋 7. Template de Payload de Delegação (Master -> Worker)

```markdown
### CONTRATO DE TAREFA [TASK_ID]

- **Objetivo:** [Descrição concisa e unívoca da entrega esperada]
- **Modelo da Tool:** inherit (herança dinâmica do modelo ativo da sessão)
- **Arquivos Autorizados:**
    - `caminho/do/arquivo1.ext`
    - `caminho/do/arquivo2.ext`
- **Regras & Padrões:**
    - Estrita conformidade com os padrões do repositório (Clean Code, POSIX, sem números mágicos).
    - Preservar assinaturas existentes e comentários não relacionados.
    - Proibido editar arquivos fora da lista autorizada e vedado alterar código sob `**/OSS/**`.
    - Protocolo de Esclarecimento: Em caso de ambiguidade, pause e envie `send_message` ao Parent Conversation ID com `### [CLARIFICATION REQUEST]`.
    - Circuit Breaker: Teto de 20 chamadas de ferramenta. Se encontrar erro de ambiente ou bloqueio fora do escopo, interrompa o loop e retorne relatório parcial com `### [CIRCUIT BREAKER TRIGGERED]`.
- **Critérios de Aceite:**
    - [Critério 1: testes passam sem erros]
    - [Critério 2: linter aprovado sem warnings]
- **Formato de Retorno:** Responda utilizando o Template de Relatório de Entrega.
```

---

## 📄 8. Template de Relatório de Entrega (Worker -> Master)

```markdown
### RELATÓRIO DE ENTREGA [TASK_ID]

- **Status:** [SUCESSO | FALHA | BLOQUEIO | CIRCUIT_BREAKER]
- **Arquivos Modificados:**
    - `caminho/do/arquivo1.ext` (+X, -Y linhas)
- **Ações Executadas:**
    - [Resumo da refatoração/implementação efetuada]
- **Validações & Testes:**
    - [Comando executado e evidência de sucesso, ex.: make test -> OK]
- **Observações / Drift:** [Nenhum desvio identificado | Justificativa de ajuste]
```
