# 🧵 Concorrência & Threads em C Moderno (Pthreads & Atomics)

Este documento estabelece as diretrizes de concorrência defensiva, sincronização livre de deadlocks e operações atômicas em C23.

---

## 1. Mutexes com Detecção de Erros (`PTHREAD_MUTEX_ERRORCHECK`)

Mutexes padrão (`PTHREAD_MUTEX_NORMAL`) causam undefined behavior ou deadlocks silenciosos se uma thread tentar bloquear duas vezes ou se outra thread liberar um lock que não lhe pertence. Em ambientes de engenharia defensiva, inicialize com atributo de checagem de erros:

```c
#include <pthread.h>
#include <stdio.h>

[[nodiscard]] int init_safe_mutex(pthread_mutex_t *mtx) {
    pthread_mutexattr_t attr;
    if (pthread_mutexattr_init(&attr) != 0) return -1;
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_ERRORCHECK);

    int res = pthread_mutex_init(mtx, &attr);
    pthread_mutexattr_destroy(&attr);
    return res;
}
```

---

## 2. Aritmética e Flags Atômicas: `<stdatomic.h>`

No C23, utilize atômicos padronizados para contadores e flags de estado sem o custo de um mutex:

```c
#include <stdatomic.h>
#include <stdint.h>
#include <stdbool.h>

typedef struct {
    atomic_uint_fast64_t request_counter;
    atomic_bool is_shutdown;
} ServerMetrics;

void record_request(ServerMetrics *m) {
    atomic_fetch_add_explicit(&m->request_counter, 1, memory_order_relaxed);
}

bool check_shutdown(const ServerMetrics *m) {
    return atomic_load_explicit(&m->is_shutdown, memory_order_acquire);
}
```

---

## 3. Diretrizes de Prevenção de Deadlock

1. **Ordem Estrita de Aquisição:** Se dois mutexes precisarem ser travados simultaneamente, sempre adquira-os na mesma ordem hierárquica por ponteiro (`if (m1 < m2)`).
2. **Escopo Mínimo de Lock:** Nunca execute operações bloqueantes de I/O ou chamadas de sistema longas segurando um mutex.
3. **Condition Variables com While Loop:** Sempre cheque predicados de variáveis de condição dentro de um `while`, nunca de um `if`, para proteger contra despertares espúrios (_spurious wakeups_).
