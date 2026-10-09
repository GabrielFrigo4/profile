#!/usr/bin/env sh
# ----------------------------------------------------------------
# Module: ANSI and Semantic UI Emission
# ----------------------------------------------------------------
set -eu

### ================================
### SEMANTIC UI EMISSION
### ================================
_ui_escape=$'\e'
_ui_reset="${_ui_escape}[0m"
_ui_cyan="${_ui_escape}[1;36m"
_ui_green="${_ui_escape}[1;32m"
_ui_yellow="${_ui_escape}[1;33m"
_ui_red="${_ui_escape}[1;31m"
_ui_blue="${_ui_escape}[1;34m"
_ui_magenta="${_ui_escape}[1;35m"

_ui_has_color() {
	[ -t 1 ] || return 1
	case "${TERM:-}" in dumb|"") return 1 ;; *) return 0 ;; esac
}

_ui_step() { _ui_has_color && printf "%s==>%s %s\n" "${_ui_cyan}" "${_ui_reset}" "$*" || printf "==> %s\n" "$*"; }
_ui_sub()  { _ui_has_color && printf "%s  ↳%s %s\n" "${_ui_blue}" "${_ui_reset}" "$*" || printf "  -> %s\n" "$*"; }
_ui_ok()   { _ui_has_color && printf "%s  ✅%s %s\n" "${_ui_green}" "${_ui_reset}" "$*" || printf "  OK %s\n" "$*"; }
_ui_warn() { _ui_has_color && printf "%s  ⚠️ %s %s\n" "${_ui_yellow}" "${_ui_reset}" "$*" || printf "  WARN %s\n" "$*"; }
_ui_err()  { [ -t 2 ] && printf "%s  ❌%s %s\n" "${_ui_red}" "${_ui_reset}" "$*" >&2 || printf "  FAIL %s\n" "$*" >&2; }
_ui_info() { _ui_has_color && printf "%s  ℹ️ %s %s\n" "${_ui_magenta}" "${_ui_reset}" "$*" || printf "  INFO %s\n" "$*"; }
