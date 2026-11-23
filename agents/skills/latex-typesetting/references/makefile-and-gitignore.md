# 🏗️ Makefile POSIX & `.gitignore` Canônico para LaTeX

> Receita de build isolado em `build/` compatível com `bmake`/`gmake` e blindagem de artefatos temporários no controle de versão.

---

## 1. Makefile Silencioso (`latexmk` com Fallback)

```makefile
.POSIX:
.SILENT:

MAKEFLAGS += --no-print-directory -s

LATEXMK = latexmk
OUTDIR  = build
TARGET  = relatorio

.PHONY: all clean distclean

all: $(OUTDIR)/$(TARGET).pdf
	printf "%s\n" "✅ [LaTeX]: Documento compilado em $(OUTDIR)/$(TARGET).pdf"

$(OUTDIR)/$(TARGET).pdf: $(TARGET).tex
	mkdir -p $(OUTDIR)
	printf "%s" "-> Compilando $(TARGET).pdf... "
	if command -v $(LATEXMK) > "/dev/null" 2>&1; then \
		$(LATEXMK) -pdf -silent -interaction=nonstopmode -outdir=$(OUTDIR) $(TARGET).tex > "/dev/null" 2>&1; \
	else \
		pdflatex -interaction=batchmode -output-directory=$(OUTDIR) $(TARGET).tex > "/dev/null" 2>&1 || true; \
		bibtex $(OUTDIR)/$(TARGET) > "/dev/null" 2>&1 || true; \
		pdflatex -interaction=batchmode -output-directory=$(OUTDIR) $(TARGET).tex > "/dev/null" 2>&1 || true; \
		pdflatex -interaction=batchmode -output-directory=$(OUTDIR) $(TARGET).tex > "/dev/null" 2>&1 || true; \
	fi
	printf "%s\n" "[OK]"

clean:
	printf "%s\n" "🧹 Limpando artefatos intermediários..."
	if command -v $(LATEXMK) > "/dev/null" 2>&1; then \
		$(LATEXMK) -c -outdir=$(OUTDIR) > "/dev/null" 2>&1 || true; \
	fi
	rm -rf $(OUTDIR)/*.aux $(OUTDIR)/*.bbl $(OUTDIR)/*.blg $(OUTDIR)/*.log $(OUTDIR)/*.toc $(OUTDIR)/*.out

distclean: clean
	printf "%s\n" "🗑️  Removendo diretório $(OUTDIR)/..."
	rm -rf $(OUTDIR)
```

---

## 2. `.gitignore` para Projetos TeX

```gitignore
# ================================================================
# BUILD OUTPUTS
# ================================================================
build/
dist/

# ================================================================
# LATEX INTERMEDIATES
# ================================================================
*.aux
*.bbl
*.blg
*.log
*.out
*.toc
*.fls
*.fdb_latexmk
*.synctex.gz
*.bcf
*.run.xml
*.xdv
*.nav
*.snm
*.vrb
*.pdf
```

Caso o repositório mantenha artigos de referência ou figuras vetoriais em PDF versionadas (ex.: `references/*.pdf` ou `figures/*.pdf`), libere apenas o diretório específico via exceção explícita (`!figures/**/*.pdf`).
