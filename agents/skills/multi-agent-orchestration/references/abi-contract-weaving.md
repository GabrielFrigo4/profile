# 🧬 Propagação Atômica de Contratos & ABI Poliglotas

> Coordenação paralela de alterações estruturais de dados entre múltiplas camadas a partir de uma Fonte Única da Verdade (SSOT).

---

## 1. Particionamento por Camada Tecnológica

Ao alterar uma entidade central de domínio (novo campo, tipo, layout binário ou enum), particione a propagação entre Workers disjuntos com `"Model": "inherit"`:

1. **Camada de Baixo Nível (`include/`, `src/core/`):** Structs nativas (C/C++/Rust) com padding explícito e serializadores binários.
2. **Camada de Persistência & API (`backend/`):** Migrações SQL declarativas e modelos/DTOs tipados.
3. **Camada de Interface & Cliente (`frontend/`):** Tipos estáticos, parsers de borda e stores reativos.
4. **Pipeline Gráfico / Shaders (`shaders/`):** Uniform/Storage Buffers com alinhamento `std140`/`std430`.
5. **Documentação & Contratos (`docs/`):** Diagramas `erDiagram` e especificações atualizadas.

---

## 2. Invariantes de Paridade & Validação Cruzada

- **Verificação Estática de Layout:** Valide tamanhos e alinhamentos via `static_assert(sizeof(...) == X)` e `offsetof` entre structs de CPU e buffers de GPU.
- **Testes Round-Trip:** Execute serialização ponta a ponta através das fronteiras (Baixo Nível $\rightarrow$ Backend $\rightarrow$ Cliente) garantindo zero truncamento ou divergência de endianness.
- **Atomicidade Transversal:** Integre todas as camadas somente após todas compilarem e passarem nos testes conjuntos.

---

## 3. Template de Propagação de Contrato

```markdown
### CONTRATO DE PROPAGAÇÃO DE ABI [WEAVE-ID]

- **Fonte da Verdade (SSOT):** `contracts/entidade.spec.md`
- **Alocação de Modelo:** inherit
- **Alteração Solicitada:** [Descrição do campo, tipo e alinhamento]
- **Worker 1 (Low-Level):** `include/types.h`
- **Worker 2 (Backend):** `backend/models/`
- **Worker 3 (Frontend):** `frontend/src/types/`
- **Worker 4 (Shaders):** `shaders/include/ubo_layout.glsl`
- **Worker 5 (Docs):** `docs/contracts.md`
```
