---
name: argos-adversarial-crucible
description: >-
    Runbook cognitivo para o Master Orchestrator (Planner Agent) orquestrar
    verificação adversarial red-team versus blue-team com sub-agentes efêmeros,
    geradores de casos de borda extremos, injeção de falhas e compilação com sanitizers.
---

# ⚔️ Crisol Adversarial Red-Team / Blue-Team

Diretrizes operacionais para o **Master Orchestrator** (_Planner Agent_) instanciar células assimétricas de verificação de código com **Specialist Sub-Agents** (_Execution Workers_) e **Adversarial Verifiers** (_QA Agents_), onde a aprovação de uma funcionalidade exige sobrevivência ao fogo cruzado entre construtores e atacantes automatizados.

---

## 🏛️ 1. Topologia da Célula Assimétrica (Pool 2 a 8 Workers)

A célula adversarial opera dividindo o pool de workers efêmeros (entre 2 e 8 agentes simultâneos, média 4) em três papéis isolados por diretório:

1. **Workers 1 e 2 — Blue Team (Execution Workers / Builders):**
    - **Escopo Exclusivo:** `src/` (ou caminho equivalente de código de produção).
    - **Missão:** Implementar a funcionalidade solicitada conforme a especificação arquitetural, tipos canônicos e contratos de interface.
    - **Restrição:** Não possuem acesso de leitura ou escrita a `tests/adversarial/`.
2. **Workers 3 e 4 — Red Team (Adversarial Verifiers / Breakers):**
    - **Escopo Exclusivo:** `tests/adversarial/` (ou suíte hostil isolada).
    - **Missão:** Ler exclusivamente especificações e cabeçalhos públicos (`include/`, schemas de API), gerando baterias de testes de estresse, casos patológicos, estouro de inteiros, limites de buffer e entradas malformadas.
    - **Restrição:** Proibido ler a implementação do Blue Team e proibido alterar `src/`.
3. **Worker 5 — Inquisitor (QA Agent / Verificador):**
    - **Escopo Exclusivo:** `Makefile` e rotinas de orquestração de testes.
    - **Missão:** Compilar a implementação com sanitizers ativos (`-fsanitize=address,undefined`) e rodar os testes hostis, coletando logs brutos de erro e métricas.

### Gradiente de Modelos & Invariante de Spawn

- **Herança Dinâmica de Modelo:** Todos os workers operam com `Model: 'inherit'` na chamada `invoke_subagent` para paridade com o modelo ativo da sessão (ou tier rápido nativo do runtime, sem hardcode de versão ou tier).
- **Escalação Cirúrgica (Exceção de Alta Densidade):** Em módulos de alta criticidade (criptografia, arenas de memória), o Master pode alocar no máximo **1 Adversarial Verifier** com capacidade estendida para formular vetores de ataque matemáticos, mantendo o restante da célula em paridade padrão e com teardown imediato pós-entrega.
- **Interdição de Swarm e Cron:** A célula opera via subagentes privados. É vedado o uso da tool `swarm` e de polling periódico via `schedule`.

---

## 🔄 2. Ciclo de Combate & Critérios de Sobrevivência

O fluxo adversarial opera em quatro tempos rigorosos:

1. **Geração Paralela:** O Master despacha o Blue Team (_Execution Workers_) para construir e o Red Team (_Adversarial Verifiers_) para atacar simultaneamente em seus diretórios disjuntos com `Model: 'inherit'`.
2. **Execução pelo Inquisitor:** O Inquisitor compila o código do Blue Team contra os testes do Red Team.
3. **Auditoria de Danos:**
    - **Aprovação:** Todos os testes passam sem segfaults, memory leaks, panics ou violações de sanitizer (exit code `0`).
    - **Fratura:** Ocorreu falha ou crash. O Master extrai o contraexemplo mínimo do log e aciona 1 ciclo de reparo para o Blue Team (máximo de 2 retries).
4. **Teardown & Merge:** Os testes adversariais são incorporados permanentemente à suíte de regressão do projeto e os workers são finalizados (`manage_subagents` kill).

---

## 🔒 3. Prevenção de Trapaça & Conluio Cognitivo

- **Isolamento de Visibilidade:** O Red Team nunca deve ver a implementação interna para evitar testes moldados ao código existente (_blind verification_).
- **Zero Colisão de Escrita:** Nenhuma alteração cruzada entre `src/` e `tests/adversarial/` é permitida.
- **Injeção de Casos de Borda:** O Red Team deve obrigar o uso de valores extremos: `0`, `-1`, `INT_MAX`, strings nulas, payloads gigantes e sequências de escape incompletas.

---

## ⚖️ 4. Diretrizes Imperativas (DOs & DON'Ts)

| Prática   | Diretiva Operacional                                                                                |
| :-------- | :-------------------------------------------------------------------------------------------------- |
| **DO**    | Restrinja o Blue Team estritamente ao diretório de produção (`src/`).                               |
| **DO**    | Declare `Model: 'inherit'` (ou tier rápido nativo do runtime) no payload JSON de `invoke_subagent`. |
| **DO**    | Restrinja escalações de capacidade a no máximo 1 instância cirúrgica, com teardown imediato.        |
| **DO**    | Utilize compiladores e executáveis com sanitizers ativos (`ASan`, `UBSan`) no harness.              |
| **DO**    | Promova os testes adversariais aprovados a testes permanentes de regressão.                         |
| **DON'T** | Não faça hardcode de nomes, versões ou tiers específicos de modelo na chamada da tool.              |
| **DON'T** | Não use `swarm` nativo ou monitoramento via cron (`schedule`).                                      |
| **DON'T** | Não permita que o Red Team edite código de produção para facilitar o teste.                         |
| **DON'T** | Não permita que o Blue Team veja os testes hostis antes da primeira compilação.                     |
| **DON'T** | Não aceite aprovações baseadas em soft review sem execução real com exit code `0`.                  |
| **DON'T** | Não ultrapasse 2 retries corretivos se uma falha estrutural for detectada.                          |

---

## 📋 5. Template de Invocação da Célula Adversarial

```markdown
### PROTOCOLO DE COMBATE ADVERSARIAL [CRUCIBLE-ID]

- **Alvo:** [Módulo / Função sob verificação estrita]
- **Alocação de Modelo:** inherit (herança dinâmica do modelo ativo da sessão ou tier rápido nativo)
- **Blue Team (Workers 1-2):** `src/caminho/do/modulo.ext`
- **Red Team (Workers 3-4):** `tests/adversarial/test_modulo.ext`
- **Inquisitor (Worker 5):** `make test-adversarial SANITIZE=1`
- **Circuit Breaker:** Teto de 20 chamadas de ferramenta; interrompa em caso de bloqueio.
- **Condição de Vitória:** Zero vazamentos, zero alertas de sanitizer e 100% de asserções cumpridas.
```
