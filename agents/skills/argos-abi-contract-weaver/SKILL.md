---
name: argos-abi-contract-weaver
description: >-
    Runbook cognitivo para o Master Orchestrator (Planner Agent) orquestrar
    a propagação atômica e paralela de esquemas e contratos ABI através de stacks poliglotas,
    sincronizando structs C23, migrações Go SQLite, stores Svelte e shaders GLSL.
---

# 🧬 Tecelão de Contratos Poliglotas & ABI

Diretrizes operacionais para o **Master Orchestrator** (_Planner Agent_) propagar alterações de esquemas estruturais de dados de forma atômica e sincronizada por todas as camadas de uma arquitetura poliglota, coordenando **Specialist Sub-Agents** (_Execution Workers_).

---

## 🏛️ 1. O Desafio da Fronteira Poliglota

Em sistemas híbridos de alta performance, uma alteração em uma entidade de domínio (ex.: novo campo de telemetria, timestamp ou enum de estado) requer sincronização exata em múltiplas linguagens e subsistemas:

1. **Baixo Nível:** Structs empacotadas C23/C++23 com padding canônico e layouts de memória.
2. **Persistência & Backend:** Migrações SQL (SQLite WAL) e modelos relacionais em Go/PocketBase.
3. **Frontend Reativo:** Types/interfaces TypeScript e stores reativos SvelteKit 5 Runes.
4. **Pipeline Gráfico:** Estruturas `std140`/`std430` de Uniform Buffer Objects (UBO) em GLSL.
5. **Documentação:** Diagramas de entidade-relacionamento (ER) Mermaid e especificações de API.

---

## 🧵 2. Particionamento por Camadas Tecnológicas (Pool 2 a 8 Workers)

A partir de um Contrato Canônico Único (SSOT — _Single Source of Truth_), o Master instancia uma frota dinâmica de **2 a 8 Execution Workers concorrentes** (operando tipicamente com 4 Workers em paridade via `Model: 'inherit'`) em escopos estritamente desacoplados:

- **Worker 1 (Sistemas / Low-Level):**
    - _Escopo:_ `include/` e `src/core/`.
    - _Entrega:_ Definições de struct em C23 (`#pragma pack` ou alinhamento natural), serializers e deserializers binários.
- **Worker 2 (Backend / Persistência):**
    - _Escopo:_ `backend/migrations/` e `backend/models/`.
    - _Entrega:_ Migrações declarativas SQL e bindings correspondentes em Go.
- **Worker 3 (Frontend / UI):**
    - _Escopo:_ `frontend/src/lib/types/` e `frontend/src/lib/stores/`.
    - _Entrega:_ Interfaces TypeScript, parsers de validação e stores Svelte 5 (`$state`).
- **Worker 4 (Shaders / Gráficos):**
    - _Escopo:_ `shaders/include/` e buffers gráficos.
    - _Entrega:_ Uniform Buffers com cálculo rigoroso de alinhamento `std140` (vec4 padding).
- **Worker 5 (Documentação / Auditoria):**
    - _Escopo:_ `docs/` e `README.md`.
    - _Entrega:_ Diagramas Mermaid `erDiagram` atualizados e documentação das alterações de ABI.

### Invariante de Spawn & Interdição de Swarm

- **Herança Dinâmica de Modelo:** Cada _Execution Worker_ deve ser invocado com `Model: 'inherit'` declarado no payload JSON de `invoke_subagent` para paridade com o modelo ativo da sessão (ou tier rápido nativo do runtime, sem hardcode de versão ou tier).
- **Interdição de Swarm e Cron:** A sincronização opera via subagentes pontuais com contratos isolados. É vedado o uso da ferramenta `swarm` e de polling via `schedule`.

---

## 🔒 3. Invariante de Paridade & Validação Cruzada

O Master só considera a tecelagem concluída quando todas as camadas compilam e passam nos testes de integração:

1. **Validação de Tamanhos de Struct:** Verificação via `static_assert(sizeof(...) == X)` para garantir alinhamento idêntico entre C23 e buffers GLSL.
2. **Serialização Round-Trip:** Teste de ida e volta (C23 $\rightarrow$ Go $\rightarrow$ TypeScript) para verificar se nenhum byte é corrompido na fronteira.
3. **Commit Atômico Transversal:** Todas as camadas são mescladas em um único commit Git semanticamente consistente.

---

## ⚖️ 4. Diretrizes Imperativas (DOs & DON'Ts)

| Prática   | Diretiva Operacional                                                                                |
| :-------- | :-------------------------------------------------------------------------------------------------- |
| **DO**    | Particione cada linguagem ou camada para um worker diferente.                                       |
| **DO**    | Declare `Model: 'inherit'` (ou tier rápido nativo do runtime) no payload JSON de `invoke_subagent`. |
| **DO**    | Use uma Fonte Canônica da Verdade (SSOT) para derivar todas as alterações.                          |
| **DO**    | Adicione `static_assert` para verificar tamanhos e alinhamentos de memória binária.                 |
| **DO**    | Execute testes de serialização cruzada antes de finalizar a orquestração.                           |
| **DON'T** | Não faça hardcode de nomes, versões ou tiers específicos de modelo na chamada da tool.              |
| **DON'T** | Não use `swarm` nativo ou monitoramento via cron (`schedule`).                                      |
| **DON'T** | Não permita que um worker edite arquivos fora de sua camada tecnológica atribuída.                  |
| **DON'T** | Não deixe camadas dessincronizadas em commits separados; propague de forma atômica.                 |
| **DON'T** | Não ignore diferenças de padding e endianness entre CPU e GPU (GLSL `std140`).                      |

---

## 📋 5. Template de Invocação de Propagação de Contrato

```markdown
### CONTRATO DE PROPAGAÇÃO DE ABI [WEAVE-ID]

- **Fonte da Verdade (SSOT):** `contracts/entidade.spec.md`
- **Alocação de Modelo:** inherit (herança dinâmica do modelo ativo da sessão ou tier rápido nativo)
- **Alteração Solicitada:** [Ex.: Adição de campo `timestamp_ns` de 64 bits]
- **Worker 1 (C23):** `include/types.h`
- **Worker 2 (Go):** `backend/models/types.go`
- **Worker 3 (TypeScript):** `frontend/src/lib/types/index.ts`
- **Worker 4 (GLSL):** `shaders/include/ubo_layout.glsl`
- **Worker 5 (Docs):** `docs/architecture/contracts.md`
- **Circuit Breaker:** Teto de 20 chamadas de ferramenta; interrompa em caso de bloqueio.
```
