---
name: illumos-cloud
description: Runbook cognitivo para desenvolvimento, empacotamento, orquestração e operação em nuvem baseada no ecossistema illumos/Solaris (SmartOS, OmniOS, OpenIndiana, Solaris Zones nativas e lx-brand, Crossbow, ZFS, SMF e DTrace).
---

# ☀️ illumos Cloud & Enterprise UNIX Infrastructure Skill

Esta habilidade orienta o agente de IA na arquitetura, desenvolvimento e operação de softwares e infraestrutura de nuvem baseada no ecossistema **illumos** — a linhagem de código aberto descendente direta do OpenSolaris / System V, mantida por projetos como **SmartOS** (Triton DataCenter), **OmniOS CE**, **OpenIndiana** e a infraestrutura de hypervisores da **Oxide Computer Company**.

---

## 🏛️ 1. O Legado Arquitetural de illumos na Nuvem

O ecossistema illumos foi o berço de tecnologias que redefiniram a computação em nuvem corporativa moderna:

1. **ZFS:** O primeiro sistema de arquivos projetado do zero para integridade atômica, soma de verificação em todas as leituras (_checksumming_), volume pool unificado e snapshots sem custo.
2. **Zones (Contêineres de Kernel):** A tecnologia de contêineres de alta segurança e densidade pioneira da Sun Microsystems (2004).
3. **Crossbow:** A primeira arquitetura completa de virtualização de rede a nível de kernel.
4. **DTrace:** O framework de instrumentação dinâmica e depuração em produção que inspirou o eBPF no Linux.

---

## 🛡️ 2. Solaris / illumos Zones

As **Zones** oferecem isolamento perfeito de processos e recursos com overhead de desempenho nulo.

### Tipos de Zonas:

1. **Zonas Nativas (Native Brand / `joyent`):**
    - Espaço de usuário illumos puro rodando sobre o kernel illumos compartilhado.
    - Padrão de segurança militar e máxima performance em bancos de dados e serviços compilados para illumos.
2. **Zonas Linux Emuladas (`lx-brand`):**
    - O kernel illumos intercepta e traduz chamadas de sistema do Linux em tempo de execução sem emulação de CPU.
    - Permite executar distribuições completas de Linux (Ubuntu, Debian, Alpine, Rocky) e binários nativos do Linux com acesso a ZFS, DTrace e Crossbow.

---

## ☁️ 3. SmartOS: O Hipervisor de Nuvem sem Disco

O **SmartOS** é o sistema operacional de referência para nuvens públicas e privadas (utilizado no Triton DataCenter):

1. **Execução 100% em RAM:**
    - O sistema base inicializa a partir de USB, iPXE ou imagem de rede e reside inteiramente na memória RAM.
    - Discos físicos são dedicados 100% para o ZFS Storage Pool (`zones`), eliminando riscos de corrupção do sistema operacional host.
2. **Orquestração Declarativa com `vmadm` e `imgadm`:**
    - Instâncias (tanto Zones quanto VMs bhyve/KVM) são descritas em arquivos JSON:
    ```sh
    # Importar imagem de sistema:
    imgadm vacuum
    imgadm import <uuid-da-imagem>

    # Criar instância via manifesto JSON:
    vmadm create -f instance.json

    # Listar instâncias ativas:
    vmadm list
    ```

---

## 🌐 4. Virtualização de Rede com Crossbow

O subsistema **Crossbow** elimina a necessidade de criar pontes de software (_bridges_) pesadas ou interfaces de rede proprietárias:

1. **VNICs Nativas (`dladm`):**
    - Criação de placas de rede virtuais diretamente no hardware com endereço MAC exclusivo e fila de hardware dedicada:
    ```sh
    # Criar uma interface virtual sobre a placa física igb0 com limite de banda:
    dladm create-vnic -l igb0 -m auto -p maxbw=1G vnic_app0
    ```
2. **Switches Virtuais Efêmeros (_Etherstubs_):**
    - Criação de switches de rede inteiramente na memória do kernel para tráfego ultrarrápido entre containers locais sem tocar nas portas físicas.

---

## ⚙️ 5. SMF: Service Management Facility

Diferente de scripts de inicialização clássicos ou de gerenciadores de processo externos, o **SMF** garante supervisão contínua em nível de sistema:

```sh
# Consultar status detalhado de serviços:
svcs -xv

# Habilitar ou reiniciar um serviço:
svcadm enable svc:/network/http:pocketbase
svcadm restart svc:/network/http:pocketbase
```

- Se um daemon sofrer um crash (_segfault_), o SMF o reinicia instantaneamente e preserva os logs de falha no repositório SMF.
