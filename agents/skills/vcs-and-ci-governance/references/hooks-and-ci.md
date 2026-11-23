# 🪝 Self-Healing Hooks, Travessia Topológica & CI Portátil

> Arquitetura detalhada de quality gates locais e pipelines de integração contínua independentes de plataforma.

---

## 1. Self-Healing Hooks (`.githooks/`)

- **`pre-commit`:**
    1. Inspeciona arquivos staged (`git diff --cached --name-only --diff-filter=d`) e aplica `chmod 0755` + `git update-index --chmod=+x` em hooks e arquivos iniciados por `#!`, ou `0644` + `--chmod=-x` nos demais.
    2. Normaliza trailing whitespace e finais de linha conforme `.gitattributes`.
    3. Executa formatadores declarativos (Prettier) e corretor de réguas estruturais nos arquivos staged, re-estagiando automaticamente com `git add`.
    4. Bloqueia commits se detectar conflitos, shebangs rígidos, redirects sem aspas, escapes octais ou erros de sintaxe (`sh -n`, `zsh -n`, `bash -n`, `ksh -n`, `py_compile`).
- **`commit-msg`:**
    - Aceita escopos com ponto (`^([a-zA-Z]+)(\([a-zA-Z0-9_,.-]+\))?:\s*(.*)$`).
    - Normaliza o tipo para minúsculas, prefixa `chore: ` caso ausente e exige ao menos `8` caracteres.

---

## 2. Busca Recursiva Topológica com `-prune`

Localiza repositórios raiz, submódulos e worktrees em profundidade arbitrária sem percorrer `.git/` internos:

```sh
find . \( -type d -name ".git" -print -prune \) -o \( -type f -name ".git" -print \) 2> "/dev/null" | \
	awk '{ n=split($0, a, "/"); print n, $0 }' | \
	sort -n -k1,1 | \
	cut -d' ' -f2-
```

---

## 3. Diretrizes de Pipelines CI/CD Multiplataforma

- **Cancelamento de Execuções Redundantes:** Configure `concurrency` por workflow e ref para evitar filas acumuladas em pushes consecutivos.
- **Verificações Obrigatórias:**
    1. Integridade de submódulos quando `.gitmodules` existir.
    2. Ausência de marcadores de conflito (`<<<<<<<`, `>>>>>>>`) e erros de whitespace (`git diff --check`).
    3. Auditoria de modos do índice Git (`100755` vs `100644`) e finais de linha (`eol=lf`).
    4. Política estática (shebangs `#!/usr/bin/env`, zero octais ANSI, redirects protegidos, ausência de caminhos pessoais hardcoded).
    5. Validação sintática multi-shell e checagem de formatação declarativa.
- **Plataformas Alvo:** Linux nativo, VMs FreeBSD (lembrando de alocar PTY com `script -q /dev/null` em testes interativos `-i`), macOS e Windows MSYS2 (`UCRT64`).

---

## 4. Observabilidade via CLI (`gh`)

```sh
gh auth status
gh run list -L 5
gh run view <run-id> --log-failed
gh run rerun <run-id> --failed
gh pr list
gh pr checks <pr-number>
```
