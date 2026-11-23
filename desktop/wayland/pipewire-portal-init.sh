#!/usr/bin/env sh
# ----------------------------------------------------------------
# Utility: PipeWire and XDG Desktop Portal Session Initializer
# ----------------------------------------------------------------
set -eu

_portal_needs_restart=0

### ================================
### PROCESS AND ENV HELPERS
### ================================
_list_pids_by_bin() {
	ps -o pid= -o args= -U "$(id -u)" 2> "/dev/null" | awk -v t="$1" '$2 ~ "(^|/)" t "$" { print $1 }'
}

_count_pids_by_bin() {
	_pids="$(_list_pids_by_bin "$1" || true)"
	[ -z "${_pids}" ] && { printf '0\n'; return 0; }
	printf '%s\n' "${_pids}" | awk 'END { print NR }'
}

_wait_cond() {
	_max="$1"
	[ "$#" -ge 1 ] && shift
	_i=0
	while [ "${_i}" -lt "${_max}" ]; do
		"$@" > "/dev/null" 2>&1 && return 0
		sleep 0.1
		_i=$((_i + 1))
	done
	return 1
}

_kill_pids() {
	_pids="$1"
	_wait_max="${2:-20}"
	[ -n "${_pids}" ] || return 0
	for _pid in ${_pids}; do kill -TERM "${_pid}" 2> "/dev/null" || true; done
	_i=0
	while [ "${_i}" -lt "${_wait_max}" ]; do
		_alive=0
		for _pid in ${_pids}; do kill -0 "${_pid}" 2> "/dev/null" && { _alive=1; break; }; done
		[ "${_alive}" -eq 0 ] && return 0
		sleep 0.1
		_i=$((_i + 1))
	done
	for _pid in ${_pids}; do kill -KILL "${_pid}" 2> "/dev/null" || true; done
	return 0
}

_extract_proc_env() {
	_pid="$1"
	_var_name="$2"
	if command -v procstat > "/dev/null" 2>&1; then
		procstat -e "${_pid}" 2> "/dev/null" | awk -v k="${_var_name}" 'NR == 2 { for (i = 3; i <= NF; i++) if ($i ~ "^" k "=") { sub(/^[^=]*=/, "", $i); print $i; exit } }' || true
	elif [ -r "/proc/${_pid}/environ" ]; then
		tr '\0' '\n' < "/proc/${_pid}/environ" 2> "/dev/null" | awk -v k="${_var_name}" '$0 ~ "^" k "=" { sub(/^[^=]*=/, ""); print; exit }' || true
	fi
}

_dbus_bus_valid() {
	_addr="${1:-}"
	[ -n "${_addr}" ] || return 1
	case "${_addr}" in
		unix:path=*)
			_sock="${_addr#unix:path=}"
			[ -S "${_sock%%,*}" ]
			;;
		*) return 0 ;;
	esac
}

_spawn_detached() {
	if command -v daemon > "/dev/null" 2>&1; then
		daemon -f "$1" > "/dev/null" 2>&1 || true
	else
		nohup "$1" > "/dev/null" 2>&1 < "/dev/null" &
	fi
}

_dbus_has_name() {
	dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames 2> "/dev/null" | grep -Fq "\"$1\""
}

_resolve_first_bin() {
	for _cand in "$@"; do
		[ -x "${_cand}" ] && { printf '%s\n' "${_cand}"; return 0; }
	done
	return 1
}

### ================================
### WAYLAND SESSION DISCOVERY
### ================================
_discover_wayland_session() {
	_need_discover=0
	[ -z "${XDG_RUNTIME_DIR:-}" ] && _need_discover=1
	[ -z "${WAYLAND_DISPLAY:-}" ] && _need_discover=1
	_dbus_bus_valid "${DBUS_SESSION_BUS_ADDRESS:-}" || _need_discover=1

	if [ "${_need_discover}" -eq 1 ]; then
		_kwin_pid="$(pgrep -u "$(id -u)" -x kwin_wayland 2> "/dev/null" | head -n 1 || true)"
		if [ -n "${_kwin_pid}" ]; then
			for _env_key in XDG_RUNTIME_DIR WAYLAND_DISPLAY DBUS_SESSION_BUS_ADDRESS DISPLAY XDG_CURRENT_DESKTOP; do
				_env_val="$(_extract_proc_env "${_kwin_pid}" "${_env_key}")"
				[ -n "${_env_val}" ] || continue
				case "${_env_key}" in
					XDG_RUNTIME_DIR) [ -z "${XDG_RUNTIME_DIR:-}" ] && export XDG_RUNTIME_DIR="${_env_val}" ;;
					WAYLAND_DISPLAY) [ -z "${WAYLAND_DISPLAY:-}" ] && export WAYLAND_DISPLAY="${_env_val}" ;;
					DBUS_SESSION_BUS_ADDRESS) _dbus_bus_valid "${DBUS_SESSION_BUS_ADDRESS:-}" || export DBUS_SESSION_BUS_ADDRESS="${_env_val}" ;;
					DISPLAY) [ -z "${DISPLAY:-}" ] && export DISPLAY="${_env_val}" ;;
					XDG_CURRENT_DESKTOP) [ -z "${XDG_CURRENT_DESKTOP:-}" ] && export XDG_CURRENT_DESKTOP="${_env_val}" ;;
				esac
			done
		fi
	fi

	if [ -z "${XDG_RUNTIME_DIR:-}" ] || [ ! -d "${XDG_RUNTIME_DIR:-}" ]; then
		if [ -d "/var/run/xdg/$(id -un)" ]; then
			export XDG_RUNTIME_DIR="/var/run/xdg/$(id -un)"
		elif [ -d "/var/run/user/$(id -u)" ]; then
			export XDG_RUNTIME_DIR="/var/run/user/$(id -u)"
		else
			export XDG_RUNTIME_DIR="/tmp/runtime-$(id -u)"
			mkdir -p "${XDG_RUNTIME_DIR}"
			chmod 0700 "${XDG_RUNTIME_DIR}"
		fi
	fi

	if [ -z "${WAYLAND_DISPLAY:-}" ] && [ -S "${XDG_RUNTIME_DIR}/wayland-0" ]; then
		export WAYLAND_DISPLAY="wayland-0"
	fi

	export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-KDE}"
	export XDG_SESSION_TYPE="wayland"
	export MOZ_ENABLE_WAYLAND=1
	export GTK_USE_PORTAL=1

	if command -v dbus-update-activation-environment > "/dev/null" 2>&1; then
		dbus-update-activation-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_RUNTIME_DIR MOZ_ENABLE_WAYLAND GTK_USE_PORTAL > "/dev/null" 2>&1 || true
	fi
	return 0
}

### ================================
### ORPHAN PORTAL CLEANUP
### ================================
_purge_orphan_portals() {
	[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ] || return 0
	_portal_pids="$(_list_pids_by_bin "xdg-desktop-portal" || true) $(_list_pids_by_bin "xdg-desktop-portal-kde" || true)"
	for _pid in ${_portal_pids}; do
		_proc_dbus="$(_extract_proc_env "${_pid}" "DBUS_SESSION_BUS_ADDRESS")"
		if [ -z "${_proc_dbus}" ] || [ "${_proc_dbus}" != "${DBUS_SESSION_BUS_ADDRESS}" ]; then
			_kill_pids "${_pid}" 10
		fi
	done
	return 0
}

### ================================
### PIPEWIRE STACK ENSURE
### ================================
_restart_pipewire_stack() {
	_portal_needs_restart=1
	_kill_pids "$(_list_pids_by_bin "wireplumber" || true)" 15
	_kill_pids "$(_list_pids_by_bin "pipewire" || true)" 15
	rm -f "${XDG_RUNTIME_DIR}/pipewire-0" "${XDG_RUNTIME_DIR}/pipewire-0.lock" "${XDG_RUNTIME_DIR}/pipewire-0-manager" "${XDG_RUNTIME_DIR}/pipewire-0-manager.lock"

	_pw_bin="$(command -v pipewire 2> "/dev/null" || true)"
	[ -n "${_pw_bin}" ] || return 1
	_spawn_detached "${_pw_bin}"

	_wait_cond 50 test -S "${XDG_RUNTIME_DIR}/pipewire-0" || true
	if ! _wait_cond 15 pgrep -u "$(id -u)" -x wireplumber; then
		_wp_bin="$(command -v wireplumber 2> "/dev/null" || true)"
		[ -n "${_wp_bin}" ] && _spawn_detached "${_wp_bin}"
	fi
	_wait_cond 30 pw-cli info 0 || true
	return 0
}

_ensure_pipewire_stack() {
	_force_restart="${1:-}"
	_pw_healthy=0
	if [ "${_force_restart}" != "--restart" ] \
		&& pgrep -u "$(id -u)" -x pipewire > "/dev/null" 2>&1 \
		&& [ -S "${XDG_RUNTIME_DIR}/pipewire-0" ] \
		&& pw-cli info 0 > "/dev/null" 2>&1; then
		_pw_healthy=1
	fi

	[ "${_pw_healthy}" -eq 0 ] && { _restart_pipewire_stack; return $?; }

	_pw_count="$(_count_pids_by_bin "pipewire")"
	_wp_count="$(_count_pids_by_bin "wireplumber")"
	if [ "${_pw_count}" -gt 1 ] || [ "${_wp_count}" -gt 1 ]; then
		_restart_pipewire_stack
		return $?
	fi

	if [ "${_wp_count}" -eq 0 ]; then
		_wp_bin="$(command -v wireplumber 2> "/dev/null" || true)"
		[ -n "${_wp_bin}" ] && { _spawn_detached "${_wp_bin}"; _wait_cond 30 pw-cli info 0 || true; }
	fi
	return 0
}

### ================================
### XDG PORTALS ENSURE
### ================================
_ensure_xdg_portals() {
	_kde_portal_bin="$(_resolve_first_bin \
		"/usr/local/lib/libexec/xdg-desktop-portal-kde" \
		"/usr/local/libexec/xdg-desktop-portal-kde" \
		"/usr/lib/libexec/xdg-desktop-portal-kde" \
		"/usr/libexec/xdg-desktop-portal-kde" \
		"/usr/lib/x86_64-linux-gnu/libexec/xdg-desktop-portal-kde" || true)"
	_xdg_portal_bin="$(_resolve_first_bin \
		"/usr/local/libexec/xdg-desktop-portal" \
		"/usr/libexec/xdg-desktop-portal" \
		"/usr/lib/xdg-desktop-portal/xdg-desktop-portal" || true)"

	_kde_count="$(_count_pids_by_bin "xdg-desktop-portal-kde")"
	_xdg_count="$(_count_pids_by_bin "xdg-desktop-portal")"

	if [ "${_portal_needs_restart}" -eq 1 ] || [ "${_kde_count}" -ne 1 ] || [ "${_xdg_count}" -ne 1 ]; then
		_kill_pids "$(_list_pids_by_bin "xdg-desktop-portal" || true)" 20
		_kill_pids "$(_list_pids_by_bin "xdg-desktop-portal-kde" || true)" 20

		if [ -n "${_kde_portal_bin}" ]; then
			_spawn_detached "${_kde_portal_bin}"
			_wait_cond 40 _dbus_has_name "org.freedesktop.impl.portal.desktop.kde" || true
		fi
		if [ -n "${_xdg_portal_bin}" ]; then
			_spawn_detached "${_xdg_portal_bin}"
			_wait_cond 40 _dbus_has_name "org.freedesktop.portal.Desktop" || true
		fi
	fi
	return 0
}

### ================================
### MAIN ENTRYPOINT
### ================================
_main() {
	_discover_wayland_session
	_purge_orphan_portals
	_ensure_pipewire_stack "${1:-}"
	_ensure_xdg_portals
}

_main "${1:-}"
