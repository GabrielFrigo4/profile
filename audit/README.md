# 🔍 Codebase Quality & Architecture Auditors

> Ferramentas de análise estática e auditoria arquitetural para garantir o equilíbrio do repositório.

---

## 🎯 Finalidade

Esta pasta centraliza os scripts de inspeção de código para manter o repositório em conformidade estrita com o [`PRINCIPLES.md`](../PRINCIPLES.md):

- **Equilíbrio Arquitetural:** Regra de Linhas (Piso < 8 fatal, Aviso <= 16, Sweet Spot 17-128, Aviso 129-255, Teto > 256 fatal).
- **Legibilidade no GitHub:** Facilitar a consulta direta das receitas no navegador.

---

## 📂 Catálogo de Ferramentas

| Ferramenta                     | Linguagem | Descrição                                                                     |
| :----------------------------- | :-------- | :---------------------------------------------------------------------------- |
| [`all.py`](all.py)             | Python 3  | **Runner mestre:** executa a suite completa e gera o dashboard consolidado    |
| [`monoliths.py`](monoliths.py) | Python 3  | Detecta scripts acima de 256 linhas (fatal) e entre 129-256 linhas (aviso)    |
| [`nanos.py`](nanos.py)         | Python 3  | Detecta scripts abaixo de 8 linhas (fatal) e entre 8-16 linhas (aviso)        |
| [`syntax.py`](syntax.py)       | Python 3  | Valida sintaxe POSIX (`sh -n`), shebangs, modo defensivo `set -eu` e `chmod`  |
| [`banners.py`](banners.py)     | Python 3  | Valida geometria de réguas (32/64 cols), não-vazamento e suporte a `--fix`    |
| [`links.py`](links.py)         | Python 3  | Valida integridade de 100% dos links relativos em arquivos Markdown (`.md`)   |
| [`formats.py`](formats.py)     | Python 3  | Valida sintaxe de JSON, JSONC, YAML (multi-doc), PowerShell (`.ps1`) e `.reg` |

---

## 🚀 Como Executar

Execute a partir da raiz do repositório:

### Suíte Completa (Recomendado)

```sh
python3 audit/all.py
```

### Execuções Individuais

```sh
python3 audit/monoliths.py
python3 audit/nanos.py
python3 audit/syntax.py
python3 audit/banners.py
python3 audit/links.py
python3 audit/formats.py
```
