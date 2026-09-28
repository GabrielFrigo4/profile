# 🧵 Concorrência & Threads em C++ Moderno (C++20/C++23)

Este documento estabelece as diretrizes de concorrência segura, threads cooperativas com cancelamento estrito e primitivas de sincronização contemporâneas.

---

## 1. Threads com Junção Automática: `std::jthread` & `std::stop_token`

Substitua `std::thread` por `std::jthread` (C++20/C++23). Ele junta automaticamente na destruição (evitando `std::terminate`) e oferece cancelamento cooperativo nativo:

```cpp
#include <thread>
#include <chrono>
#include <print>

void background_worker(std::stop_token stoken, int id) {
    while (!stoken.stop_requested()) {
        std::println("Worker {} ativo...", id);
        std::this_thread::sleep_for(std::chrono::milliseconds(200));
    }
    std::println("Worker {} finalizado de forma limpa.", id);
}

int main() {
    // Ao sair do escopo, jthread solicita parada cooperativa e faz join()!
    std::jthread worker(background_worker, 1);
    std::this_thread::sleep_for(std::chrono::seconds(1));
    return 0;
}
```

---

## 2. Primitivas de Sincronização: `std::latch` e `std::barrier`

Para sincronizar inicialização de subsistemas ou fases de processamento sem o overhead de mutexes manuais:

```cpp
#include <latch>
#include <thread>
#include <vector>

void init_subsystems(int thread_count) {
    std::latch start_gate(thread_count);
    std::vector<std::jthread> pool;

    for (int i = 0; i < thread_count; ++i) {
        pool.emplace_back([&start_gate, i] {
            // Inicialização específica da thread...
            start_gate.count_down();
            start_gate.wait(); // Aguarda todas estarem prontas
        });
    }
}
```

---

## 3. Atômicos e Ordenação de Memória

- Utilize `std::atomic<T>` para flags de sincronização e contadores.
- Prefira `std::memory_order_relaxed` para métricas e `std::memory_order_acquire`/`release` para publicação de ponteiros/dados sem bloqueio.
