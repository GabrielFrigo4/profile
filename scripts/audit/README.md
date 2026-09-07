# 🔍 Codebase Quality & Architecture Auditors

> Ferramentas de análise estática e auditoria arquitetural para garantir o equilíbrio do repositório.

---

## 🎯 Finalidade

Esta pasta centraliza os scripts de inspeção de código para manter o repositório em conformidade estrita com o [`PRINCIPLES.md`](../../PRINCIPLES.md):

- **Equilíbrio Arquitetural:** Nem monólitos gigantes (> 128 linhas), nem micro-scripts excessivamente fragmentados (< 16 linhas).
- **Legibilidade no GitHub:** Facilitar a consulta direta das receitas no navegador.

---

## 📂 Catálogo de Ferramentas

| Ferramenta                     | Linguagem | Descrição                                                                         |
| :----------------------------- | :-------- | :-------------------------------------------------------------------------------- |
| [`all.py`](all.py)             | Python 3  | **Runner mestre:** executa a suite completa e gera o dashboard consolidado        |
| [`monoliths.py`](monoliths.py) | Python 3  | Detecta scripts que ultrapassam o limite de 128 linhas (com suporte a whitelist) |
| [`nanos.py`](nanos.py)         | Python 3  | Detecta micro-scripts com menos de 16 linhas para sugerir consolidações temáticas |
| [`syntax.py`](syntax.py)       | Python 3  | Valida sintaxe POSIX (`sh -n`), shebangs, modo defensivo `set -eu` e `chmod`      |
| [`links.py`](links.py)         | Python 3  | Valida integridade de 100% dos links relativos em arquivos Markdown (`.md`)       |
| [`formats.py`](formats.py)     | Python 3  | Valida sintaxe de JSON, JSONC, YAML (multi-doc), PowerShell (`.ps1`) e `.reg`     |

---

## 🚀 Como Executar

Execute a partir da raiz do repositório:

```sh
# 1. Executar a suite completa (Recomendado)
python3 scripts/audit/all.py

# 2. Execuções individuais:
python3 scripts/audit/monoliths.py
python3 scripts/audit/nanos.py
python3 scripts/audit/syntax.py
python3 scripts/audit/links.py
python3 scripts/audit/formats.py
```
