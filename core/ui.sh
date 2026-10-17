#!/usr/bin/env sh
# ----------------------------------------------------------------
# Module: ANSI and Semantic UI Emission
# ----------------------------------------------------------------
set -eu

### ================================
### SEMANTIC UI EMISSION
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

_ui_warn() {
	if _ui_has_color; then
		echo -n $'\e[1;33m  ⚠️ \e[0m '
	else
		echo -n "  WARN "
	fi
	echo "$*"
}

_ui_err() {
	if [ -t 2 ]; then
		echo -n $'\e[1;31m  ❌\e[0m ' >&2
	else
		echo -n "  FAIL " >&2
	fi
	echo "$*" >&2
}

_ui_info() {
	if _ui_has_color; then
		echo -n $'\e[1;35m  ℹ️ \e[0m '
	else
		echo -n "  INFO "
	fi
	echo "$*"
}
