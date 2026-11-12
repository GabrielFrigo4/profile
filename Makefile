.POSIX:
.SILENT:

MAKEFLAGS += --no-print-directory -s

# ----------------------------------------------------------------
# Makefile: Profile Dotfiles
# ----------------------------------------------------------------

.PHONY: help hooks audit sync test format prettier fix-banners ci clean

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
	cmd "format"         "Formata documentações Markdown com Prettier"; \
	cmd "prettier"       "Formata documentações Markdown com Prettier"; \
	cmd "clean"          "Remove artefatos temporários, caches e ambientes virtuais (.venv)"; \
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
	PYTHONPYCACHEPREFIX="$${PYTHONPYCACHEPREFIX:-$$HOME/.cache/pycache}" PYTHONDONTWRITEBYTECODE=1 python3 .scripts/audit/all.py

sync:
	sh profile.sh sync

test:
	echo "🧪 Validando sintaxe POSIX dos scripts..."
	find . -name "*.sh" -not -path "*/.git/*" -exec sh -n {} +
	echo "🎨 Verificando isolamento do tema GTK do Emacs..."
	test -f desktop/themes/Emacs-Doom-Dark/gtk-3.0/gtk.css
	grep -q "@import" desktop/themes/Emacs-Doom-Dark/gtk-3.0/gtk.css
	grep -q "background-image: none" desktop/themes/Emacs-Doom-Dark/gtk-3.0/gtk.css
	grep -q "#1e1e1e" desktop/themes/Emacs-Doom-Dark/gtk-3.0/gtk.css
	! grep -q "#1e1e1e" desktop/gtk-3.0/gtk.css
	! grep -q "#1e1e1e" desktop/gtk-4.0/gtk.css
	echo "🔍 Verificando ausência de __pycache__ e *.pyc no Profile..."
	if [ -n "$$(find . -type d -name "__pycache__" -not -path "*/.git/*")" ] || [ -n "$$(find . -type f -name "*.pyc" -not -path "*/.git/*")" ]; then \
		echo "❌ Erro: __pycache__ ou *.pyc encontrados!"; \
		exit 1; \
	fi
	echo "✅ Todos os testes do Profile foram aprovados!"

format: prettier
	echo "✅ Formatação concluída!"

prettier:
	echo "🎨 Formatando documentações e configurações com Prettier..."
	if command -v prettier > "/dev/null" 2>&1; then \
		find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.jsonc" -o -name "*.yml" -o -name "*.yaml" -o -name "*.html" -o -name "*.css" \) \
			-not -path "*/OSS/*" -not -path "*/.git/*" -not -path "*/.venv/*" -not -path "*/node_modules/*" \
			-not -path "*/var/*" -not -path "*/tmp/*" -not -path "*/build/*" -not -path "*/dist/*" \
			-not -path "*/target/*" -not -path "*/.cache/*" \
			-exec prettier --write {} + 2> "/dev/null" || true; \
	elif command -v npx > "/dev/null" 2>&1; then \
		find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.jsonc" -o -name "*.yml" -o -name "*.yaml" -o -name "*.html" -o -name "*.css" \) \
			-not -path "*/OSS/*" -not -path "*/.git/*" -not -path "*/.venv/*" -not -path "*/node_modules/*" \
			-not -path "*/var/*" -not -path "*/tmp/*" -not -path "*/build/*" -not -path "*/dist/*" \
			-not -path "*/target/*" -not -path "*/.cache/*" \
			-exec npx --yes prettier --write {} + 2> "/dev/null" || true; \
	fi

fix-banners:
	echo "📏 Normalizando réguas de banners de cabeçalho e seções..."
	PYTHONPYCACHEPREFIX="$${PYTHONPYCACHEPREFIX:-$$HOME/.cache/pycache}" PYTHONDONTWRITEBYTECODE=1 python3 .scripts/audit/banners.py --fix
	echo "✅ Réguas de banners normalizadas com sucesso!"

ci: test audit
	echo "🚀 Profile 100% aprovado no CI local!"

### ================================
### CLEANUP
### ================================
clean:
	echo "🧹 Limpando artefatos temporários, caches e ambientes virtuais..."
	rm -rf .venv bin/ build/ dist/ .tmp/ *.log
	find . -type d -name "__pycache__" -exec rm -rf {} + 2> "/dev/null" || true
	echo "✅ Workspace limpo!"
