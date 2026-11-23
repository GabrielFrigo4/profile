# 🐧 Linux: Virtualização Empresarial, Podman & Incus

No Linux, a soberania de infraestrutura apoia-se em conteinerização sem daemon (Podman), virtualização aberta com Proxmox VE, containers de sistema Incus/LXC e observabilidade eBPF.

---

## 🔒 Podman Rootless & Quadlets (`systemd`)

1. **Rootless por Padrão:** Containers executam sem privilégios de root via `subuid`/`subgid` (com `:Z` para rotulagem SELinux):
    ```sh
    podman run -d --name web -p 8080:8080 -v ./data:/data:Z ghcr.io/org/web:latest
    ```
2. **Quadlets Declarativos (`~/.config/containers/systemd/api.container`):**
    ```ini
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
    Gerencie via `systemctl --user daemon-reload && systemctl --user start api`.

---

## 📦 Containers de Sistema com Incus / LXC

Para ambientes que demandam um espaço de usuário completo com boot sub-segundo integrado a pools ZFS ou Btrfs:

```sh
incus launch images:debian/stable node-worker
incus exec node-worker -- apt-get update
```

---

## 🖥️ Proxmox VE & Observabilidade eBPF

- **Proxmox VE:** Unifica hipervisor **KVM** e containers **LXC** sobre clusters Ceph ou OpenZFS, com SDN e firewall integrado.
- **eBPF:** Auditoria contínua de rede, segurança em runtime e rastreamento de syscalls com overhead mínimo no kernel.
