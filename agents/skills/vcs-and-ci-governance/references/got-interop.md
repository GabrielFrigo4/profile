# 🌳 Game of Trees (Got) & Sincronização Resiliente

> Interoperabilidade prática sobre repositórios `.git`, normalização de finais de linha e sincronização POSIX em 4 fases.

---

## 1. Fluxo Diário com `got` e `tog`

```sh
got clone https://github.com/org/repo.git repo.git
got checkout repo.git work-tree-repo
cd work-tree-repo
got status
got diff
got commit -m "feat(core): implement input parser"
got update
got send
```

```sh
tog log
tog diff
tog blame arquivo.c
tog tree
```

---

## 2. Normalização `.gitattributes`

```gitattributes
* text=auto eol=lf
*.sh text eol=lf
*.md text eol=lf
Makefile text eol=lf
*.cmd text eol=crlf
*.ps1 text eol=crlf
```

---

## 3. Sincronização Resiliente em 4 Fases (POSIX `sh`)

1. Limpe alterações puras de filemode (`0 0` no `git diff --numstat`) via `git checkout --`.
2. Crie stash com timestamp apenas se houver mudanças reais em conteúdo ou untracked.
3. Tente `pull --ff-only`, depois `pull --rebase` e por fim `pull`.
4. Restaure o stash, limpe eventual drift de filemode e garanta `chmod 0755` em `.githooks/*`.

```sh
command git -C "${_target}" diff --numstat 2> "/dev/null" | while IFS="$(printf '\t')" read -r _add _del _file; do
	if [ "${_add}" = "0" ] && [ "${_del}" = "0" ] && [ -n "${_file}" ]; then
		command git -C "${_target}" checkout -- "${_file}" > "/dev/null" 2>&1 || true
	fi
done

_status="$(command git -C "${_target}" status --porcelain 2> "/dev/null" || true)"
_has_dirty=0
if [ -n "${_status}" ]; then
	_has_dirty=1
	command git -C "${_target}" stash push -u -m "autostash-before-update-$(date +%s)" > "/dev/null" 2>&1 || true
fi

_pull_ok=0
if command git -C "${_target}" pull --ff-only > "/dev/null" 2>&1; then
	_pull_ok=1
elif command git -C "${_target}" pull --rebase > "/dev/null" 2>&1; then
	_pull_ok=1
elif command git -C "${_target}" pull > "/dev/null" 2>&1; then
	_pull_ok=1
fi

if [ "${_pull_ok}" -eq 1 ]; then
	if [ "${_has_dirty}" -eq 1 ]; then
		command git -C "${_target}" stash pop > "/dev/null" 2>&1 || true
		command git -C "${_target}" diff --numstat 2> "/dev/null" | while IFS="$(printf '\t')" read -r _add _del _file; do
			if [ "${_add}" = "0" ] && [ "${_del}" = "0" ] && [ -n "${_file}" ]; then
				command git -C "${_target}" checkout -- "${_file}" > "/dev/null" 2>&1 || true
			fi
		done
	fi
	if [ -d "${_target}/.githooks" ]; then
		chmod 0755 "${_target}/.githooks/"* 2> "/dev/null" || true
	fi
fi
```

---

## 4. Referências Oficiais

- **Game of Trees (Got) & Manuais:** <https://gameoftrees.org/> | <https://gameoftrees.org/manual.html>
- **Git SCM & Pro Git:** <https://git-scm.com/> | <https://git-scm.com/book/en/v2>
