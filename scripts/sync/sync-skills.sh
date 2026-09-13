#!/usr/bin/env sh
# ----------------------------------------------------------------
# Utility: Profile AI Skills Synchronizer
# ----------------------------------------------------------------
set -eu

_repo_root="$(cd "$(dirname "${0}")/../.." && pwd)"
_target_dir="${1:-${HOME}/.gemini/config/skills}"

echo "🧠 [Profile] Sincronizando Portable AI Skills..."
echo "  ↳ Destino: ${_target_dir}"

_target_parent="$(dirname "${_target_dir}")"
[ ! -d "${_target_parent}" ] && mkdir -p "${_target_parent}"

if [ -L "${_target_dir}" ] && [ "$(readlink "${_target_dir}")" = "${_repo_root}/skills" ]; then
	echo "  👉 Link simbólico unificado já ativo."
else
	if [ -e "${_target_dir}" ] || [ -L "${_target_dir}" ]; then
		rm -rf "${_target_dir}"
	fi
	ln -s "${_repo_root}/skills" "${_target_dir}"
	echo "  🔗 Link unificado criado: ${_target_dir} -> ${_repo_root}/skills"
fi

echo "✅ [Profile] Skills de IA sincronizadas com sucesso!"
exit 0
