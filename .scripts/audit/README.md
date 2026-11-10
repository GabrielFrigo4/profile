# 🔍 Suíte Canônica de Auditoria Estática & Quality Gates

> Catálogo e documentação técnica dos módulos de auditoria estática do ecossistema.

---

## 📖 Visão Geral

A suíte em `.scripts/audit/` provê verificação determinística e semântica de conformidade com os princípios canônicos de arquitetura, portabilidade POSIX e higiene de código.

---

## 🛠️ Catálogo dos Módulos de Auditoria

| Módulo             | Escopo & Verificação                                                                     | Referência de Domínio      |
| :----------------- | :--------------------------------------------------------------------------------------- | :------------------------- |
| **`all.py`**       | Orquestrador e executor central da suíte completa de testes                              | Quality Gate Integrado     |
| **`banners.py`**   | Geometria estrutural de banners (64 hífens) e réguas de seções (32 colunas)              | Princípio de Não-Vazamento |
| **`comments.py`**  | Auditoria da Taxonomia Tripartite de Comentários em scripts e blocos Markdown            | Clean Code & Não-Vazamento |
| **`formats.py`**   | Validação sintática e integridade de arquivos declarativos (JSON, YAML, PS1, REG)        | Integridade de Formatos    |
| **`links.py`**     | Validação de consistência e não-quebra de links relativos entre documentos Markdown      | Hiperlinks Canônicos       |
| **`monoliths.py`** | Controle de teto máximo de complexidade e tamanho de scripts (Regra <= 256 linhas)       | Orçamento de Linhas        |
| **`nanos.py`**     | Detecção de micro-scripts hiperfragmentados (Regra >= 8 linhas)                          | Consolidação Temática      |
| **`skills.py`**    | Orçamento de densidade e integridade estrutural de Portable AI Skills (Regra 17-128-256) | Arquitetura de Skills      |
| **`syntax.py`**    | Portabilidade POSIX `/bin/sh`, shebangs, modo defensivo `set -eu` e modos de arquivo     | Portabilidade UNIX         |
| **`tone.py`**      | Densidade de sinal, economia de tokens e conformidade de escapes ANSI                    | Tom Técnico Estilo RFC     |

---

## 🚀 Execução Operacional

A suíte pode ser invocada via Makefile ou diretamente pelo interpretador Python 3:

```sh
make audit
```

Ou executando o orquestrador diretamente:

```sh
python3 .scripts/audit/all.py
```

Para executar um módulo individual:

```sh
python3 .scripts/audit/comments.py
python3 .scripts/audit/banners.py
python3 .scripts/audit/syntax.py
```
