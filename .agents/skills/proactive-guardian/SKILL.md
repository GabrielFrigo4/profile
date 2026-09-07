---
name: proactive-guardian
description: >-
  Proactive health guardian and autonomous quality enforcement for Universal Profile.
  Use to continuously audit JSON/YAML/TOML syntax, Markdown link integrity,
  XDG compliance, symlink health, and enforce the presence of README.md in all directories.
---

# Proactive Guardian — Autonomous Dotfiles & AI Quality Enforcement

Esta skill define as diretrizes operacionais para atuação **proativa** de qualidade no repositório **Universal Profile Environment** (`Profile`).

O agente nunca deve agir de forma passiva diante de arquivos de configuração inválidos, links Markdown quebrados, ausência de documentação em subpastas ou tentativas de poluição da raiz de `$HOME`. Se um desvio for detectado, o agente deve assumir a responsabilidade de auditar, propor e corrigir imediatamente.

---

## 1. Filosofia de Ação Proativa

1. **Ação Direta no Escopo de Dotfiles:**
   - Se um arquivo JSON ou YAML contiver erro de formatação ou vírgulas soltas, **corrija imediatamente de acordo com o padrão canônico**.
   - Se um script de sincronização estiver sem quoting em variáveis ou `> "/dev/null"`, **corrija imediatamente**.
2. **Garantia de Documentação Universal:**
   - Todo subdiretório DEVE possuir um `README.md`. Se uma nova ferramenta for adicionada em `software/`, crie o respectivo `README.md` imediatamente no mesmo ciclo de entrega.

---

## 2. Checklist de Auditoria Proativa Contínua

- [ ] **Validação de Formatos:** 100% dos arquivos JSON, YAML, TOML e .reg aprovados por `formats.py`.
- [ ] **Links Relativos:** 100% dos links Markdown verificados e válidos por `links.py`.
- [ ] **README em Toda Pasta:** Sem diretórios órfãos sem documentação.
- [ ] **Permissões POSIX:** `chmod 0755` para scripts executáveis e `chmod 0644` para dotfiles e documentações.
- [ ] **Zero Secrets:** Nenhuma chave privada, token ou senha no histórico ou arquivos.

---

## 3. Fluxo de Entrega com Qualidade

Antes de finalizar qualquer modificação:
1. `git diff --check`
2. `python3 scripts/audit/all.py`
3. `./.githooks/pre-commit`
