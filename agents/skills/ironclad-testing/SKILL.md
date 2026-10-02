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

A postura de teste segue 3 leis inegociáveis:

1. **O Código DEVE Quebrar com Dignidade:** Testar não é apenas verificar se o resultado correto é emitido quando os dados são perfeitos. É garantir que, diante do caos, o software encerra de forma atômica, segura, limpa e com código de saída diferente de zero.
2. **Proibição da Cobertura Cosmética:** Ter 100% de linhas cobertas não significa nada se as asserções forem triviais. É proibido criar testes cujo único assert seja `assert True`, `assert err == nil` sem checar o payload, ou testes que apenas exercitam o código sem validar invariantes de estado.
3. **A Prova da Mutação (Mutation Mindset):** Antes de considerar um caso de teste concluído, pergunte a si mesmo: _Se eu intencionalmente alterar um operador `<` para `<=`, ou comentar uma validação de erro no código-fonte, este teste falhará?_ Se a resposta for "não", o teste é inútil e deve ser reescrito.

---

## 2. 🧱 As 5 Barreiras de Contenção (Shift-Left Absoluto)

Nenhum código defeituoso deve avançar para o commit. A contenção é realizada em camadas concêntricas:

```text
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

### Detalhamento das Barreiras

- **Barreira 0 (Compiladores e Linters no Rigor Máximo):**
    - **C Moderno (C23):** `-std=c23 -Wall -Wextra -Wpedantic -Werror`.
    - **C++ Moderno (C++23):** `-std=c++23 -Wall -Wextra -Wpedantic -Werror`.
    - **POSIX Shell:** `sh -n` e `shellcheck -s sh -S error`.
    - **Python:** Tipos e sintaxe estrita com `mypy --strict` e `ruff`.
    - **Go:** `golangci-lint run` e análise estática nativa (`go vet`).
- **Barreira 1 (Sanitizers Dinâmicos e Race Detection):**
    - C23 / C++23: compilar e rodar testes obrigatoriamente com `-fsanitize=address,undefined -fno-omit-frame-pointer`.
    - Go: testes de concorrência executam com `go test -race -count=1 ./...`.
- **Barreira 2 (Invariantes de Borda e Testes Negativos):**
    - _Limites Numéricos:_ `0`, `-1`, inteiros máximos (`INT_MAX`, `SIZE_MAX`), overflow e underflow.
    - _Limites de Strings:_ strings vazias (`""`), só espaços, bytes nulos prematuros, sem newline final.
    - _Limites de Sistema de Arquivos:_ caminhos inexistentes, arquivos sem permissão de leitura (`0000`), diretórios protegidos (`0400`), links simbólicos circulares ou quebrados.
    - _Limites de Processo:_ sinais inesperados (`SIGPIPE`, `SIGINT`), variáveis de ambiente indefinidas ou vazias.
- **Barreira 3 (Harness Local Hermético & Makefile Silencioso):**
    - A execução de `make test` ou `make check` deve ser local, hermética, reproduzível e rápida (< 1s para testes unitários).
    - Regra do Silêncio: se passou, silêncio absoluto ou resumo limpo de 1 linha. Se falhou, emissão imediata da causa exata.
- **Barreira 4 (Git Quality Gates em `.githooks`):**
    - O hook `.githooks/pre-commit` bloqueia qualquer commit se testes, linters ou formatação Prettier falharem.

---

## 3. 🔬 Implementações de Referência por Linguagem (`examples/`)

Os testes canônicos e padrões de harness do ecossistema estão estruturados modularmente na pasta [`examples/`](./examples/):

| Linguagem / Runtime     | Padrão Arquitetural & Invariantes                                                         | Arquivo de Referência                                                    |
| :---------------------- | :---------------------------------------------------------------------------------------- | :----------------------------------------------------------------------- |
| **C Moderno (C23)**     | Aritmética segura `<stdckdint.h>`, `nullptr`, asserções cirúrgicas e sanitizers           | [`examples/c23/test_invariants.c`](./examples/c23/test_invariants.c)     |
| **C++ Moderno (C++23)** | Retorno monádico `std::expected`, `std::print`, checagens `static_assert` em compile-time | [`examples/cpp23/test_expected.cpp`](./examples/cpp23/test_expected.cpp) |
| **POSIX Shell (`sh`)**  | Test runner hermético puro, contenção com subshells, `trap` e zero dependências           | [`examples/posix_sh/test_runner.sh`](./examples/posix_sh/test_runner.sh) |
| **Go (1.23+)**          | Testes paralelos table-driven (`t.Parallel()`), bordas zero/negativas e anti-leak         | [`examples/go/timeout_test.go`](./examples/go/timeout_test.go)           |
| **Python (3.12+)**      | Parametrização adversarial (`@pytest.mark.parametrize`) e captura de exceções             | [`examples/python/test_parser.py`](./examples/python/test_parser.py)     |

---

## 4. 🔕 A Regra do Silêncio e Diagnóstico Cirúrgico

1. **Silêncio no Sucesso:**
    - Uma suíte de testes nunca deve emitir 500 linhas de logs verbosos.
    - Quando todos os testes passam, a saída é estritamente silenciosa ou consiste em uma única linha afirmativa: `✅ All 100 tests passed in 24ms.`
2. **Raio-X Imediato na Falha:**
    - Em caso de falha, o teste emite no `stderr`: caso específico, arquivo e linha exata, valor esperado vs recebido e variáveis causadoras do erro.

---

## 5. 📋 Checklist do Advogado do Diabo (Devil's Advocate)

Antes de aprovar qualquer alteração de código ou encerrar validações, confirme:

|   #   | Pergunta Inquisitória                                                                       | Se a resposta for "Não" ou "Não sei"                                  |
| :---: | :------------------------------------------------------------------------------------------ | :-------------------------------------------------------------------- |
| **1** | Se eu adulterar um operador lógico no código sob teste, algum teste falha?                  | Escreva um teste de mutação que cubra essa ramificação exata.         |
| **2** | Testei com entrada vazia (`""`, `0`, `nullptr`, `None`, `[]`)?                              | Adicione teste negativo para o valor nulo/vazio.                      |
| **3** | Testei com caracteres especiais (espaços, aspas, quebras de linha, `$`, bytes nulos)?       | Teste a resiliência de parsing com caracteres hostis.                 |
| **4** | O código falha de forma determinística retornando erro ou causa _panic/segfault_?           | Trate o erro na raiz com código de retorno defensivo.                 |
| **5** | O teste limpa seus próprios arquivos temporários mesmo se for abortado (`trap`, `finally`)? | Adicione mecanismos de limpeza idempotente.                           |
| **6** | O teste depende de internet ou de serviços externos que podem falhar?                       | Isole a lógica pura de rede; testes unitários devem ser 100% offline. |
| **7** | No C23/C++23, os sanitizers (`-fsanitize=address,undefined`) rodaram sem queixas?           | Elimine qualquer _undefined behavior_ ou vazamento de memória.        |
| **8** | O linter (`shellcheck`, `mypy`, `clang-tidy`) passou sem supressões preguiçosas?            | Corrija a causa raiz do aviso em vez de silenciá-lo com comentários.  |

---

## 🔗 Links Oficiais de Referência & Obras Recomendadas

- **The Open Group (POSIX.1-2024 Base Specifications):** <https://pubs.opengroup.org/onlinepubs/9799919799/>
- **LLVM Clang Sanitizers Documentation:** <https://clang.llvm.org/docs/AddressSanitizer.html> | <https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html>
- **ISO C++ Standard:** <https://isocpp.org/>
- **Literatura Técnica:**
    - _The Art of Software Testing_ (Glenford J. Myers, Corey Sandler, Tom Badgett, Wiley).
    - _Working Effectively with Legacy Code_ (Michael C. Feathers, Prentice Hall).
    - _The Practice of Programming_ (Brian W. Kernighan & Rob Pike, Addison-Wesley).
