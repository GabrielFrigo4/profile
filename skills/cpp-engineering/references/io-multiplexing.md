# ⚡ Multiplexação de I/O & Event Loops em C++23 (kqueue / epoll)

Este documento orienta o encapsulamento moderno de mecanismos de multiplexação de E/S orientados a objetos, combinando `kqueue` e `epoll` com lambdas e handlers desacoplados.

---

## 1. Loop de Eventos Orientado a Lambdas com `kqueue`

No FreeBSD e macOS, encapsulamos o `kqueue` em uma classe RAII que associa descritores a funções de callback:

```cpp
#if defined(__FreeBSD__) || defined(__OpenBSD__) || defined(__APPLE__)
#include <sys/types.h>
#include <sys/event.h>
#include <sys/time.h>
#include <unistd.h>
#include <functional>
#include <unordered_map>

class KqueueLoop {
private:
    int m_kq = -1;
    std::unordered_map<int, std::function<void(int)>> m_handlers;

public:
    KqueueLoop() : m_kq(::kqueue()) {}
    ~KqueueLoop() {
        if (m_kq >= 0) ::close(m_kq);
    }

    void add_read_handler(int fd, std::function<void(int)> callback) {
        struct kevent ev = {};
        EV_SET(&ev, static_cast<uintptr_t>(fd), EVFILT_READ, EV_ADD | EV_ENABLE, 0, 0, nullptr);
        ::kevent(m_kq, &ev, 1, nullptr, 0, nullptr);
        m_handlers[fd] = std::move(callback);
    }

    void run_once(int timeout_ms = -1) {
        struct timespec ts = {};
        struct timespec *pts = nullptr;
        if (timeout_ms >= 0) {
            ts.tv_sec = timeout_ms / 1000;
            ts.tv_nsec = (timeout_ms % 1000) * 1000000;
            pts = &ts;
        }

        struct kevent active_events[32] = {};
        int nev = ::kevent(m_kq, nullptr, 0, active_events, 32, pts);
        for (int i = 0; i < nev; ++i) {
            int fd = static_cast<int>(active_events[i].ident);
            if (auto it = m_handlers.find(fd); it != m_handlers.end()) {
                it->second(fd);
            }
        }
    }
};
#endif
```

---

## 2. Padrões de I/O de Alta Velocidade em C++23

1. **Zero Dynamic Allocation no Hot Path:** Use arrays e buffers estáticos ou `std::array` para a coleta de eventos ativos.
2. **Buffer Views:** Utilize `std::span<char>` ou `std::string_view` para inspecionar pacotes recebidos sem copiar memória.
3. **Tratamento de Desconexão:** Remova descritores do mapa de handlers antes de chamar `::close()`.
