---
name: freebsd-cloud
description: Runbook cognitivo para desenvolvimento, empacotamento, orquestração e operação de softwares e infraestrutura na nuvem FreeBSD moderna (Jails, Bastille, Podman nativo com runj, imagens OCI no Docker Hub, bhyve, ZFS datasets e VNET).
---

# ☁️ FreeBSD Cloud & Modern Infrastructure Skill

Esta habilidade orienta o agente de IA na arquitetura, desenvolvimento de software e operação de infraestrutura para **ambientes de nuvem baseados em FreeBSD moderno** (ciclos 14.x, 15.x e 16-CURRENT).

---

## 🏛️ 1. Isolamento Nativo: Jails e Bastille

As **Jails** são a tecnologia original de conteinerização do mundo UNIX (introduzida no FreeBSD 4.0 em 2000), operando com sobrecarga de CPU/memória próxima de zero.

### Características Centrais das Jails Modernas:

1. **Pilha de Rede VNET:** Cada Jail possui sua própria pilha de rede independente, com interface virtual (`epair`), tabela de roteamento e regras de firewall `pf` exclusivas.
2. **Controle Fino com `rctl(8)`:** O subsistema Resource Accounting (`racct`) e Resource Limits (`rctl`) impõe cotas rigorosas de consumo de hardware:
    ```sh
    # Limitar uso de memória de uma jail a 2GB
    rctl -a jail:app_worker:memoryuse:deny=2G
    ```
3. **Orquestração com Bastille:**
    - Framework moderno e sem dependências pesadas para automação de Jails:
    ```sh
    bastille bootstrap 14.2-RELEASE
    bastille create -V app-server 14.2-RELEASE 10.0.0.10/24 vnet0
    bastille start app-server
    bastille cmd app-server pkg install -y go git
    ```

---

## 🐳 2. Podman Nativo e Containers OCI no FreeBSD

> [!IMPORTANT]
> **Podman é Nativo no FreeBSD:**
> O FreeBSD suporta nativamente o utilitário `podman` para gerenciar containers compatíveis com os padrões da **Open Container Initiative (OCI)**.

1. **Runtime `runj`:**
    - O Podman no FreeBSD utiliza o runtime `runj` (implementação de especificação OCI escrita em Go que mapeia containers diretamente para FreeBSD Jails).
2. **Imagens Oficiais e Comunitárias no Docker Hub:**
    - O Docker Hub e registros OCI públicos possuem imagens nativas do FreeBSD prontas para execução (ex: `freebsd:14.2`, `freebsd:14-build`, `dougb/freebsd`).
    - Comandos canônicos de operação:
    ```sh
    # Instalar podman no FreeBSD:
    pkg install podman

    # Baixar e executar um container FreeBSD:
    podman pull freebsd:14.2
    podman run --rm -it freebsd:14.2 uname -a
    ```
3. **Redes com Netavark:** Suporte a redes OCI modernas sem bridges manuais complexas.

---

## 🖥️ 3. Virtualização de Alto Desempenho com `bhyve`

Para cenários onde é necessário rodar outros sistemas operacionais (Linux com kernel específico, OpenBSD, Windows Server) dentro de um host FreeBSD:

1. **`bhyve`:** Hypervisor minimalista e de alta performance acelerado por hardware (Intel VT-x / AMD-V) integrado ao base system.
2. **Gerenciamento com `vm-bhyve`:**
    ```sh
    vm init
    vm create debian-node
    vm start debian-node
    ```

---

## 💾 4. Armazenamento Cloud com ZFS Nativo

Todo host e jail em nuvem FreeBSD utiliza OpenZFS nativo:

1. **Datasets Dedicados por Serviço:** Isolamento de `zroot/data/pocketbase`, `zroot/data/postgres`, permitindo snapshots e rollbacks independentes.
2. **Replicação Remota sem Parada:**
    ```sh
    # Backup atômico e envio incremental para servidor de storage
    zfs snapshot zroot/data@backup_today
    zfs send -i zroot/data@backup_yesterday zroot/data@backup_today | ssh backup-node zfs receive pool/vault
    ```
3. **Boot Environments (`bectl`):**
    - Antes de qualquer atualização crítica de sistema no cloud (`freebsd-update` ou compilação de base), crie um boot environment para rollback instantâneo em caso de falha:
    ```sh
    bectl create pre-upgrade
    bectl activate pre-upgrade
    ```

---

## 🌐 5. Provedores de Nuvem e Cloud-Init

O FreeBSD disponibiliza imagens oficiais prontas em todos os maiores provedores de cloud:

- **AWS (EC2):** AMIs oficiais com inicialização por bootloader ZFS e suporte a instâncias Graviton (ARM64) e AMD64.
- **Hetzner Cloud, DigitalOcean, Vultr, Linode:** Imagens com suporte a Cloud-Init (`cloud-init` em ports) para injeção declarativa de chaves SSH, hostname e provisionamento automático no boot.
