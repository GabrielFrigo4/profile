---
name: posix-shell-standards
description: Manual cognitivo e validador de padrões de shell POSIX, baseline FreeBSD /bin/sh, taxonomia de emissão (echo vs echo -n $'\e...' vs printf), quoting rigoroso e programação defensiva.
---

# 🐚 Padrões de Shell POSIX & Portabilidade Rigorosa

Esta habilidade orienta a escrita, revisão e refatoração de scripts de shell no ecossistema soberano, garantindo código portátil, limpo, defensivo e aderente ao **Tier 2 (Extended)** sob a matriz canônica: **FreeBSD `/bin/sh`**, **`zsh`**, **`bash`** e **OpenBSD `ksh`** (interpretadores ultra-restritos como Debian `dash` e NetBSD `sh` estão fora de escopo).

---

## 🧭 Pilares de Portabilidade & Engenharia UNIX

1. **Baseline FreeBSD `/bin/sh`:** O shell nativo do FreeBSD é o piso universal de compatibilidade. Shebang obrigatório: `#!/usr/bin/env sh`.
2. **Taxonomia Estrita de Emissão:** `echo "$msg"` para texto simples; `echo -n` para fluxos sem quebra e sequências de escape ANSI; `printf` reservado estritamente para formatação de tabelas e padding posicional.
3. **Escapes ANSI & Banimento de Octal:** Não use notação octal (`\033`, `\001`) para escapes ou bytes de controle. Use escapes hexadecimais (`\x1b`, `\x01`) ou `$'\e...'`. Octais são admitidos exclusivamente em permissões POSIX (`chmod 0755`, `0644`, `0700`, `0600`).
4. **Quoting Defensivo & Zero Chaves Supérfluas:** Empregar `"$var"` sem chaves desnecessárias. Reservar `"${var}"` unicamente para concatenações contíguas (`"${prefix}_suffix"`) ou expansões de parâmetros POSIX (`"${var:-default}"`).
5. **Comentários Estruturais em 3 Camadas:** Headers com 64 hífens, seções internas com réguas de 32 colunas (`### ================================`), e zero comentários narrativos inline.

---

## 📚 Módulos Especializados da Subpasta references/

Consulte as regras detalhadas e especificações técnicas nos subarquivos:

- **[bashisms-traps.md](references/bashisms-traps.md):** Catálogo de armadilhas não-portáteis (`[[ ]]` vs `[ ]`, arrays vs parâmetros posicionais, `source` vs `.`, `&>` vs `> ... 2>&1`, substituição de processo).
- **[ansi-sequences.md](references/ansi-sequences.md):** Engenharia de sequências ANSI e escapes, supressão de `printf` supérfluo, peculiaridades de prompt no OpenBSD `ksh` (`\x01`) e diretrizes de terminal TTY.
- **[defensive-runtime.md](references/defensive-runtime.md):** Práticas de tempo de execução (traps de saída, arquivos temporários com `mktemp`, sanitização de caminhos, subshells em pipelines e verificação via `command -v`).
- **[ui-framework.md](references/ui-framework.md):** Padrão universal de emissão de interface `_ui_*` (`_ui_step`, `_ui_ok`, `_ui_err`, `_ui_warn`, `_ui_banner`), detecção de cores e paridade multiplataforma (Windows PowerShell/NuShell).

---

## 👑 Hierarquia Canônica de Shells

Em documentações, benchmarks, Makefiles e testes interativos, respeite sempre a ordem canônica:

1. **`zsh`** (ergonomia máxima de terminal e autocompletion interativo)
2. **`bash`** (padrão de compatibilidade e ecossistemas corporativos)
3. **`sh`** (FreeBSD `/bin/sh` base) ou **`ksh`** (OpenBSD `/bin/ksh` base)

---

## 🔗 Referências Oficiais

- [POSIX.1-2024 Shell Command Language (IEEE 1003.1)](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/sh.html)
- [FreeBSD sh(1) Manual Page](https://man.freebsd.org/sh)
- [ShellCheck Static Analysis Engine](https://www.shellcheck.net/)
