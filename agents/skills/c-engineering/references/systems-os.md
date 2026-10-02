# 🌐 Engenharia de Sistemas POSIX.1-2024 / FreeBSD / Linux

Este documento estabelece as diretrizes de baixo nível para programação de sistemas robusta, segura e auditável em **C Moderno (C23)** sobre plataformas **POSIX.1-2024**.

---

## 1. Descritores de Arquivo Defensivos (`O_CLOEXEC`)

Em sistemas multithread e multiprocesso, descritores de arquivo devem ser abertos com flags atômicas que impeçam vazamentos de herança via `fork()`/`exec()` e ataques de symlink:

```c
#include <fcntl.h>
#include <unistd.h>

[[nodiscard]] int safe_open_file(const char *path) {
    if (path == nullptr) return -1;

    // O_CLOEXEC: fecha automaticamente em execve()
    // O_NOFOLLOW: rejeita links simbólicos contra race conditions
    int fd = open(path, O_RDONLY | O_CLOEXEC | O_NOFOLLOW);
    return fd;
}
```

Ao operar em diretórios, prefira a família `*at()` (`openat`, `fstatat`, `unlinkat`), ancorando operações em um `dirfd` e eliminando TOCTOU (_Time-of-Check to Time-of-Use_).

---

## 2. Gerenciamento Seguro de Processos e Zumbis

Sempre colha processos-filhos de forma assíncrona utilizando `sigaction` e `waitpid` não-bloqueante (`WNOHANG`), prevenindo esgotamento de PID na tabela do kernel:

```c
#include <signal.h>
#include <sys/wait.h>

void setup_child_reaper(void) {
    struct sigaction sa = {};
    sa.sa_handler = [](int sig) {
        [[maybe_unused]] int status;
        while (waitpid(-1, &status, WNOHANG) > 0) {}
    };
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_RESTART | SA_NOCLDSTOP;
    sigaction(SIGCHLD, &sa, nullptr);
}
```

---

## 3. Substituição de Funções Vulneráveis da libc

Evite o uso de APIs obsoletas sem verificação de limites:

- `gets()`: Banida da especificação (substitua por `fgets` ou `getline`).
- `strcpy()` e `strcat()`: Inseguras (use `snprintf` ou cálculo manual de buffers).
- `sprintf()`: Risco de buffer overflow (substitua por `snprintf`).

```c
// [Padrão seguro e defensivo]
char buffer[256] = {};
int written = snprintf(buffer, sizeof(buffer), "User: %s, UID: %d", username, uid);
if (written < 0 || (size_t)written >= sizeof(buffer)) {
    // Tratar truncamento ou falha de codificação
}
```

---

## 4. Limpeza Automática de Recursos via Atributos

Em compiladores Clang e GCC modernos, utilize `__attribute__((cleanup))` para emular RAII defensivo em C:

```c
static inline void auto_close_fd(int *fd) {
    if (fd != nullptr && *fd >= 0) {
        close(*fd);
        *fd = -1;
    }
}

#define auto_fd __attribute__((cleanup(auto_close_fd)))

void process_data(const char *path) {
    auto_fd int fd = open(path, O_RDONLY | O_CLOEXEC);
    if (fd < 0) return;
    // O descritor é fechado garantidamente ao sair do escopo!
}
```
