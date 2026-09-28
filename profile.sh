#!/usr/bin/env sh
# ----------------------------------------------------------------
# Interface: Universal Profile Component & Runtime Entrypoint
# ----------------------------------------------------------------
set -eu

_PROFILE_ROOT="$(cd "$(dirname "$0")" && pwd)"
export PROFILE_DIR="${_PROFILE_ROOT}"

_self_heal_perms() {
	if [ -d "${_PROFILE_ROOT}/.git" ] && command -v git > "/dev/null" 2>&1; then
		git -C "${_PROFILE_ROOT}" config core.hooksPath .githooks 2> "/dev/null" || true
	fi
	if [ -d "${_PROFILE_ROOT}/.githooks" ]; then
		chmod 0755 "${_PROFILE_ROOT}/.githooks/"* 2> "/dev/null" || true
	fi
	[ -f "${_PROFILE_ROOT}/profile.sh" ] && chmod 0755 "${_PROFILE_ROOT}/profile.sh" 2> "/dev/null" || true
	[ -f "${_PROFILE_ROOT}/install.sh" ] && chmod 0755 "${_PROFILE_ROOT}/install.sh" 2> "/dev/null" || true
	if [ -d "${_PROFILE_ROOT}/audit" ]; then
		chmod 0755 "${_PROFILE_ROOT}/audit/"*.py 2> "/dev/null" || true
	fi
}
_self_heal_perms

### ================================
### ANSI & SEMANTIC UI EMISSION
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

### ================================
### DETECCAO DE INVOCACAO
### ================================
_profile_is_sourced() {
	if [ -n "${ZSH_VERSION:-}" ]; then
		case "${ZSH_EVAL_CONTEXT:-}" in *:file*) return 0 ;; *) return 1 ;; esac
	fi
	if [ -n "${BASH_VERSION:-}" ]; then
		[ "${BASH_SOURCE[0]}" != "$0" ] && return 0 || return 1
	fi
	case "${0##*/}" in profile.sh) return 1 ;; *) return 0 ;; esac
}

### ================================
### SUBCOMANDOS DE LINHA DE COMANDO
### ================================
_profile_help() {
	cat <<- EOF
		Universal Profile — Interface Unificada de Componente

		Uso:
		  profile.sh [sync|update|test|audit|help] [opcoes]
		  . profile.sh              # Sourceia e exporta variaveis de ambiente
	EOF
}

_profile_link() {
	_src="$1" _dst="$2" _dry_run="${3:-0}" _backup="${4:-0}" _timestamp="${5:-}"
	[ ! -e "${_src}" ] && return 0

	if [ "${_dry_run}" -eq 1 ]; then
		_ui_sub "[DRY-RUN] ${_dst} -> ${_src}"
		return 0
	fi

	_dst_dir="$(dirname "${_dst}")"
	[ ! -d "${_dst_dir}" ] && mkdir -p "${_dst_dir}"

	if [ -L "${_dst}" ]; then
		[ "$(readlink "${_dst}" 2> "/dev/null" || true)" = "${_src}" ] && { _ui_sub "[OK] ${_dst}"; return 0; }
		rm -f "${_dst}"
	elif [ -e "${_dst}" ]; then
		mv "${_dst}" "${_dst}.bak.${_timestamp}"
		_ui_warn "[BACKUP] ${_dst}.bak.${_timestamp}"
	fi

	ln -sf "${_src}" "${_dst}"
	_ui_ok "[LINK] ${_dst}"
}

_profile_sync() {
	_dry_run=0
	_backup=0
	_timestamp="$(date +%Y%m%d%H%M%S)"
	_os_type="$(uname -s)"
	_cfg="${XDG_CONFIG_HOME:-${HOME}/.config}"
	_data="${XDG_DATA_HOME:-${HOME}/.local/share}"

	for _arg in "$@"; do
		case "${_arg}" in
			--dry-run) _dry_run=1 ;;
			--backup) _backup=1 ;;
		esac
	done

	_ui_step "Sincronizando ecossistema declarativo (${_os_type}) a partir de: ${_PROFILE_ROOT}"
	[ "${_dry_run}" -eq 1 ] && _ui_warn "Modo DRY-RUN ativado (nenhum arquivo será modificado)."

	_ui_step "Formatadores globais e linters..."
	_profile_link "${_PROFILE_ROOT}/tools/.clang-format" "${HOME}/.clang-format" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/tools/.prettierrc" "${HOME}/.prettierrc" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/tools/.stylua.toml" "${HOME}/.stylua.toml" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/tools/.editorconfig" "${HOME}/.editorconfig" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/tools/clangd.yaml" "${_cfg}/clangd/config.yaml" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/tools/mermaid-puppeteer.json" "${HOME}/.mermaid-puppeteer-config.json" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/tools/mermaid-theme.json" "${HOME}/.mermaid-theme-config.json" "${_dry_run}" "${_backup}" "${_timestamp}"

	_ui_step "Editores modernos (Zed, VSCode, VSCodium, Antigravity)..."
	_profile_link "${_PROFILE_ROOT}/editors/zed/settings.json" "${_cfg}/zed/settings.json" "${_dry_run}" "${_backup}" "${_timestamp}"
	if [ "${_os_type}" = "Darwin" ]; then
		_app="${HOME}/Library/Application Support"
		_profile_link "${_PROFILE_ROOT}/editors/vscode/settings.json" "${_app}/Code/User/settings.json" "${_dry_run}" "${_backup}" "${_timestamp}"
		_profile_link "${_PROFILE_ROOT}/editors/vscodium/settings.json" "${_app}/VSCodium/User/settings.json" "${_dry_run}" "${_backup}" "${_timestamp}"
		_profile_link "${_PROFILE_ROOT}/editors/antigravity/settings.json" "${_app}/Antigravity/User/settings.json" "${_dry_run}" "${_backup}" "${_timestamp}"
	else
		_profile_link "${_PROFILE_ROOT}/editors/vscode/settings.json" "${_cfg}/Code/User/settings.json" "${_dry_run}" "${_backup}" "${_timestamp}"
		_profile_link "${_PROFILE_ROOT}/editors/vscode/settings.json" "${_cfg}/vscode-oss/User/settings.json" "${_dry_run}" "${_backup}" "${_timestamp}"
		_profile_link "${_PROFILE_ROOT}/editors/vscodium/settings.json" "${_cfg}/VSCodium/User/settings.json" "${_dry_run}" "${_backup}" "${_timestamp}"
		_profile_link "${_PROFILE_ROOT}/editors/antigravity/settings.json" "${_cfg}/Antigravity/User/settings.json" "${_dry_run}" "${_backup}" "${_timestamp}"
	fi

	_ui_step "Emuladores de terminal e shells alternativos..."
	_profile_link "${_PROFILE_ROOT}/terminals/konsole/Bash.profile" "${_data}/konsole/Bash.profile" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/terminals/konsole/Shell.profile" "${_data}/konsole/Shell.profile" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/terminals/konsole/Zsh.profile" "${_data}/konsole/Zsh.profile" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/terminals/nushell/config.nu" "${_cfg}/nushell/config.nu" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/terminals/nushell/env.nu" "${_cfg}/nushell/env.nu" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/terminals/powershell/profile.ps1" "${_cfg}/powershell/profile.ps1" "${_dry_run}" "${_backup}" "${_timestamp}"
	_profile_link "${_PROFILE_ROOT}/terminals/powershell/Microsoft.PowerShell_profile.ps1" "${_cfg}/powershell/Microsoft.PowerShell_profile.ps1" "${_dry_run}" "${_backup}" "${_timestamp}"

	_ui_step "Skills portáteis de IA (Antigravity & Gemini)..."
	_profile_link "${_PROFILE_ROOT}/skills" "${HOME}/.gemini/config/skills" "${_dry_run}" "${_backup}" "${_timestamp}"

	_ui_ok "Sincronização concluída com sucesso!"
}

_profile_update() {
	_ui_step "Atualizando repositório em: ${_PROFILE_ROOT}"
	_status="$(command git -C "${_PROFILE_ROOT}" status --porcelain 2> "/dev/null" || true)"
	_has_dirty=0
	if [ -n "${_status}" ]; then
		_has_dirty=1
		_ui_warn "Alterações locais detectadas em ${_PROFILE_ROOT} (criando auto-stash)..."
		command git -C "${_PROFILE_ROOT}" stash push -u -m "autostash-before-update-$(date +%s)" > "/dev/null" 2>&1 || true
	fi
	command git -C "${_PROFILE_ROOT}" pull --ff-only 2> "/dev/null" || command git -C "${_PROFILE_ROOT}" pull --rebase 2> "/dev/null" || command git -C "${_PROFILE_ROOT}" pull
	[ "${_has_dirty}" -eq 1 ] && command git -C "${_PROFILE_ROOT}" stash pop > "/dev/null" 2>&1 || true
	[ -d "${_PROFILE_ROOT}/.githooks" ] && chmod 0755 "${_PROFILE_ROOT}/.githooks/"* 2> "/dev/null" || true
	_profile_sync "$@"
}

_profile_test() {
	_ui_step "Validando sintaxe POSIX dos scripts..."
	find "${_PROFILE_ROOT}" -name "*.sh" -not -path "*/.git/*" -exec sh -n {} +
	_ui_ok "Todos os scripts estão sintaticamente corretos!"
}

_profile_audit() {
	_ui_step "Executando auditoria estática..."
	if command -v python3 > "/dev/null" 2>&1 && [ -f "${_PROFILE_ROOT}/audit/all.py" ]; then
		python3 "${_PROFILE_ROOT}/audit/all.py"
	else
		_ui_info "Python3 ou audit/all.py ausente; executando apenas teste sintático."
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
		_ui_err "Comando desconhecido: ${_cmd}"
		_profile_help >&2
		exit 1
		;;
esac
