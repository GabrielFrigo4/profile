---
name: antifragile-engineering
description: >-
    Engenharia de sistemas antifrágeis, auto-cura em tempo de execução (self-healing),
    cascata ativa de descoberta XDG/FHS, prevenção de falhas cegas e robustez adaptativa
    sob perturbação em scripts POSIX, NuShell, PowerShell, dotfiles e ferramentas CLI.
---

# 🛡️ Antifragile Engineering — Sistemas Resilientes & Auto-Cura

Diretrizes para sistemas e scripts que não apenas resistem a variações ambientais, mas auto-descobrem recursos, curam permissões em voo e reparam o estado da sessão sem intervenções manuais.

---

## 🏛️ 1. Espectro da Resiliência Sistêmica

| Dimensão               | Frágil (Quebra)                      | Robusto (Resiste)                 | Antifrágil (Auto-Cura)                                                       |
| :--------------------- | :----------------------------------- | :-------------------------------- | :--------------------------------------------------------------------------- |
| **Localização**        | Caminho fixo (`~/.app/data`)         | Fallback estático rígido          | Cascata ativa: Env $\rightarrow$ Projeto $\rightarrow$ XDG $\rightarrow$ FHS |
| **Permissões POSIX**   | Aborta (`permissions too open`)      | Exibe aviso pedindo ajuste manual | Auto-cura silenciosa (`chmod 0600`) antes de invocar o binário               |
| **Estado de Sessão**   | Variável vazia quebra o script       | Usa default estático              | Descobre recurso real e reexporta a variável na sessão ativa                 |
| **Encaminhamento CLI** | Alias rígido sem repasse de flags    | Função simples sem encaminhamento | Função com repasse integral de argumentos (`"$@"`, `$args`)                  |
| **Falha de Recurso**   | Aborta com `-i ""` ou `No such file` | Retorna erro limpo                | Verifica vias alternativas (ex.: `ssh-agent`) antes de falhar                |

---

## 📐 2. Os 5 Pilares da Engenharia Antifrágil

1. **Cascata Ativa de Descoberta (Local > Global):**
    1. Variável explícita da sessão com validação física (`[ -f "${VAR}" ]`).
    2. Contexto local do projeto ou diretório ativo do componente (`${APP_HOME}/...`).
    3. Padrão XDG Data (`${XDG_DATA_HOME:-${HOME}/.local/share}/<app>/...`).
    4. Padrão XDG Config (`${XDG_CONFIG_HOME:-${HOME}/.config}/<app>/...`).
    5. Fallback clássico (`${HOME}/.<app>/...`) e espaço global (`/usr/local/share/<app>/...`, `/etc/<app>/...`).
2. **Auto-Cura em Tempo de Voo:** Repare permissões restritas antes de usar credenciais ou chaves:
    ```sh
    if [ -n "${_found_key}" ] && [ -f "${_found_key}" ]; then
        chmod 0600 "${_found_key}" 2> "/dev/null" || true
    fi
    ```
3. **Auto-Correção da Sessão:** Ao resolver dinamicamente um caminho ausente, atualize o ambiente (`export SERVICE_KEY="${_resolved_key}"`) para beneficiar subprocessos.
4. **Zero Falha Cega & Argument Forwarding:** Não injete flags vazias (`-i ""`); preserve argumentos (`"$@"` em POSIX, `...$rest` em NuShell, `@args` em PowerShell).
5. **Invariante Out-of-the-Box:** Registre `0755`/`0644` no Git Index, crie diretórios sob demanda (`mkdir -p`) e aplique auto-cura de bits POSIX em filesystems que não os preservam.

---

## 🛠️ 3. Padrões Multi-Shell & Anti-Patterns (`references/`)

Implementações de referência em POSIX `sh`, NuShell e PowerShell, além de anti-patterns comuns (nil concatenation, parse-time `source` no NuShell e pontes NFS Host/Guest):

- [`references/multi-shell-patterns.md`](references/multi-shell-patterns.md)

---

## 🔗 4. Obras & Fontes Canônicas

- **Taleb, N. N.** _Antifragile: Things That Gain from Disorder_. | **Raymond, E. S.** _The Art of UNIX Programming_.
- **POSIX.1-2024:** <https://pubs.opengroup.org/onlinepubs/9799919799/> | **XDG Base Dir:** <https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html>
