# 🪤 Armadilhas de Bashismos & Portabilidade Estrita

Extensões exclusivas do GNU Bash falham sumariamente sob `/bin/sh` puro (FreeBSD, Dash, NetBSD) ou OpenBSD `/bin/ksh`. Abaixo estão os padrões proibidos e seus substitutos canônicos POSIX:

---

## 📊 Matriz Comparativa: Bashismo vs POSIX Canônico

| Recurso / Sintaxe          | Bashismo Proibido (`bash`)        | Padrão POSIX Obrigatório (`sh`)       |
| :------------------------- | :-------------------------------- | :------------------------------------ |
| **Teste Condicional**      | `[[ $a == $b && -f $c ]]`         | `[ "$a" = "$b" ] && [ -f "$c" ]`      |
| **Igualdade de Strings**   | `[ "$a" == "$b" ]`                | `[ "$a" = "$b" ]`                     |
| **Inclusão de Scripts**    | `source script.sh`                | `. ./script.sh`                       |
| **Redirecionamento Duplo** | `command &> /dev/null`            | `command > "/dev/null" 2>&1`          |
| **Redirecionamento Pipe**  | `command1                         | & command2`                           | `command1 2>&1      | command2` |
| **Herestring**             | `grep foo <<< "$bar"`             | `printf '%s\n' "$bar"                 | grep foo`           |
| **Arrays Indexados**       | `arr=("a" "b"); echo "${arr[0]}"` | `set -- "a" "b"; echo "$1"`           |
| **Concatenação de Array**  | `arr+=("c")`                      | `set -- "$@" "c"`                     |
| **Substituição de Proc**   | `diff <(cmd1) <(cmd2)`            | Arquivos temporários via `mktemp`     |
| **Expansão de String**     | `${var:0:4}` (substring)          | `echo "$var"                          | cut -c 1-4`ou`expr` |
| **Localização de Binário** | `which prog`                      | `command -v prog > "/dev/null" 2>&1`  |
| **Declaração de Função**   | `function foo() { ... }`          | `foo() { ... }`                       |
| **Leitura Silenciosa**     | `read -s -p "Prompt: " pass`      | `stty -echo; read -r pass; stty echo` |
| **Incremento Aritmético**  | `((count++))` ou `let count++`    | `count=$((count + 1))`                |

---

## 🔍 Exemplos Práticos de Refatoração

### 1. Testes e Avaliações Lógicas

```sh
# Proibido (Bashismo):
if [[ -n "$target" && "$target" =~ ^[0-9]+$ ]]; then
    ...
fi

# POSIX Canônico:
if [ -n "$target" ]; then
    case "$target" in
        *[!0-9]*) ;; # Contém não-dígito
        *) ... ;;    # Apenas dígitos
    esac
fi
```

### 2. Iteração sem Arrays

```sh
# Proibido:
repos=("Setup" "Shell" "Profile")
for r in "${repos[@]}"; do
    git -C "$r" status
done

# POSIX Canônico (parâmetros posicionais):
set -- "Setup" "Shell" "Profile"
for r in "$@"; do
    git -C "$r" status
done
```
