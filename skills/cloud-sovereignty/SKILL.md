---
name: cloud-sovereignty
description: Runbook cognitivo definitivo para repatriação de nuvem (Cloud-Exit) e soberania de infraestrutura, cobrindo bare-metal, FreeBSD (Jails/Sylve/runj), Linux (Proxmox/Podman Quadlets/Incus), illumos (Oxide/Zones/Crossbow) e OpenBSD.
---

# 🏛️ Soberania de Nuvem & Engenharia de Cloud-Exit

Esta habilidade orienta o planejamento, arquitetura, migração e operação de sistemas de infraestrutura no paradigma do **Cloud-Exit** — a repatriação estratégica de cargas de trabalho de nuvens públicas monopolistas (AWS, GCP, Azure) para infraestruturas soberanas baseadas em servidores dedicados (_bare-metal_), provedores independentes (Hetzner, OVH) ou data centers próprios.

---

## 🎯 Por que Cloud-Exit? (A Justificativa Econômica e Técnica)

1. **Economia Radical:** Redução de 70% a 90% dos custos recorrentes em relação a instâncias virtuais equivalentes em hiperescaladores e eliminação de taxas abusivas de tráfego de saída (_egress fees_).
2. **Desempenho Determinístico:** Eliminação de ruído de vizinhos (_noisy neighbors_), limites artificiais de IOPS de disco e contenção de CPU virtual.
3. **Erradicação do Lock-in Proprietário:** Substituição de serviços fechados por padrões abertos (POSIX, OpenZFS, binários nativos estáticos e containers OCI neutros).

---

## 🧭 Matriz Multi-OS de Soberania

Nenhum sistema operacional é a resposta universal para todos os problemas. A excelência arquitetural aloca cada tecnologia onde sua engenharia se destaca:

| Sistema Operacional | Papel Estratégico na Infraestrutura Soberana                     | Tecnologias Canônicas                                                |
| :------------------ | :--------------------------------------------------------------- | :------------------------------------------------------------------- |
| **FreeBSD**         | **Maestro de Armazenamento, Jails VNET e Containers Leves**      | OpenZFS, Jails VNET, Bastille, Sylve, Podman nativo com `runj`, `pf` |
| **Linux**           | **Cavalo de Batalha para Cargas Heterogêneas, GPUs & Clusters**  | Proxmox VE, Podman rootless (Quadlets), Incus/LXC, Ceph, eBPF        |
| **illumos**         | **Referência Máxima de Isolamento Multitenant & Missão Crítica** | SmartOS, Oxide Computer (Propolis), Zones (`lx-brand`), Crossbow     |
| **OpenBSD**         | **Escudo de Borda, Roteamento Soberano e Firewalls**             | Firewall `pf` estrito, `bgpd`, `relayd`, `pledge` e `unveil`         |

---

## 📚 Módulos Especializados da Subpasta references/

Consulte as especificações aprofundadas por ecossistema nos arquivos dedicados:

- **[freebsd.md](references/freebsd.md):** OpenZFS de raiz, Jails VNET, Bastille, Sylve, Podman nativo com runtime `runj`, imagens OCI oficiais, `pf` moderno e automação com `flua`.
- **[linux.md](references/linux.md):** Virtualização empresarial com Proxmox VE (KVM + LXC), Podman rootless integrado via systemd Quadlets, Incus e observabilidade eBPF.
- **[illumos.md](references/illumos.md):** Computadores de nuvem privada com Oxide Computer (Propolis/Rust), SmartOS sem disco, virtualização de rede com Crossbow e supervisão SMF.
- **[openbsd.md](references/openbsd.md):** Roteadores soberanos de borda, firewall Packet Filter (`pf`), concentração VPN WireGuard e mitigação de exploração com `pledge` e `unveil`.

---

## 📋 Roteiro Canônico de Execução de Repatriação

1. **Auditoria de Dependências:** Migrar bancos proprietários para SQLite/PostgreSQL e armazenamento proprietário para OpenZFS/MinIO.
2. **Padronização em Binários ou OCI Neutro:** Compilar microsserviços em binários únicos (Go, C23) ou imagens OCI agnósticas.
3. **Provisionamento Bare-Metal:** Alocar servidores dedicados com rede redundante e discos NVMe em espelhamento ZFS.
4. **Governança Automatizada:** Controlar infraestrutura com scripts portáteis (`#!/usr/bin/env sh`) e Makefiles silenciosos (`.POSIX: .SILENT:`).

---

## 🔗 Referências Oficiais & Projetos

- [Sylve Infrastructure Platform](https://sylve.io/)
- [Proxmox Virtual Environment](https://proxmox.com/en/)
- [Oxide Computer Company RFDs](https://rfd.shared.oxide.computer/)
- [The FreeBSD Project](https://www.freebsd.org/)
- [OpenBSD PF Guide](https://www.openbsd.org/faq/pf/)
