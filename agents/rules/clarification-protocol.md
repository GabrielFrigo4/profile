---
description: Protocolo bidirecional de alinhamento proativo e resolução de ambiguidades (Master <-> User via ask_question e Worker <-> Master via send_message).
globs: "**/*"
always_on: true
---

# 💬 Proactive Clarification & Alignment Protocol

1. **Princípio da Não-Adivinhação:**
    - Não adote soluções baseadas em suposições silenciosas quando houver mais de um caminho arquitetural viável, requisitos divergentes ou conflito entre especificação e código.
    - Esclareça dúvidas no momento em que forem identificadas para evitar retrabalho estrutural.

2. **Elo 1 — Master <-> User (`ask_question`):**
    - Antes de executar refatorações amplas ou decisões de design com trade-offs, audite o código no disco e acione `ask_question`.
    - Apresente contexto objetivo, liste as alternativas numeradas e aponte sempre a opção recomendada com o prefixo `(Recommended)` no topo.

3. **Elo 2 — Worker <-> Master (`send_message`):**
    - Subagentes devem pausar alterações e despachar `send_message` ao agente pai (`Recipient: parent_conversation_id`) ao detectar incompatibilidade entre contrato e arquivos reais, ou efeito colateral não previsto.
    - Utilize o cabeçalho `### [CLARIFICATION REQUEST]` com arquivo afetado, divergência e opções. Aguarde retorno reativo antes de editar.

4. **Autonomia vs. Consulta:**
    - Resolva de forma autônoma: erros sintáticos óbvios, aplicação da Boy Scout Rule, formatação POSIX e correções cobertas por testes unívocos.
    - Submeta a alinhamento: novas dependências, alterações de assinatura pública, exclusão de rotinas legadas com consumidores incertos e divergências de modelo de dados.
