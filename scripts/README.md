# 🛠️ Profile Scripts & Automações

> Utilitários de sincronização de dotfiles, implantação de skills de IA e auditoria contínua.

---

## 🎯 Finalidade

Este diretório centraliza scripts auxiliares executados no espaço do usuário (sem privilégios administrativos), permitindo criar links simbólicos instantâneos para suas configurações e auditar a consistência de formatos.

---

## 📂 Catálogo de Subdiretórios

| Diretório | Tipo | Descrição |
| :--- | :--- | :--- |
| [`sync/`](sync/) | Automação Shell | Scripts para vincular dotfiles e skills de IA no `$HOME` via `ln -sf` |
| [`audit/`](audit/) | Suíte Python | Testes de integridade de links Markdown e validação de JSON, YAML e TOML |

---

## 🚀 Como Usar

```sh
./scripts/sync/sync-dotfiles.sh

./scripts/sync/sync-skills.sh

python3 scripts/audit/all.py
```
