#!/usr/bin/env sh
# ----------------------------------------------------------------
# Interface: Universal Profile Component & Runtime Entrypoint
# ----------------------------------------------------------------
set -eu

_PROFILE_ROOT="$(cd "$(dirname "$0")" && pwd)"
export PROFILE_DIR="${_PROFILE_ROOT}"

. "${_PROFILE_ROOT}/core/perms.sh"
_self_heal_perms
. "${_PROFILE_ROOT}/core/ui.sh"
. "${_PROFILE_ROOT}/core/sync.sh"
. "${_PROFILE_ROOT}/core/extensions.sh"

### ================================
### DETECCAO DE INVOCACAO
### ================================
_profile_is_sourced() {
	if [ -n "${ZSH_VERSION:-}" ]; then
		case "${ZSH_EVAL_CONTEXT:-}" in *:file*) return 0 ;; *) return 1 ;; esac
	fi
	if [ -n "${BASH_VERSION:-}" ]; then
		if [ "${BASH_SOURCE[0]}" != "$0" ]; then
			return 0
		else
			return 1
		fi
	fi
	case "${0##*/}" in profile.sh) return 1 ;; *) return 0 ;; esac
}

### ================================
### SUBCOMANDOS DE LINHA
### ================================
_profile_help() {
	cat <<- EOF
		Universal Profile — Interface Unificada de Componente

		Uso:
		  profile.sh [sync|update|extensions|test|audit|help] [opcoes]
		  . profile.sh              # Sourceia e exporta variaveis de ambiente

		Opcoes de Sincronizacao:
		  --dry-run, -n             Simula operacoes sem alterar arquivos
		  --backup, -b              Cria backup (.bak) antes de substituir
		  --status, -s              Audita e compara divergencias (drift)
		  --pull                    Reconcilia alteracoes do sistema para o Git
		  --extensions, -e          Sincroniza extensoes declaradas de IDE
	EOF
}

_profile_update() {
	_ui_step "Atualizando repositorio em: ${_PROFILE_ROOT}"
	_status="$(command git -C "${_PROFILE_ROOT}" status --porcelain 2> "/dev/null" || true)"
	_has_dirty=0
	if [ -n "${_status}" ]; then
		_has_dirty=1
		_ui_warn "Alteracoes locais detectadas em ${_PROFILE_ROOT} (criando auto-stash)..."
		command git -C "${_PROFILE_ROOT}" stash push -u -m "autostash-before-update-$(date +%s)" > "/dev/null" 2>&1 || true
	fi
	command git -C "${_PROFILE_ROOT}" pull --ff-only 2> "/dev/null" || command git -C "${_PROFILE_ROOT}" pull --rebase 2> "/dev/null" || command git -C "${_PROFILE_ROOT}" pull
	if [ "${_has_dirty}" -eq 1 ]; then
		command git -C "${_PROFILE_ROOT}" stash pop > "/dev/null" 2>&1 || true
	fi
	if [ -d "${_PROFILE_ROOT}/.githooks" ]; then
		chmod 0755 "${_PROFILE_ROOT}/.githooks/"* 2> "/dev/null" || true
	fi
	_profile_sync "$@"
}

_profile_test() {
	_ui_step "Validando sintaxe POSIX dos scripts..."
	find "${_PROFILE_ROOT}" -name "*.sh" -not -path "*/.git/*" -exec sh -n {} +
	_ui_ok "Todos os scripts estao sintaticamente corretos!"
}

_profile_audit() {
	_ui_step "Executando auditoria estatica..."
	if command -v python3 > "/dev/null" 2>&1 && [ -f "${_PROFILE_ROOT}/.scripts/audit/all.py" ]; then
		python3 "${_PROFILE_ROOT}/.scripts/audit/all.py"
	else
		_ui_info "Python3 ou .scripts/audit/all.py ausente; executando apenas teste sintatico."
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
	sync)       _profile_sync "$@" ;;
	update)     _profile_update "$@" ;;
	extensions) _profile_extensions "$@" ;;
	test)       _profile_test ;;
	audit)      _profile_audit ;;
	help|-h|--help) _profile_help ;;
	*)
		_ui_err "Comando desconhecido: ${_cmd}"
		_profile_help >&2
		exit 1
		;;
esac
