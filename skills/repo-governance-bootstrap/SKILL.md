---
name: repo-governance-bootstrap
description: Runbook cognitivo para estruturar, auditar e atualizar a governança canônica (.agents, .githooks, .github, AGENTS.md, PRINCIPLES.md, Makefile) em qualquer repositório existente.
---

# 🏛️ Repo Governance Bootstrap Skill

Esta habilidade orienta o agente de IA na injeção, auditoria e padronização da suíte completa de governança e engenharia rigorosa em repositórios novos ou existentes no ecossistema de **Gabriel Frigo**.

---

## 🎯 Invariantes & A Regra de Ouro

> [!IMPORTANT]
> **A Regra de Ouro do Agente:** Ao entrar em qualquer diretório de repositório, o agente DEVE SEMPRE ler os arquivos `AGENTS.md`, `PRINCIPLES.md` e a pasta `.agents/` daquele repositório antes de realizar qualquer alteração.

Toda governança implantada por esta skill deve garantir:

1. **Makefile POSIX Silencioso:**
    ```makefile
    .POSIX:
    .SILENT:

    MAKEFLAGS += --no-print-directory -s
    ```
2. **Padrão de Comentários em Três Camadas (Regra do Não-Vazamento):**
    - Header Banner: exatamente 64 hífens (`# ----------------------------------------------------------------`).
    - Seções Estruturais: réguas de 32 caracteres (`### ================================` e `### --------------------------------`). Título $\le$ 32 caracteres.
    - Zero Comentários Narrativos: código autoexplicativo, blocos separados por linhas em branco.
3. **Githooks POSIX Defensivos:** Executáveis via `#!/usr/bin/env sh`, permissão `chmod 0755`, sem bashismos.
4. **Permissões Canônicas em 4 Dígitos Octais:** `chmod 0755`, `chmod 0644`, `chmod 0700`, `chmod 0600`.
5. **Os 18 Princípios de Engenharia:** 17 Princípios UNIX (Eric S. Raymond) + Soberania do Usuário.
6. **Hermeticidade e Isolamento de Git Hooks:** Os hooks em `.githooks/` devem ser 100% autônomos. NUNCA devem chamar scripts contidos em skills de IA externas ou globais. Toda automação do hook deve usar utilitários locais do repositório (`scripts/` locais) ou lógica direta em POSIX `/bin/sh`.

---

## 📋 Checklist de Arquivos a Gerar / Auditar

```
<repo-root>/
├── AGENTS.md                  # Briefing de IA, identidade, regras críticas e referências
├── PRINCIPLES.md              # 18 Princípios de Engenharia contextualizados ao projeto
├── Makefile                   # Orquestrador POSIX silencioso compatível com bmake e gmake
├── .agents/
│   ├── rules/                 # Regras contextuais ativas (clean-code, linguagem, etc.)
│   └── skills/                # Procedimentos e runbooks locais do projeto
├── .githooks/
│   ├── pre-commit             # Quality gate (whitespace, sintaxe, quoting, clean code)
│   └── commit-msg             # Validador semântico (add:, fix:, feat:, docs:, etc.)
└── .github/
    └── workflows/
        └── ci.yml             # Pipeline de integração contínua multiplataforma
```

---

## 🛠️ Procedimento Operacional Passo a Passo

### Passo 1: Diagnóstico e Leitura Inicial

1. Identifique as linguagens principais do repositório (C, C++, Go, Shell, Python, LaTeX, etc.).
2. Identifique ferramentas de build existentes e leia os arquivos `README.md` e manifestos de dependências.

### Passo 2: Estruturação do `AGENTS.md`

Crie ou atualize o `AGENTS.md` no padrão institucional:

- Título e subtítulo com emoji temático.
- Seção **1. Identidade e Papel**.
- Seção **2. Regras Críticas para Agentes de IA** (incluindo a Regra de Ouro e limites estritos).
- Seção **3. Regra da Proatividade e Correção Contínua (Boy Scout Rule)**: Orientação mandante para o agente corrigir ativamente qualquer desvio encontrado.
- Seção **4. Estrutura do Repositório** (árvore ASCII limpa).
- Seção **5. Comandos de Verificação Rápida** (tabela com alvos do Makefile).
- Seção **6. Referências Obrigatórias** (links para `PRINCIPLES.md` e `.agents/`).

### Passo 3: Criação do `PRINCIPLES.md` Contextualizado

Adapte os **18 Princípios de Design** à realidade técnica do repositório:

- Não copie cegamente textos de outros projetos (ex: falar de provisionamento de pacotes num projeto de IA ou em C puro).
- Traduza cada uma das 17 regras UNIX + Soberania do Usuário para o domínio exato do projeto.
- Conclua com as diretrizes de **Clean Code** e a arquitetura de comentários em 3 camadas.

### Passo 4: Padronização do `Makefile`

Garanta a presença do cabeçalho canônico:

```makefile
.POSIX:
.SILENT:

MAKEFLAGS += --no-print-directory -s
```

- Utilize `CC ?= cc` e `CXX ?= c++`.
- Utilize `$(MAKE) -C subdir target` de forma limpa.
- Utilize operador `!=` para atribuição de comandos de shell: `VAR != command`.
- Remova `@` redundantes de receitas.
- Teste a sintaxe tanto com `make -n` quanto com `bmake -n`.

### Passo 5: Implantação de `.githooks/`

1. Instale `pre-commit` com validações de:
    - `git diff --check --cached` (whitespace e quebras de linha).
    - Ausência de binários e segredos staged.
    - Validação de sintaxe dos scripts de shell (`sh -n` ou `bash -n` quando aplicável).
    - Validação de código Python (`py_compile`) ou C/C++ se aplicável.
    - Enforcing de aspas em redirecionamentos (`> "/dev/null"`).
    - Prettier para arquivos Markdown staged (`prettier --check`).
2. Instale `commit-msg` com validação de formato semântico (`<tipo>: <descrição>`).
3. Aplique permissão: `chmod 0755 .githooks/*`.
4. Configure no Git: `git config core.hooksPath .githooks`.

### Passo 6: Criação de `.agents/rules/`

Crie regras ativas com frontmatter YAML (`globs:`, `always_on: true`):

- Regra de Clean Code e proibição de comentários narrativos.
- Regra de padrões de código da linguagem principal do projeto.

---

## 🧪 Validação Final

Após aplicar o bootstrap, execute:

```sh
make -n && bmake -n
find . -name "*.sh" -not -path "*/.git/*" -exec sh -n {} +
./.githooks/pre-commit
```

Tudo deve passar com **0 erros** e aprovação total.

---

## 📚 Literatura de Referência & Ferramentas Oficiais

Recomenda-se enfaticamente ao agente de IA e aos operadores o estudo das referências canônicas de governança:

- **Git SCM Oficial:** <https://git-scm.com/> | Hooks: <https://git-scm.com/docs/githooks>
- **Livro Canônico Pro Git (Scott Chacon & Ben Straub):** <https://git-scm.com/book/en/v2>
- **Prettier Code Formatter:** <https://prettier.io/>
- **ShellCheck Linter:** <https://www.shellcheck.net/>
- **Conventional Commits Specification:** <https://www.conventionalcommits.org/>
