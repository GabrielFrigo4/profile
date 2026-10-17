#!/usr/bin/env sh
# ----------------------------------------------------------------
# Utility: Universal Profile Installer
# ----------------------------------------------------------------
set -eu

_repo_root="$(cd "$(dirname "$0")" && pwd)"

### ================================
### ANSI & SEMANTIC UI EMISSION
### ================================
_ui_color_reset=$'\e[0m'
_ui_color_bold=$'\e[1m'
_ui_color_cyan=$'\e[1;36m'
_ui_color_green=$'\e[1;32m'
_ui_color_yellow=$'\e[1;33m'
_ui_color_red=$'\e[1;31m'
_ui_color_blue=$'\e[1;34m'
_ui_color_magenta=$'\e[1;35m'
_ui_color_dim=$'\e[2m'

_ui_has_color() {
	[ -t 1 ] || return 1
	case "${TERM:-}" in
		dumb|"") return 1 ;;
		*) return 0 ;;
	esac
}

_ui_step() {
	if _ui_has_color; then
		echo -n "${_ui_color_cyan}==>${_ui_color_reset} "
	else
		echo -n "==> "
	fi
	echo "$*"
}

_ui_sub() {
	if _ui_has_color; then
		echo -n "${_ui_color_blue}  ↳${_ui_color_reset} "
	else
		echo -n "  -> "
	fi
	echo "$*"
}

_ui_ok() {
	if _ui_has_color; then
		echo -n "${_ui_color_green}  ✅${_ui_color_reset} "
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
