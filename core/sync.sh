#!/usr/bin/env sh
# ----------------------------------------------------------------
# Module: Dotfiles Sinking and Reconciling Engine
# ----------------------------------------------------------------
set -eu

### ================================
### SUBCOMANDOS DE LINHA
### ================================
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

	_with_ext=0
	for _arg in "$@"; do
		case "${_arg}" in
			--dry-run|-n)    _dry_run=1 ;;
			--backup|-b)     _backup=1 ;;
			--status|-s)     _mode="status" ;;
			--pull)          _mode="pull" ;;
			--extensions|-e) _with_ext=1 ;;
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
		_sync "editors/vscode/settings.json" "${_cfg}/Code - OSS/User/settings.json"
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

	if [ "${_with_ext}" -eq 1 ] && command -v _profile_extensions > "/dev/null" 2>&1; then
		_ext_flags="install"
		[ "${_dry_run}" -eq 1 ] && _ext_flags="${_ext_flags} --dry-run"
		[ "${_mode}" = "status" ] && _ext_flags="status"
		_profile_extensions ${_ext_flags}
	fi

	_ui_ok "Operacao (${_mode}) concluida com sucesso!"
}
