# ⚡ Multiplexação de I/O & Event Loops em C (kqueue / epoll / poll)

Este documento orienta a implementação de loops de eventos de altíssima performance e baixa latência em C Moderno, cobrindo as interfaces nativas dos kernels BSD e Linux.

---

## 1. `kqueue(2)` — O Padrão Canônico no FreeBSD, macOS e OpenBSD

O `kqueue` é uma das interfaces de notificação de eventos mais elegantes e eficientes da história do UNIX. Permite monitorar sockets, timers, sinais e processos com descritores unificados:

```c
#if defined(__FreeBSD__) || defined(__OpenBSD__) || defined(__APPLE__)
#include <sys/types.h>
#include <sys/event.h>
#include <sys/time.h>

[[nodiscard]] int register_read_event(int kq, int target_fd) {
    struct kevent change = {};
    EV_SET(&change, (uintptr_t)target_fd, EVFILT_READ, EV_ADD | EV_ENABLE, 0, 0, nullptr);

    if (kevent(kq, &change, 1, nullptr, 0, nullptr) == -1) {
        return -1;
    }
    return 0;
}

void event_loop(int kq) {
    struct kevent events[64] = {};
    while (true) {
        int nev = kevent(kq, nullptr, 0, events, 64, nullptr);
        if (nev < 0) {
            if (errno == EINTR) continue;
            break;
        }
        for (int i = 0; i < nev; i++) {
            int fd = (int)events[i].ident;
            // Processar leitura não-bloqueante no descritor fd
        }
    }
}
#endif
```

---

## 2. `poll(2)` — O Baseline Portátil POSIX.1-2024

Para ferramentas de linha de comando ou utilitários que devem compilar de forma 100% agnóstica sem `#ifdef` de kernel:

```c
#include <poll.h>
#include <errno.h>

[[nodiscard]] int wait_for_read(int fd, int timeout_ms) {
    struct pollfd pfd = {
        .fd = fd,
        .events = POLLIN,
        .revents = 0
    };

    while (true) {
        int ret = poll(&pfd, 1, timeout_ms);
        if (ret < 0 && errno == EINTR) continue;
        return ret;
    }
}
```

---

## 3. Diretrizes de Performance para Event Loops em C

1. **Sockets Non-Blocking:** Sempre configure `O_NONBLOCK` via `fcntl(fd, F_SETFL, flags | O_NONBLOCK)`.
2. **Buffer Alignment:** Alinhe buffers de leitura com o tamanho de bloco do sistema (4096 bytes).
3. **Tratamento de `EAGAIN` e `EWOULDBLOCK`:** Ao ler em loop até esgotar, encerre o ciclo de leitura ao receber `EAGAIN` sem considerar erro fatal.
