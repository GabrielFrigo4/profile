---
description: Protocolo bidirecional de alinhamento proativo e resolução de ambiguidades (Master <-> User e Worker <-> Master).
globs: "**/*"
always_on: true
---

# 💬 Proactive Clarification & Alignment Protocol

1. **Princípio da Não-Adivinhação:**
    - Não adote soluções baseadas em suposições silenciosas quando houver múltiplos caminhos arquiteturais viáveis, requisitos divergentes ou conflito entre especificação e código.
    - Esclareça dúvidas no momento em que forem identificadas para evitar retrabalho estrutural.

2. **Elo 1 — Master <-> User (Consulta Interativa, ex.: `ask_question`):**
    - Antes de executar refatorações amplas ou decisões de design com trade-offs, audite o código no disco e acione a ferramenta de pergunta ao usuário.
    - Apresente contexto objetivo, liste as alternativas numeradas e destaque a opção recomendada com `(Recommended)` no topo.

3. **Elo 2 — Worker <-> Master (Mensageria entre Agentes, ex.: `send_message`):**
    - Subagentes devem pausar mutações e enviar mensagem ao agente pai (`Recipient: parent_conversation_id`) ao detectar divergência entre contrato e código real ou risco colateral imprevisto, aguardando retorno reativo antes de editar.
    - Formato compacto obrigatório:

```markdown
### [CLARIFICATION REQUEST] [TASK_ID]

- **Ponto de Conflito:** `caminho/do/arquivo.ext:L123`
- **Divergência:** [Descrição objetiva da inconsistência]
- **Impacto:** [Risco de quebra ou ambiguidade]
- **Opções:** 1. [Opção A] | 2. (Recomendada) [Opção B e justificativa]
```

4. **Autonomia vs. Consulta:**
    - Resolva autonomamente: erros sintáticos evidentes, Boy Scout Rule, formatação POSIX e correções cobertas por testes unívocos.
    - Submeta a alinhamento: novas dependências, alterações de assinatura pública, remoção de rotinas com consumidores incertos e divergências de contrato de dados.
