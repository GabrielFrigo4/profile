#!/usr/bin/env sh
# ----------------------------------------------------------------
# Utility: [Nome do Utilitário / Ferramenta]
# ----------------------------------------------------------------
set -eu

_has_tty_color() {
	[ -t 1 ] && [ "${TERM:-dumb}" != "dumb" ]
}

_log_step() {
	if _has_tty_color; then
		echo -n $'\e[1;36m==>\e[0m '
	else
		echo -n "==> "
	fi
	echo "$*"
}

_log_ok() {
	if _has_tty_color; then
		echo -n $'\e[1;32m  OK\e[0m '
	else
		echo -n "  OK "
	fi
	echo "$*"
}

_log_err() {
	if _has_tty_color; then
		echo -n $'\e[1;31m  ERRO\e[0m ' >&2
	else
		echo -n "  ERRO " >&2
	fi
	echo "$*" >&2
}

_log_step "Verificando dependências do sistema..."
if command -v git > "/dev/null" 2>&1; then
	_log_ok "Dependência verificada com sucesso!"
else
	_log_err "Git não encontrado no PATH."
	exit 1
fi
