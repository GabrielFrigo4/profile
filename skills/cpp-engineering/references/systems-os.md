# 🛡️ Abstrações RAII para Sistemas Operacionais (POSIX) em C++23

Este documento estabelece as diretrizes de encapsulamento RAII (_Resource Acquisition Is Initialization_) de recursos nativos de sistemas operacionais (POSIX / FreeBSD / Linux) em C++ Moderno.

---

## 1. `UniqueFd`: O Descritor de Arquivo com Destruição Determinística

Nunca utilize `int fd` diretamente no código de aplicação. Encapsule descritores em wrappers move-only que fecham automaticamente em qualquer caminho de saída ou exceção:

```cpp
#include <unistd.h>
#include <utility>

class UniqueFd {
private:
    int m_fd = -1;

public:
    constexpr UniqueFd() noexcept = default;
    explicit UniqueFd(int fd) noexcept : m_fd(fd) {}

    ~UniqueFd() noexcept {
        reset();
    }

    // Move-only: Proíbe cópia acidental de descritor
    UniqueFd(const UniqueFd &) = delete;
    UniqueFd &operator=(const UniqueFd &) = delete;

    UniqueFd(UniqueFd &&other) noexcept : m_fd(std::exchange(other.m_fd, -1)) {}
    UniqueFd &operator=(UniqueFd &&other) noexcept {
        if (this != &other) {
            reset();
            m_fd = std::exchange(other.m_fd, -1);
        }
        return *this;
    }

    [[nodiscard]] int get() const noexcept { return m_fd; }
    [[nodiscard]] bool is_valid() const noexcept { return m_fd >= 0; }

    void reset(int new_fd = -1) noexcept {
        if (m_fd >= 0) {
            ::close(m_fd);
        }
        m_fd = new_fd;
    }

    [[nodiscard]] int release() noexcept {
        return std::exchange(m_fd, -1);
    }
};
```

---

## 2. `MMapRegion`: Memória Mapeada com Desmapeamento Automático

Mapeamentos de memória via `mmap(2)` devem possuir ciclo de vida garantido por RAII:

```cpp
#include <sys/mman.h>
#include <cstddef>
#include <utility>

class MMapRegion {
private:
    void *m_addr = MAP_FAILED;
    size_t m_length = 0;

public:
    MMapRegion(void *addr, size_t length) noexcept
        : m_addr(addr), m_length(length) {}

    ~MMapRegion() noexcept {
        if (m_addr != MAP_FAILED && m_length > 0) {
            ::munmap(m_addr, m_length);
        }
    }

    MMapRegion(const MMapRegion &) = delete;
    MMapRegion &operator=(const MMapRegion &) = delete;

    MMapRegion(MMapRegion &&other) noexcept
        : m_addr(std::exchange(other.m_addr, MAP_FAILED)),
          m_length(std::exchange(other.m_length, 0)) {}

    [[nodiscard]] void *data() const noexcept { return m_addr; }
    [[nodiscard]] size_t size() const noexcept { return m_length; }
};
```

---

## 3. `ProcessGuard`: Gerenciamento Seguro de Subprocessos

Garante que processos criados por `fork()` sejam esperados via `waitpid` ou terminados com `SIGTERM` ao término do escopo da aplicação:

```cpp
#include <sys/wait.h>
#include <signal.h>
#include <utility>

class ProcessGuard {
private:
    pid_t m_pid = -1;

public:
    explicit ProcessGuard(pid_t pid) noexcept : m_pid(pid) {}

    ~ProcessGuard() noexcept {
        if (m_pid > 0) {
            ::kill(m_pid, SIGTERM);
            int status = 0;
            ::waitpid(m_pid, &status, 0);
        }
    }

    ProcessGuard(const ProcessGuard &) = delete;
    ProcessGuard &operator=(const ProcessGuard &) = delete;
};
```
