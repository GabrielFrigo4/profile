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
	_profile_item "${_PROFILE_ROOT}/desktop/xorg/cursor.theme" "${HOME}/.icons/default/index.theme" "${_action_mode}" "${_is_dry_run}" "${_use_backup}" "${_stamp}"
	_profile_item "${_PROFILE_ROOT}/desktop/xorg/cursor.theme" "${_target_data}/icons/default/index.theme" "${_action_mode}" "${_is_dry_run}" "${_use_backup}" "${_stamp}"
	_profile_item "${_PROFILE_ROOT}/desktop/wayland/display.conf" "${_target_config}/environment.d/00-display.conf" "${_action_mode}" "${_is_dry_run}" "${_use_backup}" "${_stamp}"
	_display_ensure_xauthority "${_action_mode}" "${_is_dry_run}"
}
