.POSIX:
.SILENT:

MAKEFLAGS += --no-print-directory

# ----------------------------------------------------------------
# Makefile: Profile Dotfiles
# ----------------------------------------------------------------

.PHONY: help audit sync test ci

### ================================
### HELP & DOCUMENTATION
### ================================
help:
	echo "🎨 Universal Profile — Dotfiles Declarativos & Skills de IA"
	echo ""
	echo "Comandos disponíveis:"
	echo "  make audit    - Executa auditoria estática de qualidade"
	echo "  make sync     - Sincroniza dotfiles, editores e skills no sistema"
	echo "  make test     - Valida sintaxe de scripts utilitários"
	echo "  make ci       - Executa suite completa de validação"
	echo ""

### ================================
### ACTIONS & AUDITING
### ================================
audit:
	echo "🔍 Executando suíte de auditoria do Profile..."
	python3 scripts/audit/all.py

sync:
	echo "🎨 Sincronizando dotfiles e editores..."
	sh scripts/sync/sync-dotfiles.sh
	echo "🧠 Sincronizando skills de IA..."
	sh scripts/sync/sync-skills.sh

test:
	echo "🧪 Validando sintaxe POSIX dos scripts..."
	find . -name "*.sh" -not -path "*/.git/*" -exec sh -n {} +
	echo "✅ Todos os scripts do Profile são válidos!"

ci: test audit
	echo "🚀 Profile 100% aprovado no CI local!"
