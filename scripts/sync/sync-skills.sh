#!/usr/bin/env sh
# ----------------------------------------------------------------
# Utility: Profile AI Skills Synchronizer
# ----------------------------------------------------------------
set -eu

_repo_root="$(cd "$(dirname "$0")/../.." && pwd)"
_target_dir="${1:-${HOME}/.gemini/config/skills}"

echo "🧠 [Profile] Sincronizando Portable AI Skills..."
echo "  ↳ Destino: ${_target_dir}"

mkdir -p "${_target_dir}"

for _skill_dir in "${_repo_root}/skills/"*; do
	if [ -d "${_skill_dir}" ]; then
		_skill_name="$(basename "${_skill_dir}")"
		echo "  ↳ Vinculando skill: ${_skill_name}"
		ln -sf "${_skill_dir}" "${_target_dir}/${_skill_name}"
	fi
done

echo "✅ [Profile] Skills de IA sincronizadas com sucesso!"
exit 0
