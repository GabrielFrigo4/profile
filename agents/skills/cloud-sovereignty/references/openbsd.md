# 🐡 OpenBSD: Segurança de Borda, Roteamento & Bastions

O OpenBSD é a escolha primária para nós de borda (edge routers, concentradores VPN, balanceadores TLS e firewalls defensivos) em arquiteturas de Cloud-Exit soberano.

---

## 🛡️ Firewall Packet Filter (`pf`) Canônico

O Packet Filter original do OpenBSD oferece filtragem determinística com mitigação ativa de intrusões:

```pf
# /etc/pf.conf
set skip on lo

# Bloqueio padrão com política estrita
block drop all

# Inspeção com modulação de estados e proteção SYN
pass in on egress proto tcp to port { 22 80 443 } modulate state (max-src-conn 50, max-src-conn-rate 15/5)
pass out on egress modulate state
```

---

## 🔒 Confinamento de Processos: `pledge` & `unveil`

No OpenBSD, binários de sistema e serviços são confinados pelo kernel:

1. **`pledge(2)`:** Restringe as chamadas de sistema permitidas para um processo (ex: apenas `stdio`, `rpath`, `inet`).
2. **`unveil(2)`:** Oculta partes inteiras do sistema de arquivos para a aplicação. Mesmo sob invasão remota com execução de código, o invasor é incapaz de ler `/etc/master.passwd` ou executar comandos fora dos caminhos revelados.

---

## 🌐 Roteamento e Terminação Segura

- **`relayd`:** Balanceador de carga e proxy reverso leve com terminação TLS e verificação de saúde integrada.
- **`bgpd` & `ospfd`:** Daemons de roteamento dinâmico do sistema base para interconexão BGP multihomed em data centers e pontos de troca de tráfego (IXPs).
- **WireGuard Nativo (`wg`):** Criação de túneis de malha segura entre filiais e hosts de borda diretamente no kernel.
