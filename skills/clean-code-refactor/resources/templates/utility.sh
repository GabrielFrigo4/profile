#!/usr/bin/env sh
# ----------------------------------------------------------------
# Utility: [Nome do Utilitário / Ferramenta]
# ----------------------------------------------------------------
set -eu

. "${SHELL_REPO_DIR:-${HOME}/.shell}/library/ui.sh"

_ui_banner "Iniciando Operação"
_ui_step "Verificando dependências do sistema..."
_ui_sub "Inspecionando executáveis no PATH..."

if command -v git > "/dev/null" 2>&1; then
	_ui_ok "Dependência verificada com sucesso!"
else
	_ui_err "Git não encontrado no sistema."
	exit 1
fi

_ui_banner "Operação Concluída com Sucesso"
