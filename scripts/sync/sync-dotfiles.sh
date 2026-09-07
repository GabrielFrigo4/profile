#!/usr/bin/env sh

### ================================
### PROFILE DOTFILES SYNCHRONIZER
### ================================

set -eu

_repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
echo "🎨 [Profile] Sincronizando dotfiles declarativos a partir de: ${_repo_root}"

### --------------------------------
### Formatadores Globais & Linters
### --------------------------------
echo "  ↳ Sincronizando linters (.clang-format, .prettierrc, .stylua.toml)..."
[ -f "${_repo_root}/software/tools/.clang-format" ] && ln -sf "${_repo_root}/software/tools/.clang-format" "${HOME}/.clang-format"
[ -f "${_repo_root}/software/tools/.prettierrc" ] && ln -sf "${_repo_root}/software/tools/.prettierrc" "${HOME}/.prettierrc"
[ -f "${_repo_root}/software/tools/.stylua.toml" ] && ln -sf "${_repo_root}/software/tools/.stylua.toml" "${HOME}/.stylua.toml"

if [ -f "${_repo_root}/software/tools/clangd.yaml" ]; then
	mkdir -p "${HOME}/.config/clangd"
	ln -sf "${_repo_root}/software/tools/clangd.yaml" "${HOME}/.config/clangd/config.yaml"
fi

### --------------------------------
### Editores Minimalistas (Vim & Emacs)
### --------------------------------
echo "  ↳ Sincronizando configurações de editores de terminal..."
if [ -f "${_repo_root}/software/editors/vim/lite.vim" ]; then
	ln -sf "${_repo_root}/software/editors/vim/lite.vim" "${HOME}/.vimrc"
	mkdir -p "${HOME}/.config/nvim"
	ln -sf "${_repo_root}/software/editors/vim/lite.vim" "${HOME}/.config/nvim/init.vim"
fi

if [ -f "${_repo_root}/software/editors/emacs/lite.el" ]; then
	mkdir -p "${HOME}/.emacs.d"
	ln -sf "${_repo_root}/software/editors/emacs/lite.el" "${HOME}/.emacs.d/init.el"
fi

### --------------------------------
### Zed Editor
### --------------------------------
if [ -f "${_repo_root}/software/editors/zed/settings.json" ]; then
	echo "  ↳ Sincronizando Zed settings..."
	mkdir -p "${HOME}/.config/zed"
	ln -sf "${_repo_root}/software/editors/zed/settings.json" "${HOME}/.config/zed/settings.json"
fi

### --------------------------------
### Visual Studio Code & Antigravity
### --------------------------------
if [ -f "${_repo_root}/software/editors/vscode/settings.json" ]; then
	echo "  ↳ Sincronizando VS Code settings..."
	mkdir -p "${HOME}/.config/Code/User"
	ln -sf "${_repo_root}/software/editors/vscode/settings.json" "${HOME}/.config/Code/User/settings.json"
fi

if [ -f "${_repo_root}/software/editors/antigravity/settings.json" ]; then
	echo "  ↳ Sincronizando Antigravity settings..."
	mkdir -p "${HOME}/.config/Antigravity/User"
	ln -sf "${_repo_root}/software/editors/antigravity/settings.json" "${HOME}/.config/Antigravity/User/settings.json"
fi

echo "✅ [Profile] Todos os dotfiles foram sincronizados com sucesso via symlinks!"
exit 0
