.POSIX:
.SILENT:

MAKEFLAGS += --no-print-directory -s

# ----------------------------------------------------------------
# Makefile: Profile Dotfiles
# ----------------------------------------------------------------

.PHONY: help hooks audit sync test fix-banners ci

### ================================
### HELP & DOCUMENTATION
### ================================
help:
	_e=$$'\e'; \
	cmd() { printf "    $${_e}[36mmake %-22s$${_e}[0m %s\n" "$$1" "$$2"; }; \
	sec() { printf "\n  $${_e}[1;33m%s$${_e}[0m\n" "$$1"; }; \
	sub() { printf "  $${_e}[1;34m  ── %s ──$${_e}[0m\n" "$$1"; }; \
	printf "\n  $${_e}[1;37mUniversal Profile — Dotfiles Declarativos & Skills de IA$${_e}[0m\n"; \
	printf "  ============================================================\n"; \
	sec "Setup & Ganchos:"; \
	cmd "hooks"          "Configura e aplica permissões canônicas em .githooks"; \
	sec "Sincronização & Instalação:"; \
	cmd "sync"           "Sincroniza dotfiles, editores e skills no sistema"; \
	sec "Qualidade & Auditoria:"; \
	cmd "test"           "Valida sintaxe POSIX dos scripts utilitários"; \
	cmd "audit"          "Executa auditoria estática completa (JSON/YAML/TOML/links)"; \
	cmd "ci"             "Executa suite completa de CI local"; \
	echo ""

### ================================
### GIT HOOKS & PERMISSIONS
### ================================
hooks:
	echo "🪝 Configurando ganchos Git (.githooks)..."
	chmod 0755 .githooks/pre-commit .githooks/commit-msg 2> "/dev/null" || true
	git config core.hooksPath .githooks 2> "/dev/null" || true
	echo "  ✅ Profile: core.hooksPath -> .githooks"

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

fix-banners:
	echo "📏 Normalizando réguas de banners de cabeçalho e seções..."
	python3 audit/banners.py --fix
	echo "✅ Réguas de banners normalizadas com sucesso!"

ci: test audit
	echo "🚀 Profile 100% aprovado no CI local!"
