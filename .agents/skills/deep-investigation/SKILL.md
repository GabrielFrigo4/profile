---
name: deep-investigation
description: >-
  Deep root-cause technical investigation and primary sources research for Universal Profile.
  Use when diagnosing LSP server schema errors, editor extension configurations (VS Code, Zed, Antigravity),
  terminal ANSI rendering, font glyph ligatures, and AI agent prompt contracts.
---

# Deep Investigation — Editor Schemas & AI Protocol Research

Esta skill define o protocolo de investigação técnica de excelência no repositório **Universal Profile Environment** (`Profile`).

Quando nos deparamos com falhas de validação de schemas de editores, quebras de compatibilidade de LSP (Language Server Protocol), renderização corrompida de fontes ou inconsistências de APIs de inteligência artificial, **nunca devemos recorrer a adivinhações superficiais**.

---

## 1. Regra de Ouro: Fontes Primárias Atuais

1. **Schemas de Editores:**
   - **VS Code / Antigravity:** Consulte a documentação oficial da Microsoft para o schema de `settings.json` e a especificação da API de extensões.
   - **Zed:** Consulte os releases oficiais do Zed e a documentação em `zed.dev/docs` para atualizações de syntax highlighting e language servers.
2. **Formatadores e Linters:**
   - Documentações oficiais de LLVM para `.clang-format` e `clangd`, Prettier docs e StyLua manual.
3. **Padrões de IA e Agentes:**
   - Especificação oficial de `SKILL.md` com YAML Frontmatter do Google Antigravity e modelos modernos.

---

## 2. Hierarquia de Fontes Primárias

```text
Nível 1: Código-Fonte Upstream & Schemas Oficiais (Ground Truth)
   ↳ microsoft/vscode schema repository, zed-industries/zed, LLVM clang sources.

Nível 2: Documentações Oficiais da Ferramenta
   ↳ code.visualstudio.com/docs, zed.dev/docs, prettier.io.

Nível 3: Release Notes e Commit Logs Upstream
   ↳ Novas chaves introduzidas e configurações descontinuadas.
```

---

## 3. Protocolo de Diagnóstico

1. **Isolar o Erro:** Capture a linha e a chave exata rejeitada pelo parser ou pelo editor.
2. **Validar contra o Schema Oficial:** Confirme se o tipo da propriedade (boolean, string, array) corresponde à versão ativa da ferramenta.
3. **Testar Sintaxe:** Valide com `python3 scripts/audit/formats.py` e garanta conformidade estrita.
