---
name: sovereign-infrastructure
description: >-
    Arquitetura para soberania de infraestrutura e repatriação de nuvem (Cloud-Exit),
    cobrindo bare-metal, FreeBSD (OpenZFS, Jails VNET, Bastille, Podman runj), Linux
    (Proxmox, Podman Quadlets, Incus, eBPF), illumos (Zones, Crossbow), OpenBSD e
    entrega web em binário único embutido.
---

# 🏛️ Sovereign Infrastructure — Bare-Metal & Cloud-Exit

Diretrizes para migração e operação de cargas de trabalho fora de hiperescaladores proprietários em infraestrutura dedicada (_bare-metal_), baseada em padrões abertos POSIX, OpenZFS e conteinerização nativa.

---

## 🎯 1. Princípios de Soberania & Cloud-Exit

- **Previsibilidade Econômica:** Eliminação de taxas de saída (_egress fees_), ruído de vizinhos (_noisy neighbors_) e limites artificiais de IOPS.
- **Zero Lock-in Proprietário:** Substituição de bancos e armazenamentos proprietários por SQLite/PostgreSQL e OpenZFS com replicação nativa (`zfs send` / `zfs receive`).
- **Automação Portátil:** Scripts `#!/usr/bin/env sh` e Makefiles silenciosos (`.POSIX: .SILENT:`) operando com autonomia entre plataformas.

---

## 🧭 2. Matriz Multi-OS de Infraestrutura

| Sistema     | Papel Estratégico                       | Primitivas Canônicas                             | Referência                                       |
| :---------- | :-------------------------------------- | :----------------------------------------------- | :----------------------------------------------- |
| **FreeBSD** | Storage ZFS, Jails VNET e OCI nativo    | OpenZFS, `bectl`, Bastille, Podman `runj`, `pf`  | [`references/freebsd.md`](references/freebsd.md) |
| **Linux**   | Virtualização KVM/LXC, GPUs e clusters  | Proxmox VE, Podman Quadlets, Incus, Ceph, eBPF   | [`references/linux.md`](references/linux.md)     |
| **illumos** | Isolamento multitenant e rede em kernel | Zones (`lx-brand`), SmartOS RAM, Crossbow VNICs  | [`references/illumos.md`](references/illumos.md) |
| **OpenBSD** | Borda, roteamento e firewalls estritos  | `pf`, `pledge(2)`, `unveil(2)`, `relayd`, `bgpd` | [`references/openbsd.md`](references/openbsd.md) |

---

## 📦 3. Single-Binary Embedded Web Pattern

Para painéis administrativos, APIs e serviços internos sem inchaço de múltiplos containers ou `node_modules` em produção:

- **Frontend Compilado & Embutido:** Compile assets estáticos em tempo de build e incorpore-os diretamente no executável via recurso nativo de embed (ex.: `//go:embed` em Go), entregando um único binário estático e reproduzível.
- **Estado SQLite WAL Integrado:** Adote SQLite em modo Write-Ahead Logging (`WAL`) no mesmo host para leituras/escritas concorrentes e backups atômicos por snapshot de filesystem (ZFS) ou cópia de arquivo único.
- **Tempo Real via SSE & Deploy Atômico:** Prefira Server-Sent Events (`SSE`) sobre HTTP padrão a brokers intermediários complexos; atualize serviços substituindo um único binário e reiniciando o daemon do sistema.

---

## 📋 4. Roteiro de Repatriação

1. Audite dependências gerenciadas e migre estado para SQL/SQLite e volumes OpenZFS replicados.
2. Empacote serviços em binários estáticos ou imagens OCI neutras executadas com isolamento rootless/Jail.
3. Provisione servidores com discos NVMe em espelhamento ZFS e automação declarativa reprodutível.
