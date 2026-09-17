---
name: ironclad-testing
description: >-
    Runbook cognitivo definitivo para engenharia de testes rigorosos, invariantes defensivas,
    mentalidade adversarial (Advogado do Diabo) e barreiras intransigentes de contenção
    contra código ruim em C Moderno (C23), C++23, POSIX Shell, Go, Python e Makefiles.
---

# 🛡️ Ironclad Testing — Engenharia de Testes Rigorosos & Barreiras Anti-Regressão

Esta skill define o padrão supremo de qualidade, tolerância zero para fragilidade e engenharia de testes adversariais em todo o ecossistema.

Quando solicitada a testar, auditar ou validar qualquer software, script ou componente, **a IA nunca deve agir como uma testemunha complacente que apenas confirma o caminho feliz**. Sua missão primordial é atuar como um **Advogado do Diabo (Engenheiro de QA Adversarial)**, buscando ativamente quebrar o código nas fronteiras, injetar falhas e provar matematicamente e na prática que nenhuma regressão passará despercebida.

---

## 1. ⚔️ A Regra de Ouro: O Mindset do Advogado do Diabo

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        A FALÁCIA DO CAMINHO FELIZ                       │
├─────────────────────────────────────────────────────────────────────────┤
│ IA Comum:   "Escrevi 5 testes unitários, todos passaram. Cobertura 100%!"│
│             ↳ Testa apenas entradas válidas, com mocks que mentem.     │
│                                                                         │
│ Engenheiro: "O que acontece se a rede cair no meio da escrita? E se     │
│ Ironclad:   o disco estiver cheio? E se o buffer receber 0 bytes? E se  │
│             a string contiver um byte nulo prematuro?"                  │
│             ↳ Testa a destruição controlada e o comportamento de falha. │
└─────────────────────────────────────────────────────────────────────────┘
```

A postura de teste segue 3 leis inegociáveis:

1. **O Código DEVE Quebrar com Dignidade:** Testar não é apenas verificar se o resultado correto é emitido quando os dados são perfeitos. É garantir que, diante do caos, o software encerra de forma atômica, segura, limpa e com exit code diferente de zero.
2. **Proibição da Cobertura Cosmética:** Ter 100% de linhas cobertas não significa nada se as asserções forem triviais. É proibido criar testes cujo único assert seja `assert True`, `assert err == nil` sem checar o payload, ou testes que apenas exercitam o código sem validar invariantes de estado.
3. **A Prova da Mutação (Mutation Mindset):** Antes de considerar um caso de teste concluído, pergunte a si mesmo: _Se eu intencionalmente alterar um operador `<` para `<=`, ou comentar uma validação de erro no código-fonte, este teste falhará?_ Se a resposta for "não", o teste é inútil e deve ser reescrito.

---

## 2. 🧱 As 5 Barreiras de Contenção (Shift-Left Absoluto)

Nenhum código defeituoso deve avançar para o commit. A contenção é realizada em camadas concêntricas:

```
[Barreira 0: Análise Estática & Compilador Estrito]
       │
       ▼
[Barreira 1: Sanitizers Dinâmicos & Detecção de Corrida]
       │
       ▼
[Barreira 2: Invariantes de Borda & Testes Negativos]
       │
       ▼
[Barreira 3: Harness Local Hermético & Makefile Silencioso]
       │
       ▼
[Barreira 4: Git Quality Gates (.githooks) & CI Estéril]
```

### Barreira 0: Compiladores e Linters no Rigor Máximo

- **C Moderno (C23):** Compilação com `-std=c23 -Wall -Wextra -Wpedantic -Werror`.
- **C++ Moderno (C++23):** Compilação com `-std=c++23 -Wall -Wextra -Wpedantic -Werror`.
- **POSIX Shell:** Verificação com `sh -n` e `shellcheck -s sh -S error`.
- **Python:** Verificação de sintaxe e tipos estritos com `mypy --strict` e `ruff`.
- **Go:** `golangci-lint run` e análise estática nativa (`go vet`).

### Barreira 1: Sanitizers Dinâmicos e Race Detection

- Em linguagens nativas (C23 / C++23), testes executam obrigatoriamente com:
  `-fsanitize=address,undefined -fno-omit-frame-pointer`.
- Em Go, testes de concorrência executam obrigatoriamente com:
  `go test -race -count=1 ./...`.

### Barreira 2: Invariantes de Borda e Testes Negativos

Todo módulo deve possuir testes cobrindo sistematicamente:

- **Limites Numéricos:** `0`, `-1`, inteiros máximos (`INT_MAX`, `SIZE_MAX`), _overflow_ e _underflow_.
- **Limites de Strings:** Strings vazias (`""`), strings contendo apenas espaços, strings com bytes nulos intermediários, strings sem terminador newline final (`EOF`).
- **Limites de Sistema de Arquivos:** Arquivos inexistentes, arquivos sem permissão de leitura (`0000`), diretórios protegidos (`0400`), links simbólicos circulares ou quebrados.
- **Limites de Processo:** Sinais inesperados (`SIGPIPE`, `SIGINT`), variáveis de ambiente indefinidas ou vazias.

### Barreira 3: Harness Local Hermético & Makefile Silencioso

- A execução de `make test` ou `make check` deve ser local, hermética, reprodutível e rápida (< 1 segundo para testes unitários).
- **Regra do Silêncio:** O alvo de teste não deve poluir a saída do terminal com logs desnecessários. Se passou, silêncio absoluto ou um resumo unificado limpo. Se falhou, emissão imediata do raio-X cirúrgico da falha.

### Barreira 4: Git Quality Gates (.githooks)

- O hook `.githooks/pre-commit` é a barreira final de contenção na máquina do desenvolvedor. Se qualquer teste, formatação Prettier ou linter falhar, o commit é bloqueado na raiz.

---

## 3. 🔬 Arsenal Prático por Linguagem

### 1. C Moderno (C23) — Harness Canônico & Sanitizers

No C Moderno (C23), o teste deve se beneficiar de `<stdckdint.h>`, `nullptr`, `static_assert` e atributos `[[nodiscard]]`.

```c
#include <stdio.h>
#include <stdlib.h>
#include <stdckdint.h>

/* Macro de asserção cirúrgica com diagnóstico exato */
#define IRON_ASSERT(expr, msg)                                                   	do {                                                                         		if (!(expr)) {                                                           			fprintf(stderr, "❌ [FALHA] %s:%d: %s (asserção: %s)
",             			        __FILE__, __LINE__, msg, #expr);                             			return 1;                                                            		}                                                                        	} while (0)

/* Função sob teste com atributo obrigatório de retorno checado */
[[nodiscard]] static int safe_multiply(int a, int b, int *result) {
	if (result == nullptr) {
		return -1;
	}
	/* C23: Detecção de overflow no nível do compilador */
	if (ckd_mul(result, a, b)) {
		return -2; /* Overflow detectado */
	}
	return 0;
}

/* Caso de teste negativo: deve detectar overflow com segurança */
static int test_integer_overflow_detection(void) {
	int res = 0;
	int status = safe_multiply(1000000, 1000000, &res);
	IRON_ASSERT(status == -2, "Multiplicação deve retornar -2 em overflow");

	status = safe_multiply(10, 20, &res);
	IRON_ASSERT(status == 0 && res == 200, "Cálculo válido deve produzir 200");

	status = safe_multiply(10, 20, nullptr);
	IRON_ASSERT(status == -1, "Ponteiro nulo deve retornar -1 com segurança");
	return 0;
}

int main(void) {
	if (test_integer_overflow_detection() != 0) {
		return 1;
	}
	printf("✅ [C23] Todos os testes de invariantes passaram com sucesso.
");
	return 0;
}
```

**Flags de Compilação Obrigatórias no Makefile:**

```makefile
CFLAGS ?= -std=c23 -Wall -Wextra -Wpedantic -Werror -fsanitize=address,undefined -O2
```

---

### 2. C++ Moderno (C++23) — Invariantes com `std::expected`

No C++23, erradica-se o uso de exceções descontroladas através de tipos de erro determinísticos em tempo de compilação:

```cpp
#include <cstdint>
#include <expected>
#include <print>
#include <string_view>

enum class ParseError { EmptyInput, InvalidDigit, Overflow };

[[nodiscard]] constexpr std::expected<uint32_t, ParseError>
parse_port(std::string_view sv) noexcept {
	if (sv.empty()) return std::unexpected(ParseError::EmptyInput);
	uint64_t val = 0;
	for (char c : sv) {
		if (c < "0"[0] || c > "9"[0]) return std::unexpected(ParseError::InvalidDigit);
		val = val * 10 + static_cast<uint64_t>(c - "0"[0]);
		if (val > 65535) return std::unexpected(ParseError::Overflow);
	}
	return static_cast<uint32_t>(val);
}

/* Invariantes checadas em tempo de compilação */
static_assert(parse_port("8080").value() == 8080);
static_assert(parse_port("").error() == ParseError::EmptyInput);
static_assert(parse_port("99999").error() == ParseError::Overflow);
static_assert(parse_port("abc").error() == ParseError::InvalidDigit);

int main() {
	std::println("✅ [C++23] Invariantes de compilação e runtime 100% verificadas.");
	return 0;
}
```

---

### 3. POSIX Shell (`/bin/sh`) — Test Runner Puro e Autônomo

Scripts em shell nunca devem depender de frameworks externos como BATS. Eles devem ser testados usando a própria linguagem POSIX com subshells isolados:

```sh
#!/usr/bin/env sh
set -eu

_tests_run=0
_tests_failed=0

assert_eq() {
	_expected="$1"
	_actual="$2"
	_msg="${3:-Valores devem ser iguais}"
	_tests_run=$((_tests_run + 1))

	if [ "${_expected}" != "${_actual}" ]; then
		printf "❌ [FALHA] %s
" "${_msg}" >&2
		printf "   Esperado: [%s]
" "${_expected}" >&2
		printf "   Recebido: [%s]
" "${_actual}" >&2
		_tests_failed=$((_tests_failed + 1))
	fi
}

assert_fails() {
	_cmd="$1"
	_msg="${2:-Comando deve falhar com exit code não-zero}"
	_tests_run=$((_tests_run + 1))

	# Executa em subshell para conter set -e
	if ( eval "${_cmd}" ) > "/dev/null" 2>&1; then
		printf "❌ [FALHA] %s (o comando foi bem-sucedido inesperadamente)
" "${_msg}" >&2
		printf "   Comando: %s
" "${_cmd}" >&2
		_tests_failed=$((_tests_failed + 1))
	fi
}

# --- Bateria de Testes ---
test_directory_parsing() {
	_temp_dir="$(mktemp -d 2> "/dev/null" || mktemp -d -t "test")"
	trap 'rm -rf "${_temp_dir}"' EXIT INT TERM

	# Borda: diretório com espaços e caracteres especiais
	_weird_path="${_temp_dir}/pasta com espacos"
	mkdir -p "${_weird_path}"

	assert_eq "1" "$([ -d "${_weird_path}" ] && echo 1 || echo 0)" "Diretório complexo criado"
	assert_fails "ls '${_temp_dir}/inexistente'" "Arquivo inexistente deve retornar erro"
}

test_directory_parsing

if [ "${_tests_failed}" -gt 0 ]; then
	printf "💥 %d de %d testes falharam!
" "${_tests_failed}" "${_tests_run}" >&2
	exit 1
fi

printf "✅ [POSIX sh] Todos os %d testes passaram silenciosamente.
" "${_tests_run}"
exit 0
```

---

### 4. Go (1.23+) — Table-Driven Tests & Anti-Leak

```go
package config_test

import (
	"testing"
)

func TestParseTimeout(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name      string
		input     string
		wantMs    int
		expectErr bool
	}{
		{name: "válido milissegundos", input: "500ms", wantMs: 500, expectErr: false},
		{name: "borda zero", input: "0ms", wantMs: 0, expectErr: false},
		{name: "negativo inválido", input: "-10ms", wantMs: 0, expectErr: true},
		{name: "string vazia", input: "", wantMs: 0, expectErr: true},
		{name: "unidade ausente", input: "500", wantMs: 0, expectErr: true},
		{name: "overflow numérico", input: "99999999999999999999ms", wantMs: 0, expectErr: true},
	}

	for _, tc := range cases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			got, err := ParseTimeout(tc.input)
			if (err != nil) != tc.expectErr {
				t.Fatalf("ParseTimeout(%q) erro inesperado: %v (esperava erro: %v)", tc.input, err, tc.expectErr)
			}
			if !tc.expectErr && got != tc.wantMs {
				t.Errorf("ParseTimeout(%q) = %d; esperado %d", tc.input, got, tc.wantMs)
			}
		})
	}
}
```

---

### 5. Python (3.12+) — Parametrização Adversarial

```python
import pytest
from app.parser import parse_port

@pytest.mark.parametrize("input_val,expected", [
    (80, 80),
    ("8080", 8080),
    (65535, 65535),
])
def test_parse_port_valid(input_val, expected):
    assert parse_port(input_val) == expected

@pytest.mark.parametrize("invalid_val", [
    "",
    "   ",
    "-1",
    0,
    65536,
    999999,
    "8080abc",
    None,
    [],
])
def test_parse_port_adversarial_rejections(invalid_val):
    with pytest.raises(ValueError):
        parse_port(invalid_val)
```

---

## 4. 🔕 A Regra do Silêncio e Diagnóstico Cirúrgico

1. **Silêncio no Sucesso:**
    - Uma suíte de testes nunca deve emitir 500 linhas de logs com `"Testing foo... OK"`.
    - Se 100 testes passaram, a saída é estritamente silenciosa ou consiste em **uma única linha afirmativa**:
      `✅ All 100 tests passed in 24ms.`
2. **Raio-X Imediato na Falha:**
    - Se ocorrer uma falha, o teste não deve mascarar o motivo. Deve imprimir no `stderr`:
        - O caso de teste específico que falhou.
        - A linha exata do arquivo.
        - O valor esperado vs o valor efetivamente obtido (diff limpo).
        - As variáveis de contexto que provocaram o estado de erro.

---

## 5. 📋 Checklist do Advogado do Diabo (Devil's Advocate)

Antes de aprovar qualquer alteração de código ou encerrar uma tarefa de validação, a IA deve passar por esta checagem mental:

|   #   | Pergunta Inquisitória                                                                                | Se a resposta for "Não" ou "Não sei"                                  |
| :---: | :--------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------- |
| **1** | Se eu adulterar um operador lógico no código sob teste, algum teste falha?                           | Escreva um teste de mutação que cubra essa ramificação exata.         |
| **2** | Testei com entrada vazia (`""`, `0`, `nullptr`, `None`, `[]`)?                                       | Adicione teste negativo para o valor nulo/vazio.                      |
| **3** | Testei com caracteres especiais (espaços, aspas, quebras de linha, `$`, bytes nulos)?                | Teste a resiliência de parsing com caracteres hostis.                 |
| **4** | O código falha de forma determinística retornando erro ou causa _panic/segfault_?                    | Trate o erro na raiz com código de retorno defensivo.                 |
| **5** | O teste limpa seus próprios arquivos temporários mesmo se for abortado (`trap`, `defer`, `finally`)? | Adicione mecanismos de limpeza idempotente.                           |
| **6** | O teste depende de internet ou de serviços externos que podem falhar?                                | Isole a lógica pura de rede; testes unitários devem ser 100% offline. |
| **7** | No C23/C++23, os sanitizers (`-fsanitize=address,undefined`) rodaram sem queixas?                    | Elimine qualquer _undefined behavior_ ou vazamento de memória.        |
| **8** | O linter (`shellcheck`, `mypy`, `clang-tidy`) passou sem supressões preguiçosas?                     | Corrija a causa raiz do aviso em vez de silenciá-lo com comentários.  |

---

## 6. 🔄 Ciclo de Vida da Governança

1. **Manutenção:** Atualize este runbook sempre que novos padrões de teste ou ferramentas de auditoria forem incorporados.
2. **Sincronização:** Todas as atualizações nesta skill refletem instantaneamente no ecossistema através de:
   `${HOME}/.gemini/config/skills/ironclad-testing -> Environment/Profile/skills/ironclad-testing`
