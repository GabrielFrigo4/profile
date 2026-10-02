---
name: technical-writing-standards
description: Runbook cognitivo definitivo para redação técnica, arquitetura de READMEs institucionais, diagramação visual Mermaid, tipografia Reader-First e formatação estrita via Prettier.
---

# ✍️ Padrões Canônicos de Redação Técnica & Design de READMEs

Esta habilidade orienta a especificação, estruturação, diagramação visual e redação de **READMEs institucionais, manuais técnicos e documentações Markdown de alto padrão**, estruturado sob a arquitetura de **Tier 2 (Extended)**.

---

## 🧭 O Princípio Reader-First (Legibilidade & Acessibilidade)

A documentação técnica do ecossistema deve proporcionar uma experiência impecável em múltiplos ambientes simultaneamente:

1. **Portais GitHub/GitLab:** Primeira impressão profissional em menos de 10 segundos, com badges vetoriais em alta resolução e diagramas claros.
2. **Modos de Leitura (Reader View / Obsidian):** Tipografia semântica, respiro visual e ausência de ruído estrutural.
3. **Leitores de Terminal (CLI):** Compatibilidade com renderizadores CLI (`glow`, `bat`, `cat`).
4. **Acessibilidade Universal (WCAG):** Árvores de cabeçalho estritas (`# H1` $\rightarrow$ `## H2` $\rightarrow$ `### H3`) e texto alternativo em imagens.

---

## 🏛️ Invariantes Estruturais Globais

- **Título Único (H1):** Exatamente um `# H1` no topo do arquivo.
- **Réguas Divisórias:** Linha horizontal `---` antes de cada seção `## H2`.
- **Blocos de Terminal Universal:** Sempre use o identificador `sh` (```sh) para comandos de CLI, compilação e pacotes. Proibido usar `shell`, `console` ou `terminal`. Identificadores específicos (`zsh`, `bash`, `fish`, `pwsh`) são restritos a código que exige recursos exclusivos daquele interpretador.
- **Formatação Mandatória Prettier:** Todo documento Markdown deve ser formatado com `npx prettier --write <arquivo>`.
- **Zero Linhas em Branco no EOF:** Arquivos devem terminar com exatamente um `\n` final, sem linhas em branco extras (`git diff --check`).

---

## 📚 Módulos Especializados da Subpasta references/

Consulte as especificações detalhadas nos subarquivos dedicados:

- **[readme-design.md](references/readme-design.md):** Engenharia de badges vetoriais com Shields.io e Simple Icons, improvisação canônica de slugs, hero sections, tabelas de catálogo e portais de repositórios.
- **[diagrams-mermaid.md](references/diagrams-mermaid.md):** Diagramação em código Mermaid, arquitetura hierárquica híbrida (`flowchart TD` com `direction LR` e `~~~`), diagramas de sequência e citações seguras de rótulos.
- **[typography-style.md](references/typography-style.md):** Tipografia técnica, alinhamento de tabelas (`:---`, `:---:`, `---:`), admonitions do GitHub (`> [!NOTE]`, etc.), proteção de URLs com parênteses `<...>` e acessibilidade.
- **[tone-and-economy.md](references/tone-and-economy.md):** Tom sóbrio, dicotomia de estilos (Sistema/IA vs Humano), gramática declarativa contrastiva e eliminação de token-bloat dramático.

---

## 🔗 Referências Oficiais & Especificações

- [CommonMark Specification](https://spec.commonmark.org/)
- [GitHub Flavored Markdown (GFM) Specification](https://github.github.com/gfm/)
- [Simple Icons SVG Library](https://simpleicons.org/)
- [Shields.io Metadata Badges](https://shields.io/)
- [Mermaid-JS Documentation](https://mermaid.js.org/)
- [Prettier Code Formatter](https://prettier.io/)
