---
name: xdg-fhs-standards
description: Runbook cognitivo para governança, mapeamento e conformidade estrita com a especificação XDG Base Directory (Config, Data, State, Cache) e Filesystem Hierarchy Standard (FHS), orientando a resolução de caminhos, segregação de privilégios e modularização de runtimes.
---

# 🏛️ XDG Base Directory Specification & FHS Standards

Este runbook define as diretrizes arquiteturais para localização de arquivos, segregação de privilégios e hierarquia de resolução de caminhos no ecossistema soberano, harmonizando a especificação **XDG Base Directory** com o **Filesystem Hierarchy Standard (FHS)** do UNIX.

---

## 🧭 Princípios Fundamentais de Segregação

O ecossistema opera sob uma distinção rigorosa entre dois mundos:

1. **Espaço do Sistema (FHS — Global / Privilegiado):**
    - Diretórios compartilhados entre usuários ou essenciais para a operação do host (`/usr/local/share`, `/etc`).
    - Requer privilégios administrativos (`root` / `sudo` / `doas`) para escrita.
    - **Somente código executável ou dados públicos** podem residir aqui (ex: **Universal Shell** para o par `root` + admin).
    - **PROIBIDO PARA SEGREDOS:** Credenciais, chaves privadas ou tokens NUNCA devem ser armazenados em caminhos de sistema.

2. **Espaço do Usuário (XDG Base Directory — Rootless / Soberano):**
    - Diretórios privativos do usuário dentro de `$HOME` sem necessidade de `sudo`.
    - Isolamento natural com permissões estritas (`0755` para dotfiles, `0700` para segredos).
    - Onde residem **Profile**, **Vault** e a **Suíte de Editores**.

---

## 🗺️ Matriz de Mapeamento XDG vs. FHS

```mermaid
flowchart TD
    subgraph FHS ["🏛️ FHS (Sistema / Global)"]
        F_SHARE["/usr/local/share/<app><br/>(Assets e Runtimes Compartilhados)"]
        F_BIN["/usr/local/bin<br/>(Binários Globais do Host)"]
        F_ETC["/etc<br/>(Configurações Globais da Máquina)"]
    end

    subgraph XDG ["👤 XDG Base Directory (Espaço do Usuário)"]
        X_DATA["$XDG_DATA_HOME (~/.local/share)<br/>(Motores, Runtimes, Plugins, Dados)"]
        X_CONFIG["$XDG_CONFIG_HOME (~/.config)<br/>(Dotfiles, Preferências, Configurações)"]
        X_STATE["$XDG_STATE_HOME (~/.local/state)<br/>(Histórico, Logs de Sessão, Undo)"]
        X_CACHE["$XDG_CACHE_HOME (~/.cache)<br/>(Arquivos Voláteis e Temporários)"]
    end

    F_SHARE -.->|Equivalente Rootless| X_DATA
    F_ETC -.->|Equivalente de Usuário| X_CONFIG
```

| Variável de Ambiente   | Valor Padrão (Fallback) | Papel Arquitetural                                     | Exemplos no Ecossistema                                  |
| :--------------------- | :---------------------- | :----------------------------------------------------- | :------------------------------------------------------- |
| **`$XDG_CONFIG_HOME`** | `~/.config`             | Configurações declarativas e dotfiles (`/etc` usuário) | `~/.config/profile`, `~/.config/nvim`, `~/.config/helix` |
| **`$XDG_DATA_HOME`**   | `~/.local/share`        | Motores, bibliotecas e runtimes (`/usr/share` usuário) | `~/.local/share/shell`, plugins Mason, Elpaca            |
| **`$XDG_STATE_HOME`**  | `~/.local/state`        | Estado persistente que não é configuração pura         | Históricos de shell (`zsh_history`, `bash_history`)      |
| **`$XDG_CACHE_HOME`**  | `~/.cache`              | Dados voláteis, caches de compilação e buffers         | Cache de inicialização do Shell, cache do Elpaca         |

---

## 📐 Cascata de Resolução Canônica do Ecossistema

Para conciliar a pureza modular rootless com a conveniência prática de administradores, o ecossistema adota uma cascata estrita de 4 níveis:

### 1. 🐚 Universal Shell

- **1º (Sistema / Global):** `/usr/local/share/shell` — Padrão de fato para o par `root` + administrador da máquina.
- **2º (XDG Data - Recomendado):** `~/.local/share/shell` — Recomendado filosoficamente pela modularização e independência rootless.
- **3º (XDG Config):** `~/.config/shell` — Ergonomia unificada sob a pasta central de configurações.
- **4º (Home Direta):** `~/.shell` — Atalho clássico e ambiente Windows MSYS2.

### 2. 🎨 Universal Profile

- **1º (XDG Data):** `~/.local/share/profile` — Isolamento rootless para dados do perfil.
- **2º (XDG Config - Padrão):** `~/.config/profile` — Localização canônica dos dotfiles declarativos.
- **3º (Home Direta):** `~/.profile` — Fallback para ambientes POSIX legados.
- **4º (Global - Não Recomendado):** `/usr/local/share/profile` — Suportado defensivamente, mas desaconselhado pois dotfiles pertencem ao usuário.

### 3. 🔐 Universal Vault (`chmod 0700`)

- **1º (XDG Data):** `~/.local/share/vault` — Armazenamento seguro rootless.
- **2º (XDG Config):** `~/.config/vault` — Configuração integrada e isolada.
- **3º (Home Direta - Padrão Universal):** `~/.vault` (Unix) ou `%USERPROFILE%\.vault` (Windows).
- **4º (Global - Estritamente Não Recomendado):** `/usr/local/share/vault` — Permitido apenas para cofre exclusivo do `root`.

> [!IMPORTANT]
> **Recomendado vs. Mais Usado:**
> O termo **"Recomendado"** expressa o ideal de engenharia (desacoplamento, segurança e soberania do usuário sem privilégios).
> O termo **"Padrão de Sistema"** atende à ergonomia prática de estações administradas onde `root` e usuário precisam do mesmo shell interativo. O ecossistema é tolerante e resiliente, operando com perfeição em qualquer camada.

---

## 🔗 Links Oficiais & Fontes Canônicas

- **XDG Base Directory Specification:** <https://specifications.freedesktop.org/> | Especificação Base: <https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html>
- **Filesystem Hierarchy Standard (FHS):** <https://refspecs.linuxfoundation.org/> | Especificação FHS: <https://refspecs.linuxfoundation.org/fhs.shtml>
- **The Open Group (POSIX Base Specifications):** <https://www.opengroup.org/> | Directory Structure: <https://pubs.opengroup.org/onlinepubs/9699919799/>
