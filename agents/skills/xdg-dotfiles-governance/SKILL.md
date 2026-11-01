---
name: xdg-dotfiles-governance
description: Runbook cognitivo definitivo para governança de dotfiles, conformidade estrita com a especificação XDG Base Directory, auditoria de symlinks, validação sintática e permissões octais.
---

# 🏛️ Governança de Dotfiles & Especificação XDG Base Directory

Este runbook estabelece as diretrizes normativas para organização de dotfiles, conformidade estrita com a especificação XDG Base Directory, validação sintática declarativa, integridade de symlinks e disciplina de permissões octais em ambientes UNIX/POSIX soberanos.

---

## 🧭 Segregação Canônica XDG Base Directory

Aplicações e dotfiles no espaço do usuário **DEVEM** operar em modo rootless sem privilégios administrativos (`root`/`sudo`), respeitando rigorosamente a hierarquia canônica XDG:

| Variável           | Fallback Padrão            | Finalidade Arquitetural               | Permissões      |
| :----------------- | :------------------------- | :------------------------------------ | :-------------- |
| `$XDG_CONFIG_HOME` | `~/.config`                | Configurações declarativas e dotfiles | `0755` / `0644` |
| `$XDG_DATA_HOME`   | `~/.local/share`           | Runtimes, dados persistentes, plugins | `0755` / `0644` |
| `$XDG_STATE_HOME`  | `~/.local/state`           | Histórico de sessões, logs de runtime | `0755` / `0644` |
| `$XDG_CACHE_HOME`  | `~/.cache`                 | Caches voláteis e dados regeneráveis  | `0755` / `0644` |
| `$XDG_RUNTIME_DIR` | `/tmp` ou `/run/user/$UID` | Sockets IPC, pipes e locks efêmeros   | `0700` / `0600` |

- **Segredos e Credenciais:** Arquivos confidenciais (chaves, tokens) **NUNCA DEVEM** residir no espaço global do sistema (`/etc`) e **DEVEM** possuir permissões restritas (`0700` para diretórios, `0600` para arquivos).
- **Zero-Pollution no `$HOME`:** Softwares **NÃO DEVEM** criar dotfiles soltos na raiz de `$HOME` quando houver suporte a `$XDG_CONFIG_HOME` ou `$XDG_DATA_HOME`.

---

## 📐 Cascata Universal de Resolução POSIX

Scripts e loaders **DEVEM** resolver caminhos de forma defensiva via expansão de parâmetros POSIX:

```sh
config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/appname"
data_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/appname"
state_dir="${XDG_STATE_HOME:-${HOME}/.local/state}/appname"
cache_dir="${XDG_CACHE_HOME:-${HOME}/.cache}/appname"
```

Em ferramentas multiplataforma ou de provisionamento, utilize a cascata de resolução em 4 níveis:

1. **Global / Sistema:** `/usr/local/share/<app>`
2. **XDG Data (Rootless):** `${XDG_DATA_HOME:-${HOME}/.local/share}/<app>`
3. **XDG Config:** `${XDG_CONFIG_HOME:-${HOME}/.config}/<app>`
4. **Fallback Clássico:** `${HOME}/.<app>`

---

## 🔍 Auditoria de Symlinks & Integridade

Links simbólicos órfãos (_dangling symlinks_) quebram pipelines e editores. A integridade **DEVE** ser auditada periodicamente:

```sh
find "${XDG_CONFIG_HOME:-${HOME}/.config}" -maxdepth 3 -xtype l -exec ls -la {} + 2> "/dev/null" || true
find "${HOME}" -maxdepth 1 -xtype l -exec ls -la {} + 2> "/dev/null" || true
```

- Symlinks quebrados **DEVEM** ser reparados na origem ou removidos imediatamente.
- Symlinks em produção **NÃO DEVEM** apontar para árvores de desenvolvimento (`~/Documents/...`).

---

## 🧪 Validação Sintática Declarativa

Arquivos de configuração **DEVEM** ser formalmente validados antes de comitados ou sincronizados:

```sh
find editors terminals tools browsers -name "*.json" -exec python3 -m json.tool {} > "/dev/null" \;
python3 -c 'import yaml, glob; [yaml.safe_load(open(f)) for f in glob.glob("tools/**/*.yaml", recursive=True)]'
python3 -c 'import tomllib, glob; [tomllib.load(open(f, "rb")) for f in glob.glob("tools/**/*.toml", recursive=True)]'
```

---

## 🔒 Governança de Permissões Octais Canônicas

Todo arquivo mantido no repositório **DEVE** seguir a disciplina estrita de permissões de 4 dígitos:

- **Dotfiles, configs e documentação (`*.json`, `*.toml`, `*.md`):** `chmod 0644`
- **Scripts de automação, hooks e loaders (`*.sh`):** `chmod 0755`
- **Diretórios de trabalho padrão:** `chmod 0755`
- **Cofres, chaves privadas e tokens de autenticação:** `chmod 0700` (dirs) / `chmod 0600` (arquivos)

O Git Index **DEVE** registrar modos canônicos `100755` para executáveis e `100644` para dados declarativos.

---

## 📚 Referências Normativas

- **XDG Base Directory Specification:** <https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html>
- **Filesystem Hierarchy Standard (FHS 3.0):** <https://refspecs.linuxfoundation.org/fhs.shtml>
- **POSIX.1-2024 Base Specifications (IEEE Std 1003.1-2024):** <https://pubs.opengroup.org/onlinepubs/9699919799/>
- **JSON (ECMA-404) & YAML & TOML Specs:** <https://www.json.org/> | <https://yaml.org/> | <https://toml.io/>
