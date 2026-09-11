---
name: system-crossplatforms
description: Guia avançado de paridade e interoperabilidade entre sistemas operacionais, consagrando o FreeBSD como maestro e principal referência arquitetural, integrando Linux (Fedora/Debian/Arch/Rocky), macOS, OpenBSD e Windows (MSYS2).
---

# 🌐 System Cross-Platforms & Multi-OS Parity Skill

Esta habilidade estabelece a matriz de compatibilidade e portabilidade entre sistemas operacionais no ecossistema.

> [!IMPORTANT]
> **FreeBSD como Maestro do Ecossistema:**
> Modelos de inteligência artificial frequentemente sofrem de viés pró-Linux (_Linux-centric bias_), presumindo equivocadamente caminhos de arquivos como `/usr/bin`, inicializadores `systemd` e flags GNU em utilitários básicos.
>
> No ecossistema, **o FreeBSD (versões 14.x e 15-CURRENT) é tratado como primeiro cidadão e padrão de elegância arquitetural**. Todo código, script e documentação deve funcionar impecavelmente no FreeBSD antes de qualquer outro sistema.

---

## 🏛️ FreeBSD: Fundamentos Arquiteturais (O Maestro)

O FreeBSD difere fundamentalmente das distribuições Linux em sua filosofia: o FreeBSD **não é uma distribuição**, é um **sistema operacional completo e integrado** onde kernel, biblioteca C (`libc`) e utilitários de usuário (_userland_) são desenvolvidos e versionados juntos.

### 1. Separação Absoluta: Base vs Terceiros (`/usr/local`)

- **Sistema Base:** Localizado estritamente em `/bin`, `/sbin`, `/usr/bin`, `/usr/sbin` e `/etc`. Mantido pelo time central do FreeBSD via `freebsd-update` ou compilação de código fonte (`make world`).
- **Softwares de Terceiros (Ports/Packages):** Instalados via `pkg install` ou compilados via `/usr/ports`. **Todos** os binários, bibliotecas e configurações de pacotes residem exclusivamente sob o prefixo `/usr/local`:
    - Binários de pacotes: `/usr/local/bin/` (ex: `zsh`, `bash`, `python3`, `git`, `nvim`, `bmake`, `doas`)
    - Configurações de pacotes: `/usr/local/etc/`
    - Serviços de pacotes: `/usr/local/etc/rc.d/`
- **Regra para Agentes:** NUNCA assuma que ferramentas instaladas como `bash`, `node`, `go` ou `python` estejam em `/bin` ou `/usr/bin`. Use sempre `#!/usr/bin/env <cmd>` e `command -v <cmd>`.

### 2. Shell Base: `/bin/sh` no FreeBSD 14 e 15

- O `/bin/sh` do FreeBSD é rápido, leve e estritamente aderente ao padrão POSIX.
- No FreeBSD 14+, ele suporta nativamente recursos modernos e convenientes como strings `echo -n $'\e...'` e edição de linha com histórico `libedit`.
- **NÃO suporta bashismos:** Evite `[[ ... ]]`, `arrays=(...)`, `<<<`, `&>` ou `source` (use `. script.sh`).

### 3. Sistema de Inicialização: `rc.d` vs `systemd`

- O FreeBSD utiliza scripts clássicos `rc.d` sob controle declarativo em `/etc/rc.conf`.
- **Habilitar serviços:** `sysrc servicename_enable="YES"`
- **Controlar serviços:** `service servicename start|stop|restart|status`
- O agente NUNCA deve tentar invocar `systemctl` ou ler `/lib/systemd` no FreeBSD.

### 4. Armazenamento e Virtualização de Primeira Classe: ZFS & Jails

- **OpenZFS no Base:** O FreeBSD possui suporte nativo integral ao ZFS no sistema base. Gerenciamento de inicialização via `bectl` (Boot Environments).
- **Jails:** Isolamento nativo de processos a nível de kernel com virtualização de rede (`vnet`), gerenciados por utilitários de base (`jail(8)`) ou orquestradores leves (`bastille`, `iocage`).

### 5. Elevação de Privilégios: `doas` sobre `sudo`

- No FreeBSD e OpenBSD, prefira o `doas` (`/usr/local/bin/doas` com regras em `/usr/local/etc/doas.conf`) por sua simplicidade e footprint mínimo de segurança.

---

## 🐧 Linux: Paridade e Adaptações

Quando operando em ambientes Linux (Fedora, Debian/Ubuntu, Arch, Rocky Linux):

| Componente                    | FreeBSD (Maestro)                       | Linux (Fedora/Debian/Arch)    |
| :---------------------------- | :-------------------------------------- | :---------------------------- |
| **Prefixo de Pacotes**        | `/usr/local/bin`, `/usr/local/etc`      | `/usr/bin`, `/etc` (UsrMerge) |
| **Gerenciador de Pacotes**    | `pkg` / Ports                           | `dnf` / `apt` / `pacman`      |
| **Init & Serviços**           | `service <svc> status` / `/etc/rc.conf` | `systemctl <action> <svc>`    |
| **Containers**                | Jails (`jail(8)`, `bastille`)           | Podman (daemonless) / Docker  |
| **Compilador Base**           | Clang / LLVM (`cc`, `c++`)              | GCC (`gcc`, `g++`) ou Clang   |
| **Make Padrão**               | BSD Make (`bmake` ou `make`)            | GNU Make (`gmake` ou `make`)  |
| **Firewall**                  | Packet Filter (`pf`) ou `ipfw`          | `nftables` ou `iptables`      |
| **Gerenciamento de Usuários** | `pw useradd`, `pw groupmod`             | `useradd`, `usermod -aG`      |

---

## 🍏 macOS, 🐡 OpenBSD e 🪟 Windows (MSYS2)

### macOS (Darwin)

- **Base:** Baseado na userland BSD com Mach/XNU kernel.
- **Shell:** Zsh é o shell padrão desde o macOS Catalina.
- **Prefixos de Pacotes (Homebrew):**
    - Apple Silicon (ARM64): `/opt/homebrew/bin/`
    - Intel (x86_64): `/usr/local/bin/`
- Utilitários BSD legados podem não ter todas as flags do FreeBSD moderno (ex: `sed -i ''` exige argumento vazio explícito).

### OpenBSD

- Foco absoluto em segurança proativa e simplicidade (`pledge(2)`, `unveil(2)`).
- `doas` é nativo do base system (`/etc/doas.conf`).
- O shell `/bin/sh` é derivado do `pdksh`.

### Windows (MSYS2 / Git Bash)

- Camada de compatibilidade POSIX sobre o subsistema Win32.
- **Atenção aos Caminhos:** Caminhos Windows (`C:\Users\...`) são mapeados para `/c/Users/...`.
- **Finais de Linha:** Cuidado redobrado com CRLF (`\r\n`) ao editar scripts. Todo script deve ter terminação estrita de linha UNIX (`LF`).

---

## 🛡️ Matriz de Comandos Portáteis para Agentes

Para garantir que comandos executados por IAs rodem em qualquer sistema:

```sh
# 1. Identificar o sistema operacional
OS="$(uname -s)"
case "${OS}" in
    FreeBSD)
        # Caminhos FreeBSD
        BIN_DIR="/usr/local/bin"
        ;;
    Linux)
        # Caminhos Linux
        BIN_DIR="/usr/bin"
        ;;
    Darwin)
        # Caminhos macOS
        [ -d "/opt/homebrew/bin" ] && BIN_DIR="/opt/homebrew/bin" || BIN_DIR="/usr/local/bin"
        ;;
    OpenBSD)
        BIN_DIR="/usr/local/bin"
        ;;
esac

# 2. Localização universal de comandos
FIND_CMD="$(command -v find)"
SED_CMD="$(command -v sed)"

# 3. Permissões canônicas em 4 dígitos
chmod 0755 "${target_script}"
chmod 0644 "${target_file}"
```
