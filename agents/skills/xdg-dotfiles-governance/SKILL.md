---
name: xdg-dotfiles-governance
description: >-
    Governança de dotfiles declarativos, conformidade com a especificação XDG Base
    Directory, cascata de resolução Local > Global, auditoria POSIX de symlinks,
    validação sintática de JSON/JSONC/YAML/TOML e disciplina de permissões octais.
---

# 🏛️ Governança de Dotfiles & Especificação XDG Base Directory

Diretrizes normativas para organização de dotfiles rootless, precedência Local > Global, integridade de links simbólicos, validação sintática declarativa e permissões octais.

---

## 🧭 1. Segregação Canônica XDG Base Directory

Aplicações e dotfiles no espaço do usuário operam em modo rootless sem privilégios administrativos (`root`/`sudo`), respeitando a hierarquia XDG:

| Variável           | Fallback Padrão            | Finalidade Arquitetural               | Permissões      |
| :----------------- | :------------------------- | :------------------------------------ | :-------------- |
| `$XDG_CONFIG_HOME` | `~/.config`                | Configurações declarativas e dotfiles | `0755` / `0644` |
| `$XDG_DATA_HOME`   | `~/.local/share`           | Runtimes, dados persistentes, plugins | `0755` / `0644` |
| `$XDG_STATE_HOME`  | `~/.local/state`           | Histórico de sessões, logs de runtime | `0755` / `0644` |
| `$XDG_CACHE_HOME`  | `~/.cache`                 | Caches voláteis e dados regeneráveis  | `0755` / `0644` |
| `$XDG_RUNTIME_DIR` | `/tmp` ou `/run/user/$UID` | Sockets IPC, pipes e locks efêmeros   | `0700` / `0600` |

- **Segredos e Credenciais:** Arquivos confidenciais nunca residem em `/etc` e exigem permissões restritas (`0700` diretórios, `0600` arquivos).
- **Zero-Pollution no `$HOME`:** Prefira `$XDG_CONFIG_HOME` e `$XDG_DATA_HOME` antes de criar dotfiles na raiz de `$HOME`.

---

## 📐 2. Cascata Universal de Resolução POSIX (Local > Global)

Resolva caminhos com precedência estrita **Local > Global** usando expansão de parâmetros POSIX:

1. **Variável Explícita de Sessão:** `${APP_DIR}` ou `${APP_CONFIG}` quando definida e existente.
2. **Contexto Local do Projeto:** `./.<app>/` ou manifesto local no diretório corrente.
3. **Escopo do Usuário (XDG Data $\rightarrow$ XDG Config $\rightarrow$ Fallback Home):**
    - `${XDG_DATA_HOME:-${HOME}/.local/share}/<app>`
    - `${XDG_CONFIG_HOME:-${HOME}/.config}/<app>`
    - `${HOME}/.<app>`
4. **Escopo Global do Sistema:** `/usr/local/share/<app>` $\rightarrow$ `/etc/<app>`.

```sh
config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/appname"
data_dir="${XDG_DATA_HOME:-${HOME}/.local/share}/appname"
state_dir="${XDG_STATE_HOME:-${HOME}/.local/state}/appname"
cache_dir="${XDG_CACHE_HOME:-${HOME}/.cache}/appname"
```

---

## 🔍 3. Auditoria POSIX de Symlinks & Validação Declarativa

Verifique symlinks órfãos de forma portátil (sem `-xtype l` exclusivo do GNU find):

```sh
find "${XDG_CONFIG_HOME:-${HOME}/.config}" -maxdepth 3 -type l -exec sh -c 'for l; do [ -e "$l" ] || ls -la "$l"; done' sh {} + 2> "/dev/null" || true
find "${HOME}" -maxdepth 1 -type l -exec sh -c 'for l; do [ -e "$l" ] || ls -la "$l"; done' sh {} + 2> "/dev/null" || true
```

- Symlinks em produção não devem apontar para árvores de desenvolvimento (`<dev-hub>/...`).
- **Validação Sintática (JSON vs. JSONC):** Arquivos `.json` estritos podem ser validados com `json.load`; configurações de editores em **JSONC** (que contêm comentários `//` / `/* */` e vírgulas finais) exigem sanitização prévia de comentários/trailing commas antes do parser JSON padrão.

```sh
python3 -c 'import yaml, glob; [yaml.safe_load(open(f)) for f in glob.glob("config/**/*.yaml", recursive=True)]'
python3 -c 'import tomllib, glob; [tomllib.load(open(f, "rb")) for f in glob.glob("config/**/*.toml", recursive=True)]'
```

---

## 🔒 4. Permissões Octais & Referências

- **Dotfiles, configs e docs (`*.json`, `*.toml`, `*.md`):** `0644` (`100644` no Git Index).
- **Scripts de automação, hooks e entrypoints (`#!`):** `0755` (`100755` no Git Index).
- **Cofres, chaves privadas e tokens:** `0700` (diretórios) / `0600` (arquivos).
- **Specs:** [XDG Base Directory](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) | [FHS 3.0](https://refspecs.linuxfoundation.org/fhs.shtml) | [POSIX.1-2024](https://pubs.opengroup.org/onlinepubs/9699919799/)
