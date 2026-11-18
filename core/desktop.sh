#!/usr/bin/env sh
# ----------------------------------------------------------------
# Module: Desktop Environments, GTK and Applications Sync
# ----------------------------------------------------------------
set -eu

### ================================
### DETECCAO DE DE & COLOR-SCHEME
### ================================
_desktop_detect_env() {
	_d_raw="${XDG_CURRENT_DESKTOP:-${XDG_SESSION_DESKTOP:-${DESKTOP_SESSION:-}}}"
	_d_low="$(printf '%s\n' "${_d_raw}" | tr '[:upper:]' '[:lower:]')"
	for _d_pair in cinnamon:cinnamon budgie:budgie pantheon:pantheon mate:mate xfce:xfce lxqt:lxqt lxde:lxde cosmic:cosmic deepin:deepin dde:deepin kde:kde plasma:kde gnome:gnome; do
		case "${_d_low}" in *"${_d_pair%:*}"*) printf '%s\n' "${_d_pair#*:}"; return 0 ;; esac
	done

	if command -v pgrep > "/dev/null" 2>&1; then
		for _d_probe in "plasmashell:kde" "kwin_wayland:kde" "gnome-shell:gnome" "cosmic-comp:cosmic" "cosmic-session:cosmic" "xfce4-session:xfce" "mate-session:mate" "cinnamon:cinnamon" "lxqt-session:lxqt" "lxsession:lxde" "budgie-wm:budgie" "budgie-panel:budgie" "gala:pantheon" "wingpanel:pantheon" "dde-desktop:deepin"; do
			pgrep -x "${_d_probe%:*}" > "/dev/null" 2>&1 && { printf '%s\n' "${_d_probe#*:}"; return 0; }
		done
	fi

	for _d_chk in "${HOME}/.config/plasmarc:kde" "${HOME}/.config/kwinrc:kde" "/usr/local/share/plasma:kde" "/usr/share/plasma:kde" "${HOME}/.config/dconf:gnome" "/usr/share/gnome-shell:gnome" "/usr/local/share/gnome-shell:gnome"; do
		[ -e "${_d_chk%:*}" ] && { printf '%s\n' "${_d_chk#*:}"; return 0; }
	done
	for _d_dir in mate cinnamon xfce4:xfce lxqt cosmic; do
		_d_key="${_d_dir%%:*}" _d_val="${_d_dir#*:}"
		for _d_base in "${HOME}/.config" "/usr/share" "/usr/local/share"; do
			[ -d "${_d_base}/${_d_key}" ] && { printf '%s\n' "${_d_val}"; return 0; }
		done
	done
	printf '%s\n' "gnome"
}

_desktop_has_dbus() {
	[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ] || [ -S "${XDG_RUNTIME_DIR:-}/bus" ]
}

_desktop_kde_val() {
	if command -v kreadconfig6 > "/dev/null" 2>&1; then
		kreadconfig6 --file kdeglobals --group "$1" --key "$2" 2> "/dev/null" || true
	elif command -v kreadconfig5 > "/dev/null" 2>&1; then
		kreadconfig5 --file kdeglobals --group "$1" --key "$2" 2> "/dev/null" || true
	elif [ -f "${_config_dir}/kdeglobals" ]; then
		awk -F= -v g="[$1]" -v k="$2" '/^\[/{s=$0} s==g && $1==k{print $2; exit}' "${_config_dir}/kdeglobals" 2> "/dev/null" || true
	fi
}

_desktop_portal_scheme() {
	_desktop_has_dbus && command -v gdbus > "/dev/null" 2>&1 || return 1
	_d_cmd="gdbus"
	command -v timeout > "/dev/null" 2>&1 && _d_cmd="timeout 2 gdbus"
	_d_out="$(${_d_cmd} call --session --dest org.freedesktop.portal.Desktop --object-path /org/freedesktop/portal/desktop --method org.freedesktop.portal.Settings.Read org.freedesktop.appearance color-scheme 2> "/dev/null" || true)"
	case "${_d_out}" in
		*"uint32 1"*) printf '%s\n' "dark"; return 0 ;;
		*"uint32 2"*) printf '%s\n' "light"; return 0 ;;
	esac
	return 1
}

_desktop_detect_scheme() {
	_d_de="${1:-gnome}"
	if [ "${_os_type:-}" = "Darwin" ] && command -v defaults > "/dev/null" 2>&1; then
		defaults read -g AppleInterfaceStyle 2> "/dev/null" | grep -qi "dark" && printf '%s\n' "dark" || printf '%s\n' "light"
		return 0
	fi

	case "${_d_de}" in
		gnome|budgie|pantheon)
			command -v gsettings > "/dev/null" 2>&1 && case "$(gsettings get org.gnome.desktop.interface color-scheme 2> "/dev/null" || true)" in *prefer-dark*) printf '%s\n' "dark"; return 0 ;; *prefer-light*|*default*) printf '%s\n' "light"; return 0 ;; esac ;;
		kde|lxqt)
			case "$(_desktop_kde_val General ColorScheme | tr '[:upper:]' '[:lower:]')" in *dark*|*night*|*black*|*obsidian*) printf '%s\n' "dark"; return 0 ;; *light*|*breeze*) printf '%s\n' "light"; return 0 ;; esac
			case "$(_desktop_kde_val KDE LookAndFeelPackage | tr '[:upper:]' '[:lower:]')" in *dark*) printf '%s\n' "dark"; return 0 ;; *breeze.desktop*) printf '%s\n' "light"; return 0 ;; esac
			_d_klum="$(_desktop_kde_val "Colors:Window" BackgroundNormal | awk -F, 'NF>=3{print (($1*299+$2*587+$3*114)/1000 < 128) ? "dark" : "light"}')"
			[ -n "${_d_klum}" ] && { printf '%s\n' "${_d_klum}"; return 0; } ;;
		xfce)
			command -v xfconf-query > "/dev/null" 2>&1 && case "$(xfconf-query -c xsettings -p /Net/ThemeName 2> "/dev/null" || true)" in *[Dd]ark*) printf '%s\n' "dark"; return 0 ;; ""|"''") ;; *) printf '%s\n' "light"; return 0 ;; esac ;;
		cinnamon|mate)
			_d_sc="org.cinnamon.desktop.interface"; [ "${_d_de}" = "mate" ] && _d_sc="org.mate.interface"
			command -v gsettings > "/dev/null" 2>&1 && case "$(gsettings get "${_d_sc}" gtk-theme 2> "/dev/null" || true)" in *[Dd]ark*|*[Bb]lack*) printf '%s\n' "dark"; return 0 ;; ""|"''") ;; *) printf '%s\n' "light"; return 0 ;; esac ;;
		cosmic)
			[ -f "${_config_dir}/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark" ] && { grep -qi "true" "${_config_dir}/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark" 2> "/dev/null" && printf '%s\n' "dark" || printf '%s\n' "light"; return 0; } ;;
	esac

	_desktop_portal_scheme && return 0
	printf '%s\n' "dark"
}

_desktop_pick_theme() {
	_d_first="${1:-}"
	for _d_cand in "$@"; do
		for _d_dir in "/usr/share/themes" "/usr/local/share/themes" "${_data_dir}/themes" "${HOME}/.themes"; do
			[ -d "${_d_dir}/${_d_cand}" ] && { printf '%s\n' "${_d_cand}"; return 0; }
		done
	done
	printf '%s\n' "${_d_first}"
}

### --------------------------------
### LIMPEZA DE TEMAS LEGADOS
### --------------------------------
_desktop_clean_legacy_themes() {
	for _d_stale in "${_data_dir}/themes/Emacs-Doom-Dark" "${_data_dir}/themes/Emacs-Kanagawa-Dark" "${HOME}/.themes/Emacs-Doom-Dark" "${HOME}/.themes/Emacs-Kanagawa-Dark" "${_data_dir}/themes/Adwaita-dark"; do
		[ -L "${_d_stale}" ] || continue
		if [ "${_d_stale}" = "${_data_dir}/themes/Adwaita-dark" ]; then
			case "$(readlink "${_d_stale}" 2> "/dev/null" || true)" in */adw-gtk3*|*/Emacs-*) ;; *) [ ! -e "${_d_stale}" ] || continue ;; esac
		fi
		if [ "${_mode}" = "status" ]; then _ui_warn "[LEGACY-LINK] ${_d_stale}"
		elif [ "${_mode}" = "sync" ] && [ "${_dry_run}" -eq 1 ]; then _ui_sub "[DRY-RUN CLEAN] ${_d_stale}"
		elif [ "${_mode}" = "sync" ]; then rm -f "${_d_stale}" 2> "/dev/null" || unlink "${_d_stale}" 2> "/dev/null" || true; _ui_ok "[CLEAN] ${_d_stale}"
		fi
	done
}

### --------------------------------
### SINCRONIZACAO GTK & ATALHOS
### --------------------------------
_desktop_sync_gsettings() {
	[ "${_de}" = "gnome" ] && _desktop_has_dbus && command -v gsettings > "/dev/null" 2>&1 || return 0
	_d_cur="$(gsettings get org.gnome.desktop.interface "$1" 2> "/dev/null" || true)"
	[ -n "${_d_cur}" ] && [ "${_d_cur}" != "'$2'" ] || return 0
	[ "${_dry_run}" -eq 1 ] && { _ui_sub "[DRY-RUN] gsettings org.gnome.desktop.interface $1=$2"; return 0; }
	gsettings set org.gnome.desktop.interface "$1" "$2" 2> "/dev/null" || true
	_ui_ok "[GSETTINGS] $1 -> $2"
}

_desktop_install_generated() {
	_g_tmp="$1" _g_dst="$2" _g_tag="${3:-}"
	mkdir -p "$(dirname "${_g_dst}")"
	if [ -L "${_g_dst}" ]; then rm -f "${_g_dst}"; fi
	if [ -f "${_g_dst}" ] && cmp -s "${_g_tmp}" "${_g_dst}" 2> "/dev/null"; then _ui_sub "[OK] ${_g_dst}"; return 0; fi
	if [ "${_backup}" -eq 1 ] && [ -e "${_g_dst}" ]; then
		mv "${_g_dst}" "${_g_dst}.bak.${_timestamp}" 2> "/dev/null" && _ui_warn "[BACKUP] ${_g_dst}.bak.${_timestamp}" || true
	elif [ -d "${_g_dst}" ]; then rm -rf "${_g_dst}"
	fi
	cp -f "${_g_tmp}" "${_g_dst}"
	chmod 0644 "${_g_dst}" 2> "/dev/null" || true
	if [ -n "${_g_tag}" ]; then _ui_ok "[COPY] ${_g_dst} (${_g_tag})"; else _ui_ok "[COPY] ${_g_dst}"; fi
}

_sync_gtk_de_profile() {
	_de="$(_desktop_detect_env)"
	_scheme="$(_desktop_detect_scheme "${_de}")"
	_icon="Adwaita" _cursor="Adwaita" _blink="1200" _mod="" _snd=""
	[ "${_scheme}" = "dark" ] && _prefer_dark="true" || _prefer_dark="false"

	case "${_de}" in
		kde|lxqt)
			_cursor="breeze_cursors"
			[ "${_scheme}" = "dark" ] && { _icon="breeze-dark"; _theme="Breeze-Dark"; } || { _icon="breeze"; _theme="Breeze"; }
			[ "${_de}" = "kde" ] && _blink="1000" _mod="colorreload-gtk-module" _snd="ocean" ;;
		cinnamon) [ "${_scheme}" = "dark" ] && _theme="Mint-Y-Dark" || _theme="Mint-Y" ;;
		mate)     [ "${_scheme}" = "dark" ] && _theme="$(_desktop_pick_theme "Yaru-MATE-dark" "BlackMATE")" || _theme="$(_desktop_pick_theme "Yaru-MATE" "MATE")" ;;
		xfce)     [ "${_scheme}" = "dark" ] && _theme="Greybird-dark" || _theme="Greybird" ;;
		cosmic)
			[ "${_scheme}" = "dark" ] && _theme="cosmic-dark" || _theme="cosmic"
			{ [ -d "/usr/share/icons/Cosmic" ] || [ -d "/usr/local/share/icons/Cosmic" ]; } && _icon="Cosmic" ;;
		*)        [ "${_scheme}" = "dark" ] && _theme="$(_desktop_pick_theme "adw-gtk3-dark" "Yaru-dark" "Adwaita-dark")" || _theme="$(_desktop_pick_theme "adw-gtk3" "Yaru" "Adwaita")" ;;
	esac

	if [ "${_icon}" = "Adwaita" ] && [ ! -d "/usr/share/icons/Adwaita" ] && [ ! -d "/usr/local/share/icons/Adwaita" ] && [ ! -d "${_data_dir}/icons/Adwaita" ] && [ ! -d "${HOME}/.icons/Adwaita" ]; then
		[ "${_scheme}" = "dark" ] && _icon="breeze-dark" || _icon="breeze"
	fi
	[ "${_mode}" = "pull" ] && return 0

	for _v in "3.0" "4.0"; do
		_target_file="${_config_dir}/gtk-${_v}/settings.ini"
		_src_ini="${_PROFILE_ROOT}/desktop/gtk-${_v}/settings.ini"
		[ -f "${_src_ini}" ] || continue
		if [ "${_mode}" = "status" ]; then
			[ -f "${_target_file}" ] && [ ! -L "${_target_file}" ] && grep -qx "gtk-theme-name=${_theme}" "${_target_file}" 2> "/dev/null" && grep -qx "gtk-application-prefer-dark-theme=${_prefer_dark}" "${_target_file}" 2> "/dev/null" && _ui_ok "[IN-SYNC] ${_target_file} (${_theme})" || _ui_warn "[DRIFT] ${_target_file}"
		elif [ "${_dry_run}" -eq 1 ]; then
			_ui_sub "[DRY-RUN] ${_target_file} (${_theme}, dark=${_prefer_dark})"
		else
			_tmp_ini="$(mktemp "${TMPDIR:-/tmp}/profile-gtk-ini.XXXXXX")"
			awk -v icon="${_icon}" -v cursor="${_cursor}" -v blink="${_blink}" -v mod="${_mod}" -v snd="${_snd}" -v theme="${_theme}" -v dark="${_prefer_dark}" -v v="${_v}" '
				/^gtk-icon-theme-name=/ { print "gtk-icon-theme-name=" icon; next }
				/^gtk-cursor-theme-name=/ { print "gtk-cursor-theme-name=" cursor; next }
				/^gtk-cursor-blink-time=/ { print "gtk-cursor-blink-time=" blink; next }
				/^gtk-theme-name=/ { print "gtk-theme-name=" theme; next }
				/^gtk-application-prefer-dark-theme=/ { print "gtk-application-prefer-dark-theme=" dark; next }
				/^gtk-modules=/ || /^gtk-sound-theme-name=/ { next }
				/^gtk-menu-images=/ { print $0; if (v == "3.0" && mod != "") print "gtk-modules=" mod; next }
				/^gtk-primary-button-warps-slider=/ { print $0; if (snd != "") print "gtk-sound-theme-name=" snd; next }
				{ print $0 }
			' "${_src_ini}" > "${_tmp_ini}"
			_desktop_install_generated "${_tmp_ini}" "${_target_file}" "${_theme}"
			rm -f "${_tmp_ini}"
		fi
	done

	if [ "${_mode}" = "sync" ]; then
		if [ "${_dry_run}" -eq 0 ] && [ -d "${_data_dir}/profile/runtime" ]; then rm -rf "${_data_dir}/profile/runtime" 2> "/dev/null" || true; fi
		_desktop_sync_gsettings "gtk-theme" "${_theme}"
		_desktop_sync_gsettings "icon-theme" "${_icon}"
		_desktop_sync_gsettings "cursor-theme" "${_cursor}"
	fi
}

_desktop_sync_gtk_css() {
	[ "${_mode}" = "pull" ] && return 0
	_de="$(_desktop_detect_env)"
	for _v in "3.0" "4.0"; do
		_src_css="${_PROFILE_ROOT}/desktop/gtk-${_v}/gtk.css"
		_dst_css="${_config_dir}/gtk-${_v}/gtk.css"
		[ -f "${_src_css}" ] || continue
		_tmp_css="$(mktemp "${TMPDIR:-/tmp}/profile-gtk-css.XXXXXX")"
		cp -f "${_src_css}" "${_tmp_css}"
		if { [ "${_de}" = "kde" ] || [ -f "${_config_dir}/gtk-${_v}/colors.css" ]; } && ! grep -q "colors\.css" "${_tmp_css}" 2> "/dev/null"; then
			[ -s "${_tmp_css}" ] && [ -n "$(tail -c 1 "${_tmp_css}" 2> "/dev/null" || true)" ] && printf '\n' >> "${_tmp_css}"
			printf '%s\n' "@import 'colors.css';" >> "${_tmp_css}"
		fi
		if [ "${_mode}" = "status" ]; then
			[ -f "${_dst_css}" ] && [ ! -L "${_dst_css}" ] && cmp -s "${_tmp_css}" "${_dst_css}" 2> "/dev/null" && _ui_ok "[IN-SYNC] ${_dst_css}" || _ui_warn "[DRIFT] ${_dst_css}"
		elif [ "${_dry_run}" -eq 1 ]; then
			_ui_sub "[DRY-RUN] ${_dst_css}"
		else
			_desktop_install_generated "${_tmp_css}" "${_dst_css}"
		fi
		rm -f "${_tmp_css}"
	done
}

_desktop_sync_apps() {
	[ -d "${_PROFILE_ROOT}/desktop/applications" ] || return 0
	for _d_app in "${_PROFILE_ROOT}/desktop/applications/"*.desktop; do
		[ -f "${_d_app}" ] || continue
		_d_dst="${_data_dir}/applications/${_d_app##*/}"
		_profile_item "${_d_app}" "${_d_dst}" "${_mode}" "${_dry_run}" "${_backup}" "${_timestamp}"
		if [ "${_mode}" = "sync" ] && [ "${_dry_run}" -eq 0 ] && [ -f "${_d_dst}" ] && [ ! -L "${_d_dst}" ]; then chmod 0644 "${_d_dst}" 2> "/dev/null" || true; fi
	done
	if [ "${_mode}" = "sync" ] && command -v update-desktop-database > "/dev/null" 2>&1; then
		[ "${_dry_run}" -eq 1 ] && _ui_sub "[DRY-RUN] update-desktop-database ${_data_dir}/applications" || { [ -d "${_data_dir}/applications" ] && update-desktop-database "${_data_dir}/applications" 2> "/dev/null" || true; }
	fi
}

_desktop_sync_all() {
	_ui_step "Atalhos XDG de desktop e toolkits gráficos (GTK 3/4)..."
	_desktop_sync_apps
	_desktop_sync_gtk_css
	_desktop_clean_legacy_themes
	_sync_gtk_de_profile
}
