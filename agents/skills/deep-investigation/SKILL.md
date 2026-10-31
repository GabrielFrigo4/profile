---
name: deep-investigation
description: >-
    Runbook cognitivo para investigação técnica profunda de causa raiz e consulta a fontes primárias.
    Ativar ao diagnosticar falhas de compilação, schemas de editores, divergências de runtime,
    APIs de sistemas, comportamentos inesperados de bibliotecas e inconsistências de protocolos.
---

# 🔍 Deep Investigation — Investigação de Causa Raiz & Fontes Primárias

> _"It is a capital mistake to theorize before one has data. Insensibly one begins to twist facts to suit theories, instead of theories to suit facts."_<br>
> — Arthur Conan Doyle, _A Scandal in Bohemia_ (1891)

Esta skill estabelece o protocolo de investigação técnica profunda de causa raiz e verificação em fontes primárias para todo o ecossistema soberano. Em diagnósticos de falhas de compilação, quebras de ABI/LSP, validações de schemas de editores, comportamentos anômalos de runtimes ou discrepâncias de APIs de sistemas operacionais, o agente NÃO DEVE recorrer a suposições superficiais ou soluções paliativas de contorno.

---

## 🏛️ A Hierarquia Canônica de Fontes Primárias

Ao diagnosticar qualquer comportamento anômalo, o agente DEVE consultar fontes primárias estruturadas segundo os três níveis de autoridade técnica:

```text
Nível 1: Código-Fonte Upstream & Especificações Formais (Ground Truth)
   ↳ Padrões ISO/IEC (C23, C++23), POSIX.1-2024, schemas JSON/YAML oficiais,
     árvore de código upstream (microsoft/vscode, zed-industries/zed, LLVM, FreeBSD src, Linux kernel).

Nível 2: Manpages e Documentações Canônicas da Plataforma
   ↳ Manpages oficiais (seções 1, 2, 3, 5, 8), docs oficiais de editores,
     manuais técnicos mantidos pelos desenvolvedores originais da ferramenta.

Nível 3: Release Notes, Changelogs e Histórico de Commits Upstream
   ↳ Commits de introdução ou descontinuação de chaves, migrações de flags,
     notas de versão oficiais e breaking changes documentadas no Git.
```

---

## ⚖️ Matriz de Postura Investigativa

| Dimensão                  | Anti-padrão Especulativo (Evite)              | Investigação Profunda (Use)                                       |
| :------------------------ | :-------------------------------------------- | :---------------------------------------------------------------- |
| **Origem da Informação**  | Fóruns genéricos, posts de blog obsoletos     | **Especificações oficiais e código-fonte upstream**               |
| **Tratamento de Schema**  | Supor propriedades por analogia com outro app | **Validar contra o schema JSON formal da ferramenta**             |
| **Quebra de Compilação**  | Tentar flags aleatórias até o erro sumir      | **Inspecionar AST, flags do padrão ISO e manpages do compilador** |
| **Comportamento de Rede** | Adicionar delays arbitrários (`sleep`)        | **Inspecionar handshakes, retornos de syscalls e headers**        |
| **Solução de Contorno**   | Mascarar erros com redirects ou shims ad-hoc  | **Sanar a causa raiz diretamente na fonte de verdade**            |

---

## 📋 Protocolo Operacional em 4 Passos

Ao investigar divergências ou incidentes técnicos em qualquer componente do ecossistema:

1. **Isolar o Sintoma & Reprodução Mínima:**
    - Capture a linha exata, o código de retorno, sinal do OS, stack trace ou chave rejeitada pelo parser.
    - Crie um caso de reprodução mínimo e determinístico sem ruídos de contexto.
2. **Consultar o Ground Truth (Fontes Primárias):**
    - Verifique a assinatura canônica de funções, tipos de dados em schemas ou contratos de chamadas na fonte oficial.
    - Em editores e ferramentas de terminal, confronte diretamente com o schema JSON/TOML distribuído pelo upstream.
3. **Diagnóstico Determinístico da Causa Raiz:**
    - Identifique por que a falha ocorre em nível estrutural antes de propor modificações.
    - Evite suposições não comprovadas por evidências mensuráveis.
4. **Resolução Estrutural Definitiva:**
    - Aplique a alteração atômica no ponto de definição canônico.
    - Garanta conformidade com as regras arquiteturais do repositório (zero shims residuais, pureza declarativa).

---

## 🔍 Diretrizes de Tom e Verificação

- **Regra:** Fundamentar correções em especificações e código-fonte oficial.
- **Evite:** Inserir chaves não documentadas ou tentar combinações sem validação de schema.
- **Use:** Verificação estática com linters e testes automatizados antes de concluir a entrega.
