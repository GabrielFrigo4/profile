#!/usr/bin/env sh
# ----------------------------------------------------------------
# Interface: Universal Profile Component & Runtime Entrypoint
# ----------------------------------------------------------------
set -eu

_PROFILE_ROOT="$(cd "$(dirname "$0")" && pwd)"
export PROFILE_DIR="${_PROFILE_ROOT}"

### ================================
### DETECCAO DE INVOCACAO (SOURCE VS EXEC)
### ================================
_profile_is_sourced() {
	if [ -n "${ZSH_VERSION:-}" ]; then
		case "${ZSH_EVAL_CONTEXT:-}" in
			*:file*) return 0 ;;
			*) return 1 ;;
		esac
	fi
	if [ -n "${BASH_VERSION:-}" ]; then
		[ "${BASH_SOURCE[0]}" != "$0" ] && return 0 || return 1
	fi
	case "${0##*/}" in
		profile.sh) return 1 ;;
		*) return 0 ;;
	esac
}

### ================================
### SUBCOMANDOS DE LINHA DE COMANDO
### ================================
_profile_help() {
	cat <<- EOF
		Universal Profile — Interface Unificada de Componente

		Uso:
		  profile.sh [comando] [opcoes]
		  . profile.sh              # Sourceia e exporta variaveis de ambiente

		Comandos:
		  sync      Sincroniza dotfiles declarativos e runbooks de IA
		  update    Atualiza o repositorio (git pull --ff-only) e sincroniza
		  test      Valida a sintaxe POSIX de todos os scripts
		  audit     Executa a suite completa de auditoria estatica
		  help      Exibe esta mensagem de ajuda
	EOF
}

_profile_sync() {
	echo "🎨 [Profile] Sincronizando ecossistema declarativo a partir de: ${_PROFILE_ROOT}"
	if [ -f "${_PROFILE_ROOT}/scripts/sync/sync-dotfiles.sh" ]; then
		sh "${_PROFILE_ROOT}/scripts/sync/sync-dotfiles.sh" "$@"
	fi
	if [ -f "${_PROFILE_ROOT}/scripts/sync/sync-skills.sh" ]; then
		sh "${_PROFILE_ROOT}/scripts/sync/sync-skills.sh"
	fi
	echo "✅ [Profile] Sincronização concluída com sucesso!"
}

_profile_update() {
	echo "🔄 [Profile] Atualizando repositório em: ${_PROFILE_ROOT}"
	command git -C "${_PROFILE_ROOT}" diff --numstat 2> "/dev/null" | while IFS="$(printf '\t')" read -r _add _del _file; do
		if [ "${_add}" = "0" ] && [ "${_del}" = "0" ] && [ -n "${_file}" ]; then
			command git -C "${_PROFILE_ROOT}" checkout -- "${_file}" > "/dev/null" 2>&1 || true
		fi
	done
	_status="$(command git -C "${_PROFILE_ROOT}" status --porcelain 2> "/dev/null" || true)"
	_has_dirty=0
	if [ -n "${_status}" ]; then
		_has_dirty=1
		echo "⚠️  [Profile] Alterações locais detectadas em ${_PROFILE_ROOT}."
		echo "  ↳ Criando auto-stash defensivo..."
		command git -C "${_PROFILE_ROOT}" stash push -u -m "autostash-before-update-$(date +%s)" > "/dev/null" 2>&1 || true
	fi
	command git -C "${_PROFILE_ROOT}" pull --ff-only 2> "/dev/null" || command git -C "${_PROFILE_ROOT}" pull --rebase 2> "/dev/null" || command git -C "${_PROFILE_ROOT}" pull
	if [ "${_has_dirty}" -eq 1 ]; then
		command git -C "${_PROFILE_ROOT}" stash pop > "/dev/null" 2>&1 || true
		command git -C "${_PROFILE_ROOT}" diff --numstat 2> "/dev/null" | while IFS="$(printf '\t')" read -r _add _del _file; do
			if [ "${_add}" = "0" ] && [ "${_del}" = "0" ] && [ -n "${_file}" ]; then
				command git -C "${_PROFILE_ROOT}" checkout -- "${_file}" > "/dev/null" 2>&1 || true
			fi
		done
	fi
	if [ -d "${_PROFILE_ROOT}/.githooks" ]; then
		chmod 0755 "${_PROFILE_ROOT}/.githooks/"* 2> "/dev/null" || true
	fi
	_profile_sync "$@"
}

_profile_test() {
	echo "🧪 [Profile] Validando sintaxe POSIX dos scripts..."
	find "${_PROFILE_ROOT}" -name "*.sh" -not -path "*/.git/*" -exec sh -n {} +
	echo "✅ [Profile] Todos os scripts estão sintaticamente corretos!"
}

_profile_audit() {
	echo "🔍 [Profile] Executando auditoria estática..."
	if command -v python3 > "/dev/null" 2>&1 && [ -f "${_PROFILE_ROOT}/scripts/audit/all.py" ]; then
		python3 "${_PROFILE_ROOT}/scripts/audit/all.py"
	else
		echo "ℹ️  Python3 ou script all.py ausente; executando apenas teste sintático."
		_profile_test
	fi
}

### ================================
### EXECUCAO PRINCIPAL
### ================================
if _profile_is_sourced; then
	return 0 2> "/dev/null" || exit 0
fi

_cmd="${1:-help}"
shift 2> "/dev/null" || true

case "${_cmd}" in
	sync)   _profile_sync "$@" ;;
	update) _profile_update "$@" ;;
	test)   _profile_test ;;
	audit)  _profile_audit ;;
	help|-h|--help) _profile_help ;;
	*)
		echo "❌ Comando desconhecido: ${_cmd}" >&2
		_profile_help >&2
		exit 1
		;;
esac
