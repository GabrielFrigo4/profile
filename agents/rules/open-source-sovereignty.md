---
description: Invariante de isolamento e soberania para forks e repositórios de terceiros em diretórios **/Open Source/**.
globs: "**/*"
always_on: true
---

# 🛡️ Open Source Repositories Isolation & Sovereignty

1. **Natureza dos Repositórios em `**/Open Source/**`:**
    - Diretórios sob `Open Source/` (ou legados `OSS/`, ex.: `<workspace>/Open Source/<Projeto>`) contêm código upstream de terceiros com licenças, convenções de estilo, linters, sistemas de build e arquiteturas próprias.
    - Esses repositórios operam como forks ou espelhos soberanos e não pertencem ao ecossistema autoral direto.

2. **Isolamento de Padrões Internos:**
    - Não aplique templates internos, `PRINCIPLES.md`, `AGENTS.md`, `.githooks`, `.prettierrc` ou réguas estruturais de 64/32 colunas dentro de diretórios `**/Open Source/**` ou `**/OSS/**`.
    - Não remova comentários explicativos, não reescreva cabeçalhos e não execute limpezas de taxonomia tripartite no código upstream.
    - Exclua diretórios `**/Open Source/**` e `**/OSS/**` de rotinas automatizadas de formatação global, linter em lote e scripts de hooks de commit.

3. **Condições de Edição e Contribuição:**
    - O agente só deve inspecionar ou alterar arquivos dentro de `**/Open Source/<Projeto>` (ou `**/OSS/<Projeto>`) quando o usuário solicitar expressamente uma tarefa voltada àquele projeto específico.
    - Ao realizar correções ou patches nesses repositórios, adote estritamente o estilo, convenções de código, formatação e fluxo de contribuição definidos pelo upstream do projeto.
