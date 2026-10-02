# ☁️ FreeBSD: Armazenamento, Jails & Conteinerização Nativa

No ecossistema FreeBSD (ciclos 14.x, 15.x e 16-CURRENT), a soberania de infraestrutura baseia-se em OpenZFS integrado ao kernel, conteinerização de altíssima densidade via Jails e compatibilidade OCI nativa.

---

## 🏛️ Jails VNET, Bastille & Sylve

As **Jails** operam com overhead virtualmente nulo, compartilhando o kernel do host mas isolando completamente processos, sistemas de arquivos e pilhas de rede.

1. **VNET (Virtual Network Stack):** Cada Jail possui sua interface virtual (`epair`), tabela de roteamento e regras de `pf` exclusivas.
2. **BastilleBSD:** Ferramenta de linha de comando para automação rápida:
    ```sh
    bastille bootstrap 15.0-RELEASE
    bastille create -V app-server 15.0-RELEASE 10.0.0.10/24 vnet0
    bastille start app-server
    bastille cmd app-server pkg install -y go git
    ```
3. **Sylve (<https://sylve.io/>):** Painel web de infraestrutura moderna (Go + SvelteKit) para FreeBSD 15.0+ que unifica o ciclo de vida de VMs Bhyve, Jails, OpenZFS e firewall `pf`.

---

## 🐳 Podman Nativo e Containers OCI (`runj`)

O FreeBSD roda `podman` nativamente sem camadas de emulação Linux:

1. **Runtime `runj`:** Mapeia especificações OCI diretamente para FreeBSD Jails nativas com redes Netavark.
2. **Imagens Oficiais no Docker Hub (`freebsd/*`):**
    ```sh
    pkg install podman
    podman pull freebsd/freebsd-runtime:15.1
    podman run --rm -it freebsd/freebsd-runtime:15.1 uname -a
    ```

---

## 🛡️ Firewall `pf` Moderno & Alta Performance

Sintaxe inline moderna com tradução `nat-to` e redirecionamento `rdr-to`:

```pf
# Tradução de saída (NAT)
pass out on $ext_if inet from !($ext_if) to any nat-to ($ext_if)

# Redirecionamento de porta para Jail VNET
pass in on $ext_if proto tcp to any port 80 rdr-to 10.0.0.10 port 8080
```

---

## 💾 OpenZFS, Snapshots & Boot Environments

- Datasets dedicados por serviço (`zroot/data/app`) permitindo backups atômicos:
    ```sh
    zfs snapshot zroot/data@backup_today
    zfs send -i zroot/data@backup_yesterday zroot/data@backup_today | ssh backup-node zfs receive pool/vault
    ```
- **Boot Environments (`bectl`):** Rollbacks instantâneos de sistema antes de grandes upgrades:
    ```sh
    bectl create pre-upgrade
    bectl activate pre-upgrade
    ```

---

## 🤖 Gestão de TTY em CI/CD: O Padrão `script -q /dev/null`

Para evitar congelamento de shells interativos em pipelines headless decorrente de `SIGTTIN` (sinal 21) no kernel FreeBSD:

```sh
script -q /dev/null bash -i -c 'echo "Prompt OK: ${PS1}"'
```
