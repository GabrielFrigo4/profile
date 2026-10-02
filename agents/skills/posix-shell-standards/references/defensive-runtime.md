# 🛡️ Práticas Defensivas de Tempo de Execução

Scripts de shell corporativos e de automação de infraestrutura devem operar com garantias antifrágeis e tolerância a falhas.

---

## 🔒 Quoting Rigoroso sem Chaves Supérfluas

1. **Proteção Contra Word-Splitting e Globbing:** Sempre envolva variáveis em aspas duplas:
    ```sh
    # Correto:
    rm -f "$target_file"

    # Vulnerável:
    rm -f $target_file
    ```
2. **Eliminação de Chaves Desnecessárias:** Não escreva `"${var}"` quando `"$var"` for perfeitamente unívoco.
    - Use chaves apenas quando concatenar caracteres adjacentes: `"${prefix}_suffix"`.
    - Use chaves para operadores POSIX: `"${path:-/tmp}"`, `"${filename%.*sh}"`, `"${#string}"`.

---

## 🛑 Gestão Segura de Sinais e Limpeza com `trap`

Arquivos temporários e recursos alocados devem ser limpos incondicionalmente em caso de término normal ou interrupção (`SIGINT`, `SIGTERM`):

```sh
tmpdir="$(mktemp -d 2>"/dev/null" || mktemp -d -t 'mytmp')" || exit 1

cleanup() {
    exit_code=$?
    rm -rf "$tmpdir"
    exit "$exit_code"
}

trap cleanup EXIT INT TERM HUP
```

---

## 🌊 Subshells em Pipelines

No padrão POSIX, cada estágio de um pipeline (`cmd1 | cmd2`) executa em um subshell separado. Variáveis modificadas dentro de loops no pipe perdem seu valor fora dele:

```sh
# Anti-padrão (variável 'count' é perdida fora do loop):
count=0
cat data.txt | while IFS= read -r line; do
    count=$((count + 1))
done
echo "Total: $count" # Imprime 0 no FreeBSD sh/Dash!

# Padrão Canônico POSIX (redirecionamento de entrada):
count=0
while IFS= read -r line || [ -n "$line" ]; do
    count=$((count + 1))
done < data.txt
echo "Total: $count" # Imprime o valor correto
```

---

## 📁 Redirecionamentos Citados

Sempre envolva destinos de redirecionamento em aspas para consistência sintática:

```sh
# Canônico:
command > "/dev/null" 2>&1
exec 3< "/dev/urandom"
```
