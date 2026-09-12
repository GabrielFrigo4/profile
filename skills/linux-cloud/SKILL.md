---
name: linux-cloud
description: Runbook cognitivo para desenvolvimento, conteinerização moderna, orquestração e operação de software em nuvem Linux (Podman rootless/daemonless, Incus e LXC, systemd-nspawn, KVM/QEMU, Cloud-Init e observabilidade eBPF).
---

# 🐧 Linux Cloud & Modern Infrastructure Skill

Esta habilidade orienta o agente de IA na arquitetura, conteinerização de microsserviços, orquestração de servidores e operação de software em **ambientes modernos de nuvem Linux** (Fedora, Debian, Ubuntu, Arch e Rocky Linux).

---

## 🔒 1. Podman: Conteinerização Segura e Sem Daemon

No ecossistema de nuvem moderna, **o Podman é a ferramenta canônica de containers OCI**, eliminando a dependência do daemon monolithic com privilégios de root do Docker.

### Diretrizes de Engenharia com Podman:

1. **Rootless por Padrão:**
    - Execute containers sempre no espaço do usuário sem `sudo` (`subuid` e `subgid` configurados):
    ```sh
    podman run -d --name api-service -p 8080:8080 -v ./data:/data:Z ghcr.io/org/api:latest
    ```
    - A flag `:Z` é obrigatória em distribuições com SELinux ativo (Fedora/Rocky) para configurar os contextos de segurança.
2. **Integração com systemd (Quadlet):**
    - No Linux moderno, containers não devem depender de reinicializações manuais. Use **Quadlet** (`.container` em `~/.config/containers/systemd/`) para gerenciar containers como serviços nativos do systemd no espaço de usuário (`systemctl --user`).
3. **Pods Locais com YAML do Kubernetes:**
    - Teste e orquestre pilhas de containers localmente usando a especificação declarativa do Kubernetes via `podman play kube app-pod.yaml`.

---

## 📦 2. Containers de Sistema com Incus e LXC

Quando a aplicação exige um sistema operacional completo com init, múltiplos daemons e isolamento de servidor (sem a sobrecarga de virtualização de hardware):

1. **Incus:** A evolução comunitária, aberta e independente do ecossistema LXD/LXC.
2. **Vantagens em Nuvem:**
    - Inicialização em menos de 1 segundo.
    - Densidade de instâncias até 10x maior que máquinas virtuais tradicionais.
    - Armazenamento nativo com suporte a ZFS e Btrfs.
    ```sh
    incus launch images:debian/12 worker-node
    incus exec worker-node -- apt-get update
    ```

---

## 🛡️ 3. systemd-nspawn: Sandboxes Leves para CI/CD

Para auditorias pontuais, compilações herméticas e ambientes de teste locais sem instalar camadas complexas de containers:

```sh
systemd-nspawn -D /var/lib/machines/test-root --bind-ro=/home/app:/app
```

---

## ☁️ 4. Implantação Declarativa: Cloud-Init & Imagens Imutáveis

1. **Cloud-Init:** Padrão universal para inicialização de instâncias em nuvem (AWS, GCP, Azure, Hetzner, Proxmox):
    - Configuração de usuários, chaves SSH autorizadas e pacotes essenciais via manifesto YAML `#cloud-config`.
2. **Sistemas Operacionais Imutáveis / OCI Bootable:**
    - Tendência de ponta para nós de infraestrutura: Fedora CoreOS, Flatcar e sistemas com suporte a `bootc` (onde a imagem do próprio host é versionada e distribuída como um container OCI).

---

## 👁️ 5. Observabilidade e Segurança com eBPF

Em clusters e servidores de produção modernos, a depuração de desempenho e a auditoria de rede devem priorizar a tecnologia **eBPF** (Extended Berkeley Packet Filter), permitindo monitorar chamadas de sistema e tráfego de rede em tempo real sem alterar código fonte ou injetar proxies pesados.

---

## 🖥️ 6. Orquestração e Virtualização Empresarial: Proxmox VE

Quando a infraestrutura exige hospedar múltiplos nós, máquinas virtuais completas e containers de sistema em escala corporativa no Linux:

1. **Proxmox Virtual Environment (<https://proxmox.com/en/>):**
    - A plataforma open-source líder no mundo Linux (baseada em Debian) para virtualização corporativa e computação em nuvem privada/híbrida.
    - Unifica **KVM (Kernel-based Virtual Machine)** para virtualização total de hardware e **LXC (Linux Containers)** para containers de sistema leves e ultrarrápidos.
    - Armazenamento distribuído e local de alta resiliência com suporte nativo a **OpenZFS** e **Ceph**.
    - Clusters de alta disponibilidade gerenciados via Corosync, redes definidas por software (SDN), firewall integrado e painel web rico.
    - Representa no universo Linux a contraparte dominante ao que o **Sylve** (<https://sylve.io/>) realiza no FreeBSD e o **Triton DataCenter / SmartOS** entrega no ecossistema illumos.

---

## 🔗 Links Oficiais de Referência

- **Proxmox Virtual Environment:** <https://proxmox.com/en/>
- **Podman Container Tools:** <https://podman.io/>
- **Incus Linux Containers:** <https://linuxcontainers.org/incus/>
- **Cloud-Init Project:** <https://cloud-init.io/>
