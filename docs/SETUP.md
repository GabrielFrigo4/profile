# 📦 O Repositório Setup (Provisionamento de Sistema Operacional)

> Papel, contratos de interface e integração do repositório **Setup** dentro do **Quarteto de Produtividade**.

---

## 🎯 Visão Geral

O repositório **[Setup](https://github.com/GabrielFrigo4/setup)** é o pilar de infraestrutura do sistema hospedeiro (*Clean Host*). Ele é responsável por todas as tarefas que exigem **privilégios administrativos (`root` / `sudo` / `doas` / Admin)**:

- Instalação e atualização de pacotes do sistema via `dnf`, `apt`, `pkg` e `winget`.
- Configuração de drivers de hardware, subsistema de som, aceleração gráfica e Wayland.
- Provisionamento de subsistemas de containers (**Incus**, **Podman**, **Docker**) e **FreeBSD Jails**.
- Automações de inicialização do kernel, sysctl e storage ZFS.

---

## 🚀 Como o Profile se Conecta ao Setup

1. O **Setup** é executado primeiro no ciclo de vida da máquina (modelo *Zero-Clone* via GitHub web ou `curl | sh`).
2. O **Setup** instala os editores gráficos (VS Code, Zed, Antigravity) e dependências básicas de sistema.
3. Em seguida, o **Profile** entra em ação no espaço do usuário (`$HOME`), aplicando dotfiles estáticos e runbooks cognitivos através de links simbólicos (`ln -sf`).

---

## 🔗 Referências

- Repositório oficial: **[Setup no GitHub](https://github.com/GabrielFrigo4/setup)**
- Manifesto federado: **[ENVIRONMENT.md](../ENVIRONMENT.md)**
- Princípios de engenharia: **[PRINCIPLES.md](../PRINCIPLES.md)**
