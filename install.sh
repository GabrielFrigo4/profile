#!/usr/bin/env sh
# ----------------------------------------------------------------
# Utility: Universal Profile Installer
# ----------------------------------------------------------------
set -eu

_repo_root="$(cd "$(dirname "$0")" && pwd)"

echo "🎨 [Profile] Instalando e sincronizando ecossistema declarativo..."
echo "  ↳ Origem: ${_repo_root}"

### --------------------------------
### Sincronizar Dotfiles & Skills
### --------------------------------
sh "${_repo_root}/profile.sh" sync "$@"

echo "✅ [Profile] Instalação e sincronização concluídas com sucesso!"
exit 0
