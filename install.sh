#!/usr/bin/env sh
# ----------------------------------------------------------------
# Utility: Universal Profile Installer
# ----------------------------------------------------------------
set -eu

_repo_root="$(cd "$(dirname "$0")" && pwd)"

### ================================
### ANSI & SEMANTIC UI EMISSION
### ================================
_ui_has_color() {
	[ -t 1 ] || return 1
	case "${TERM:-}" in
		dumb|"") return 1 ;;
		*) return 0 ;;
	esac
}

_ui_step() {
	if _ui_has_color; then
		echo -n $'\e[1;36m==>\e[0m '
	else
		echo -n "==> "
	fi
	echo "$*"
}

_ui_sub() {
	if _ui_has_color; then
		echo -n $'\e[1;34m  ↳\e[0m '
	else
		echo -n "  -> "
	fi
	echo "$*"
}

_ui_ok() {
	if _ui_has_color; then
		echo -n $'\e[1;32m  ✅\e[0m '
	else
		echo -n "  OK "
	fi
	echo "$*"
}

_ui_step "Instalando e sincronizando ecossistema declarativo..."
_ui_sub "Origem: ${_repo_root}"

### ================================
### SINCRONIZACAO DE DOTFILES
### ================================
sh "${_repo_root}/profile.sh" sync "$@"

_ui_ok "Instalação e sincronização concluídas com sucesso!"
exit 0
