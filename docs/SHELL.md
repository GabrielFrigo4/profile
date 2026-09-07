# 🐚 Universal Shell Ecosystem

O repositório **[Universal Shell Environment](https://github.com/GabrielFrigo4/Shell)** é o "motor dinâmico" do ecossistema. Ele contém a lógica interativa da linha de comando, prompts otimizados, aliases globais, funções utilitárias e gerenciamento de contexto para todos os ambientes.

Enquanto o `Configuration` cuida do provisionamento estático e dotfiles do host, o `Shell` provê agilidade e ergonomia ao terminal no dia a dia.

---

## 📂 Instalação e Caminhos Padrão

O repositório Shell é clonado globalmente ou localmente por usuário:

```sh
# Instalação Global Recomendada (Linux / FreeBSD / macOS)
sudo git clone "https://github.com/GabrielFrigo4/Shell" "/usr/local/share/shell"

# Executar a instalação escolhendo o contexto desejado:
sh "/usr/local/share/shell/install.sh" --context desktop
# Opções de contexto: desktop, server, container, wsl
```

---

## 🗂️ Arquitetura Modular do Shell

O repositório Shell foi projetado seguindo estritamente os princípios de modularidade e separação de interesses:

```
Shell/
├── core/             # Ciclo de vida principal e carregador do ambiente (environment.sh, vault.sh)
├── context/          # Especializações por tipo de máquina (desktop, server, container, wsl)
├── target/           # Especializações por sistema operacional (linux, freebsd, windows)
├── library/          # Funções utilitárias reutilizáveis (detect.sh, functions.sh)
├── theme/            # Temas visuais e prompts rápidos (bash.sh, zsh.sh)
└── install.sh        # Instalador idempotente
```

---

## 🛠️ A Matriz de Shells Suportados

Para garantir consistência e performance sem adicionar complexidade desnecessária, focamos nos interpretadores mais maduros:

### Ambientes UNIX (Linux, FreeBSD, macOS, WSL2)

- **`sh`**: Shell POSIX puro (`/bin/sh` do FreeBSD, `dash` do Debian). Utilizado em scripts de infraestrutura ultra-leves e rápidos.
- **`bash`**: Presente nativamente na maioria das distribuições Linux e servidores.
- **`zsh`**: Shell interativo padrão diário, altamente configurado com autocompletion e navegação eficiente.

### Ambientes Windows Nativo

- **`pwsh` (PowerShell Core)**: Automação moderna de scripts e manipulação de objetos.
- **`cmd`**: Prompt clássico do Windows com suporte a `clink` para readline.
- **`nushell`**: Shell moderno com dados estruturados para pipelines avançados.
