# 🖥️ Framework Semântico de Emissão de UI (`_ui_*`)

Para scripts de orquestração, hooks e ferramentas CLI do ecossistema, é proibido o uso de `echo` avulso com emojis desordenados. Todas as saídas interativas devem convergir para a biblioteca semântica `_ui_*`.

---

## 🎨 Verificação Defensiva de Terminal (`_ui_has_color`)

A biblioteca deve respeitar pipes e saídas em lote, desativando cores se `stdout` não for terminal interativo ou se `TERM` for inválido:

```sh
_ui_has_color() {
    [ -t 1 ] || return 1
    case "${TERM:-}" in
        dumb|"") return 1 ;;
        *) return 0 ;;
    esac
}
```

---

## 📊 Tabela de Verbos Semânticos

| Função           | Prefixo TTY (Cores ANSI)                    | Fallback Plano      | Propósito                                            |
| :--------------- | :------------------------------------------ | :------------------ | :--------------------------------------------------- |
| **`_ui_step`**   | `\e[1;36m==>\e[0m ` (Ciano)                 | `==> `              | Início de grande etapa de execução                   |
| **`_ui_sub`**    | `\e[1;34m  ↳\e[0m ` (Azul)                  | ` ->`               | Subtarefa, ação aninhada ou item sob processamento   |
| **`_ui_ok`**     | `\e[1;32m  ✅\e[0m ` (Verde)                | ` OK`               | Operação concluída com sucesso                       |
| **`_ui_warn`**   | `\e[1;33m  ⚠️ \e[0m ` (Amarelo)             | ` WARN`             | Alerta ou falha não-bloqueante                       |
| **`_ui_err`**    | `\e[1;31m  ❌\e[0m ` (Vermelho em `stderr`) | ` FAIL` em `stderr` | Falha crítica ou interrupção direcionada para `>&2`  |
| **`_ui_info`**   | `\e[1;35m  ℹ️ \e[0m ` (Magenta)             | ` INFO`             | Informações contextuais, notas ou recargas de estado |
| **`_ui_banner`** | Régua dupla de 64 `=` em Ciano              | Régua plana de 64 = | Abertura/fechamento de relatórios ou rotinas amplas  |

---

## 💻 Implementação Canônica POSIX

```sh
_ui_step() {
    if _ui_has_color; then
        echo -n $'\e[1;36m==>\e[0m '
    else
        echo -n "==> "
    fi
    echo "$*"
}

_ui_ok() {
    if _ui_has_color; then
        echo -n $'\e[1;32m  ✅\e[0m '
    else
        echo -n "  OK "
    fi
    echo "$*"
}

_ui_err() {
    if _ui_has_color; then
        echo -n $'\e[1;31m  ❌\e[0m ' >&2
    else
        echo -n "  FAIL " >&2
    fi
    echo "$*" >&2
}
```

---

## 🪟 Paridade em Ambientes Windows

O ecossistema mantém paridade com esta mesma taxonomia nos dotfiles do Windows:

- **PowerShell (`profile.ps1`):** `function _ui_step`, `_ui_ok`, `_ui_err`.
- **NuShell (`config.nu`):** `def _ui_step`, `_ui_ok`, `_ui_err`.
- **CMD/Clink (`profile.lua` / `profile.cmd`):** Funções Lua integradas com escapes ANSI no Windows Terminal.
