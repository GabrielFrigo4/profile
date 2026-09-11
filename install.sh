#!/usr/bin/env sh
# ----------------------------------------------------------------
# Utility: Universal Profile Installer
# ----------------------------------------------------------------
set -eu

_repo_root="$(cd "$(dirname "$0")" && pwd)"

echo "🎨 [Profile] Instalando e sincronizando ecossistema declarativo..."
echo "  ↳ Origem: ${_repo_root}"

### --------------------------------
### Sincronizar Dotfiles
### --------------------------------
echo "↳ 1. Sincronizando dotfiles de ferramentas, editores e terminais..."
if [ -f "${_repo_root}/scripts/sync/sync-dotfiles.sh" ]; then
	sh "${_repo_root}/scripts/sync/sync-dotfiles.sh" "$@"
fi

### --------------------------------
### Sincronizar Skills de IA
### --------------------------------
echo "↳ 2. Sincronizando runbooks cognitivos de IA..."
if [ -f "${_repo_root}/scripts/sync/sync-skills.sh" ]; then
	sh "${_repo_root}/scripts/sync/sync-skills.sh"
fi

echo "✅ [Profile] Instalação e sincronização concluídas com sucesso!"
exit 0
