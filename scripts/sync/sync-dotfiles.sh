#!/usr/bin/env sh
# ----------------------------------------------------------------
# Utility: Profile Dotfiles Synchronizer
# ----------------------------------------------------------------
set -eu

_repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
_os_type="$(uname -s)"
_dry_run=0
_backup=0
_timestamp="$(date +%Y%m%d%H%M%S)"

for _arg in "$@"; do
	case "${_arg}" in
		--dry-run) _dry_run=1 ;;
		--backup) _backup=1 ;;
		--help|-h)
			echo "Uso: $0 [--dry-run] [--backup]"
			exit 0
			;;
	esac
done

echo "🎨 [Profile] Sincronizando dotfiles (${_os_type}) a partir de: ${_repo_root}"
[ "${_dry_run}" -eq 1 ] && echo "  ⚠️ Modo DRY-RUN ativado (nenhum arquivo será modificado)."

_link() {
	_src="$1"
	_dst="$2"

	[ ! -e "${_src}" ] && return 0

	if [ "${_dry_run}" -eq 1 ]; then
		echo "  [DRY-RUN] ${_dst} -> ${_src}"
		return 0
	fi

	_dst_dir="$(dirname "${_dst}")"
	[ ! -d "${_dst_dir}" ] && mkdir -p "${_dst_dir}"

	if [ -e "${_dst}" ] || [ -L "${_dst}" ]; then
		if [ "${_backup}" -eq 1 ] && [ ! -L "${_dst}" ]; then
			mv "${_dst}" "${_dst}.bak.${_timestamp}"
			echo "  [BACKUP] ${_dst}.bak.${_timestamp}"
		else
			rm -rf "${_dst}"
		fi
	fi

	ln -sf "${_src}" "${_dst}"
	echo "  [LINK] ${_dst}"
}

### --------------------------------
### Formatadores Globais & Linters
### --------------------------------
echo "↳ 1. Formatadores globais e linters..."
_link "${_repo_root}/tools/.clang-format" "${HOME}/.clang-format"
_link "${_repo_root}/tools/.prettierrc" "${HOME}/.prettierrc"
_link "${_repo_root}/tools/.stylua.toml" "${HOME}/.stylua.toml"
_link "${_repo_root}/tools/.editorconfig" "${HOME}/.editorconfig"
_link "${_repo_root}/tools/clangd.yaml" "${HOME}/.config/clangd/config.yaml"

### --------------------------------
### Editores de Texto
### --------------------------------
echo "↳ 2. Editores de texto (Emacs, Helix, NeoVim, Vim)..."
_ed="${_repo_root}/../Editor"
[ -e "${_ed}/Emacs/init.el" ] && _link "${_ed}/Emacs" "${HOME}/.emacs.d" || _link "${_repo_root}/editors/emacs/lite.el" "${HOME}/.emacs.d/init.el"

if [ -e "${_ed}/Helix/config.toml" ]; then
	_link "${_ed}/Helix/config.toml" "${HOME}/.config/helix/config.toml"
	_link "${_ed}/Helix/languages.toml" "${HOME}/.config/helix/languages.toml"
fi

if [ -e "${_ed}/NeoVim/init.lua" ]; then
	_link "${_ed}/NeoVim/init.lua" "${HOME}/.config/nvim/init.lua"
	_link "${_ed}/NeoVim/lua" "${HOME}/.config/nvim/lua"
else
	_link "${_repo_root}/editors/vim/lite.vim" "${HOME}/.config/nvim/init.vim"
fi

if [ -e "${_ed}/Vim/vimrc" ]; then
	_link "${_ed}/Vim/vimrc" "${HOME}/.vimrc"
	_link "${_ed}/Vim" "${HOME}/vimfiles"
	_link "${_ed}/Vim" "${HOME}/.vim"
else
	_link "${_repo_root}/editors/vim/lite.vim" "${HOME}/.vimrc"
fi

### --------------------------------
### Editores Modernos & IDEs
### --------------------------------
echo "↳ 3. Editores modernos (Zed, VSCode, Antigravity)..."
_link "${_repo_root}/editors/zed/settings.json" "${HOME}/.config/zed/settings.json"

if [ "${_os_type}" = "Darwin" ]; then
	_app="${HOME}/Library/Application Support"
	_link "${_repo_root}/editors/vscode/settings.json" "${_app}/Code/User/settings.json"
	_link "${_repo_root}/editors/antigravity/settings.json" "${_app}/Antigravity/User/settings.json"
else
	_link "${_repo_root}/editors/vscode/settings.json" "${HOME}/.config/Code/User/settings.json"
	_link "${_repo_root}/editors/vscode/settings.json" "${HOME}/.config/vscode-oss/User/settings.json"
	_link "${_repo_root}/editors/antigravity/settings.json" "${HOME}/.config/Antigravity/User/settings.json"
fi

### --------------------------------
### Emuladores de Terminal & Shells
### --------------------------------
echo "↳ 4. Emuladores de terminal e shells alternativos..."

_konsole_dir="${HOME}/.local/share/konsole"
_link "${_repo_root}/terminals/konsole/Bash.profile" "${_konsole_dir}/Bash.profile"
_link "${_repo_root}/terminals/konsole/Shell.profile" "${_konsole_dir}/Shell.profile"
_link "${_repo_root}/terminals/konsole/Zsh.profile" "${_konsole_dir}/Zsh.profile"

_nu_dir="${HOME}/.config/nushell"
_link "${_repo_root}/terminals/nushell/config.nu" "${_nu_dir}/config.nu"
_link "${_repo_root}/terminals/nushell/env.nu" "${_nu_dir}/env.nu"
_link "${_repo_root}/terminals/nushell/nushell.nu" "${_nu_dir}/nushell.nu"

_pwsh_dir="${HOME}/.config/powershell"
_link "${_repo_root}/terminals/powershell/profile.ps1" "${_pwsh_dir}/profile.ps1"
_link "${_repo_root}/terminals/powershell/Microsoft.PowerShell_profile.ps1" "${_pwsh_dir}/Microsoft.PowerShell_profile.ps1"

echo "✅ [Profile] Todos os dotfiles sincronizados com sucesso!"
exit 0
