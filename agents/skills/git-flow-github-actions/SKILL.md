---
name: git-flow-github-actions
description: Runbook cognitivo para o ciclo completo de entrega contínua soberana, cobrindo hooks self-healing (.githooks), Conventional Commits, pipelines GitHub Actions e busca recursiva topológica (upgit).
---

# 🚀 Git Flow, Quality Gates & GitHub Actions

Esta habilidade orienta o desenvolvedor e o agente de IA na operação, padronização e orquestração do **ciclo completo de entrega contínua soberana**, integrando quality gates com auto-cura em `.githooks/`, Conventional Commits, GitHub Actions e inspeção via GitHub CLI (`gh`).

---

## 🎯 Arquitetura em Quatro Camadas da Entrega Soberana

1. **Shift-Left Local com Auto-Cura (`.githooks/`):**
    - `pre-commit`: auto-cura de modos octais (`0755`/`0644`), whitespace, prettier e banners com `git add` automático.
    - `commit-msg`: validação de Conventional Commits, tipos `sec`/`init`, escopo com ponto (`.`) e auto-normalização de prefixo `chore: `.
    - Referência detalhada: [`references/self-healing-hooks.md`](./references/self-healing-hooks.md).
2. **Operação Git Soberana & Busca Topológica:**
    - Varredura de submódulos e repositórios aninhados via padrão `upgit` (`find ... -print -prune` ordenado por profundidade topológica).
3. **CI Remoto (GitHub Actions):**
    - Matriz multiplataforma (Linux, FreeBSD VM via `vmactions`, macOS, Windows MSYS2).
4. **Observabilidade (gh CLI):**
    - Monitoramento, inspeção de falhas e re-execuções sem sair do terminal.

---

## 🪝 1. Regras Mandatórias de Hooks Locais (`.githooks/`)

1. **Hermeticidade e Autonomia Estrita:** Hooks locais nunca dependem de scripts de IA externos (`~/.gemini/` ou `.agents/`). Lógica expressa em shell POSIX (`sh`) ou utilitários internos do repositório.
2. **Portabilidade Dual:** Shebang `#!/usr/bin/env sh`, sem bashismos ou flags GNU-específicas no FreeBSD.
3. **Permissões e Ativação:** `chmod 0755 .githooks/*` e registro local `git config core.hooksPath .githooks`.

---

## 🐙 2. Protocolo de Git Flow & Commits Atômicos

```sh
git status -s
git diff
git add caminho/para/arquivo.ext
git diff --check --cached
git commit -m "docs(readme): update architecture diagram and install instructions"
git push origin main
```

---

## ⚙️ 3. Engenharia de Pipelines GitHub Actions

Workflows de CI/CD devem residir em `.github/workflows/ci.yml`:

```yaml
concurrency:
    group: ${{ github.workflow }}-${{ github.ref }}
    cancel-in-progress: true

env:
    FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true
```

- **Matriz Multiplataforma:**
    - Linux: `runs-on: ubuntu-latest`
    - FreeBSD VM: `uses: vmactions/freebsd-vm@v1` com `release: "15"`, `usesh: true`
    - Windows MSYS2: `uses: msys2/setup-msys2@v2` com subsistema `UCRT64`
    - macOS: `runs-on: macos-latest`

---

## 🔍 4. Observabilidade & Diagnóstico com GitHub CLI (`gh`)

```sh
gh auth status
gh run list -L 5
gh run view <run-id> --log-failed
gh run rerun <run-id> --failed
gh pr list
gh pr checks <pr-number>
```

---

## 📚 Referências Oficiais & Literatura Recomendada

- **Git SCM — Documentação Oficial de Hooks:** <https://git-scm.com/docs/githooks>
- **Manual Oficial do GitHub CLI (`gh`):** <https://cli.github.com/manual/>
- **GitHub Actions — Documentação Canônica:** <https://docs.github.com/en/actions>
- **Especificação Conventional Commits (v1.0.0):** <https://www.conventionalcommits.org/>
