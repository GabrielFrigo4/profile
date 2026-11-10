# 🪝 Self-Healing Hooks & Recursive Topological Git Traversal

> Especificação técnica de hooks com auto-cura no Git local e busca recursiva topológica de repositórios no ecossistema.

---

## 1. Padrão de Self-Healing Hooks (`.githooks/`)

Diferente de hooks punitivos tradicionais que apenas abortam o commit diante de desvios menores, os **Self-Healing Hooks** corrigem ativamente a árvore staged e regravam o índice antes da validação final:

### Pre-Commit Auto-Cura (`.githooks/pre-commit`)

1. **Auto-Cura de Modos Octais:**
    - Inspeciona arquivos staged com `git diff --cached --name-only --diff-filter=d`.
    - Detecta scripts e executáveis por extensão (`.sh`, `.githooks/*`) ou shebang (`#!` na primeira linha).
    - Aplica `chmod 0755` e sincroniza o índice Git com `git update-index --chmod=+x`.
    - Arquivos regulares (configs, documentos, código-fonte) recebem `chmod 0644` e `git update-index --chmod=-x`.
2. **Whitespace & Prettier:**
    - Remove trailing whitespace e corrige finais de linha UNIX (`LF`).
    - Dispara formatação Prettier onde aplicável, seguida de `git add` automático para re-estagiar as correções.
3. **Geometria de Banners:**
    - Executa auditores estruturais com flag `--fix` para ajustar réguas de 32 e 64 colunas, estagiando os arquivos corrigidos.

### Commit-Msg Auto-Cura (`.githooks/commit-msg`)

1. **Escopo Flexível com Ponto:**
    - O padrão regex aceita ponto (`.`) em escopos técnicos: `^([a-zA-Z]+)(\([a-zA-Z0-9_.-]+\))?:\s*(.*)$`.
    - Permite escopos como `feat(sync.sh): ...` ou `fix(gtk-3.0): ...`.
2. **Tipos Semânticos Canônicos:**
    - Reconhece os tipos: `add`, `update`, `fix`, `docs`, `feat`, `chore`, `refactor`, `style`, `ci`, `test`, `sec`, `init`.
3. **Auto-Normalização:**
    - Converte o tipo para minúsculas (`type.lower()`).
    - Normaliza espaçamento entre delimitadores.
    - Aplica automaticamente o prefixo `chore: ` caso a mensagem seja enviada sem prefixo semântico válido.

---

## 2. Busca Recursiva Topológica com `-prune` (Padrão `upgit`)

Para atualizar ou inspecionar repositórios Git aninhados e submódulos em profundidade arbitrária sem invadir as entranhas internas do Git:

```sh
find . \( -type d -name ".git" -print -prune \) -o \( -type f -name ".git" -print \) 2> "/dev/null" | \
	awk '{ n=split($0, a, "/"); print n, $0 }' | \
	sort -n -k1,1 | \
	cut -d' ' -f2-
```

### Justificativas Técnicas:

1. **Eficiência e Proteção com `-prune`:**
    - Ao encontrar um diretório `.git`, o comando imprime o caminho e poda a árvore (`-print -prune`), impedindo a travessia de objetos, logs e refs internas.
2. **Submódulos e Worktrees:**
    - Mapeia diretórios `.git` raiz e arquivos pontuais `.git` (usados por submódulos e worktrees) via `-type f -name ".git"`.
3. **Ordenação Topológica:**
    - O pipeline `awk` conta o número de delimitadores `/` no caminho (`split($0, a, "/")`).
    - O `sort -n -k1,1` classifica da raiz para as folhas mais profundas, garantindo que repositórios superiores sejam avaliados na ordem correta.
