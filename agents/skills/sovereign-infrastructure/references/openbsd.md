# 🐡 OpenBSD: Segurança de Borda, Roteamento & Bastions

O OpenBSD atua como camada defensiva primária para roteadores de borda, concentradores VPN, balanceadores TLS e firewalls determinísticos.

---

## 🛡️ Firewall Packet Filter (`pf`)

```pf
set skip on lo
block drop all
pass in on egress proto tcp to port { 22 80 443 } modulate state (max-src-conn 50, max-src-conn-rate 15/5)
pass out on egress modulate state
```

---

## 🔒 Confinamento de Processos: `pledge` & `unveil`

- **`pledge(2)`:** Restringe em tempo de execução o subconjunto de syscalls permitidas ao processo (ex.: `stdio`, `rpath`, `inet`).
- **`unveil(2)`:** Oculta o restante da árvore de diretórios do processo, impedindo acesso a arquivos fora dos caminhos explicitamente liberados.

---

## 🌐 Roteamento & Proxies Nativos

- **`relayd`:** Proxy reverso e balanceador de carga com terminação TLS e checagens de saúde integradas.
- **`bgpd` / `ospfd`:** Daemons nativos de roteamento dinâmico para interconexão BGP multihomed.
- **WireGuard (`wg`):** Túneis criptográficos integrados diretamente ao kernel para malhas privadas entre hosts.
