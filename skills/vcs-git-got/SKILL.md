---
name: vcs-git-got
description: Runbook cognitivo para controle de versão soberano com Git e Game of Trees (Got), cobrindo interoperabilidade no mesmo repositório .git, tog, convenções de commit, automação e arquitetura DVCS.
---

# 🌳 VCS Soberano: Git & Game of Trees (Got)

Esta habilidade orienta o desenvolvedor e o agente de IA no domínio dos **Sistemas de Controle de Versão Distribuídos (DVCS)** no ecossistema soberano, estabelecendo as diretrizes operacionais, a coexistência harmoniosa entre **Git** e **Game of Trees (Got)**, e as boas práticas de histórico limpo e rastreabilidade.

---

## 🎯 Por que Git e Got Coexistem?

O ecossistema adota uma abordagem pragmática: **o formato de repositório Git é o padrão universal de armazenamento, mas a interface de linha de comando não precisa ser monopólio do binário `git`**.

```mermaid
flowchart TD
    subgraph Storage ["💾 Formato Universal no Disco"]
        REPO[".git / Bare Repository<br/>• Objetos (Blobs, Trees, Commits, Tags)<br/>• Referências e Branches compatíveis"]
    end

    subgraph Got ["🌳 Game of Trees (Got) & tog"]
        G1["got checkout / got update"]
        G2["got commit / got diff / got status"]
        G3["tog (Navegador TUI ultrarrápido)"]
        G4["CLI minimalista estilo OpenBSD/UNIX"]
    end

    subgraph Git ["🐙 Git CLI & Automação"]
        T1["git submodule / git push / git fetch"]
        T2["Git Hooks (.githooks/)"]
        T3["Pipelines CI/CD & GitHub Actions"]
        T4["Operações complexas de plumbing"]
    end

    REPO --> Got
    REPO --> Git
```

### O Contraste Filosófico:

1. **Game of Trees (Got) — (<https://gameoftrees.org/>):**
    - Criado pela equipe do **OpenBSD** (liderado por Stefan Sperling), o Got prioriza uma interface de linha de comando simples, intuitiva, previsível e estritamente aderente à filosofia UNIX.
    - **Compatibilidade Nativa:** O Got opera diretamente sobre repositórios no formato Git (lê e grava árvores, blobs e commits de um repositório `.git` ou bare repository sem conversões).
    - **Segurança e Confinamento:** No OpenBSD, o Got utiliza `pledge(2)` e `unveil(2)` para proteção contra execução arbitrária e vazamentos de caminho.
    - **TUI Embutida (`tog`):** Acompanha o utilitário interativo `tog(1)` para navegação visual em terminais com velocidade instantânea.
2. **Git — (<https://git-scm.com/>):**
    - O padrão dominante da indústria mundial de software.
    - Essencial para automações de infraestrutura, sincronização com remotos distribuídos (`git push`/`fetch`), orquestração de submódulos e execução de hooks de qualidade (`.githooks/`).

---

## 🌳 1. Guia Operacional com Game of Trees (Got)

Para desenvolvedores em **OpenBSD**, **FreeBSD** (`pkg install got`) e **Linux** (`got-portable`):

### Fluxo de Trabalho Básico:

```sh
# 1. Clonar um repositório Git remoto para um bare repository local:
got clone https://github.com/usuario/repo.git repo.git

# 2. Criar uma árvore de trabalho (work tree) a partir do repositório clonado:
got checkout repo.git work-tree-repo

# 3. Inspecionar alterações de forma limpa e concisa:
cd work-tree-repo
got status

# 4. Visualizar diferenças sem saídas poluídas:
got diff

# 5. Criar commit atômico:
got commit -m "feat(core): implement robust input parsing"

# 6. Atualizar a work tree com alterações do repositório base:
got update

# 7. Sincronizar (enviar) alterações de volta para o remote Git:
got send
```

### O Navegador Interativo `tog`:

O Got inclui nativamente o utilitário `tog`, permitindo inspecionar o grafo de commits sem ferramentas pesadas externas:

```sh
# Navegar interativamente pelo histórico de commits:
tog log

# Inspecionar diffs linha por linha interativamente:
tog diff

# Visualizar anotações de autoria (blame) em tempo real:
tog blame arquivo.c

# Navegar na árvore de arquivos do repositório:
tog tree
```

---

## 🐙 2. Padrões de Excelência com Git

No desenvolvimento diário e automações de CI/CD:

### 1. Commits Atômicos e Semânticos

- Cada commit deve representar **uma única unidade lógica de alteração** que não quebre a compilação nem a suíte de testes.
- **Convenção de Mensagens:**
    - `feat(<escopo>): <descrição no imperativo>` — nova funcionalidade.
    - `fix(<escopo>): <descrição no imperativo>` — correção de bug.
    - `docs(<escopo>): <descrição no imperativo>` — alterações exclusivamente em documentação.
    - `refactor(<escopo>): <descrição no imperativo>` — alteração interna de código sem alteração de comportamento.
    - `chore(<escopo>): <descrição no imperativo>` — ajustes em build, submódulos ou dependências.

### 2. Normalização Universal de Finais de Linha (`LF`)

Para evitar poluição de diffs entre Linux, FreeBSD, macOS e Windows (MSYS2), todo repositório DEVE conter um arquivo `.gitattributes` na raiz:

```gitattributes
# Forcar rigorosamente quebras de linha UNIX (LF)
* text=auto eol=lf
*.sh text eol=lf
*.md text eol=lf
Makefile text eol=lf
```

### 3. Governança via Git Hooks Portáteis

- Conforme o padrão do ecossistema, hooks de validação residem em `.githooks/` e utilizam o shebang universal:
    ```sh
    #!/usr/bin/env sh
    ```
- O `pre-commit` valida whitespace (`git diff --check --cached`), sintaxe de shell (`sh -n`), integridade de links e formatação Markdown.
- O `commit-msg` valida a estrutura semântica da mensagem antes de gravar o commit.

---

## 🔄 3. Padrão de Sincronização Resiliente & Auto-Cura de Repositórios

Em estações de trabalho heterogêneas (FreeBSD, Linux, macOS), discrepâncias de permissões POSIX (`filemode` 0755 vs 0644) ou edições locais temporárias podem deixar árvores de trabalho em estado sujo (_dirty_). Sem um tratamento defensivo prévio, operações de `git pull` podem falhar por conflito ou entrar em ciclos viciosos de `stash` (quando permissões alteradas são salvas e restauradas repetidamente).

Para garantir que comandos de atualização (`update-shell`, `upsh`, `update-profile`, `update-vault`, `update-editors`, `update-git`) executem com resiliência total, adota-se a arquitetura de **4 fases**:

```mermaid
flowchart TD
    A["Início: Inspeção do Repositório"] --> B{"Há diff real de código<br/>ou arquivos untracked?"}
    B -- "Não (Apenas drift de filemode)" --> C["Auto-cura: checkout -- .<br/>(Sem poluir a pilha com stashes)"]
    B -- "Sim (Modificações reais)" --> D["Isolamento: git stash push -u<br/>com timestamp rastreável"]
    C --> E["Cascata de Sincronização:<br/>--ff-only ➔ --rebase ➔ pull"]
    D --> E
    E --> F{"Stash defensivo criado?"}
    F -- "Sim" --> G["git stash pop<br/>(Drop defensivo se status limpo)"]
    F -- "Não" --> H["Garantia Canônica Pós-Pull:<br/>chmod 0755 em *.sh e .githooks/"]
    G --> H
    H --> I["Submódulos recursivos (se .gitmodules existir)"]
```

### Arquitetura de Implementação Canônica (POSIX Shell):

```sh
_content_diff="$(command git -C "${_target}" diff -U0 2> "/dev/null" | grep '^[+-][^+-]' || true)"
if [ -z "${_content_diff}" ] && [ -z "$(command git -C "${_target}" status --porcelain 2> "/dev/null" | grep '^??' || true)" ]; then
	command git -C "${_target}" checkout -- . > "/dev/null" 2>&1 || true
fi

_stash_created=""
if [ -n "$(command git -C "${_target}" status --porcelain 2> "/dev/null")" ]; then
	command git -C "${_target}" stash push -u -m "autostash-before-update-$(date +%s)" > "/dev/null" 2>&1 && _stash_created="1"
fi

_pull_ok=0
if command git -C "${_target}" pull --ff-only > "/dev/null" 2>&1; then
	_pull_ok=1
elif command git -C "${_target}" pull --rebase > "/dev/null" 2>&1; then
	_pull_ok=1
elif command git -C "${_target}" pull > "/dev/null" 2>&1; then
	_pull_ok=1
fi

if [ "${_pull_ok}" -eq 1 ]; then
	if [ "${_stash_created}" = "1" ]; then
		command git -C "${_target}" stash pop > "/dev/null" 2>&1 || true
	fi
	find "${_target}" -maxdepth 2 -type f \( -name "*.sh" -o -path "*/.githooks/*" \) -exec chmod 0755 {} + 2> "/dev/null" || true
fi
```

---

## 🧭 Quando Usar Cada Ferramenta?

| Cenário / Tarefa                              | Ferramenta Recomendada   | Justificativa Técnica                                                                      |
| :-------------------------------------------- | :----------------------- | :----------------------------------------------------------------------------------------- |
| **Navegação visual no histórico no terminal** | **`tog` (Got)**          | Ultrarrápido, nativo, sem dependências e com atalhos de teclado vi.                        |
| **Edição e commits em estações BSD/POSIX**    | **`got`**                | Sintaxe limpa, sem a prolixidade confusa de comandos modernos do Git (`switch`/`restore`). |
| **CI/CD, GitHub Actions e automações**        | **`git`**                | Suporte universal nativo em todos os runners e ferramentas de esteira.                     |
| **Gerenciamento de Submódulos**               | **`git submodule`**      | Suporte consolidado a árvores aninhadas com rastreamento determinístico de commit hashes.  |
| **Hooks de Governança Local**                 | **`git` (`.githooks/`)** | Disparo atômico e transparente no fluxo de trabalho de qualquer desenvolvedor.             |

---

## 📚 Literatura de Referência & Links Oficiais

Recomenda-se enfaticamente ao agente de IA e aos operadores o estudo das fontes canônicas de versionamento de software:

- **Game of Trees (Got) Oficial:** <https://gameoftrees.org/>
- **Manuais do Got e tog:** <https://gameoftrees.org/manual.html>
- **Código Fonte Oficial do Got:** <https://gameoftrees.org/code.html>
- **Git Oficial:** <https://git-scm.com/>
- **Livro Canônico Pro Git (Scott Chacon & Ben Straub, 2ª edição, Apress):**
    - Leitura indispensável sobre a estrutura interna de objetos e grafos direcionados acíclicos (DAG): <https://git-scm.com/book/en/v2>
- **Filosofia de Design UNIX:** _The Art of UNIX Programming_ (Eric S. Raymond) — Regra da Modularidade e Regra da Transparência em ferramentas de versão: <http://www.catb.org/~esr/writings/taoup/html/>
