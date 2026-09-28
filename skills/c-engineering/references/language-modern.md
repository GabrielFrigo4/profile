# ⚡ Recursos Contemporâneos do C Moderno (C23)

Este documento aprofunda os recursos introduzidos pelo padrão **ISO/IEC 9899:2024 (C23)**, substituindo práticas arcaicas por garantias estáticas de compilação.

---

## 1. Tipagem e Ponteiros: `nullptr` Nativo

Substitua terminantemente a macro `NULL` ou literal `0` pela palavra-chave nativa `nullptr` (tipo `nullptr_t`). Ela é fortemente tipada e elimina ambiguidades em ponteiros e sobrecargas:

```c
// [PROIBIDO - Arcaico]
void *p = NULL;
int *q = 0;

// [OBRIGATÓRIO - C23]
void *p = nullptr;
int *q = nullptr;
```

---

## 2. Constantes em Tempo de Compilação: `constexpr` e `typeof`

Substitua macros `#define` por `constexpr` para valores numéricos e arrays imutáveis. Utilize `typeof` para inferência de tipos limpa e segura:

```c
// [PROIBIDO - Macros perigosas]
#define BUFFER_SIZE 4096

// [OBRIGATÓRIO - C23]
constexpr size_t buffer_size = 4096;
typeof(buffer_size) allocated_bytes = 0;
```

---

## 3. Aritmética Segura Contra Overflow: `<stdckdint.h>`

No C23, qualquer operação aritmética com risco de overflow de inteiros deve ser protegida por `<stdckdint.h>`. As funções usam instruções nativas da CPU e previnem **Undefined Behavior**:

```c
#include <stdckdint.h>
#include <stdint.h>

[[nodiscard]] bool safe_buffer_grow(size_t current, size_t added, size_t *out_total) {
    if (ckd_add(out_total, current, added)) {
        // Overflow detectado com segurança absoluta!
        return false;
    }
    return true;
}
```

Funções canônicas disponíveis:

- `ckd_add(result, a, b)`: Soma aritmética verificada.
- `ckd_sub(result, a, b)`: Subtração aritmética verificada.
- `ckd_mul(result, a, b)`: Multiplicação aritmética verificada.

---

## 4. Atributos Padronizados: `[[nodiscard]]` e `[[maybe_unused]]`

Exija que chamadores inspecionem retornos críticos (status de erro, ponteiros alocados, descritores):

```c
[[nodiscard]] int initialize_subsystem(void);
[[nodiscard]] void *safe_allocate(size_t count, size_t elem_size);

void handle_signal([[maybe_unused]] int sig) {
    // Parâmetro deliberadamente ignorado
}
```

---

## 5. Inicialização Limpa e Segura: `= {}`

Estruturas, buffers e uniões são inicializados integralmente com zeros usando `{}` vazio, sem sintaxes legadas `{0}` ou chamadas manuais a `memset`:

```c
struct sockaddr_storage addr = {};
int counters[64] = {};
```

---

## 6. Asserções Estáticas Nativas: `static_assert`

Valide alinhamentos e restrições arquiteturais em tempo de compilação sem macros:

```c
static_assert(sizeof(uint64_t) == 8, "uint64_t deve possuir 64 bits");
static_assert(sizeof(size_t) >= 4, "Arquitetura com espaço de memória incompatível");
```

---

## 7. Booleanos e Tipos de Largura Exata

- Palavras-chave nativas `bool`, `true` e `false` dispensam `<stdbool.h>`.
- Tipos de `<stdint.h>` (`uint32_t`, `int64_t`, `size_t`, `ssize_t`) são mandatórios contra a ambiguidade de `long` e `short`.
- `<stdbit.h>` fornece operações de contagem de bits (`stdc_count_ones`, `stdc_leading_zeros`).
