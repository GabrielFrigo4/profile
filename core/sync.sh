#!/usr/bin/env sh
# ----------------------------------------------------------------
# Module: Dotfiles Sinking and Reconciling Engine
# ----------------------------------------------------------------
set -eu

[ -f "${_PROFILE_ROOT:-.}/core/desktop.sh" ] && . "${_PROFILE_ROOT:-.}/core/desktop.sh"
[ -f "${_PROFILE_ROOT:-.}/core/display.sh" ] && . "${_PROFILE_ROOT:-.}/core/display.sh"

### ================================
### SUBCOMANDOS DE LINHA
### ================================
_profile_item() {
	_source_path="$1" _target_path="$2" _action_mode="${3:-sync}" _is_dry_run="${4:-0}" _use_backup="${5:-0}" _timestamp="${6:-}"
	[ ! -e "${_source_path}" ] && return 0

	if [ "${_action_mode}" = "status" ]; then
		[ ! -e "${_target_path}" ] && [ ! -L "${_target_path}" ] && { _ui_warn "[MISSING] ${_target_path}"; return 0; }
		[ -L "${_target_path}" ] && { [ "$(readlink "${_target_path}" 2> "/dev/null" || true)" = "${_source_path}" ] && _ui_ok "[IN-SYNC] ${_target_path}" || _ui_warn "[DRIFT] ${_target_path}"; return 0; }
		[ -d "${_source_path}" ] && [ -d "${_target_path}" ] && { diff -rq "${_source_path}" "${_target_path}" > "/dev/null" 2>&1 && _ui_ok "[IN-SYNC-DIR] ${_target_path}" || _ui_warn "[DRIFT-DIR] ${_target_path}"; return 0; }
		cmp -s "${_source_path}" "${_target_path}" 2> "/dev/null" && _ui_ok "[IN-SYNC] ${_target_path}" || _ui_warn "[DRIFT] ${_target_path}"
		return 0
	fi

	if [ "${_action_mode}" = "pull" ]; then
		{ [ ! -e "${_target_path}" ] || [ -L "${_target_path}" ]; } && return 0
		if [ -d "${_source_path}" ] && [ -d "${_target_path}" ]; then
			! diff -rq "${_source_path}" "${_target_path}" > "/dev/null" 2>&1 && { [ "${_is_dry_run}" -eq 1 ] && _ui_sub "[DRY-RUN PULL] ${_target_path} -> ${_source_path}" || { cp -rf "${_target_path}/." "${_source_path}/"; _ui_ok "[RECONCILED-DIR] ${_source_path} <- ${_target_path}"; }; }
			return 0
		fi
		if [ -f "${_source_path}" ] && [ -f "${_target_path}" ]; then
			! cmp -s "${_source_path}" "${_target_path}" 2> "/dev/null" && { [ "${_is_dry_run}" -eq 1 ] && _ui_sub "[DRY-RUN PULL] ${_target_path} -> ${_source_path}" || { cp -f "${_target_path}" "${_source_path}"; _ui_ok "[RECONCILED] ${_source_path} <- ${_target_path}"; }; }
		fi
		return 0
	fi

	[ "${_is_dry_run}" -eq 1 ] && { _ui_sub "[DRY-RUN] ${_source_path} -> ${_target_path}"; return 0; }

	mkdir -p "$(dirname "${_target_path}")"
	if [ -L "${_target_path}" ]; then
		[ "$(readlink "${_target_path}" 2> "/dev/null" || true)" = "${_source_path}" ] && { _ui_sub "[OK] ${_target_path}"; return 0; }
		rm -rf "${_target_path}" 2> "/dev/null" || unlink "${_target_path}" 2> "/dev/null" || true
	elif [ -e "${_target_path}" ]; then
		if [ -d "${_source_path}" ] && [ -d "${_target_path}" ]; then
			diff -rq "${_source_path}" "${_target_path}" > "/dev/null" 2>&1 && { _ui_sub "[OK-DIR] ${_target_path}"; return 0; }
		elif [ -f "${_source_path}" ] && [ -f "${_target_path}" ]; then
			cmp -s "${_source_path}" "${_target_path}" 2> "/dev/null" && { _ui_sub "[OK] ${_target_path}"; return 0; }
		fi
		[ "${_use_backup}" -eq 1 ] && { mv "${_target_path}" "${_target_path}.bak.${_timestamp}" 2> "/dev/null" && _ui_warn "[BACKUP] ${_target_path}.bak.${_timestamp}" || { _ui_err "Falha ao criar backup de ${_target_path}"; return 1; }; } || rm -rf "${_target_path}"
	fi

	export MSYS="winsymlinks:nativestrict"
	if ln -sf "${_source_path}" "${_target_path}" 2> "/dev/null"; then
		_ui_ok "[LINK] ${_target_path}"
	else
		cp -rf "${_source_path}" "${_target_path}"
		_ui_warn "[COPY] ${_target_path} (Modo de Desenvolvedor desativado)"
	fi
}

### ================================
### WINDOWS VIM JUNCTION
### ================================
_profile_win_vim_junction() {
	_source_dir="$1" _target_link="$2" _action_mode="${3:-sync}" _is_dry_run="${4:-0}"
	[ ! -d "${_source_dir}" ] && return 0

	_source_real="$(CDPATH="" cd -P "${_source_dir}" 2> "/dev/null" && pwd -P || true)"
	_target_real=""
	if [ -d "${_target_link}" ]; then _target_real="$(CDPATH="" cd -P "${_target_link}" 2> "/dev/null" && pwd -P || true)"; fi

	_is_in_sync=0
	if [ -n "${_source_real}" ] && [ "${_target_real}" = "${_source_real}" ]; then
		_is_in_sync=1
	elif [ -L "${_target_link}" ] && [ -d "${_target_link}" ]; then
		_raw_target="$(readlink "${_target_link}" 2> "/dev/null" || true)"
		if [ -n "${_raw_target}" ] && command -v cygpath > "/dev/null" 2>&1; then _raw_target="$(cygpath -u "${_raw_target}" 2> "/dev/null" || echo "${_raw_target}")"; fi
		_raw_target="${_raw_target%/}"
		if [ -n "${_raw_target}" ] && { [ "${_raw_target}" = "${_source_dir%/}" ] || [ "${_raw_target}" = "${_source_real}" ]; }; then _is_in_sync=1; fi
	fi

	if [ "${_action_mode}" = "status" ]; then
		if [ ! -e "${_target_link}" ] && [ ! -L "${_target_link}" ]; then _ui_warn "[MISSING] ${_target_link} -> ${_source_dir}"
		elif [ "${_is_in_sync}" -eq 1 ]; then _ui_ok "[IN-SYNC-JUNCTION] ${_target_link}"
		else _ui_warn "[DRIFT] ${_target_link}"
		fi
		return 0
	fi
	if [ "${_is_dry_run}" -eq 1 ]; then
		if [ "${_is_in_sync}" -eq 1 ]; then _ui_sub "[OK] ${_target_link}"; else _ui_sub "[DRY-RUN JUNCTION] ${_target_link} -> ${_source_dir}"; fi
		return 0
	fi
	if [ "${_is_in_sync}" -eq 1 ]; then _ui_sub "[OK] ${_target_link}"; return 0; fi

	_win_source="${_source_dir}" _win_target="${_target_link}"
	if command -v cygpath > "/dev/null" 2>&1; then
		_win_source="$(cygpath -w "${_source_dir}" 2> "/dev/null" || echo "${_source_dir}")"
		_win_target="$(cygpath -w "${_target_link}" 2> "/dev/null" || echo "${_target_link}")"
	fi
	if [ -L "${_target_link}" ]; then
		unlink "${_target_link}" 2> "/dev/null" || rm -f "${_target_link}" 2> "/dev/null" || { command -v cmd.exe > "/dev/null" 2>&1 && MSYS2_ARG_CONV_EXCL="*" cmd.exe /c rmdir "${_win_target}" > "/dev/null" 2>&1; } || true
		if [ -L "${_target_link}" ] || [ -e "${_target_link}" ]; then _ui_warn "[CONFLICT] ${_target_link} existe como link protegido (mantido)"; return 0; fi
	elif [ -d "${_target_link}" ]; then
		rmdir "${_target_link}" 2> "/dev/null" || { _ui_warn "[CONFLICT] ${_target_link} existe como diretório independente (mantido)"; return 0; }
	elif [ -e "${_target_link}" ]; then
		_ui_warn "[CONFLICT] ${_target_link} existe como arquivo independente (mantido)"; return 0
	fi

	mkdir -p "$(dirname "${_target_link}")"
	if command -v cmd.exe > "/dev/null" 2>&1; then
		if MSYS2_ARG_CONV_EXCL="*" cmd.exe /c mklink /J "${_win_target}" "${_win_source}" > "/dev/null" 2>&1; then
			_ui_ok "[JUNCTION] ${_target_link} -> ${_source_dir}"
		else
			_ui_warn "[JUNCTION] Falha ao criar junction ${_target_link} -> ${_source_dir}"
		fi
	elif ln -s "${_source_dir}" "${_target_link}" 2> "/dev/null"; then
		_ui_ok "[JUNCTION] ${_target_link} -> ${_source_dir}"
	else
		_ui_warn "[JUNCTION] Falha ao criar link ${_target_link} -> ${_source_dir}"
	fi
}

### ================================
### SINCRONIZACAO DE DOTFILES
### ================================
_profile_sync() {
	_dry_run=0 _backup=0 _mode="sync" _timestamp="$(date +%Y%m%d%H%M%S)" _os_type="$(uname -s)"
	_config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}" _data_dir="${XDG_DATA_HOME:-${HOME}/.local/share}"
	_is_windows=0 _win_home="${USERPROFILE:-${HOME}}"
	_win_appdata="${APPDATA:-${_win_home}/AppData/Roaming}" _win_localappdata="${LOCALAPPDATA:-${_win_home}/AppData/Local}"

	case "${_os_type}" in
		MINGW*|MSYS*|CYGWIN*|*_NT*)
			_is_windows=1
			if command -v cygpath > "/dev/null" 2>&1; then
				_win_home="$(cygpath -u "${USERPROFILE:-/c/Users/${USER}}")"
				_win_appdata="$(cygpath -u "${APPDATA:-${_win_home}/AppData/Roaming}")"
				_win_localappdata="$(cygpath -u "${LOCALAPPDATA:-${_win_home}/AppData/Local}")"
				_win_onedrive="$(cygpath -u "${OneDriveConsumer:-${OneDrive:-${USERPROFILE}\\OneDrive}}")"
			else
				_win_onedrive="${_win_home}/OneDrive"
			fi
			_win_documents="${_win_home}/Documents"
			for _candidate_dir in "${_win_onedrive}/Documents" "${_win_onedrive}/Documentos" "${_win_home}/Documentos"; do
				[ -d "${_candidate_dir}" ] && _win_documents="${_candidate_dir}" && break
			done
			;;
	esac

	_with_extensions=0
	for _argument in "$@"; do
		case "${_argument}" in
			--help|-h)       _profile_help; return 0 ;;
			--dry-run|-n)    _dry_run=1 ;;
			--backup|-b)     _backup=1 ;;
			--status|-s)     _mode="status" ;;
			--pull)          _mode="pull" ;;
			--extensions|-e) _with_extensions=1 ;;
		esac
	done

	_sync() { _profile_item "${_PROFILE_ROOT}/$1" "$2" "${_mode}" "${_dry_run}" "${_backup}" "${_timestamp}"; }
	_ui_step "Sincronizando ecossistema (${_os_type} - ${_mode}) a partir de: ${_PROFILE_ROOT}"
	[ "${_dry_run}" -eq 1 ] && _ui_warn "Modo DRY-RUN ativado (nenhum arquivo sera modificado)."

	_ui_step "Formatadores globais e linters..."
	for _tool_file in .clang-format .prettierrc .stylua.toml .editorconfig; do
		_sync "tools/${_tool_file}" "${HOME}/${_tool_file}"
		[ "${_is_windows}" -eq 1 ] && [ "${_win_home}" != "${HOME}" ] && _sync "tools/${_tool_file}" "${_win_home}/${_tool_file}"
	done
	_sync "tools/mermaid-puppeteer.json" "${HOME}/.mermaid-puppeteer-config.json"
	_sync "tools/mermaid-theme.json" "${HOME}/.mermaid-theme-config.json"
	_clangd_target="${_config_dir}/clangd/config.yaml" && _ruff_target="${_config_dir}/ruff/ruff.toml"
	[ "${_is_windows}" -eq 1 ] && _clangd_target="${_win_localappdata}/clangd/config.yaml" && _ruff_target="${_win_appdata}/ruff/ruff.toml"
	_sync "tools/clangd.yaml" "${_clangd_target}" && _sync "tools/ruff.toml" "${_ruff_target}"

	_ui_step "Editores modernos (Zed, VSCode, VSCodium, Antigravity IDE)..."
	_sync "editors/zed/settings.json" "${_config_dir}/zed/settings.json"
	_editor_dir="${_config_dir}" && [ "${_os_type}" = "Darwin" ] && _editor_dir="${HOME}/Library/Application Support"
	[ "${_is_windows}" -eq 1 ] && _editor_dir="${_win_appdata}"
	_sync "editors/vscode/settings.json" "${_editor_dir}/Code/User/settings.json"
	[ "${_os_type}" != "Darwin" ] && [ "${_is_windows}" -eq 0 ] && _sync "editors/vscode/settings.json" "${_config_dir}/Code - OSS/User/settings.json"
	_sync "editors/vscodium/settings.json" "${_editor_dir}/VSCodium/User/settings.json" && _sync "editors/antigravity/settings.json" "${_editor_dir}/Antigravity IDE/User/settings.json"
	_vimfiles_dir=""
	if [ -d "${_win_home}/vimfiles" ]; then _vimfiles_dir="${_win_home}/vimfiles"; elif [ -d "${HOME}/vimfiles" ]; then _vimfiles_dir="${HOME}/vimfiles"; fi
	if [ "${_is_windows}" -eq 1 ] && [ "${_mode}" != "pull" ] && [ -n "${_vimfiles_dir}" ]; then
		_profile_win_vim_junction "${_vimfiles_dir}" "${_win_home}/.vim" "${_mode}" "${_dry_run}"
		if [ "${HOME%/}" != "${_win_home%/}" ]; then
			_profile_win_vim_junction "${_vimfiles_dir}" "${HOME}/.vim" "${_mode}" "${_dry_run}"
		fi
	fi

	_ui_step "Emuladores de terminal e multiplexadores..."
	_sync "terminals/tmux/tmux.conf" "${_config_dir}/tmux/tmux.conf" && _sync "terminals/tmux/tmux.conf" "${HOME}/.tmux.conf"
	if [ "${_is_windows}" -eq 1 ]; then
		_sync "terminals/windows-terminal/settings.json" "${_win_localappdata}/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
		_sync "terminals/zellij/config.kdl" "${_win_appdata}/zellij/config.kdl"
	else
		_sync "terminals/zellij/config.kdl" "${_config_dir}/zellij/config.kdl" && _sync "terminals/foot/foot.ini" "${_config_dir}/foot/foot.ini"
		for _xresources_file in .Xresources .Xdefaults; do _sync "terminals/xterm/Xresources" "${HOME}/${_xresources_file}"; done
		for _konsole_profile in Bash Shell Zsh; do _sync "terminals/konsole/${_konsole_profile}.profile" "${_data_dir}/konsole/${_konsole_profile}.profile"; done
		[ -f "${_PROFILE_ROOT}/terminals/terminfo/linux.terminfo" ] && command -v tic > "/dev/null" 2>&1 && tic -o "${HOME}/.terminfo" "${_PROFILE_ROOT}/terminals/terminfo/linux.terminfo" 2> "/dev/null" || true
		[ -n "${DISPLAY:-}" ] && [ -f "${HOME}/.Xresources" ] && command -v xrdb > "/dev/null" 2>&1 && xrdb -merge "${HOME}/.Xresources" 2> "/dev/null" || true
		_display_sync_all
		_desktop_sync_all
	fi

	_ui_step "Agentes de IA (Skills & Rules para Antigravity & Gemini)..."
	_sync "agents/skills" "${HOME}/.gemini/config/skills" && _sync "agents/rules" "${HOME}/.gemini/config/rules"
	if [ "${_is_windows}" -eq 1 ] && [ "${_win_home}" != "${HOME}" ]; then
		_sync "agents/skills" "${_win_home}/.gemini/config/skills" && _sync "agents/rules" "${_win_home}/.gemini/config/rules"
	fi

	if [ "${_with_extensions}" -eq 1 ] && command -v _profile_extensions > "/dev/null" 2>&1; then
		_extension_flags="install"
		[ "${_dry_run}" -eq 1 ] && _extension_flags="${_extension_flags} --dry-run"
		[ "${_mode}" = "status" ] && _extension_flags="status"
		_profile_extensions ${_extension_flags}
	fi

	_ui_ok "Operacao (${_mode}) concluida com sucesso!"
}
