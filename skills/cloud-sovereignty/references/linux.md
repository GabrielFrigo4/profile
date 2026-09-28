# 🐧 Linux: Virtualização Empresarial, Podman & Incus

No ecossistema Linux moderno (Debian, Fedora, Rocky, Alpine), a soberania de nuvem apoia-se em conteinerização sem daemon (Podman), virtualização corporativa com Proxmox VE e observabilidade eBPF.

---

## 🔒 Podman Rootless & Integração com systemd (Quadlets)

1. **Rootless por Padrão:** Containers são executados sem privilégios de root no espaço do usuário via `subuid`/`subgid`. Em distribuições com SELinux, a flag `:Z` garante isolamento dos volumes:
    ```sh
    podman run -d --name web -p 8080:8080 -v ./data:/data:Z ghcr.io/org/web:latest
    ```
2. **Quadlets Declarativos:** Em vez de scripts ad-hoc, use arquivos `.container` em `~/.config/containers/systemd/`:
    ```ini
    # ~/.config/containers/systemd/api.container
    [Unit]
    Description=API Microservice
    After=network-online.target

    [Container]
    Image=ghcr.io/org/api:latest
    PublishPort=8080:8080
    Volume=%h/data:/data:Z

    [Install]
    WantedBy=default.target
    ```
    Recarregue e gerencie nativamente via `systemctl --user daemon-reload && systemctl --user start api`.

---

## 📦 Containers de Sistema com Incus / LXC

Para ambientes que exigem um sistema operacional completo sem a sobrecarga de virtualização de hardware:

- **Incus:** A evolução aberta e comunitária de containers LXC.
- Inicialização sub-segundo, densidade extrema e integração nativa com pools ZFS ou Btrfs:
    ```sh
    incus launch images:debian/12 node-worker
    incus exec node-worker -- apt-get update
    ```

---

## 🖥️ Proxmox Virtual Environment (VE)

A plataforma líder para orquestração bare-metal em nuvem privada sobre Linux:

- Unifica **KVM** para virtualização total e **LXC** para containers de sistema.
- Suporte nativo a clusters distribuídos Ceph e OpenZFS de alta performance.
- Firewall definido por software, SDN e interface web corporativa.

---

## 👁️ Observabilidade e Segurança com eBPF

Uso de eBPF (Extended Berkeley Packet Filter) para auditoria contínua de rede, segurança em tempo de execução e perfilamento de chamadas de sistema sem penalidades de desempenho.
