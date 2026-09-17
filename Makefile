.POSIX:
.SILENT:

MAKEFLAGS += --no-print-directory -s

# ----------------------------------------------------------------
# Makefile: Profile Dotfiles
# ----------------------------------------------------------------

.PHONY: help audit sync test ci

### ================================
### HELP & DOCUMENTATION
### ================================
help:
	cmd() { printf "    \033[36mmake %-22s\033[0m %s\n" "$$1" "$$2"; }; \
	sec() { printf "\n  \033[1;33m%s\033[0m\n" "$$1"; }; \
	sub() { printf "  \033[1;34m  ── %s ──\033[0m\n" "$$1"; }; \
	printf "\n  \033[1;37mUniversal Profile — Dotfiles Declarativos & Skills de IA\033[0m\n"; \
	printf "  ============================================================\n"; \
	sec "Sincronização & Instalação:"; \
	cmd "sync"           "Sincroniza dotfiles, editores e skills no sistema"; \
	sec "Qualidade & Auditoria:"; \
	cmd "test"           "Valida sintaxe POSIX dos scripts utilitários"; \
	cmd "audit"          "Executa auditoria estática completa (JSON/YAML/TOML/links)"; \
	cmd "ci"             "Executa suite completa de CI local"; \
	echo ""

### ================================
### ACTIONS & AUDITING
### ================================
audit:
	echo "🔍 Executando suíte de auditoria do Profile..."
	python3 audit/all.py

sync:
	sh profile.sh sync

test:
	echo "🧪 Validando sintaxe POSIX dos scripts..."
	find . -name "*.sh" -not -path "*/.git/*" -exec sh -n {} +
	echo "✅ Todos os scripts do Profile são válidos!"

ci: test audit
	echo "🚀 Profile 100% aprovado no CI local!"
