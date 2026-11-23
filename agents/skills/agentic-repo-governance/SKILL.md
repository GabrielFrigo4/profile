---
name: agentic-repo-governance
description: >-
    Governança de artefatos de IA em repositórios (AGENTS.md, .agents/rules, skills),
    progressive disclosure em 2 estágios, curadoria C.A.R.P., hermetismo de produção
    e scaffold padronizado de novos projetos multi-stack.
---

# 🧠 Agentic & Repository Governance

Diretrizes para estruturar documentação de agentes (`AGENTS.md`, `rules/`, `skills/`), manter memória arquitetural perene e inicializar novos repositórios com qualidade e hermetismo de produção.

---

## 🏛️ 1. Tríade de Governança & Orçamento de Linhas

Todo repositório organiza contexto cognitivo em três camadas complementares:

1. **`AGENTS.md` (Constituição Local):** Identidade, ordem de leitura, invariantes críticas e comandos de quality gate. Nunca armazena tutoriais extensos.
2. **`.agents/rules/` (Restrições Invariantes):** Regras de domínio locais (ou globais transversais de tom e plataforma).
3. **`.agents/skills/` (Runbooks sob Demanda):** Procedimentos ativados em 2 estágios via frontmatter YAML (`name` igual ao diretório + `description` de 25 a 45 palavras em terceira pessoa).

| Artefato                     | Piso   | Sweet Spot Executivo  | Teto Máximo (Monólito) |
| :--------------------------- | :----- | :-------------------- | :--------------------- |
| `SKILL.md` / `AGENTS.md`     | `17` L | **`17 a 128` linhas** | `256` linhas           |
| Arquivos em `.agents/rules/` | `17` L | **`<= 128` linhas**   | `256` linhas           |

---

## ⚡ 2. Arquitetura em 2 Tiers, Precedência & Hermetismo

- **Tier 1 (Lean Skill):** Apenas `SKILL.md` ($\le 128$ linhas) para heurísticas e modelos mentais.
- **Tier 2 (Extended Skill):** `SKILL.md` manifesto ($\le 128$ linhas) + `references/`, `scripts/`, `examples/` e `resources/` lidos sob demanda. Prefira **Consolidação Horizontal** para reduzir o custo em repouso.
- **Precedência UNIX:** `<repo>/.agents/skills/` (Local) $>$ escopo global do usuário $>$ built-in da plataforma.
- **Simetria de Escopo:** Documente propriedades universais na camada do grupo, evitando falsas assimetrias em submembros.
- **Hermetismo de Produção (`rm -rf .agents`):** Nenhum script de produção, `Makefile`, hook ou pipeline de CI pode depender de arquivos em `.agents/`. Deletar `.agents/` preserva 100% da operação.

---

## 🧭 3. Curadoria C.A.R.P. & Teste dos 5 Anos

Antes de registrar conhecimento em uma skill local, aplique o **Teste dos 5 Anos**: _"Quando o `TODO.md` for zerado, esta regra continua verdadeira e acionável?"_

- **Registrar:** Invariantes arquiteturais, ordem de build, flags não óbvias, gotchas de plataforma e harnesses de teste.
- **Rejeitar:** Backlog transitório (`TODO.md`), logs de debug pontuais e duplicação de conceitos já cobertos por skills globais.
- **Ciclo:** **Criar** regras tácitas $\rightarrow$ **Atualizar** com a arquitetura $\rightarrow$ **Refatorar** movendo detalhes para `references/` $\rightarrow$ **Purgar** itens obsoletos.

---

## 🏗️ 4. Scaffold Padrão de Novos Repositórios

Ao iniciar ou auditar um projeto (`c-modern`, `shell-posix`, `cpp-modern`, `go-binary`, `python-pure`, `latex-doc`), garanta:

1. `Makefile` POSIX silencioso (`.POSIX:`, `.SILENT:`, `MAKEFLAGS += --no-print-directory -s`, subshells `(cd dir && $(MAKE) target)`).
2. Hooks autônomos em `.githooks/` (`0755`), taxonomia tripartite de comentários e permissões octais (`0755`/`0644`).
3. Desacoplamento estrito entre bancada de desenvolvimento (`<dev-hub>`) e clones de runtime em produção.

Referência detalhada de estrutura, Makefile base e scripts de scaffold: [`references/governance-lifecycle.md`](references/governance-lifecycle.md).
