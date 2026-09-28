#!/usr/bin/env sh
# ----------------------------------------------------------------
# Utility: Universal Profile Installer
# ----------------------------------------------------------------
set -eu

_repo_root="$(cd "$(dirname "$0")" && pwd)"

### ================================
### ANSI & SEMANTIC UI EMISSION
### ================================
_ui_escape=$'\e'
_ui_reset="${_ui_escape}[0m"
_ui_cyan="${_ui_escape}[1;36m"
_ui_green="${_ui_escape}[1;32m"
_ui_blue="${_ui_escape}[1;34m"

_ui_has_color() {
	[ -t 1 ] || return 1
	case "${TERM:-}" in dumb|"") return 1 ;; *) return 0 ;; esac
}

_ui_step() { _ui_has_color && printf "%s==>%s %s\n" "${_ui_cyan}" "${_ui_reset}" "$*" || printf "==> %s\n" "$*"; }
_ui_sub()  { _ui_has_color && printf "%s  ↳%s %s\n" "${_ui_blue}" "${_ui_reset}" "$*" || printf "  -> %s\n" "$*"; }
_ui_ok()   { _ui_has_color && printf "%s  ✅%s %s\n" "${_ui_green}" "${_ui_reset}" "$*" || printf "  OK %s\n" "$*"; }

_ui_step "Instalando e sincronizando ecossistema declarativo..."
_ui_sub "Origem: ${_repo_root}"

### ================================
### SINCRONIZACAO DE DOTFILES
### ================================
sh "${_repo_root}/profile.sh" sync "$@"

_ui_ok "Instalação e sincronização concluídas com sucesso!"
exit 0
