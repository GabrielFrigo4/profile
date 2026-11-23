---
name: latex-typesetting
description: >-
    Editoração científica com LaTeX e TeX, isolamento de artefatos de compilação
    em build/, Makefiles POSIX silenciosos, sincronização dinâmica de listagens de
    código, higiene Git e redação acadêmica direta orientada à formalização matemática.
---

# 📄 LaTeX Typesetting — Compilação Isolada & Redação Rigorosa

Diretrizes para documentos científicos, relatórios técnicos e monografias em LaTeX/TeX mantendo diretórios `.tex` limpos, compilação determinística e redação acadêmica clara.

---

## 🎯 1. Compilação Isolada (`-outdir=build`)

Compiladores TeX (`pdflatex`, `xelatex`, `lualatex`, `bibtex`, `biber`) geram dezenas de auxiliares (`.aux`, `.bbl`, `.blg`, `.log`, `.out`, `.toc`, `.fls`, `.synctex.gz`).

- **Invariante Clean Outdir:** Toda compilação deve redirecionar saídas intermediárias e PDFs para `build/` (ignorado no Git), preservando intacto o diretório-fonte `.tex`.
- **Pipeline:** Fontes (`main.tex`, `referencias.bib`, `figuras/`) $\rightarrow$ `latexmk -pdf -outdir=build` (ou fallback `pdflatex`/`bibtex`) $\rightarrow$ `build/main.pdf`.

---

## 🔄 2. Sincronização de Código com Listagens (`Listings` / `Minted`)

Para trechos de implementação apresentados em documentos científicos:

1. Mantenha o código-fonte compilável e testável em seu diretório original (ex.: `src/algoritmo.cpp`).
2. Inclua dinamicamente via `\lstinputlisting[language=C++]{../src/algoritmo.cpp}` ou script acionado antes da compilação no `Makefile`.
3. Valide no `pre-commit` ou CI que listagens e artefatos embarcados não divergem da fonte original.

---

## 📚 3. Módulos de Referência

| Subdomínio                     | Conteúdo Coberto                                                                        | Referência                                                                     |
| :----------------------------- | :-------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------- |
| **Makefile & `.gitignore`**    | Receita POSIX silenciosa (`bmake`/`gmake`) com `-outdir=build` e regras de `.gitignore` | [`references/makefile-and-gitignore.md`](references/makefile-and-gitignore.md) |
| **Redação Acadêmica No-Fluff** | Teste do leitor não-nativo, voz impessoal, precisão terminológica e Math-First          | [`references/academic-writing.md`](references/academic-writing.md)             |

---

## 🔗 4. Fontes Oficiais & Referências Seminais

- **LaTeX Project & CTAN:** <https://www.latex-project.org/> | <https://www.ctan.org/>
- **Leslie Lamport:** _LaTeX: A Document Preparation System_ (Addison-Wesley).
- **Donald E. Knuth:** _The TeXbook_ — <https://www-cs-faculty.stanford.edu/~knuth/abcde.html>
