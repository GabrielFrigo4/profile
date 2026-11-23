---
name: crossplatform-systems
description: >-
    Portabilidade multiplataforma entre FreeBSD, Linux, macOS, OpenBSD, illumos e
    Windows MSYS2, cobrindo neutralidade de init, multiplexação kqueue/epoll, PTY
    defensivo em CI headless, consoles virtuais e diagnósticos operacionais de sistema.
---

# 🌐 Cross-Platform Systems & Operational Diagnostics

Diretrizes para automação, portabilidade entre sistemas operacionais UNIX/POSIX e diagnóstico de saúde operacional de estações e servidores sem dependências proprietárias.

---

## 🧭 1. Matriz de Paridade Multiplataforma

| Plataforma        | Primitivas de Kernel & Eventos        | Userland, Init & Pacotes                                            |
| :---------------- | :------------------------------------ | :------------------------------------------------------------------ |
| **FreeBSD**       | `kqueue(2)` / `kevent(2)`, `vt(4)`    | Base coesa (`/usr/local`), `rc.d`/`sysrc`, `pkg`, `flua`            |
| **Linux**         | `epoll(7)`, `io_uring`, `fbcon`       | Neutralidade PID 1 (`systemd`, SysVinit, OpenRC, `runit`), `udev`   |
| **macOS**         | `kqueue(2)`, Mach                     | Apple Clang, userland BSD, Homebrew (`/opt/homebrew`, `/usr/local`) |
| **OpenBSD**       | `kqueue(2)`, `pledge(2)`, `unveil(2)` | `/bin/ksh`, `doas`, `pf(4)`, `wscons(4)`                            |
| **illumos**       | `port_create(3C)`, DTrace             | Solaris Zones, Crossbow VNICs, SMF                                  |
| **Windows MSYS2** | Subsistema `UCRT64`, symlinks nativos | Finais de linha UNIX (`LF`) e ferramentas POSIX                     |

- Arquitetura detalhada FreeBSD (tracks, base vs `/usr/local`, `flua`, OCI `runj`): [`references/freebsd-architecture.md`](references/freebsd-architecture.md).

---

## 🚦 2. TTY & CI Headless (`script -q /dev/null`)

Em runners sem PTY controlador, shells interativos (`-i`) disparam `tcsetpgrp()`. No FreeBSD isso envia `SIGTTIN` (sinal `21`) e suspende o processo (`SIGSTOP`).

```sh
script -q /dev/null bash -i -c 'echo "Prompt OK: ${PS1}"'
```

- Detalhes de kernel e alternativas (`bash +m -i`, guarda interativa): [`references/tty-ci-traps.md`](references/tty-ci-traps.md).
- Comparativo de consoles virtuais (`fbcon` 63 VTs vs `vt(4)` 16 VTs vs `wscons(4)`), F1–F4 e leitores framebuffer: [`references/virtual-consoles-tty.md`](references/virtual-consoles-tty.md).

---

## 🩺 3. Diagnóstico Operacional (Rootless)

```sh
echo "Sessão: ${XDG_SESSION_TYPE:-desconhecido} | Wayland: ${WAYLAND_DISPLAY:-nenhum}"
if command -v vainfo > "/dev/null" 2>&1; then
	vainfo
elif [ -e "/dev/dri/renderD128" ]; then
	echo "DRM Render ativo"
fi
if command -v pactl > "/dev/null" 2>&1; then
	pactl info | grep -E "Server Name|Server Version" || true
fi
echo "Descritores: $(ulimit -n) | Eventos: $([ "$(uname -s)" = "Linux" ] && echo "epoll" || echo "kqueue")"
vmstat 1 2 2> "/dev/null" || sar 1 2 2> "/dev/null" || uptime
ip -brief address 2> "/dev/null" || ifconfig -a 2> "/dev/null" || netstat -in
```

---

## 🛠️ 4. Regras Transversais de Portabilidade

1. **Shebang & Makefiles:** `#!/usr/bin/env sh` / `#!/usr/bin/env python3`; Makefiles `.POSIX: .SILENT:` com `MAKEFLAGS += --no-print-directory -s` e `(cd dir && $(MAKE) target)`.
2. **Degradação Graciosa:** Diagnósticos operam sem privilégios administrativos (`$HOME`) e protegem redirecionamentos com aspas (`> "/dev/null" 2>&1`).
3. **Permissões Octais:** `0755` para executáveis, `0644` para configurações e `0700`/`0600` para segredos.

---

## 🔗 5. Referências Oficiais

- **The FreeBSD Project:** <https://www.freebsd.org/> | <https://man.freebsd.org/>
- **Wayland & PipeWire:** <https://wayland.freedesktop.org/> | <https://pipewire.org/>
- **Mesa 3D & OpenBSD:** <https://www.mesa3d.org/> | <https://www.openbsd.org/>
