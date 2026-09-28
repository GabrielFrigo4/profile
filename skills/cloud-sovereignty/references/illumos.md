# ☀️ illumos: Isolamento de Missão Crítica & Nuvem de Rack

A linhagem illumos (OpenSolaris / System V), mantida por projetos como **SmartOS**, **OmniOS CE** e a inovadora **Oxide Computer Company**, representa a referência máxima em isolamento multitenant, observabilidade profunda e virtualização de rede em kernel.

---

## 🛡️ Solaris / illumos Zones

1. **Zonas Nativas:** Espaço de usuário illumos puro executando sobre o kernel com isolamento criptográfico e alocação estrita de recursos.
2. **Zonas Linux Emuladas (`lx-brand`):** Tradução em tempo real de chamadas de sistema Linux no kernel illumos, permitindo rodar binários Linux (Ubuntu, Debian, Alpine) aproveitando ZFS e Crossbow.

---

## ☁️ SmartOS: O Hipervisor sem Disco

Projetado especificamente para nuvens públicas e privadas:

- **Execução 100% em RAM:** Inicializa via iPXE ou USB; o sistema operacional nunca toca discos persistentes, prevenindo corrupção por escrita acidental.
- **Armazenamento 100% em ZFS (`zones`):** Todo o hardware de disco é alocado para dados e VMs.
- **Manifestos Declarativos (`vmadm`):**
    ```sh
    vmadm create -f instance.json
    vmadm list
    ```

---

## 🌐 Virtualização de Rede com Crossbow

O subsistema **Crossbow** introduziu a virtualização de rede em nível de driver:

- **VNICs Nativas (`dladm`):** Interfaces virtuais criadas diretamente sobre adaptadores físicos com MAC próprio e controle de banda por hardware:
    ```sh
    dladm create-vnic -l igb0 -m auto -p maxbw=1G vnic_app0
    ```
- **Etherstubs:** Switches virtuais puramente em memória de kernel para tráfego local ultra-veloz.

---

## 🏢 A Nova Fronteira: Oxide Computer Company

A **Oxide Computer Company** (<https://oxide.computer/>) consolida a arquitetura illumos na escala de hiperconvergência de data center:

- **illumos como Hipervisor Central:** Governa o hardware do rack, placas de controle e comutação de rede.
- **Propolis (VMM em Rust):** Monitor de máquinas virtuais moderno e seguro sobre bhyve.
- **Arquitetura Aberta:** Projeto integralmente documentado em seus RFDs (<https://rfd.shared.oxide.computer/>).
