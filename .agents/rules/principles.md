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

## 6. Limites de Linhas & Clean Code
- **Piso:** Nenhum script isolado deve ter menos de 8 linhas.
- **Teto:** Nenhum script deve ultrapassar 128 linhas (evitar monólitos).

## 7. Checklist de Validação Obrigatório
Antes de concluir qualquer alteração no Profile:
1. `git diff --check` (deve retornar 0 erros).
2. `./.githooks/pre-commit` (deve passar 100%).
3. `python3 scripts/audit/all.py` (deve aprovar 100% dos testes).
