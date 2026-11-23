#!/usr/bin/env sh
# ----------------------------------------------------------------
# Module: X11 and Wayland Display Configuration Sync
# ----------------------------------------------------------------
set -eu

### ================================
### XAUTHORITY RUNTIME HYGIENE
### ================================
_display_ensure_xauthority() {
	_sync_mode="${1:-sync}" _is_dry_run="${2:-0}"
	_xauthority_file="${HOME}/.Xauthority"

	if [ "${_sync_mode}" = "status" ]; then
		if [ -L "${_xauthority_file}" ]; then
			_ui_warn "[DRIFT] ${_xauthority_file}"
		elif [ -f "${_xauthority_file}" ]; then
			case "$(ls -ld "${_xauthority_file}" 2> "/dev/null" || true)" in
				-rw-------*) _ui_ok "[IN-SYNC] ${_xauthority_file}" ;;
				*)           _ui_warn "[DRIFT] ${_xauthority_file} (esperado: 0600)" ;;
			esac
		else
			_ui_warn "[MISSING] ${_xauthority_file}"
		fi
		return 0
	fi

	[ "${_sync_mode}" = "pull" ] && return 0
	if [ "${_is_dry_run}" -eq 1 ]; then
		if [ -f "${_xauthority_file}" ]; then
			_ui_sub "[OK] ${_xauthority_file}"
		else
			_ui_sub "[DRY-RUN] ${_xauthority_file} (0600)"
		fi
		return 0
	fi

	if [ ! -e "${_xauthority_file}" ] && [ ! -L "${_xauthority_file}" ]; then
		(umask 0077 && : > "${_xauthority_file}") 2> "/dev/null" || true
		[ -f "${_xauthority_file}" ] && _ui_ok "[XAUTH] ${_xauthority_file}"
	elif [ -f "${_xauthority_file}" ] && [ ! -L "${_xauthority_file}" ]; then
		chmod 0600 "${_xauthority_file}" 2> "/dev/null" || true
	fi
}

### --------------------------------
### CURSOR THEME GENERATION
### --------------------------------
_display_sync_cursor_theme() {
	_dst="$1"
	_c_mode="${2:-${_mode:-sync}}"
	_c_dry="${3:-${_dry_run:-0}}"
	_c_bak="${4:-${_backup:-0}}"
	_c_stamp="${5:-${_timestamp:-}}"
	_src_cur="${_PROFILE_ROOT}/desktop/xorg/cursor.theme"

	[ -f "${_src_cur}" ] || return 0
	[ "${_c_mode}" = "pull" ] && return 0

	_cursor="Adwaita"
	if command -v _desktop_detect_env > "/dev/null" 2>&1; then
		_de_cur="$(_desktop_detect_env)"
		case "${_de_cur}" in
			kde|lxqt) _cursor="breeze_cursors" ;;
		esac
	fi

	_tmp_cur="$(mktemp "${TMPDIR:-/tmp}/profile-cursor.XXXXXX")"
	sed "s|^Inherits=.*|Inherits=${_cursor}|" "${_src_cur}" > "${_tmp_cur}"

	if [ "${_c_mode}" = "status" ]; then
		if [ -f "${_dst}" ] && [ ! -L "${_dst}" ] && { cmp -s "${_tmp_cur}" "${_dst}" 2> "/dev/null" || { grep -qx '\[Icon Theme\]' "${_dst}" 2> "/dev/null" && grep -qx "Inherits=${_cursor}" "${_dst}" 2> "/dev/null"; }; }; then
			_ui_ok "[IN-SYNC] ${_dst}"
		else
			_ui_warn "[DRIFT] ${_dst}"
		fi
		rm -f "${_tmp_cur}"
		return 0
	fi

	if [ "${_c_dry}" -eq 1 ]; then
		_ui_sub "[DRY-RUN] ${_dst} (${_cursor})"
		rm -f "${_tmp_cur}"
		return 0
	fi

	mkdir -p "$(dirname "${_dst}")"
	if [ -L "${_dst}" ]; then
		rm -f "${_dst}"
	fi
	if [ -f "${_dst}" ] && cmp -s "${_tmp_cur}" "${_dst}" 2> "/dev/null"; then
		_ui_sub "[OK] ${_dst}"
	else
		if [ "${_c_bak}" -eq 1 ] && [ -e "${_dst}" ]; then
			mv "${_dst}" "${_dst}.bak.${_c_stamp}" 2> "/dev/null" && _ui_warn "[BACKUP] ${_dst}.bak.${_c_stamp}" || true
		elif [ -d "${_dst}" ]; then
			rm -rf "${_dst}"
		fi
		cp -f "${_tmp_cur}" "${_dst}"
		chmod 0644 "${_dst}" 2> "/dev/null" || true
		_ui_ok "[COPY] ${_dst} (${_cursor})"
	fi
	rm -f "${_tmp_cur}"
}

### ================================
### XORG AND WAYLAND DISPLAY SYNC
### ================================
_display_sync_all() {
	[ "${_os_type:-}" = "Darwin" ] && return 0

	_action_mode="${_mode:-sync}"
	_is_dry_run="${_dry_run:-0}"
	_use_backup="${_backup:-0}"
	_stamp="${_timestamp:-}"
	_target_config="${_config_dir:-${XDG_CONFIG_HOME:-${HOME}/.config}}"
	_target_data="${_data_dir:-${XDG_DATA_HOME:-${HOME}/.local/share}}"

	_ui_step "Display Server (Xorg, Wayland & Cursor Padrão)..."
	_profile_item "${_PROFILE_ROOT}/desktop/xorg/xserverrc" "${HOME}/.xserverrc" "${_action_mode}" "${_is_dry_run}" "${_use_backup}" "${_stamp}"
	_display_sync_cursor_theme "${HOME}/.icons/default/index.theme" "${_action_mode}" "${_is_dry_run}" "${_use_backup}" "${_stamp}"
	_display_sync_cursor_theme "${_target_data}/icons/default/index.theme" "${_action_mode}" "${_is_dry_run}" "${_use_backup}" "${_stamp}"
	_profile_item "${_PROFILE_ROOT}/desktop/wayland/display.conf" "${_target_config}/environment.d/00-display.conf" "${_action_mode}" "${_is_dry_run}" "${_use_backup}" "${_stamp}"
	if [ "${_action_mode}" = "sync" ] && [ "${_is_dry_run}" -eq 0 ]; then
		for _legacy_link in "${_target_config}/xdg-desktop-portal/portals.conf:${_PROFILE_ROOT}/desktop/wayland/portals.conf" "${_target_config}/autostart-scripts/pipewire-portal-init.sh:${_PROFILE_ROOT}/desktop/wayland/pipewire-portal-init.sh"; do
			_l_dst="${_legacy_link%%:*}" _l_src="${_legacy_link#*:}"
			if [ -L "${_l_dst}" ] && [ "$(readlink "${_l_dst}" 2> "/dev/null" || true)" = "${_l_src}" ]; then
				rm -f "${_l_dst}" 2> "/dev/null" || unlink "${_l_dst}" 2> "/dev/null" || true
			fi
		done
	fi
	_profile_item "${_PROFILE_ROOT}/desktop/wayland/portals.conf" "${_target_config}/xdg-desktop-portal/kde-portals.conf" "${_action_mode}" "${_is_dry_run}" "${_use_backup}" "${_stamp}"
	_profile_item "${_PROFILE_ROOT}/desktop/wayland/plasma-env.sh" "${_target_config}/plasma-workspace/env/00-wayland-portal.sh" "${_action_mode}" "${_is_dry_run}" "${_use_backup}" "${_stamp}"
	_profile_item "${_PROFILE_ROOT}/desktop/wayland/pipewire-portal-init.sh" "${HOME}/.local/bin/fix-wayland-screenshare.sh" "${_action_mode}" "${_is_dry_run}" "${_use_backup}" "${_stamp}"
	_profile_item "${_PROFILE_ROOT}/desktop/wayland/pipewire-portal.desktop" "${_target_config}/autostart/pipewire-portal.desktop" "${_action_mode}" "${_is_dry_run}" "${_use_backup}" "${_stamp}"
	_display_ensure_xauthority "${_action_mode}" "${_is_dry_run}"
}
