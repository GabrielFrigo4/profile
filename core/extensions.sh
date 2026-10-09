#!/usr/bin/env sh
# ----------------------------------------------------------------
# Module: IDE Declarative Extensions Synchronization Engine
# ----------------------------------------------------------------
set -eu

_profile_find_ide_cli() {
	_p_target="${1:-auto}"
	case "${_p_target}" in
		antigravity)
			command -v antigravity > "/dev/null" 2>&1 && echo "antigravity" && return 0
			;;
		vscodium)
			if command -v codium > "/dev/null" 2>&1; then echo "codium"; return 0;
			elif command -v vscodium > "/dev/null" 2>&1; then echo "vscodium"; return 0; fi
			;;
		vscode)
			if command -v code > "/dev/null" 2>&1; then echo "code"; return 0;
			elif command -v vscode > "/dev/null" 2>&1; then echo "vscode"; return 0;
			elif command -v code-oss > "/dev/null" 2>&1; then echo "code-oss"; return 0; fi
			;;
		auto|*)
			if command -v antigravity > "/dev/null" 2>&1; then echo "antigravity"; return 0;
			elif command -v code > "/dev/null" 2>&1; then echo "code"; return 0;
			elif command -v vscode > "/dev/null" 2>&1; then echo "vscode"; return 0;
			elif command -v code-oss > "/dev/null" 2>&1; then echo "code-oss"; return 0;
			elif command -v codium > "/dev/null" 2>&1; then echo "codium"; return 0;
			elif command -v vscodium > "/dev/null" 2>&1; then echo "vscodium"; return 0; fi
			;;
	esac
	return 1
}

_profile_target_from_cli() {
	case "$1" in
		antigravity) echo "antigravity" ;;
		codium|vscodium) echo "vscodium" ;;
		code|vscode|code-oss|*) echo "vscode" ;;
	esac
}

_profile_extensions() {
	_ext_act="install" _ext_target="auto" _ext_dry=0
	for _arg in "$@"; do
		case "${_arg}" in
			install|export|dump|status) _ext_act="${_arg}" ;;
			antigravity|vscode|vscodium) _ext_target="${_arg}" ;;
			--dry-run|-n) _ext_dry=1 ;;
		esac
	done

	_ext_cli="$(_profile_find_ide_cli "${_ext_target}" 2> "/dev/null" || true)"
	if [ -z "${_ext_cli}" ]; then
		_ui_warn "Nenhuma CLI de editor encontrada (antigravity, code, vscode, code-oss, codium)."
		return 0
	fi

	[ "${_ext_target}" = "auto" ] && _ext_target="$(_profile_target_from_cli "${_ext_cli}")"
	_ext_file="${_PROFILE_ROOT}/editors/${_ext_target}/extensions.txt"

	if [ "${_ext_act}" = "export" ] || [ "${_ext_act}" = "dump" ]; then
		_ui_step "Exportando extensões de ${_ext_cli} para ${_ext_file}..."
		mkdir -p "$(dirname "${_ext_file}")"
		"${_ext_cli}" --list-extensions | sort > "${_ext_file}"
		_ui_ok "Extensões exportadas com sucesso!"
		return 0
	fi

	if [ ! -f "${_ext_file}" ]; then
		_ui_info "Manifesto não encontrado: ${_ext_file}"
		return 0
	fi

	_ui_step "Sincronizando extensões de ${_ext_target} (${_ext_cli})..."
	while IFS= read -r _line || [ -n "${_line}" ]; do
		_line="$(echo "${_line}" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
		case "${_line}" in \#*|"") continue ;; esac

		if [ "${_ext_act}" = "status" ]; then
			_ui_sub "[DECLARADA] ${_line}"
		elif [ "${_ext_dry}" -eq 1 ]; then
			_ui_sub "[DRY-RUN EXT] ${_ext_cli} --install-extension ${_line}"
		else
			"${_ext_cli}" --install-extension "${_line}" --force > "/dev/null" 2>&1 || true
			_ui_ok "[EXT] ${_line}"
		fi
	done < "${_ext_file}"
	_ui_ok "Sincronização de extensões concluída!"
}
