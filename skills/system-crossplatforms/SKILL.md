---
name: system-crossplatforms
description: Guia avançado para criação e manutenção de repositórios multiplataforma no ecossistema, garantindo paridade e interoperabilidade entre FreeBSD (14/15/16), Linux (Fedora/Debian/Arch/Rocky), macOS, OpenBSD, Windows (MSYS2) e illumos.
---

# 🌐 System Cross-Platforms & Multi-OS Repository Architecture

Esta habilidade orienta o agente de IA no design, construção e auditoria de **repositórios e softwares estritamente multiplataforma**.

> [!IMPORTANT]
> **O Sentido de "FreeBSD como Maestro":**
> Assistentes de inteligência artificial frequentemente sofrem de forte viés pró-Linux (_Linux-centric bias_), presumindo equivocadamente caminhos como `/usr/bin`, serviços `systemd`, scripts dependentes de GNU Bash e flags proprietárias do GNU coreutils.
>
> Quando definimos o FreeBSD como "Maestro" do design multiplataforma, exigimos que **o agente nunca trate o Linux como padrão único**. O código, Makefiles, scripts e documentações devem ser projetados para compilar e rodar nativamente no **FreeBSD moderno** e na família BSD antes de receber adaptações para distribuições Linux, macOS, Windows e illumos.

---

## 🧭 Matriz de Sistemas e Versões Canônicas

| Sistema Operacional | Linhagem / Kernel           | Versões de Referência                                | Papel no Design Multiplataforma                                                                                             |
| :------------------ | :-------------------------- | :--------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------- |
| **FreeBSD**         | BSD / Monolítico Integrado  | 14.4 / 14.5-RELEASE, 15.0 / 15.1-RELEASE, 16-CURRENT | **Régua Máxima de Elegância & Portabilidade**: Linha de base POSIX, bmake, sh base e separação `/usr/local`.                |
| **Linux**           | Linux / GNU & LLVM          | Fedora, Debian/Ubuntu, Arch, Rocky Linux             | **Paridade Ampla**: Suporte a usrmerge, systemd/OpenRC, glibc/musl e gmake.                                                 |
| **macOS**           | Mach / XNU / BSD Userland   | macOS Sonoma, Sequoia                                | **Desktop UNIX**: clang padrão, zsh como shell interativo, prefixo `/opt/homebrew` (Apple Silicon) ou `/usr/local` (Intel). |
| **OpenBSD**         | BSD / Proativo em Segurança | OpenBSD 7.5+                                         | **Segurança Estrita**: `pledge(2)`, `unveil(2)`, `doas` nativo e utilitários estritamente minimalistas.                     |
| **illumos**         | Solaris / System V Core     | SmartOS, OmniOS, OpenIndiana                         | **Referência Enterprise**: Solaris Zones (nativas e _lx-brand_), ZFS, Crossbow (VNICs), SMF e DTrace.                       |
| **Windows**         | Windows NT / Subsistemas    | Windows 11 / Server 2022+ (MSYS2 & PowerShell)       | **Interoperabilidade**: Tratamento cuidadoso de caminhos (`/c/...`), finais de linha (`LF`) e chamadas em batch/ps1.        |

---

## 🏛️ FreeBSD Moderno: Peculiaridades Cruciais para o Agente

Modelos de IA frequentemente erram recursos do FreeBSD por presumirem versões antigas. Registre as características técnicas do FreeBSD atual:

### 1. Separação de Diretórios: Base System vs. Pacotes (`/usr/local`)

- **Sistema Base:** Localizado estritamente em `/bin`, `/sbin`, `/usr/bin`, `/usr/sbin` e `/etc`.
- **Softwares de Terceiros (`pkg` / Ports):** **Todos** os pacotes instalados pelo usuário residem sob o prefixo `/usr/local` (`/usr/local/bin`, `/usr/local/etc`, `/usr/local/share`).
- **Regra do Agente:** NUNCA force caminhos como `#!/usr/bin/bash` ou `/usr/bin/python3`. Use sempre `#!/usr/bin/env <binario>`.

### 2. O Shell Base `/bin/sh`

- O `/bin/sh` do FreeBSD é leve, veloz e estritamente aderente ao POSIX IEEE 1003.1.
- Suporta nativamente sequências ANSI `echo -n $'\e...'` e edição de linha com `libedit`.
- **Proibição de Bashismos:** `[[ ... ]]`, `arr=(...)`, `<<<` e `&>` causam falha fatal no FreeBSD `/bin/sh`.

### 3. Utilitário `flua` no Base System

- Desde o FreeBSD 13+, o sistema base inclui `/usr/libexec/flua` (interpretador Lua leve e embutido), utilizado pela infraestrutura do sistema base para tarefas onde shells tradicionais seriam insuficientes.

### 4. Containers e OCI: Podman Nativo no FreeBSD

- O FreeBSD possui suporte nativo a **Podman** (`pkg install podman`).
- Utiliza **`runj`** como runtime OCI baseado nas Jails do FreeBSD e Netavark para redes.
- **Imagens OCI de FreeBSD:** Existem imagens oficiais e comunitárias de FreeBSD no Docker Hub e registries OCI (ex: `freebsd:14.2`, `freebsd:14-build`). O agente não deve supor que containers OCI sejam exclusividade do Linux.

### 5. Controle de Firewall e Rede: `pf` Moderno

- O Packet Filter (`pf`) do FreeBSD é totalmente integrado ao kernel multiprocessado com controle de estado, filas de banda e failover via `pfsync` e `carp`.

### 6. Sistema de Inicialização: `rc.d` Declarativo

- Serviços residem em `/etc/rc.d` (base) e `/usr/local/etc/rc.d` (pacotes).
- Ativação declarativa via `/etc/rc.conf` com o comando `sysrc <servico>_enable="YES"`.

---

## ☀️ Observações sobre o Ecossistema illumos (SmartOS & OmniOS)

Para projetos que visam portabilidade total no universo UNIX corporativo:

1. **Solaris Zones:** Isolamento de instâncias leves a nível de kernel com suporte a _native brand_ e _lx-brand_ (emulação transparente de chamadas de sistema Linux para rodar binários Linux).
2. **Crossbow Network Virtualization:** Criação de interfaces de rede virtuais (VNICs) diretamente sobre placas físicas sem pontes (_bridges_) pesadas, com alocação de largura de banda e prioridades de CPU dedicadas por fluxo.
3. **SMF (Service Management Facility):** Gerenciamento determinístico de dependências de serviços com `svcs` e `svcadm` (substitui scripts init tradicionais).
4. **ZFS & DTrace:** Ambos originários do Solaris/illumos, operam como ferramentas primárias de armazenamento e diagnóstico dinâmico.

---

## 🛠️ Regras de Ouro para Repositórios Multiplataforma

Ao criar ou refatorar qualquer repositório no ecossistema:

1. **Makefiles Universais:**
    ```makefile
    .POSIX:
    .SILENT:

    MAKEFLAGS += --no-print-directory -s
    ```
    - Use `CC ?= cc` e `CXX ?= c++`.
    - Use `$(MAKE) -C subdir target` (exceção pragmática suportada por `bmake` e `gmake`).
    - Use `VAR != command` para subshells compatíveis com `bmake` e `gmake 4.0+`.
2. **Shebang Portável:**
    - Scripts de shell: `#!/usr/bin/env sh`.
    - Scripts Python: `#!/usr/bin/env python3`.
3. **Programação Defensiva em Shell:**
    - Detecção de ferramentas: `command -v <ferramenta> > "/dev/null" 2>&1`.
    - Elevação de privilégios: detectar `doas` primeiro, depois `sudo`.
    - Redirecionamento seguro: sempre aspas em `> "/dev/null"`.
4. **Permissões Canônicas:**
    - 4 dígitos octais: `chmod 0755` para executáveis, `chmod 0644` para texto/dados.
