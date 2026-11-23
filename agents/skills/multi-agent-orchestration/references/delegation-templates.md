# 📋 Templates de Spawn, Delegação & Relatório

> Contratos estruturados para instanciação de subagentes com herança dinâmica e fechamento rastreável.

---

## 1. Definição e Invocação de Subagente

```json
{
	"name": "define_subagent",
	"args": {
		"Name": "worker-task",
		"Description": "Especialista em execução no escopo restrito",
		"SystemPrompt": "Atue estritamente nos arquivos autorizados. Siga AGENTS.md e PRINCIPLES.md.",
		"EnableWriteTools": true,
		"EnableSubagentTools": false,
		"EnableMCPTools": false
	}
}
```

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

---

## 2. Payload de Delegação (Master -> Worker)

```markdown
### CONTRATO DE TAREFA [TASK_ID]

- **Objetivo:** [Descrição concisa e unívoca da entrega esperada]
- **Modelo da Tool:** inherit
- **Arquivos Autorizados:**
    - `caminho/do/arquivo1.ext`
    - `caminho/do/arquivo2.ext`
- **Regras & Padrões:**
    - Conformidade estrita com os padrões do repositório (Clean Code, POSIX, quoting).
    - Preservar assinaturas públicas e trabalho prévio não relacionado.
    - Proibido editar fora da lista autorizada e em `**/Open Source/**` (ou `**/OSS/**`).
    - Em ambiguidade ou conflito, pause e envie `send_message` com `### [CLARIFICATION REQUEST]`.
    - Circuit Breaker: interrompa loops de erro ambiental e retorne `### [CIRCUIT BREAKER TRIGGERED]`.
- **Critérios de Aceite:**
    - [Critério 1: suíte de testes aprovada sem regressões]
    - [Critério 2: linters e verificadores estáticos sem avisos]
- **Formato de Retorno:** Responda usando o Template de Relatório de Entrega.
```

---

## 3. Relatório de Entrega (Worker -> Master)

```markdown
### RELATÓRIO DE ENTREGA [TASK_ID]

- **Status:** [SUCESSO | FALHA | BLOQUEIO | CIRCUIT_BREAKER]
- **Arquivos Modificados:**
    - `caminho/do/arquivo1.ext` (+X, -Y linhas)
- **Ações Executadas:**
    - [Resumo objetivo das alterações efetuadas]
- **Validações & Testes:**
    - [Comando executado após a última edição e resultado observado]
- **Observações / Drift:** [Nenhum desvio | Justificativa técnica]
```
