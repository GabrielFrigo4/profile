---
description: Invariante de isolamento e soberania para forks e repositórios de terceiros em diretórios **/OSS/**.
globs: "**/*"
always_on: true
---

# 🛡️ OSS Repositories Isolation & Sovereignty

1. **Natureza dos Repositórios em `**/OSS/**`:**
    - Diretórios sob `OSS/` (ex.: `~/Documents/Personal/OSS/ModernGL`, `~/Documents/Personal/OSS/PackageKit`) contêm código upstream de terceiros com licenças, convenções de estilo, linters, sistemas de build e arquiteturas próprias.
    - Esses repositórios operam como forks soberanos e não pertencem ao ecossistema autoral direto.

2. **Isolamento de Padrões Internos:**
    - Não aplique templates universais do ecossistema, `PRINCIPLES.md`, `AGENTS.md`, `.githooks`, `.prettierrc` ou réguas estruturais de 64/32 colunas dentro de diretórios `**/OSS/**`.
    - Não remova comentários explicativos, não reescreva cabeçalhos e não execute limpezas de taxonomia tripartite no código upstream.
    - Exclua repositórios `**/OSS/**` de rotinas automatizadas de formatação global, linter em lote e scripts de hooks de commit da estação.

3. **Condições de Edição e Contribuição:**
    - O agente só deve inspecionar ou alterar arquivos dentro de `**/OSS/<Projeto>` quando o usuário solicitar expressamente uma tarefa voltada àquele projeto específico.
    - Ao realizar correções ou patches em repositórios sob `**/OSS/**`, adote estritamente o estilo, convenções de código, formatação e fluxo de contribuição definidos pelo upstream do projeto.
