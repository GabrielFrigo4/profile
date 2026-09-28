#!/usr/bin/env sh
# ----------------------------------------------------------------
# Example: Self-Contained POSIX Shell Test Runner
# ----------------------------------------------------------------
set -eu

_tests_run=0
_tests_failed=0

assert_eq() {
	_expected="$1"
	_actual="$2"
	_msg="${3:-Valores devem ser iguais}"
	_tests_run=$((_tests_run + 1))

	if [ "${_expected}" != "${_actual}" ]; then
		printf "❌ [FALHA] %s\n" "${_msg}" >&2
		printf "   Esperado: [%s]\n" "${_expected}" >&2
		printf "   Recebido: [%s]\n" "${_actual}" >&2
		_tests_failed=$((_tests_failed + 1))
	fi
}

assert_fails() {
	_cmd="$1"
	_msg="${2:-Comando deve falhar com exit code não-zero}"
	_tests_run=$((_tests_run + 1))

	# Executa em subshell para conter set -e
	if ( eval "${_cmd}" ) > "/dev/null" 2>&1; then
		printf "❌ [FALHA] %s (o comando foi bem-sucedido inesperadamente)\n" "${_msg}" >&2
		printf "   Comando: %s\n" "${_cmd}" >&2
		_tests_failed=$((_tests_failed + 1))
	fi
}

# --- Bateria de Testes ---
test_directory_parsing() {
	_temp_dir="$(mktemp -d 2> "/dev/null" || mktemp -d -t "test")"
	trap 'rm -rf "${_temp_dir}"' EXIT INT TERM

	# Borda: diretório com espaços e caracteres especiais
	_weird_path="${_temp_dir}/pasta com espacos"
	mkdir -p "${_weird_path}"

	assert_eq "1" "$([ -d "${_weird_path}" ] && echo 1 || echo 0)" "Diretório complexo criado"
	assert_fails "ls '${_temp_dir}/inexistente'" "Arquivo inexistente deve retornar erro"
}

test_directory_parsing

if [ "${_tests_failed}" -gt 0 ]; then
	printf "💥 %d de %d testes falharam!\n" "${_tests_failed}" "${_tests_run}" >&2
	exit 1
fi

printf "✅ [POSIX sh] Todos os %d testes passaram silenciosamente.\n" "${_tests_run}"
exit 0
