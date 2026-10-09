#!/usr/bin/env sh
# ----------------------------------------------------------------
# Module: Repository Permissions and Self Healing
# ----------------------------------------------------------------
set -eu

### ================================
### PERMISSIONS SELF HEALING
### ================================
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
	if [ -d "${_PROFILE_ROOT}/core" ]; then
		chmod 0755 "${_PROFILE_ROOT}/core/"*.sh 2> "/dev/null" || true
	fi
	if [ -d "${_PROFILE_ROOT}/audit" ]; then
		chmod 0755 "${_PROFILE_ROOT}/audit/"*.py 2> "/dev/null" || true
	fi
	if [ -d "${_PROFILE_ROOT}/.scripts/audit" ]; then
		chmod 0755 "${_PROFILE_ROOT}/.scripts/audit/"*.py 2> "/dev/null" || true
	fi
}
