# Universal Profile — Engineering Rules & Constraints

Essas diretrizes são de aplicação obrigatória para qualquer modificação ou extensão neste repositório (`Profile`).

## 1. Zero Privilégios Administrativos (Zero-Sudo)

- Todo dotfile, configuração e automação DEVE operar exclusivamente no espaço do usuário comum (`$HOME` / `~/.config/`).
- NUNCA introduza comandos que exijam `sudo`, `doas` ou privilégios de sistema; tarefas de máquina pertencem exclusivamente ao repositório `Setup`.

## 2. Pureza Declarativa & Formatos Abertos

- Todas as configurações de editores e ferramentas devem utilizar formatos declarativos legíveis pela indústria:
    - JSON / JSONC com 2 espaços de indentação.
    - TOML estruturado por tabelas.
    - YAML limpo com 2 espaços.
    - Elisp e Vimscript enxutos e sem dependências de plugins externos em `lite.*`.
- Comentários narrativos inline óbvios são estritamente proibidos; use separação por linhas em branco.

## 3. Padrão XDG Base Directory

- Configurações devem respeitar estritamente o padrão XDG:
    - `~/.config/<ferramenta>/` para arquivos de configuração.
    - `~/.local/share/<ferramenta>/` para dados persistentes.
- NUNCA polua a raiz de `$HOME` com diretórios fora do padrão.

## 4. Progressive Disclosure para Skills de IA (`skills/`)

- Toda nova skill portátil para IA DEVE conter:
    - Cabeçalho `YAML Frontmatter` conciso (`name` e `description` rica para ativação sob demanda).
    - Documento `SKILL.md` com procedimentos diretos e orientados a ação.
    - Manuais densos ou tabelas auxiliares segregadas em `references/`.

## 5. Permissões Canônicas em 4 Dígitos

- `chmod 0755` para diretórios e scripts executáveis (`scripts/sync/*.sh`).
- `chmod 0644` para arquivos de configuração, dotfiles declarativos e Markdown.
- Redirecionamentos para `/dev/null` sempre com aspas: `> "/dev/null"`.

## 6. Limites de Linhas & Arquitetura de Comentários

- **Orçamento de Linhas (Regra 8 - 128):** Piso de 8 linhas e teto de 128 linhas úteis.
- **Camada 1 (Header Banner):** Exclusivo para linhas 2 a 4 de scripts utilitários, delimitado por 64 hífens (`# ----------------------------------------------------------------`).
- **Camada 2 (Delimitadores Estruturais de Corpo):** Réguas simétricas de 32 caracteres (`### ================================` ou `### --------------------------------`). O título DEVE ter no máximo 32 caracteres e JAMAIS vazar além da régua (total de 36 colunas com `### `).
- **Camada 3 (Zero Comentários Narrativos):** Proibição absoluta de comentários narrativos ou inline em scripts, dotfiles, templates e documentações. Separe blocos lógicos exclusivamente por linhas em branco.

## 7. Padrão Universal de READMEs

- **README Raiz:** Portal institucional com título e emoji, blockquote de missão, badges do Quarteto de Produtividade, sistemas suportados, catálogo de primeiro nível e instruções de auditoria/CI.
- **README de Subpastas:** Catálogo tabular obrigatório (`| Arquivo / Receita | Descrição | Plataforma |`) e bloco de execução limpo sem comentários inline.

## 8. Checklist de Validação Obrigatório

Antes de concluir qualquer alteração no Profile:

1. `git diff --check` (deve retornar 0 erros).
2. `./.githooks/pre-commit` (deve passar 100%).
3. `python3 scripts/audit/all.py` (deve aprovar 100% dos testes).
