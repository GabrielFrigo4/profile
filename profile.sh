#!/usr/bin/env sh
# ----------------------------------------------------------------
# Interface: Universal Profile Component & Runtime Entrypoint
# ----------------------------------------------------------------
set -eu

_PROFILE_ROOT="$(cd "$(dirname "$0")" && pwd)"
export PROFILE_DIR="${_PROFILE_ROOT}"

### ================================
### DETECCAO DE INVOCACAO
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

_profile_link() {
	_src="$1"
	_dst="$2"
	_dry_run="${3:-0}"
	_backup="${4:-0}"
	_timestamp="${5:-}"

	[ ! -e "${_src}" ] && return 0

	if [ "${_dry_run}" -eq 1 ]; then
		echo "  [DRY-RUN] ${_dst} -> ${_src}"
		return 0
	fi

	_dst_dir="$(dirname "${_dst}")"
	[ ! -d "${_dst_dir}" ] && mkdir -p "${_dst_dir}"

	if [ -e "${_dst}" ] || [ -L "${_dst}" ]; then
		if [ "${_backup}" -eq 1 ] && [ ! -L "${_dst}" ]; then
			mv "${_dst}" "${_dst}.bak.${_timestamp}"
			echo "  [BACKUP] ${_dst}.bak.${_timestamp}"
		else
			rm -rf "${_dst}"
		fi
	fi

	ln -sf "${_src}" "${_dst}"
	echo "  [LINK] ${_dst}"
}

_profile_sync() {
	_dry_run=0
	_backup=0
	_timestamp="$(date +%Y%m%d%H%M%S)"
	_os_type="$(uname -s)"

	for _arg in "$@"; do
		case "${_arg}" in
			--dry-run) _dry_run=1 ;;
			--backup) _backup=1 ;;
		esac
	done

	echo "🎨 [Profile] Sincronizando ecossistema declarativo (${_os_type}) a partir de: ${_PROFILE_ROOT}"
	[ "${_dry_run}" -eq 1 ] && echo "  ⚠️  Modo DRY-RUN ativado (nenhum arquivo será modificado)."

	echo "↳ 1. Formatadores globais e linters..."
	_profile_link "${_PROFILE_ROOT}/tools/.clang-format" "${HOME}/.clang-format" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/tools/.prettierrc" "${HOME}/.prettierrc" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/tools/.stylua.toml" "${HOME}/.stylua.toml" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/tools/.editorconfig" "${HOME}/.editorconfig" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/tools/clangd.yaml" "${HOME}/.config/clangd/config.yaml" "${_dry_run}" "${_backup}" "${_timestamp}"

	echo "↳ 2. Editores modernos (Zed, VSCode, Antigravity)..."
	_profile_link "${_PROFILE_ROOT}/editors/zed/settings.json" "${HOME}/.config/zed/settings.json" "${_dry_run}" "${_backup}" "${_timestamp}"
	if [ "${_os_type}" = "Darwin" ]; then
		_app="${HOME}/Library/Application Support"
		_profile_link "${_PROFILE_ROOT}/editors/vscode/settings.json" "${_app}/Code/User/settings.json" "${_dry_run}" "${_backup}" "${_timestamp}"
		_profile_link "${_PROFILE_ROOT}/editors/antigravity/settings.json" "${_app}/Antigravity/User/settings.json" "${_dry_run}" "${_backup}" "${_timestamp}"
	else
		_profile_link "${_PROFILE_ROOT}/editors/vscode/settings.json" "${HOME}/.config/Code/User/settings.json" "${_dry_run}" "${_backup}" "${_timestamp}"
		_profile_link "${_PROFILE_ROOT}/editors/vscode/settings.json" "${HOME}/.config/vscode-oss/User/settings.json" "${_dry_run}" "${_backup}" "${_timestamp}"
		_profile_link "${_PROFILE_ROOT}/editors/antigravity/settings.json" "${HOME}/.config/Antigravity/User/settings.json" "${_dry_run}" "${_backup}" "${_timestamp}"
	fi

	echo "↳ 3. Emuladores de terminal e shells alternativos..."
	_konsole_dir="${HOME}/.local/share/konsole"
	_profile_link "${_PROFILE_ROOT}/terminals/konsole/Bash.profile" "${_konsole_dir}/Bash.profile" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/terminals/konsole/Shell.profile" "${_konsole_dir}/Shell.profile" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/terminals/konsole/Zsh.profile" "${_konsole_dir}/Zsh.profile" "${_dry_run}" "${_backup}" "${_timestamp}"

	_nu_dir="${HOME}/.config/nushell"
	_profile_link "${_PROFILE_ROOT}/terminals/nushell/config.nu" "${_nu_dir}/config.nu" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/terminals/nushell/env.nu" "${_nu_dir}/env.nu" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/terminals/nushell/nushell.nu" "${_nu_dir}/nushell.nu" "${_dry_run}" "${_backup}" "${_timestamp}"

	_pwsh_dir="${HOME}/.config/powershell"
	_profile_link "${_PROFILE_ROOT}/terminals/powershell/profile.ps1" "${_pwsh_dir}/profile.ps1" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/terminals/powershell/Microsoft.PowerShell_profile.ps1" "${_pwsh_dir}/Microsoft.PowerShell_profile.ps1" "${_dry_run}" "${_backup}" "${_timestamp}"

	echo "↳ 4. Skills portáteis de IA (Antigravity & Gemini)..."
	_profile_link "${_PROFILE_ROOT}/skills" "${HOME}/.gemini/config/skills" "${_dry_run}" "${_backup}" "${_timestamp}"

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
	if command -v python3 > "/dev/null" 2>&1 && [ -f "${_PROFILE_ROOT}/audit/all.py" ]; then
		python3 "${_PROFILE_ROOT}/audit/all.py"
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
