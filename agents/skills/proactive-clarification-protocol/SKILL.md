---
name: proactive-clarification-protocol
description: >-
    Protocolo bidirecional de alinhamento socrático e resolução proativa de ambiguidade
    entre Master, User e Workers (Master <-> User via ask_question e Worker <-> Master
    via send_message), eliminando suposições silenciosas e retrabalho.
---

# 💬 Protocolo Bidirecional de Esclarecimento Proativo

Diretrizes operacionais e procedimentos para resolução antecipada de ambiguidades, divergências de especificação e decisões de design com múltiplos caminhos no ecossistema multi-agente.

---

## 🏛️ 1. Princípio da Não-Adivinhação

Em engenharia de software soberana, suposições silenciosas acumulam débito técnico e provocam retrabalho estrutural. O esclarecimento proativo opera através de dois elos complementares:

1. **Elo 1 (Master <-> User):** Alinhamento estratégico e tomada de decisão antes de refatorações ou modificações destrutivas.
2. **Elo 2 (Worker <-> Master):** Alinhamento tático durante a execução de subtarefas delegadas.

---

## 👑 2. Elo 1 — Alinhamento Master <-> User (`ask_question`)

Antes de executar refatorações amplas, decisões arquiteturais ou alterações com múltiplos caminhos viáveis:

1. **Auditoria Prévia Obrigatória:** Audite o código no disco (ou despache subagentes em modo de leitura/pesquisa) antes de formular perguntas.
2. **Uso de `ask_question`:** Acione a ferramenta `ask_question` para alinhar inconsistências, trade-offs ou lacunas de especificação. Nunca presuma silenciosamente o caminho quando houver dúvida legítima.
3. **Estrutura da Consulta:**
    - Contextualize brevemente a dúvida com dados concretos do código.
    - Apresente as alternativas viáveis numeradas.
    - Aponte a opção recomendada no topo com o prefixo `(Recommended)`, fundamentando tecnicamente a escolha.

---

## ⚡ 3. Elo 2 — Alinhamento Worker <-> Master (`send_message`)

Subagentes operam com contexto focado. Quando um Worker identificar conflito entre o contrato de tarefa e o código real, ambiguidade de requisito ou risco imprevisto:

1. **Suspensão Preventiva:** Interrompa edições especulativas nos arquivos afetados.
2. **Mensagem Estruturada:** Despache mensagem ao agente pai via `send_message`:
    - **Recipient:** `parent_conversation_id` fornecido no contrato de tarefa.
    - **Message:** Bloco padronizado encabeçado por `### [CLARIFICATION REQUEST]`.
3. **Espera Reativa:** Finalize o turno sem invocar ferramentas de escrita e aguarde o retorno do Master via notificação de mensagem.

---

## 📋 4. Template de Mensagem Worker -> Master

```markdown
### [CLARIFICATION REQUEST] [TASK_ID]

- **Arquivo / Ponto de Conflito:** `caminho/do/arquivo.ext:L123`
- **Divergência Observada:** [Descrição objetiva da inconsistência encontrada]
- **Impacto Potencial:** [Risco de quebra, colateral ou ambiguidade de design]
- **Opções Identificadas:**
    1. Opção A: [Descrição técnica]
    2. Opção B (Recomendada): [Descrição técnica e justificativa]
```

---

## ⚖️ 5. Matriz de Decisão: Consulta vs. Autonomia

Para preservar tokens e evitar ruído procedimental, utilize os seguintes critérios de corte:

| Cenário Observado                                               | Ação Mandatória | Canal Operacional |
| :-------------------------------------------------------------- | :-------------- | :---------------- |
| Ambiguidade em regras de negócio ou requisitos funcionais       | Consultar       | `ask_question`    |
| Múltiplas abordagens arquiteturais com trade-offs contrastantes | Consultar       | `ask_question`    |
| Divergência entre documentação canônica e código legado         | Consultar       | `ask_question`    |
| Conflito entre escopo do contrato e arquivos reais (Worker)     | Consultar       | `send_message`    |
| Risco de quebra de compatibilidade ou efeito colateral externo  | Consultar       | `send_message`    |
| Erro evidente de sintaxe, typo ou import quebrado               | Autônomo        | Boy Scout Rule    |
| Padrões canônicos já formalizados (POSIX sh, réguas, UI)        | Autônomo        | Auto-correção     |
| Falha pontual de teste unitário com causa unívoca no código     | Autônomo        | TDD / Refatoração |
