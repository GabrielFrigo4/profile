---
name: argos-multi-agent-orchestrator
description: >-
    Runbook cognitivo para orquestração multi-agente Master-Worker polimórfica (GM Argos
    ou Flash Master), gerenciando frotas efêmeras com gradiente de capacidade relativa,
    pool de concorrência máxima de 5 agentes, isolamento de escopo e qualidade assíncrona.
---

# 🏛️ Orquestração Multi-Agente Master-Worker

Diretrizes operacionais e guardrails cognitivos para agentes atuarem no papel de **Master Orchestrator** (seja o **GM Argos** com raciocínio avançado ou um **Flash Master** ágil e econômico), gerenciando frotas de sub-agentes efêmeros (**Workers**) com paralelismo seguro, consumo racional de recursos e validação de qualidade (QA).

---

## 👑 1. Hierarquia e Papéis Polimórficos

O modelo operacional baseia-se na separação estrita entre governança estratégica e execução tática:

1. **Master Orchestrator (GM Argos ou Flash Master):**
    - **Polimorfismo do Master:** A governança pode ser exercida pelo GM Argos (modelo avançado/Pro) ou por um agente Flash atuando como Master enxuto (ideal para economia de cota, testes rápidos ou tarefas rotineiras).
    - **Responsabilidade Exclusiva:** Decomposição de problemas em subtarefas atômicas, emissão de contratos de delegação, controle de concorrência, auditoria de qualidade (QA) e síntese do resultado final.
    - **Postura Operacional:** O Master não executa alterações manuais triviais se a tarefa puder ser paralelizada. Foca na supervisão e integridade da sessão.
2. **Workers (Sub-agentes Efêmeros Especialistas):**
    - **Responsabilidade:** Instanciados para executar uma única tarefa atômica, isolada e verificável (ex.: refatorar um arquivo, implementar testes, validar esquemas).
    - **Postura Operacional:** Operam estritamente no escopo delimitado, sem desvios laterais ou tarefas secundárias.
3. **Profundidade Máxima = 1 (`Max Depth = 1`):**
    - **Regra Invariante:** Workers não têm permissão para instanciar sub-agentes (`EnableSubagentTools: false`).
    - Toda criação, supervisão e encerramento de agentes é prerrogativa exclusiva do Master ativo.

---

## ⚡ 2. Matriz de Capacidade Relativa & Política de Modelos

A alocação de capacidade computacional entre Master e Workers segue uma heurística de gradiente econômico:

### Regra Canônica do Gradiente de Capacidade

$$\text{Capacidade}(\text{Worker}) \le \text{Capacidade}(\text{Master})$$

Via de regra, o Worker deve ser computacionalmente mais leve ou, no máximo, tão capaz quanto o Master.

| Modo Operacional                  | Papel do Master              | Papel dos Workers            | Cenário de Uso Recomendado                                              |
| :-------------------------------- | :--------------------------- | :--------------------------- | :---------------------------------------------------------------------- |
| **Standard (Argos Heavy)**        | GM Argos (`pro`/`inherit`)   | Flash / Flash-Lite (`flash`) | Planejamento complexo, síntese profunda e refatorações amplas.          |
| **Lean (Quota-Shield)**           | Flash Orchestrator (`flash`) | Flash / Flash-Lite (`flash`) | Tarefas rotineiras, orquestrações rápidas e máxima economia de cota.    |
| **Ponto a Ponto (Peer-to-Peer)**  | Flash ou Pro (`inherit`)     | Mesma capacidade (`inherit`) | Competições especulativas e torneios de soluções equivalentes.          |
| **Escalação Invertida (Exceção)** | Flash Master (`flash`)       | Pro Cirúrgico (`pro`)        | Subtarefa pontual com prova matemática ou invariante de alta densidade. |

### Guardrails de Alocação de Modelos

- **Primazia do Flash:** Para 95% das tarefas de execução paralela, utilize modelos da família **Flash** (`Model: 'flash'` ou `Model: 'flash_lite'`).
- **Bloqueio do Modelo 3.1 Pro Legado:** É expressamente vetado instanciar Workers ou acionar fallbacks com o modelo **3.1 Pro** ou variantes Pro legadas, devido à latência excessiva e comportamento degradado.
- **Protocolo de Escalação Invertida (Exceção Fundamentada):** Quando um Flash Master necessitar de raciocínio simbólico profundo ou prova matemática de altíssima complexidade em uma subtarefa isolada, é permitido instanciar excepcionalmente 1 Worker Pro moderno (`Model: 'pro'`). A instância deve ser encerrada imediatamente após a entrega, mantendo o custo global sob controle.

---

## 🚦 3. Limite de Concorrência & Fila em Lotes (Pool <= 5)

Para evitar sobrecarga de contexto, contenção de I/O e limites de taxa de API, o Master gerencia um pool estrito:

- **Teto Concorrente:** No máximo **5 Workers simultâneos** ativos (`MAX_ACTIVE_SLAVES = 5`).
- **Fila em Lotes (Batch Queueing):**
    - Quando um plano demandar mais de 5 subtarefas (ex.: 12 arquivos a refatorar):
        1. O Master particiona o plano em lotes (_batches_) de no máximo 5 subtarefas.
        2. Dispara o _Batch 1_ (Workers 1 a 5) e aguarda suas conclusões assíncronas.
        3. Executa a auditoria de qualidade (QA) do lote e encerra as instâncias ativas (`manage_subagents` kill).
        4. Somente após a liberação do pool, instancia o _Batch 2_ (Workers 6 a 10).
        5. Repete o ciclo até a finalização do último lote.

---

## 🔒 4. Protocolo de Comunicação & Isolamento de Contexto

A eficiência dos Workers depende da pureza de contexto e da prevenção de condições de corrida:

- **Princípio do Contexto Mínimo:**
    - O Master nunca repassa o histórico completo da sessão ao Worker.
    - Cada Worker recebe um contrato enxuto contendo apenas os dados vitais para sua tarefa.
- **Prevenção Ativa de Race Conditions:**
    - **Particionamento por Arquivo/Diretório:** Dois Workers ativos nunca recebem permissão para editar o mesmo arquivo simultaneamente.
    - Componentes com acoplamento forte devem ser atribuídos ao mesmo Worker ou executados em lotes sequenciais.

---

## 🔄 5. Ciclo de Vida e Validação de Qualidade (QA)

O fluxo de orquestração do Master é composto por 5 etapas sequenciais:

1. **Decomposição:** O Master decompõe a solicitação em subtarefas atômicas com identificadores unívocos (`TASK-01`, `TASK-02`, etc.) e escopos de arquivos restritos.
2. **Spawn:** Instanciação dos Workers (1 a 5 por lote) via `invoke_subagent` com o tier de modelo adequado e contrato estruturado.
3. **Coleta e Auditoria:** Recebimento assíncrono dos relatórios de entrega. O Master valida os critérios de aceite e a conformidade do código.
4. **Retry / Correção (Máx. 2 tentativas):** Se um Worker entregar código divergente, o Master aponta o erro exato. Persistindo a falha após 2 retries, o Master encerra o Worker e assume o reparo diretamente.
5. **Consolidação e Teardown:** O Master encerra todos os Workers ativos (`manage_subagents` kill), sintetiza as entregas e responde ao usuário com métricas e links.

---

## ⚖️ 6. Diretrizes Imperativas (DOs & DON'Ts)

| Prática   | Diretiva Operacional                                                                              |
| :-------- | :------------------------------------------------------------------------------------------------ |
| **DO**    | Permita que tanto o GM Argos quanto modelos Flash atuem soberanamente como Master Orchestrator.   |
| **DO**    | Aplique como regra geral $\text{Capacidade}(\text{Worker}) \le \text{Capacidade}(\text{Master})$. |
| **DO**    | Mantenha concorrência ativa $\le 5$ Workers simultâneos; use lotes para planos maiores.           |
| **DO**    | Particione caminhos de arquivos para eliminar qualquer risco de escrita simultânea.               |
| **DO**    | Encerre formalmente os Workers (`manage_subagents` kill) após validar cada lote.                  |
| **DON'T** | Não utilize nem faça fallback para o modelo 3.1 Pro legado.                                       |
| **DON'T** | Não permita que Workers criem sub-agentes (`depth > 1` é incompatível).                           |
| **DON'T** | Não transmita históricos de chat desnecessários ou contexto global nos briefings.                 |
| **DON'T** | Não autorize dois Workers concorrentes a modificar o mesmo arquivo no mesmo lote.                 |
| **DON'T** | Não utilize Workers Pro sem justificativa explícita de complexidade matemática/simbólica.         |

---

## 📋 7. Template de Payload de Delegação (Master -> Worker)

```markdown
### CONTRATO DE TAREFA [TASK_ID]

- **Objetivo:** [Descrição concisa e unívoca da entrega esperada]
- **Modelo Alocado:** [flash | flash_lite | inherit | pro (com justificativa)]
- **Arquivos Autorizados:**
    - `caminho/do/arquivo1.ext`
    - `caminho/do/arquivo2.ext`
- **Regras & Padrões:**
    - Estrita conformidade com os padrões do repositório (Clean Code, POSIX, sem números mágicos).
    - Preservar assinaturas existentes e comentários não relacionados.
    - Proibido editar arquivos fora da lista autorizada.
- **Critérios de Aceite:**
    - [Critério 1: testes passam sem erros]
    - [Critério 2: linter aprovado com zero warnings]
- **Formato de Retorno:** Responda utilizando o Template de Relatório de Entrega.
```

---

## 📄 8. Template de Relatório de Entrega (Worker -> Master)

```markdown
### RELATÓRIO DE ENTREGA [TASK_ID]

- **Status:** [SUCESSO | FALHA | BLOQUEIO]
- **Arquivos Modificados:**
    - `caminho/do/arquivo1.ext` (+X, -Y linhas)
- **Ações Executadas:**
    - [Resumo da refatoração/implementação efetuada]
- **Validações & Testes:**
    - [Comando executado e evidência de sucesso, ex.: make test -> OK]
- **Observações / Drift:** [Nenhum desvio identificado | Justificativa de ajuste]
```
