#!/usr/bin/env sh
# ----------------------------------------------------------------
# Module: KDE Plasma Wayland Environment Bootstrap
# ----------------------------------------------------------------
_prev_opts="$-"
set -eu

export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-wayland}"
export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-KDE}"
export MOZ_ENABLE_WAYLAND=1
export GTK_USE_PORTAL=1

case "${_prev_opts}" in *e*) ;; *) set +e ;; esac
case "${_prev_opts}" in *u*) ;; *) set +u ;; esac
unset _prev_opts
