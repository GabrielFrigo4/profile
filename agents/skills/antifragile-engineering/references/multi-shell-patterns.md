# 🛠️ Padrões Multi-Shell Antifrágil & Anti-Patterns

> Implementações de referência em POSIX `sh`, NuShell e PowerShell, mais armadilhas clássicas de fragilidade e suas correções.

---

## 1. Padrão Universal POSIX `sh`

```sh
_resolve_secret_key() {
	_explicit="${1:-}"
	_filename="${2:-}"

	if [ -n "${_explicit}" ] && [ -f "${_explicit}" ]; then
		chmod 0600 "${_explicit}" 2> "/dev/null" || true
		echo "${_explicit}"
		return 0
	fi

	for _cand in \
		"${SECRET_DIR:-}/keys/${_filename}" \
		"${XDG_DATA_HOME:-${HOME}/.local/share}/secrets/keys/${_filename}" \
		"${XDG_CONFIG_HOME:-${HOME}/.config}/secrets/keys/${_filename}" \
		"${HOME}/.secrets/keys/${_filename}" \
		"/usr/local/share/secrets/keys/${_filename}"; do
		if [ -n "${_cand}" ] && [ -f "${_cand}" ]; then
			chmod 0600 "${_cand}" 2> "/dev/null" || true
			echo "${_cand}"
			return 0
		fi
	done

	return 1
}

connect_server() {
	_ip="${SERVER_IP:-127.0.0.1}"
	_user="${SERVER_USER:-root}"
	_key="$(_resolve_secret_key "${SERVER_KEY:-}" "id_ed25519" || true)"

	if [ -n "${_key}" ]; then
		export SERVER_KEY="${_key}"
		ssh -i "${_key}" "${_user}@${_ip}" "$@"
	else
		ssh "${_user}@${_ip}" "$@"
	fi
}
```

---

## 2. Padrão NuShell

```nu
def --wrapped server-connect [...rest] {
	let ip = ($env.SERVER_IP? | default "127.0.0.1")
	let user = ($env.SERVER_USER? | default "root")
	let key = ($env.SERVER_KEY? | default "")
	if ($key | is-not-empty) and ($key | path exists) {
		ssh -i $key $"($user)@($ip)" ...$rest
	} else {
		ssh $"($user)@($ip)" ...$rest
	}
}
```

---

## 3. Padrão PowerShell

```powershell
function Resolve-Asset([string]$explicitPath, [string]$relativeSubpath) {
	if ($explicitPath -and (Test-Path $explicitPath)) { return $explicitPath }
	$homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } elseif ($env:HOME) { $env:HOME } else { "~" }
	$candidates = @(
		if ($env:APP_HOME) { Join-Path $env:APP_HOME $relativeSubpath },
		(Join-Path $homeDir ".local\share\app\$relativeSubpath"),
		(Join-Path $homeDir ".config\app\$relativeSubpath"),
		(Join-Path $homeDir ".app\$relativeSubpath")
	) | Where-Object { $_ -and (Test-Path $_) }
	if ($candidates) { return $candidates[0] }
	return $null
}
```

---

## 4. Anti-Patterns da Fragilidade

1. **Caminho Único Hardcoded:** Evite fixar `KEY="${HOME}/.secrets/keys/server.key"` diretamente; use a cascata defensiva de descoberta.
2. **Concatenação Cega de Nil (Lua / Dinâmicos):** Nunca concatene `os.getenv("VAR")` diretamente sem fallback ou verificação; se `nil`, lança exceção e aborta o carregamento do perfil inteiro.
3. **Parse-Time Static Sourcing (NuShell):** NuShell valida caminhos de `source` em tempo de parse; se o arquivo opcional não existir, a sessão falha. Verifique dinamicamente antes ou gere wrapper seguro.
4. **Suposição Rígida de Diretório em Pontes Host/Guest (NFS / VM):** Se o comando rodar fora do ponto exportado (`/home/<user>`), `cd "$PWD"` falha no guest. Valide o prefixo e aplique fallback seguro para `${HOME}`:

```sh
_guest_home="/home/${USER:-user}"
_target_dir="${_guest_home}"
case "${PWD}" in
	"${_guest_home}"|"${_guest_home}/"*) _target_dir="${PWD}" ;;
esac
ssh guest "cd \"${_target_dir}\" 2> \"/dev/null\" || cd \"${_guest_home}\"; env HOME=\"${_guest_home}\" my-cli $*"
```
