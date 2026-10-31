---
name: clean-break-refactoring
description: >-
    Runbook cognitivo para refatorações atômicas e definitivas sem legado no ecossistema soberano.
    Usar ao renomear variáveis, comandos, receitas ou infraestrutura, eliminando
    shims de transição, aliases obsoletos e débitos técnicos em ambientes monousuário.
---

# ⚡ Clean-Break Refactoring — Refatoração Sem Legado

> _"Perfection is achieved, not when there is nothing more to add, but when there is nothing left to take away."_<br>
> — Antoine de Saint-Exupéry, _Terre des hommes_ (1939)

Esta skill estabelece os protocolos de refatoração para o **Universal Environment** e o ecossistema soberano. Por ser um ambiente estritamente monousuário e governado por um único desenvolvedor soberano, introduzir shims de retrocompatibilidade, aliases de transição ou fallbacks de variáveis obsoletas constitui débito técnico injustificado e poluição de código.

---

## 🏛️ O Princípio da Soberania Monousuário

Diferente de bibliotecas públicas governadas por versionamento semântico (`semver`), que demandam ciclos de depreciação e advertências de runtime, a governança soberana exige substituição atômica:

- **Software público:** Renomear $\rightarrow$ Manter alias legado $\rightarrow$ Emitir deprecation warning $\rightarrow$ Expurgo em versão futura.
- **Ecossistema soberano:** Decisão $\rightarrow$ Renomeação global atômica $\rightarrow$ Expurgo imediato de shims $\rightarrow$ Base pura e sem ruído.

---

## ⚖️ Matriz de Decisão: Manutenção vs. Expurgo

| Dimensão                  | Software Público / Multi-Usuário    | Ecossistema Soberano                                       |
| :------------------------ | :---------------------------------- | :--------------------------------------------------------- |
| **Público-Alvo**          | Consumidores externos desconhecidos | Usuário único soberano                                     |
| **Custo de Shims**        | Aceitável para prevenir rupturas    | Inadmissível: polui o namespace e duplica pontos de falha  |
| **Aliases de Transição**  | Mantidos temporariamente            | **Eliminados sumariamente**                                |
| **Variáveis Antigas**     | Fallback em cascata                 | **Removidas de imediato**                                  |
| **Comentários de Código** | Marcadores de descontinuação        | **Vedados:** nada de notas históricas como `(antigo nome)` |
| **Postura do Agente**     | Preservação de compatibilidade      | **Execução de Clean Break atômico e direto**               |

---

## 📋 Checklist Operacional de Execução

Ao receber instruções para renomear variáveis, arquivos, rotas ou utilitários:

1. **Variáveis de Ambiente:**
    - Atualize os arquivos de ambiente canônicos (`hosts.env`, configs, loaders).
    - Não crie aliases como `VAR_ANTIGA="${VAR_NOVA}"`.
    - Remova fallbacks encadeados (`${VAR_NOVA:-${VAR_ANTIGA}}`). Utilize apenas `${VAR_NOVA:-default}`.
2. **Aliases e Funções de Terminal:**
    - Declare exclusivamente o comando novo nos shells suportados (POSIX `sh`, Bash, Zsh, PowerShell, NuShell, Clink).
    - Não crie aliases de equivalência como `alias antigo=novo`.
3. **Chaves e Arquivos Criptográficos:**
    - Mova os artefatos com `git mv` no repositório canônico (`Vault/keys/`).
    - Atualize a rotina de busca para validar apenas o identificador vigente.
    - Remova artefatos residuais em diretórios de runtime.
4. **Infraestrutura e Diretórios:**
    - Renomeie diretórios diretamente com `git mv`.
    - Ajuste chamadas de provisionamento e documentação sem marcadores de nomes passados.
5. **Auditoria de Conclusão:**
    - Realize varredura completa com `rg` para garantir zero menções ao termo antigo.
    - Execute `make audit` para confirmar conformidade dos testes estáticos.
