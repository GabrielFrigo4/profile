---
name: dotfiles-doctor
description: Runbook cognitivo para verificação de integridade de links simbólicos, sintaxe de configurações (JSON, YAML, TOML) e permissões de dotfiles.
---

# 🩺 Dotfiles Doctor Skill

Esta habilidade orienta o agente de inteligência artificial na inspeção minuciosa dos arquivos de configuração e links simbólicos mantidos pelo repositório **Profile**.

---

## 🔍 Procedimento de Inspeção

### 1. Detecção de Links Quebrados (_Dangling Symlinks_)

Verificar se algum link simbólico aponta para um alvo inexistente no `$HOME` ou `~/.config`:

```sh
find "${HOME}/.config" -maxdepth 3 -xtype l -exec ls -la {} + 2>/dev/null || true
find "${HOME}" -maxdepth 1 -xtype l -exec ls -la {} + 2>/dev/null || true
```

- Se algum link quebrado for detectado, identificar se o repositório fonte foi movido ou se o arquivo correspondente foi deletado.

### 2. Validação Sintática de Arquivos de Configuração

Validar que nenhum dotfile estático contém erros gramaticais que impeçam o carregamento por editores e ferramentas:

```sh
# Validar arquivos JSON (Zed, VS Code, Windows Terminal)
find editors terminals tools browsers -name "*.json" -exec python3 -m json.tool {} > "/dev/null" \;

# Validar arquivos YAML (Clangd)
python3 -c '
import yaml, glob
for f in glob.glob("tools/**/*.yaml", recursive=True):
    yaml.safe_load(open(f))
'

# Validar arquivos TOML (StyLua)
python3 -c '
import tomllib, glob
for f in glob.glob("tools/**/*.toml", recursive=True):
    tomllib.load(open(f, "rb"))
'
```

### 3. Validação de Permissões Canônicas

Garantir que arquivos em `Profile/` não possuam permissões de execução desnecessárias:

- Dotfiles e documentação: `0644`
- Scripts de sincronização (`sync-*.sh`): `0755`
