---
name: freebsd-cloud
description: Runbook cognitivo para desenvolvimento, empacotamento, orquestração e operação de softwares e infraestrutura na nuvem FreeBSD moderna (Jails, Bastille, Sylve, Podman nativo com runj, imagens OCI no Docker Hub, bhyve, ZFS datasets, flua e pf moderno).
---

# ☁️ FreeBSD Cloud & Modern Infrastructure Skill

Esta habilidade orienta o agente de IA na arquitetura, desenvolvimento de software e operação de infraestrutura para **ambientes de nuvem baseados em FreeBSD moderno** (ciclos 14.x, 15.x e 16-CURRENT).

---

## 📜 A Regra Universal do Shebang (`#!/usr/bin/env sh`)

Todo script de shell de provisionamento, bootstrap ou automação cloud no ecossistema DEVE obrigatoriamente utilizar:

```sh
#!/usr/bin/env sh
```

Nunca utilize caminhos absolutos hardcoded como `#!/bin/sh` ou `#!/bin/bash`. O comando `env` assegura resolução agnóstica via `PATH` no FreeBSD (`/bin/sh`), Linux, macOS e illumos.

---

## 🏛️ 1. Isolamento Nativo: Jails, Bastille & Sylve

As **Jails** são a tecnologia original de conteinerização do mundo UNIX (introduzida no FreeBSD 4.0 em 2000), operando com sobrecarga de CPU/memória próxima de zero.

### Características Centrais das Jails Modernas:

1. **Pilha de Rede VNET:** Cada Jail possui sua própria pilha de rede virtualizada independente, com interface virtual (`epair`), tabela de roteamento dedicada e regras de firewall `pf` exclusivas.
2. **Controle Fino com `rctl(8)`:** O subsistema Resource Accounting (`racct`) e Resource Limits (`rctl`) impõe cotas rigorosas de consumo de hardware:
    ```sh
    # Limitar uso de memória de uma jail a 2GB
    rctl -a jail:app_worker:memoryuse:deny=2G
    ```
3. **Orquestração com Bastille:**
    - Framework CLI leve para automação de Jails:
    ```sh
    bastille bootstrap 15.0-RELEASE
    bastille create -V app-server 15.0-RELEASE 10.0.0.10/24 vnet0
    bastille start app-server
    bastille cmd app-server pkg install -y go git
    ```
4. **Plataforma Web Moderna de Infraestrutura: `Sylve`:**
    - **Sylve** (<https://sylve.io/> / `AlchemillaHQ/Sylve`): plataforma moderna open-source de gerenciamento de infraestrutura para FreeBSD 15.0+ (`pkg install sylve` ou via ports em `sysutils/sylve`).
    - Desenvolvida com backend em Go e frontend em SvelteKit.
    - Unifica em um dashboard web intuitivo o ciclo de vida de **Bhyve VMs**, **FreeBSD Jails**, **OpenZFS** (pools, datasets, replicação), redes e firewalling PF/NAT.

---

## 🐳 2. Podman Nativo e Containers OCI no Docker Hub (`https://hub.docker.com/u/freebsd`)

> [!IMPORTANT]
> **Podman é Nativo no FreeBSD:**
> O FreeBSD suporta nativamente o utilitário `podman` para gerenciar containers compatíveis com os padrões da **Open Container Initiative (OCI)** sem virtualização de máquinas Linux.

1. **Runtime `runj`:**
    - O Podman no FreeBSD utiliza o runtime `runj` (implementação de especificação OCI escrita em Go que mapeia containers diretamente para FreeBSD Jails nativas com redes Netavark).
2. **Imagens Oficiais do FreeBSD no Docker Hub (<https://hub.docker.com/u/freebsd>):**
    - The FreeBSD Project mantém oficialmente imagens OCI prontas no namespace `freebsd`:
        - `freebsd/freebsd-runtime`: base mínima para rodar serviços e binários.
        - `freebsd/freebsd-static`: imagem minimalista para executáveis estáticos.
        - `freebsd/freebsd-dynamic`: base dinâmica com bibliotecas do sistema base.
        - `freebsd/freebsd-toolchain`: ambiente de build com Clang, headers e ferramentas.
        - `freebsd/freebsd-notoolchain`: ambiente de sistema sem compiladores.
        - Tags ativas: `15.1`, `14.5`, `16.snap` (CURRENT), `15.snap`, `14.snap`.
    - Comandos canônicos de operação:
    ```sh
    # Instalar podman no FreeBSD:
    pkg install podman

    # Baixar e executar um container nativo FreeBSD:
    podman pull freebsd/freebsd-runtime:15.1
    podman run --rm -it freebsd/freebsd-runtime:15.1 uname -a
    ```

---

## 🛡️ 3. Firewall `pf` Moderno com Paridade OpenBSD

O Packet Filter (`pf`) no FreeBSD é totalmente integrado ao kernel multiprocessado com controle de estado de alto rendimento:

1. **Sintaxe Moderna Unificada do OpenBSD:**
    - Tradução inline via `nat-to` e `rdr-to` aplicada diretamente em regras de filtragem (`pass`), abolindo a sintaxe fragmentada antiga:
    ```pf
    # Tradução de saída (NAT):
    pass out on $ext_if inet from !($ext_if) to any nat-to ($ext_if)

    # Redirecionamento de porta (Port Forwarding para Jail VNET):
    pass in on $ext_if proto tcp to any port 80 rdr-to 10.0.0.10 port 8080
    ```
2. **Tabelas Dinâmicas:**
    - `table <bruteforce> persist` para bloqueios dinâmicos com `fail2ban` ou scripts em tempo real.
3. **Desempenho SMP:** Execução multithread paralela no kernel do FreeBSD, garantindo capacidade de saturação em links de 40GbE/100GbE+.

---

## 📜 4. Automação Avançada com `flua` no Base System (`/usr/libexec/flua`)

O interpretador Lua do sistema base do FreeBSD (`flua`) elimina dependências de linguagens externas pesadas (como Python) para scripts de automação de infraestrutura:

1. **`libucl`:** Leitura e emissão de manifestos em JSON estrito, JSON simplificado/UCL (sem aspas desnecessárias, com comentários legíveis) e YAML.
2. **`libjail` (`jail(3lua)`):** Criação, consulta de parâmetros e controle de Jails de forma programática.
3. **`lfs` & `lposix`:** Manipulação de sistema de arquivos e chamadas de sistema POSIX atômicas.
4. **`libfreebsd` & `libhash`:** Inspeção de variáveis do kernel (`kenv`), módulos e integridade de dados.

---

## 🖥️ 5. Virtualização com `bhyve`

Para cenários onde é necessário rodar outros sistemas operacionais (Linux com kernel específico, OpenBSD, Windows Server) dentro de um host FreeBSD:

1. **`bhyve`:** Hypervisor minimalista e de alta performance acelerado por hardware (Intel VT-x / AMD-V) integrado ao base system.
2. **Gerenciamento com `vm-bhyve` ou `Sylve`:**
    ```sh
    vm init
    vm create debian-node
    vm start debian-node
    ```

---

## 💾 6. Armazenamento Cloud com ZFS Nativo

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

## 🌐 7. Provedores de Nuvem e Cloud-Init

O FreeBSD disponibiliza imagens oficiais prontas em todos os maiores provedores de cloud:

- **AWS (EC2):** AMIs oficiais com inicialização por bootloader ZFS e suporte a instâncias Graviton (ARM64) e AMD64.
- **Hetzner Cloud, DigitalOcean, Vultr, Linode:** Imagens com suporte a Cloud-Init (`cloud-init` em ports) para injeção declarativa de chaves SSH, hostname e provisionamento automático no boot.

---

## 🔗 Links Oficiais de Referência & Leitura Recomendada

- **The FreeBSD Project:** <https://www.freebsd.org/> | Releases: <https://www.freebsd.org/where/>
- **FreeBSD Ports & Packages Index:** <https://ports.freebsd.org/cgi/ports.cgi> | FreshPorts: <https://www.freshports.org/>
- **FreeBSD Handbook:** <https://docs.freebsd.org/en/books/handbook/>
- **Sylve Infrastructure Platform:** <https://sylve.io/> | GitHub: <https://github.com/AlchemillaHQ/Sylve>
- **BastilleBSD (Container Management):** <https://bastillebsd.org/>
- **FreeBSD Official OCI Images (Docker Hub):** <https://hub.docker.com/u/freebsd>
