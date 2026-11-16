#!/usr/bin/env sh
# ----------------------------------------------------------------
# Module: Dotfiles Sinking and Reconciling Engine
# ----------------------------------------------------------------
set -eu

[ -f "${_PROFILE_ROOT:-.}/core/desktop.sh" ] && . "${_PROFILE_ROOT:-.}/core/desktop.sh"

### ================================
### SUBCOMANDOS DE LINHA
### ================================
_profile_item() {
	_src="$1" _dst="$2" _m="${3:-sync}" _dry="${4:-0}" _bak="${5:-0}" _ts="${6:-}"
	[ ! -e "${_src}" ] && return 0

	if [ "${_m}" = "status" ]; then
		[ ! -e "${_dst}" ] && [ ! -L "${_dst}" ] && { _ui_warn "[MISSING] ${_dst}"; return 0; }
		[ -L "${_dst}" ] && { [ "$(readlink "${_dst}" 2> "/dev/null" || true)" = "${_src}" ] && _ui_ok "[IN-SYNC] ${_dst}" || _ui_warn "[DRIFT] ${_dst}"; return 0; }
		[ -d "${_src}" ] && [ -d "${_dst}" ] && { diff -rq "${_src}" "${_dst}" > "/dev/null" 2>&1 && _ui_ok "[IN-SYNC-DIR] ${_dst}" || _ui_warn "[DRIFT-DIR] ${_dst}"; return 0; }
		cmp -s "${_src}" "${_dst}" 2> "/dev/null" && _ui_ok "[IN-SYNC] ${_dst}" || _ui_warn "[DRIFT] ${_dst}"
		return 0
	fi

	if [ "${_m}" = "pull" ]; then
		{ [ ! -e "${_dst}" ] || [ -L "${_dst}" ]; } && return 0
		if [ -d "${_src}" ] && [ -d "${_dst}" ]; then
			! diff -rq "${_src}" "${_dst}" > "/dev/null" 2>&1 && { [ "${_dry}" -eq 1 ] && _ui_sub "[DRY-RUN PULL] ${_dst} -> ${_src}" || { cp -rf "${_dst}/." "${_src}/"; _ui_ok "[RECONCILED-DIR] ${_src} <- ${_dst}"; }; }
			return 0
		fi
		if [ -f "${_src}" ] && [ -f "${_dst}" ]; then
			! cmp -s "${_src}" "${_dst}" 2> "/dev/null" && { [ "${_dry}" -eq 1 ] && _ui_sub "[DRY-RUN PULL] ${_dst} -> ${_src}" || { cp -f "${_dst}" "${_src}"; _ui_ok "[RECONCILED] ${_src} <- ${_dst}"; }; }
		fi
		return 0
	fi

	[ "${_dry}" -eq 1 ] && { _ui_sub "[DRY-RUN] ${_src} -> ${_dst}"; return 0; }

	mkdir -p "$(dirname "${_dst}")"
	if [ -L "${_dst}" ]; then
		[ "$(readlink "${_dst}" 2> "/dev/null" || true)" = "${_src}" ] && { _ui_sub "[OK] ${_dst}"; return 0; }
		rm -rf "${_dst}" 2> "/dev/null" || unlink "${_dst}" 2> "/dev/null" || true
	elif [ -e "${_dst}" ]; then
		if [ -d "${_src}" ] && [ -d "${_dst}" ]; then
			diff -rq "${_src}" "${_dst}" > "/dev/null" 2>&1 && { _ui_sub "[OK-DIR] ${_dst}"; return 0; }
		elif [ -f "${_src}" ] && [ -f "${_dst}" ]; then
			cmp -s "${_src}" "${_dst}" 2> "/dev/null" && { _ui_sub "[OK] ${_dst}"; return 0; }
		fi
		[ "${_bak}" -eq 1 ] && { mv "${_dst}" "${_dst}.bak.${_ts}" 2> "/dev/null" && _ui_warn "[BACKUP] ${_dst}.bak.${_ts}" || { _ui_err "Falha ao criar backup de ${_dst}"; return 1; }; } || rm -rf "${_dst}"
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
### WINDOWS VIM JUNCTION
### ================================
_profile_win_vim_junction() {
	_src="$1" _dst="$2" _m="${3:-sync}" _dry="${4:-0}"
	[ ! -d "${_src}" ] && return 0

	_src_phys="$(CDPATH="" cd -P "${_src}" 2> "/dev/null" && pwd -P || true)"
	_dst_phys=""
	if [ -d "${_dst}" ]; then _dst_phys="$(CDPATH="" cd -P "${_dst}" 2> "/dev/null" && pwd -P || true)"; fi

	_in_sync=0
	if [ -n "${_src_phys}" ] && [ "${_dst_phys}" = "${_src_phys}" ]; then
		_in_sync=1
	elif [ -L "${_dst}" ] && [ -d "${_dst}" ]; then
		_raw_tgt="$(readlink "${_dst}" 2> "/dev/null" || true)"
		if [ -n "${_raw_tgt}" ] && command -v cygpath > "/dev/null" 2>&1; then _raw_tgt="$(cygpath -u "${_raw_tgt}" 2> "/dev/null" || echo "${_raw_tgt}")"; fi
		_raw_tgt="${_raw_tgt%/}"
		if [ -n "${_raw_tgt}" ] && { [ "${_raw_tgt}" = "${_src%/}" ] || [ "${_raw_tgt}" = "${_src_phys}" ]; }; then _in_sync=1; fi
	fi

	if [ "${_m}" = "status" ]; then
		if [ ! -e "${_dst}" ] && [ ! -L "${_dst}" ]; then _ui_warn "[MISSING] ${_dst} -> ${_src}"
		elif [ "${_in_sync}" -eq 1 ]; then _ui_ok "[IN-SYNC-JUNCTION] ${_dst}"
		else _ui_warn "[DRIFT] ${_dst}"
		fi
		return 0
	fi
	if [ "${_dry}" -eq 1 ]; then
		if [ "${_in_sync}" -eq 1 ]; then _ui_sub "[OK] ${_dst}"; else _ui_sub "[DRY-RUN JUNCTION] ${_dst} -> ${_src}"; fi
		return 0
	fi
	if [ "${_in_sync}" -eq 1 ]; then _ui_sub "[OK] ${_dst}"; return 0; fi

	_w_src="${_src}" _w_dst="${_dst}"
	if command -v cygpath > "/dev/null" 2>&1; then
		_w_src="$(cygpath -w "${_src}" 2> "/dev/null" || echo "${_src}")"
		_w_dst="$(cygpath -w "${_dst}" 2> "/dev/null" || echo "${_dst}")"
	fi
	if [ -L "${_dst}" ]; then
		unlink "${_dst}" 2> "/dev/null" || rm -f "${_dst}" 2> "/dev/null" || { command -v cmd.exe > "/dev/null" 2>&1 && MSYS2_ARG_CONV_EXCL="*" cmd.exe /c rmdir "${_w_dst}" > "/dev/null" 2>&1; } || true
		if [ -L "${_dst}" ] || [ -e "${_dst}" ]; then _ui_warn "[CONFLICT] ${_dst} existe como link protegido (mantido)"; return 0; fi
	elif [ -d "${_dst}" ]; then
		rmdir "${_dst}" 2> "/dev/null" || { _ui_warn "[CONFLICT] ${_dst} existe como diretório independente (mantido)"; return 0; }
	elif [ -e "${_dst}" ]; then
		_ui_warn "[CONFLICT] ${_dst} existe como arquivo independente (mantido)"; return 0
	fi

	mkdir -p "$(dirname "${_dst}")"
	if command -v cmd.exe > "/dev/null" 2>&1; then
		if MSYS2_ARG_CONV_EXCL="*" cmd.exe /c mklink /J "${_w_dst}" "${_w_src}" > "/dev/null" 2>&1; then
			_ui_ok "[JUNCTION] ${_dst} -> ${_src}"
		else
			_ui_warn "[JUNCTION] Falha ao criar junction ${_dst} -> ${_src}"
		fi
	elif ln -s "${_src}" "${_dst}" 2> "/dev/null"; then
		_ui_ok "[JUNCTION] ${_dst} -> ${_src}"
	else
		_ui_warn "[JUNCTION] Falha ao criar link ${_dst} -> ${_src}"
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
				_win_onedrive="$(cygpath -u "${OneDriveConsumer:-${OneDrive:-${USERPROFILE}\\OneDrive}}")"
			else
				_win_onedrive="${_win_home}/OneDrive"
			fi
			_win_docs="${_win_home}/Documents"
			for _cand in "${_win_onedrive}/Documents" "${_win_onedrive}/Documentos" "${_win_home}/Documentos"; do
				[ -d "${_cand}" ] && _win_docs="${_cand}" && break
			done
			;;
	esac

	_with_ext=0
	for _arg in "$@"; do
		case "${_arg}" in
			--help|-h)       _profile_help; return 0 ;;
			--dry-run|-n)    _dry_run=1 ;;
			--backup|-b)     _backup=1 ;;
			--status|-s)     _mode="status" ;;
			--pull)          _mode="pull" ;;
			--extensions|-e) _with_ext=1 ;;
		esac
	done

	_sync() { _profile_item "${_PROFILE_ROOT}/$1" "$2" "${_mode}" "${_dry_run}" "${_backup}" "${_timestamp}"; }
	_ui_step "Sincronizando ecossistema (${_os_type} - ${_mode}) a partir de: ${_PROFILE_ROOT}"
	[ "${_dry_run}" -eq 1 ] && _ui_warn "Modo DRY-RUN ativado (nenhum arquivo sera modificado)."

	_ui_step "Formatadores globais e linters..."
	for _f in .clang-format .prettierrc .stylua.toml .editorconfig; do
		_sync "tools/${_f}" "${HOME}/${_f}"
		[ "${_is_win}" -eq 1 ] && [ "${_win_home}" != "${HOME}" ] && _sync "tools/${_f}" "${_win_home}/${_f}"
	done
	_sync "tools/mermaid-puppeteer.json" "${HOME}/.mermaid-puppeteer-config.json"
	_sync "tools/mermaid-theme.json" "${HOME}/.mermaid-theme-config.json"
	_clangd_dst="${_cfg}/clangd/config.yaml" && _ruff_dst="${_cfg}/ruff/ruff.toml"
	[ "${_is_win}" -eq 1 ] && _clangd_dst="${_win_local}/clangd/config.yaml" && _ruff_dst="${_win_app}/ruff/ruff.toml"
	_sync "tools/clangd.yaml" "${_clangd_dst}" && _sync "tools/ruff.toml" "${_ruff_dst}"

	_ui_step "Editores modernos (Zed, VSCode, VSCodium, Antigravity IDE)..."
	_sync "editors/zed/settings.json" "${_cfg}/zed/settings.json"
	_ed_dir="${_cfg}" && [ "${_os_type}" = "Darwin" ] && _ed_dir="${HOME}/Library/Application Support"
	[ "${_is_win}" -eq 1 ] && _ed_dir="${_win_app}"
	_sync "editors/vscode/settings.json" "${_ed_dir}/Code/User/settings.json"
	[ "${_os_type}" != "Darwin" ] && [ "${_is_win}" -eq 0 ] && _sync "editors/vscode/settings.json" "${_cfg}/Code - OSS/User/settings.json"
	_sync "editors/vscodium/settings.json" "${_ed_dir}/VSCodium/User/settings.json" && _sync "editors/antigravity/settings.json" "${_ed_dir}/Antigravity IDE/User/settings.json"
	_win_vimfiles=""
	if [ -d "${_win_home}/vimfiles" ]; then _win_vimfiles="${_win_home}/vimfiles"; elif [ -d "${HOME}/vimfiles" ]; then _win_vimfiles="${HOME}/vimfiles"; fi
	if [ "${_is_win}" -eq 1 ] && [ "${_mode}" != "pull" ] && [ -n "${_win_vimfiles}" ]; then
		_profile_win_vim_junction "${_win_vimfiles}" "${_win_home}/.vim" "${_mode}" "${_dry_run}"
		if [ "${HOME%/}" != "${_win_home%/}" ]; then
			_profile_win_vim_junction "${_win_vimfiles}" "${HOME}/.vim" "${_mode}" "${_dry_run}"
		fi
	fi

	_ui_step "Emuladores de terminal e multiplexadores..."
	_sync "terminals/tmux/tmux.conf" "${_cfg}/tmux/tmux.conf" && _sync "terminals/tmux/tmux.conf" "${HOME}/.tmux.conf"
	if [ "${_is_win}" -eq 1 ]; then
		_sync "terminals/windows-terminal/settings.json" "${_win_local}/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
		_sync "terminals/zellij/config.kdl" "${_win_app}/zellij/config.kdl"
	else
		_sync "terminals/zellij/config.kdl" "${_cfg}/zellij/config.kdl" && _sync "terminals/foot/foot.ini" "${_cfg}/foot/foot.ini"
		for _xr in .Xresources .Xdefaults; do _sync "terminals/xterm/Xresources" "${HOME}/${_xr}"; done
		for _kp in Bash Shell Zsh; do _sync "terminals/konsole/${_kp}.profile" "${_data}/konsole/${_kp}.profile"; done
		[ -f "${_PROFILE_ROOT}/terminals/terminfo/linux.terminfo" ] && command -v tic > "/dev/null" 2>&1 && tic -o "${HOME}/.terminfo" "${_PROFILE_ROOT}/terminals/terminfo/linux.terminfo" 2> "/dev/null" || true
		[ -n "${DISPLAY:-}" ] && [ -f "${HOME}/.Xresources" ] && command -v xrdb > "/dev/null" 2>&1 && xrdb -merge "${HOME}/.Xresources" 2> "/dev/null" || true
		_desktop_sync_all
	fi

	_ui_step "Agentes de IA (Skills & Rules para Antigravity & Gemini)..."
	_sync "agents/skills" "${HOME}/.gemini/config/skills" && _sync "agents/rules" "${HOME}/.gemini/config/rules"
	if [ "${_is_win}" -eq 1 ] && [ "${_win_home}" != "${HOME}" ]; then
		_sync "agents/skills" "${_win_home}/.gemini/config/skills" && _sync "agents/rules" "${_win_home}/.gemini/config/rules"
	fi

	if [ "${_with_ext}" -eq 1 ] && command -v _profile_extensions > "/dev/null" 2>&1; then
		_ext_flags="install"
		[ "${_dry_run}" -eq 1 ] && _ext_flags="${_ext_flags} --dry-run"
		[ "${_mode}" = "status" ] && _ext_flags="status"
		_profile_extensions ${_ext_flags}
	fi

	_ui_ok "Operacao (${_mode}) concluida com sucesso!"
}
