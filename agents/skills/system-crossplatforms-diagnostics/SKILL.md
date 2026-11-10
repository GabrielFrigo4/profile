---
name: system-crossplatforms-diagnostics
description: Runbook cognitivo definitivo para governança de repositórios multiplataforma (FreeBSD, Linux, macOS, OpenBSD, illumos, Windows MSYS2) e diagnóstico de saúde operacional de sistemas (Wayland, VA-API, PipeWire, kqueue/epoll, memória e conectividade).
---

# 🌐 System Cross-Platforms & Operational Diagnostics

Esta habilidade orienta o agente no design, automação, portabilidade multiplataforma e diagnóstico profundo de saúde de estações de trabalho e ambientes de produção UNIX/POSIX.

---

## 🧭 As Três Dimensões da Portabilidade

1. **Repositório Multiplataforma (Build & Dev Tooling):** Makefiles, githooks e scripts de setup operam de forma transparente em qualquer sistema suportado sem utilitários proprietários.
2. **Produto Final Multiplataforma (Artifact / Release):** O artefato (binário executável, biblioteca ou script) executa com estabilidade nos sistemas de destino.
3. **Ambos Multiplataforma (O Padrão Ouro do Ecossistema):** Compilação e execução são estritamente universais e agnósticas de plataforma.

---

## 🏛️ Matriz de Paridade Multiplataforma

### 🔴 1. FreeBSD (14/15/16 CURRENT, STABLE & RELEASE)

- Kernel e userland formam base coesa. Padrão ouro de aderência POSIX e régua máxima de portabilidade.
- Multiplexação escalável via `kqueue(2)` / `kevent(2)`. Serviços via `rc.d`/`sysrc`, console em `vt(4)` e pacotes via `pkg`.
- Arquitetura base, `flua`, Jails e Sylve: [`references/freebsd-architecture.md`](./references/freebsd-architecture.md).
- DRM, LinuxKPI, GPU Intel Alder Lake e Gestão de Memória: [`references/freebsd-gpu-memory.md`](./references/freebsd-gpu-memory.md).

### 🐧 2. Linux (Neutralidade de Init: Systemd, SysVinit, OpenRC & runit)

- Multiplexação de E/S via `epoll(7)` e subsistema de eventos via `io_uring`.
- Neutralidade de PID 1: suporte a Debian/Systemd, Devuan/SysVinit, Alpine/Gentoo/OpenRC e Void/runit.
- Regras de hardware via `udev`/`eudev` em `/etc/udev/rules.d/` para independência de init.

### 🍎 3. macOS (Darwin / Mach / BSD Userland)

- Apple Clang padrão; userland BSD clássica (`sed`, `grep`, `tar` sem GNUismos); suporte a `kqueue(2)`.
- Resolução de prefixos: Homebrew ARM (`/opt/homebrew`), Intel (`/usr/local`), MacPorts (`/opt/local`).

### 🪟 4. Windows & MSYS2

- Subsistema MSYS2 com toolchain moderna `UCRT64` e finais de linha estritamente UNIX (`LF`).

### 🐡 5. OpenBSD & illumos

- **OpenBSD:** Mitigações `pledge(2)`/`unveil(2)`, firewall `pf(4)` e shell `/bin/ksh` com elevação via `doas`.
- **illumos (SmartOS/OmniOS):** Event ports (`port_create(3C)`), Solaris Zones e DTrace.

---

## 🚦 TTY & CI Headless: Padrão PTY (`script -q /dev/null`)

Em runners headless de CI/CD (GitHub Actions, SSH sem PTY), shells interativos acionam `tcsetpgrp()`. Enquanto no Linux a syscall retorna erro ignorável, no kernel FreeBSD dispara `SIGTTIN` (sinal 21), congelando o processo em `SIGSTOP`.

- Alocação PTY Defensiva: `script -q /dev/null bash -i -c 'echo "Prompt OK: ${PS1}"'`
- Detalhes de TTY e traps: [`references/tty-ci-traps.md`](./references/tty-ci-traps.md) e [`references/virtual-consoles-tty.md`](./references/virtual-consoles-tty.md).

---

## 🩺 Diagnóstico de Saúde Operacional de Sistemas

```sh
echo "Sessão: ${XDG_SESSION_TYPE:-desconhecido} | Wayland: ${WAYLAND_DISPLAY:-nenhum}"
command -v vainfo > "/dev/null" 2>&1 && vainfo || [ -e "/dev/dri/renderD128" ] && echo "DRM Render ativo"
command -v pactl > "/dev/null" 2>&1 && pactl info | grep -E "Server Name|Server Version"
echo "Descritores: $(ulimit -n) | Eventos: $([ "$(uname -s)" = "Linux" ] && echo "epoll" || echo "kqueue")"
vmstat 1 2 2> "/dev/null" || sar 1 2 2> "/dev/null" || uptime
ip -brief address 2> "/dev/null" || ifconfig -a 2> "/dev/null" || netstat -in
```

---

## 🛠️ Regras Canônicas Multiplataforma

1. **Shebang Universal:** `#!/usr/bin/env sh` para shell scripts e `#!/usr/bin/env python3` para Python.
2. **Makefiles Universais:** Cabeçalho `.POSIX: .SILENT:`, `MAKEFLAGS += --no-print-directory -s`, `(cd dir && $(MAKE) target)`.
3. **Zero-Sudo e Zero-Bypass:** Diagnósticos operam no espaço de usuário (`$HOME`), degradando graciosamente.
4. **Permissões Canônicas Octais:** `0755` para executáveis, `0644` para configurações e `0700`/`0600` para segredos.
5. **Redirecionamento Seguro:** Aspas duplas em destinos (ex: `> "/dev/null" 2>&1`).

---

## 🔗 Links Oficiais de Referência

- **The FreeBSD Project:** <https://www.freebsd.org/> | Releases: <https://www.freebsd.org/releases/>
- **Wayland Protocol Architecture:** <https://wayland.freedesktop.org/>
- **PipeWire Multimedia Daemon:** <https://pipewire.org/>
- **Mesa 3D Graphics & Video Acceleration (VA-API):** <https://www.mesa3d.org/>
- **OpenBSD Project & PF FAQ:** <https://www.openbsd.org/> | <https://www.openbsd.org/faq/pf/>
