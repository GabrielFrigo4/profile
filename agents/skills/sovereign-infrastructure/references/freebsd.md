# ☁️ FreeBSD: Armazenamento, Jails & Conteinerização Nativa

No ecossistema FreeBSD, a soberania de infraestrutura baseia-se em OpenZFS integrado ao kernel, conteinerização de altíssima densidade via Jails e compatibilidade OCI nativa.

---

## 🏛️ Jails VNET & Bastille

As **Jails** isolam processos, sistemas de arquivos e pilhas de rede compartilhando o kernel do host com overhead virtualmente nulo:

1. **VNET (Virtual Network Stack):** Cada Jail possui interface virtual (`epair`), tabela de roteamento e regras de `pf` independentes.
2. **Bastille:** Automação declarativa de Jails:
    ```sh
    bastille bootstrap <release>
    bastille create -V app-server <release> 10.0.0.10/24 vnet0
    bastille start app-server
    bastille cmd app-server pkg install -y go git
    ```

---

## 🐳 Podman Nativo e Containers OCI (`runj`)

O FreeBSD executa `podman` nativamente mapeando especificações OCI diretamente para Jails via runtime `runj` e redes Netavark:

```sh
pkg install podman
podman pull freebsd/freebsd-runtime:latest
podman run --rm -it freebsd/freebsd-runtime:latest uname -a
```

---

## 🛡️ Firewall `pf` Moderno

Sintaxe inline com tradução `nat-to` e redirecionamento `rdr-to`:

```pf
pass out on $ext_if inet from !($ext_if) to any nat-to ($ext_if)
pass in on $ext_if proto tcp to any port 80 rdr-to 10.0.0.10 port 8080
```

---

## 💾 OpenZFS, Snapshots & Boot Environments (`bectl`)

```sh
zfs snapshot zroot/data@backup_today
zfs send -i zroot/data@backup_yesterday zroot/data@backup_today | ssh backup-node zfs receive pool/replica
bectl create pre-upgrade
bectl activate pre-upgrade
```

- Use `/usr/libexec/flua` (`libucl`, `jail(3lua)`, `lposix`) para automação leve integrada ao sistema base.
