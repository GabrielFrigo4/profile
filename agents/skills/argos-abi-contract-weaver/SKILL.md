---
name: argos-abi-contract-weaver
description: >-
    Runbook cognitivo para o GM Argos orquestrar a propagação atômica e paralela de
    esquemas e contratos ABI através de stacks poliglotas, sincronizando structs C23,
    migrações Go SQLite, stores Svelte e shaders GLSL.
---

# 🧬 Tecelão de Contratos Poliglotas & ABI (GM Argos)

Diretrizes operacionais para o **GM Argos** propagar alterações de esquemas estruturais de dados de forma atômica e sincronizada por todas as camadas de uma arquitetura poliglota.

---

## 🏛️ 1. O Desafio da Fronteira Poliglota

Em sistemas híbridos de alta performance, uma alteração em uma entidade de domínio (ex.: novo campo de telemetria, timestamp ou enum de estado) requer sincronização exata em múltiplas linguagens e subsistemas:

1. **Baixo Nível:** Structs empacotadas C23/C++23 com padding canônico e layouts de memória.
2. **Persistência & Backend:** Migrações SQL (SQLite WAL) e modelos relacionais em Go/PocketBase.
3. **Frontend Reativo:** Types/interfaces TypeScript e stores reativos SvelteKit 5 Runes.
4. **Pipeline Gráfico:** Estruturas `std140`/`std430` de Uniform Buffer Objects (UBO) em GLSL.
5. **Documentação:** Diagramas de entidade-relacionamento (ER) Mermaid e especificações de API.

---

## 🧵 2. Particionamento por Camadas Tecnológicas (Pool <= 5)

A partir de um Contrato Canônico Único (SSOT — _Single Source of Truth_), o GM Argos instancia até **5 Slaves Flash concorrentes** em escopos estritamente desacoplados:

- **Slave 1 (Sistemas / Low-Level):**
    - _Escopo:_ `include/` e `src/core/`.
    - _Entrega:_ Definições de struct em C23 (`#pragma pack` ou alinhamento natural), serializers e deserializers binários.
- **Slave 2 (Backend / Persistência):**
    - _Escopo:_ `backend/migrations/` e `backend/models/`.
    - _Entrega:_ Migrações declarativas SQL e bindings correspondentes em Go.
- **Slave 3 (Frontend / UI):**
    - _Escopo:_ `frontend/src/lib/types/` e `frontend/src/lib/stores/`.
    - _Entrega:_ Interfaces TypeScript, parsers de validação e stores Svelte 5 (`$state`).
- **Slave 4 (Shaders / Gráficos):**
    - _Escopo:_ `shaders/include/` e buffers gráficos.
    - _Entrega:_ Uniform Buffers com cálculo rigoroso de alinhamento `std140` (vec4 padding).
- **Slave 5 (Documentação / Auditoria):**
    - _Escopo:_ `docs/` e `README.md`.
    - _Entrega:_ Diagramas Mermaid `erDiagram` atualizados e documentação das alterações de ABI.

---

## 🔒 3. Invariante de Paridade & Validação Cruzada

O GM Argos só considera a tecelagem concluída quando todas as camadas compilam e passam nos testes de integração:

1. **Validação de Tamanhos de Struct:** Verificação via `static_assert(sizeof(...) == X)` para garantir alinhamento idêntico entre C23 e buffers GLSL.
2. **Serialização Round-Trip:** Teste de ida e volta (C23 $\rightarrow$ Go $\rightarrow$ TypeScript) para verificar se nenhum byte é corrompido na fronteira.
3. **Commit Atômico Transversal:** Todas as camadas são mescladas em um único commit Git semanticamente consistente.

---

## ⚖️ 4. Diretrizes Imperativas (DOs & DON'Ts)

| Prática   | Diretiva Operacional                                                                |
| :-------- | :---------------------------------------------------------------------------------- |
| **DO**    | Particione cada linguagem ou camada para um worker Flash diferente.                 |
| **DO**    | Use uma Fonte Canônica da Verdade (SSOT) para derivar todas as alterações.          |
| **DO**    | Adicione `static_assert` para verificar tamanhos e alinhamentos de memória binária. |
| **DO**    | Execute testes de serialização cruzada antes de finalizar a orquestração.           |
| **DON'T** | Não permita que um worker edite arquivos fora de sua camada tecnológica atribuída.  |
| **DON'T** | Não deixe camadas dessincronizadas em commits separados; propague de forma atômica. |
| **DON'T** | Não ignore diferenças de padding e endianness entre CPU e GPU (GLSL `std140`).      |

---

## 📋 5. Template de Invocação de Propagação de Contrato

```markdown
### CONTRATO DE PROPAGAÇÃO DE ABI [WEAVE-ID]

- **Fonte da Verdade (SSOT):** `contracts/entidade.spec.md`
- **Alteração Solicitada:** [Ex.: Adição de campo `timestamp_ns` de 64 bits]
- **Worker 1 (C23):** `include/types.h`
- **Worker 2 (Go/SQL):** `backend/migrations/` e `backend/models/`
- **Worker 3 (Svelte):** `frontend/src/types/`
- **Worker 4 (GLSL):** `shaders/common.glsl`
- **Worker 5 (Docs):** `docs/architecture.md`
```
