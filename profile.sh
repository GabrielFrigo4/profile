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
	if [ -f "${_PROFILE_ROOT}/profile.sh" ]; then
		chmod 0755 "${_PROFILE_ROOT}/profile.sh" 2> "/dev/null" || true
	fi
	if [ -f "${_PROFILE_ROOT}/install.sh" ]; then
		chmod 0755 "${_PROFILE_ROOT}/install.sh" 2> "/dev/null" || true
	fi
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
		  profile.sh [sync|update|test|audit|help] [opcoes]
		  . profile.sh              # Sourceia e exporta variaveis de ambiente

		Opcoes de Sincronizacao:
		  --dry-run                 Simula operacoes sem alterar arquivos
		  --backup                  Cria backup (.bak) antes de substituir
		  --status                  Audita e compara divergencias (drift)
		  --pull                    Reconcilia alteracoes do sistema para o Git
	EOF
}

_profile_item() {
	_src="$1" _dst="$2" _m="${3:-sync}" _dry="${4:-0}" _bak="${5:-0}" _ts="${6:-}"
	if [ ! -e "${_src}" ]; then
		return 0
	fi

	if [ "${_m}" = "status" ]; then
		if [ ! -e "${_dst}" ] && [ ! -L "${_dst}" ]; then
			_ui_warn "[MISSING] ${_dst}"
			return 0
		fi
		if [ -L "${_dst}" ]; then
			if [ "$(readlink "${_dst}" 2> "/dev/null" || true)" = "${_src}" ]; then
				_ui_ok "[IN-SYNC] ${_dst}"
			else
				_ui_warn "[DRIFT] ${_dst}"
			fi
			return 0
		fi
		if [ -d "${_src}" ] && [ -d "${_dst}" ]; then
			if diff -rq "${_src}" "${_dst}" > "/dev/null" 2>&1; then
				_ui_ok "[IN-SYNC-DIR] ${_dst}"
			else
				_ui_warn "[DRIFT-DIR] ${_dst}"
			fi
			return 0
		fi
		if cmp -s "${_src}" "${_dst}" 2> "/dev/null"; then
			_ui_ok "[IN-SYNC] ${_dst}"
		else
			_ui_warn "[DRIFT] ${_dst}"
		fi
		return 0
	fi

	if [ "${_m}" = "pull" ]; then
		if [ ! -e "${_dst}" ] || [ -L "${_dst}" ]; then
			return 0
		fi
		if [ -d "${_src}" ] && [ -d "${_dst}" ]; then
			if ! diff -rq "${_src}" "${_dst}" > "/dev/null" 2>&1; then
				if [ "${_dry}" -eq 1 ]; then
					_ui_sub "[DRY-RUN PULL] ${_dst} -> ${_src}"
				else
					cp -rf "${_dst}/." "${_src}/"
					_ui_ok "[RECONCILED-DIR] ${_src} <- ${_dst}"
				fi
			fi
			return 0
		fi
		if [ -f "${_src}" ] && [ -f "${_dst}" ]; then
			if ! cmp -s "${_src}" "${_dst}" 2> "/dev/null"; then
				if [ "${_dry}" -eq 1 ]; then
					_ui_sub "[DRY-RUN PULL] ${_dst} -> ${_src}"
				else
					cp -f "${_dst}" "${_src}"
					_ui_ok "[RECONCILED] ${_src} <- ${_dst}"
				fi
			fi
			return 0
		fi
		return 0
	fi

	if [ "${_dry}" -eq 1 ]; then
		_ui_sub "[DRY-RUN] ${_src} -> ${_dst}"
		return 0
	fi

	mkdir -p "$(dirname "${_dst}")"
	if [ -L "${_dst}" ]; then
		if [ "$(readlink "${_dst}" 2> "/dev/null" || true)" = "${_src}" ]; then
			_ui_sub "[OK] ${_dst}"
			return 0
		fi
		rm -f "${_dst}"
	elif [ -e "${_dst}" ]; then
		if [ -d "${_src}" ] && [ -d "${_dst}" ]; then
			if diff -rq "${_src}" "${_dst}" > "/dev/null" 2>&1; then
				_ui_sub "[OK-DIR] ${_dst}"
				return 0
			fi
		elif [ -f "${_src}" ] && [ -f "${_dst}" ]; then
			if cmp -s "${_src}" "${_dst}" 2> "/dev/null"; then
				_ui_sub "[OK] ${_dst}"
				return 0
			fi
		fi

		if [ "${_bak}" -eq 1 ]; then
			if mv "${_dst}" "${_dst}.bak.${_ts}" 2> "/dev/null"; then
				_ui_warn "[BACKUP] ${_dst}.bak.${_ts}"
			else
				_ui_err "Falha ao criar backup de ${_dst}"
				return 1
			fi
		else
			rm -rf "${_dst}"
		fi
	fi

	export MSYS="winsymlinks:nativestrict"
	if ln -sf "${_src}" "${_dst}" 2> "/dev/null"; then
		_ui_ok "[LINK] ${_dst}"
	else
		cp -rf "${_src}" "${_dst}"
		_ui_warn "[COPY] ${_dst} (Modo de Desenvolvedor desativado)"
	fi
}

### ================================
### SINCRONIZACAO DE DOTFILES
### ================================
_profile_sync() {
	_dry_run=0 _backup=0 _mode="sync" _timestamp="$(date +%Y%m%d%H%M%S)" _os_type="$(uname -s)"
	_cfg="${XDG_CONFIG_HOME:-${HOME}/.config}" _data="${XDG_DATA_HOME:-${HOME}/.local/share}"
	_is_win=0 _win_home="${USERPROFILE:-${HOME}}"
	_win_app="${APPDATA:-${_win_home}/AppData/Roaming}" _win_local="${LOCALAPPDATA:-${_win_home}/AppData/Local}"

	case "${_os_type}" in
		MINGW*|MSYS*|CYGWIN*|*_NT*)
			_is_win=1
			if command -v cygpath > "/dev/null" 2>&1; then
				_win_home="$(cygpath -u "${USERPROFILE:-/c/Users/${USER}}")"
				_win_app="$(cygpath -u "${APPDATA:-${_win_home}/AppData/Roaming}")"
				_win_local="$(cygpath -u "${LOCALAPPDATA:-${_win_home}/AppData/Local}")"
				_od_win="${OneDriveConsumer:-${OneDrive:-${USERPROFILE}\\OneDrive}}"
				_win_onedrive="$(cygpath -u "${_od_win}")"
			else
				_win_onedrive="${_win_home}/OneDrive"
			fi

			_win_docs=""
			for _cand in \
				"${_win_onedrive}/Documents" \
				"${_win_onedrive}/Documentos" \
				"${_win_home}/Documents" \
				"${_win_home}/Documentos"; do
				if [ -d "${_cand}" ]; then
					_win_docs="${_cand}"
					break
				fi
			done
			[ -z "${_win_docs}" ] && _win_docs="${_win_home}/Documents"
			;;
	esac

	for _arg in "$@"; do
		case "${_arg}" in
			--dry-run) _dry_run=1 ;;
			--backup)  _backup=1 ;;
			--status)  _mode="status" ;;
			--pull)    _mode="pull" ;;
		esac
	done

	_sync() { _profile_item "${_PROFILE_ROOT}/$1" "$2" "${_mode}" "${_dry_run}" "${_backup}" "${_timestamp}"; }
	_ui_step "Sincronizando ecossistema (${_os_type} - ${_mode}) a partir de: ${_PROFILE_ROOT}"
	if [ "${_dry_run}" -eq 1 ]; then
		_ui_warn "Modo DRY-RUN ativado (nenhum arquivo sera modificado)."
	fi

	_ui_step "Formatadores globais e linters..."
	for _f in .clang-format .prettierrc .stylua.toml .editorconfig; do
		_sync "tools/${_f}" "${HOME}/${_f}"
		if [ "${_is_win}" -eq 1 ] && [ "${_win_home}" != "${HOME}" ]; then
			_sync "tools/${_f}" "${_win_home}/${_f}"
		fi
	done
	_sync "tools/mermaid-puppeteer.json" "${HOME}/.mermaid-puppeteer-config.json"
	_sync "tools/mermaid-theme.json" "${HOME}/.mermaid-theme-config.json"
	if [ "${_is_win}" -eq 1 ]; then
		_sync "tools/clangd.yaml" "${_win_local}/clangd/config.yaml"
	else
		_sync "tools/clangd.yaml" "${_cfg}/clangd/config.yaml"
	fi

	_ui_step "Editores modernos (Zed, VSCode, VSCodium, Antigravity IDE)..."
	if [ "${_os_type}" = "Darwin" ]; then
		_app="${HOME}/Library/Application Support"
		_sync "editors/zed/settings.json" "${_cfg}/zed/settings.json"
		_sync "editors/vscode/settings.json" "${_app}/Code/User/settings.json"
		_sync "editors/vscodium/settings.json" "${_app}/VSCodium/User/settings.json"
		_sync "editors/antigravity/settings.json" "${_app}/Antigravity IDE/User/settings.json"
	elif [ "${_is_win}" -eq 1 ]; then
		_sync "editors/zed/settings.json" "${_win_app}/Zed/settings.json"
		_sync "editors/vscode/settings.json" "${_win_app}/Code/User/settings.json"
		_sync "editors/vscodium/settings.json" "${_win_app}/VSCodium/User/settings.json"
		_sync "editors/antigravity/settings.json" "${_win_app}/Antigravity IDE/User/settings.json"
	else
		_sync "editors/zed/settings.json" "${_cfg}/zed/settings.json"
		_sync "editors/vscode/settings.json" "${_cfg}/Code/User/settings.json"
		_sync "editors/vscode/settings.json" "${_cfg}/vscode-oss/User/settings.json"
		_sync "editors/vscodium/settings.json" "${_cfg}/VSCodium/User/settings.json"
		_sync "editors/antigravity/settings.json" "${_cfg}/Antigravity IDE/User/settings.json"
	fi

	_ui_step "Emuladores de terminal e shells alternativos..."
	if [ "${_is_win}" -eq 1 ]; then
		_sync "terminals/windows-terminal/settings.json" "${_win_local}/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
		_sync "terminals/cmd/profile.lua" "${_win_local}/clink/profile.lua"
		_sync "terminals/cmd/profile.cmd" "${_win_local}/clink/profile.cmd"
		_sync "terminals/cmd/profile.cmd" "${_win_home}/profile.cmd"
		_sync "terminals/powershell/profile.ps1" "${_win_docs}/PowerShell/profile.ps1"
		_sync "terminals/powershell/Microsoft.PowerShell_profile.ps1" "${_win_docs}/PowerShell/Microsoft.PowerShell_profile.ps1"
		_sync "terminals/nushell/config.nu" "${_win_app}/nushell/config.nu"
		_sync "terminals/nushell/env.nu" "${_win_app}/nushell/env.nu"
	else
		_sync "terminals/nushell/config.nu" "${_cfg}/nushell/config.nu"
		_sync "terminals/nushell/env.nu" "${_cfg}/nushell/env.nu"
		_sync "terminals/powershell/profile.ps1" "${_cfg}/powershell/profile.ps1"
		_sync "terminals/powershell/Microsoft.PowerShell_profile.ps1" "${_cfg}/powershell/Microsoft.PowerShell_profile.ps1"
		_sync "terminals/konsole/Bash.profile" "${_data}/konsole/Bash.profile"
		_sync "terminals/konsole/Shell.profile" "${_data}/konsole/Shell.profile"
		_sync "terminals/konsole/Zsh.profile" "${_data}/konsole/Zsh.profile"
	fi

	_ui_step "Agentes de IA (Skills & Rules para Antigravity & Gemini)..."
	_sync "agents/skills" "${HOME}/.gemini/config/skills"
	_sync "agents/rules" "${HOME}/.gemini/config/rules"
	if [ "${_is_win}" -eq 1 ] && [ "${_win_home}" != "${HOME}" ]; then
		_sync "agents/skills" "${_win_home}/.gemini/config/skills"
		_sync "agents/rules" "${_win_home}/.gemini/config/rules"
	fi

	_ui_ok "Operacao (${_mode}) concluida com sucesso!"
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
	if command -v python3 > "/dev/null" 2>&1 && [ -f "${_PROFILE_ROOT}/audit/all.py" ]; then
		python3 "${_PROFILE_ROOT}/audit/all.py"
	else
		_ui_info "Python3 ou audit/all.py ausente; executando apenas teste sintatico."
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
