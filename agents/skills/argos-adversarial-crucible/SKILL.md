---
name: argos-adversarial-crucible
description: >-
    Runbook cognitivo para o GM Argos orquestrar verificação adversarial red-team versus
    blue-team com sub-agentes Flash, geradores de casos de borda extremos, injeção de
    falhas e compilação estrita com sanitizers.
---

# ⚔️ Crisol Adversarial Red-Team / Blue-Team (GM Argos)

Diretrizes operacionais para o **GM Argos** instanciar células assimétricas de verificação de código, onde a aprovação de uma funcionalidade exige sobrevivência ao fogo cruzado entre construtores e atacantes automatizados.

---

## 🏛️ 1. Topologia da Célula Assimétrica (Pool <= 5)

A célula adversarial opera dividindo o pool de workers Flash em três papéis isolados por diretório:

1. **Slaves 1 e 2 — Blue Team (Builders):**
    - **Escopo Exclusivo:** `src/` (ou caminho equivalente de código de produção).
    - **Missão:** Implementar a funcionalidade solicitada conforme a especificação arquitetural, tipos canônicos e contratos de interface.
    - **Restrição:** Não possuem acesso de leitura ou escrita a `tests/adversarial/`.
2. **Slaves 3 e 4 — Red Team (Breakers):**
    - **Escopo Exclusivo:** `tests/adversarial/` (ou suíte hostil isolada).
    - **Missão:** Ler exclusivamente especificações e cabeçalhos públicos (`include/`, schemas de API), gerando baterias de testes de estresse, casos patológicos, estouro de inteiros, limites de buffer e entradas malformadas.
    - **Restrição:** Proibido ler a implementação do Blue Team e proibido alterar `src/`.
3. **Slave 5 — Inquisitor (Harness & Verificador):**
    - **Escopo Exclusivo:** `Makefile` e rotinas de orquestração de testes.
    - **Missão:** Compilar a implementação com sanitizers ativos (`-fsanitize=address,undefined`) e rodar os testes hostis, coletando logs brutos de erro e métricas.

---

## 🔄 2. Ciclo de Combate & Critérios de Sobrevivência

O fluxo adversarial opera em quatro tempos rigorosos:

1. **Geração Paralela:** O GM Argos despacha o Blue Team para construir e o Red Team para atacar simultaneamente em seus diretórios disjuntos.
2. **Execução pelo Inquisitor:** O Inquisitor compila o código do Blue Team contra os testes do Red Team.
3. **Auditoria de Danos:**
    - **Aprovação:** Todos os testes passam sem segfaults, memory leaks, panics ou violações de sanitizer (exit code `0`).
    - **Fratura:** Ocorreu falha ou crash. O Argos extrai o contraexemplo mínimo do log e aciona 1 ciclo de reparo para o Blue Team (máximo de 2 retries).
4. **Teardown & Merge:** Os testes adversariais são incorporados permanentemente à suíte de regressão do projeto e os workers são finalizados.

---

## 🔒 3. Prevenção de Trapaça & Conluio Cognitivo

- **Isolamento de Visibilidade:** O Red Team nunca deve ver a implementação interna para evitar testes moldados ao código existente (_blind verification_).
- **Zero Colisão de Escrita:** Nenhuma alteração cruzada entre `src/` e `tests/adversarial/` é permitida.
- **Injeção de Casos de Borda:** O Red Team deve obrigar o uso de valores extremos: `0`, `-1`, `INT_MAX`, strings nulas, payloads gigantes e sequências de escape incompletas.

---

## ⚖️ 4. Diretrizes Imperativas (DOs & DON'Ts)

| Prática   | Diretiva Operacional                                                                   |
| :-------- | :------------------------------------------------------------------------------------- |
| **DO**    | Restrinja o Blue Team estritamente ao diretório de produção (`src/`).                  |
| **DO**    | Exija que o Red Team conceba testes lendo apenas especificações e contratos públicos.  |
| **DO**    | Utilize compiladores e executáveis com sanitizers ativos (`ASan`, `UBSan`) no harness. |
| **DO**    | Promova os testes adversariais aprovados a testes permanentes de regressão.            |
| **DON'T** | Não permita que o Red Team edite código de produção para "facilitar" o teste.          |
| **DON'T** | Não permita que o Blue Team veja os testes hostis antes da primeira compilação.        |
| **DON'T** | Não aceite aprovações baseadas em soft review sem execução real com exit code `0`.     |
| **DON'T** | Não ultrapasse 2 retries corretivos se uma falha estrutural for detectada.             |

---

## 📋 5. Template de Invocação da Célula Adversarial

```markdown
### PROTOCOLO DE COMBATE ADVERSARIAL [CRUCIBLE-ID]

- **Alvo:** [Módulo / Função sob verificação estrita]
- **Blue Team (Workers 1-2):** `src/caminho/do/modulo.ext`
- **Red Team (Workers 3-4):** `tests/adversarial/test_modulo.ext`
- **Inquisitor (Worker 5):** `make test-adversarial SANITIZE=1`
- **Condição de Vitória:** Zero vazamentos, zero alertas de sanitizer e 100% de asserções cumpridas.
```
