---
name: argos-speculative-tournament
description: >-
    Runbook cognitivo para o Master Orchestrator (Planner Agent) orquestrar
    torneios especulativos de N-versões algorítmicas concorrentes em worktrees Git isoladas,
    avaliando latência, consumo de memória e convergência via benchmarks automatizados.
---

# 🏆 Torneio Especulativo N-Versões

Diretrizes operacionais para o **Master Orchestrator** (_Planner Agent_) disparar competições paralelas de soluções algorítmicas divergentes em worktrees isoladas com **Specialist Sub-Agents** (_Execution Workers_), selecionando a implementação ótima com base em métricas empíricas determinísticas.

---

## 🏛️ 1. O Padrão de Exploração Especulativa

Quando uma tarefa envolve alta incerteza heurística (ex.: otimização de solver, redução de frame-time gráfico ou layout de grafos), tentar uma única linha de raciocínio é subótimo.

O Master despacha de **2 a 8 Execution Workers concorrentes** (média 4, com paridade mandatória via Herança Dinâmica `Model: 'inherit'`), cada um restrito a uma hipótese algorítmica independente e disjunta:

1. **Worker 1 (Candidato A):** Abordagem Gulosa Otimizada ou Heurística Construtiva rápida (ex.: Greedy + 2-opt).
2. **Worker 2 (Candidato B):** Metaheurística Estocástica (ex.: Simulated Annealing / Tabu Search com seed fixa).
3. **Worker 3 (Candidato C):** Programação Dinâmica, Divisão e Conquista ou Min-Cost Max-Flow.
4. **Worker 4 (Candidato D):** Busca Exata com Poda Agressiva (ex.: Branch and Bound).
5. **Worker 5 (Candidato E):** Otimização Numérica ou Vetorizada pura (ex.: SIMD / Bitwise manipulation).

---

## 🌲 2. Isolamento via Git Worktrees (`vcs-git-got`)

Para prevenir qualquer contaminação de workspace entre competidores:

1. **Criação de Worktrees Efêmeras:**
    - O Master cria ramificações temporárias:
        ```sh
        git worktree add -b "exp/cand-1" ".worktrees/cand-1"
        git worktree add -b "exp/cand-2" ".worktrees/cand-2"
        ```
2. **Alocação Exclusiva:** Cada worker opera com permissão de escrita restrita exclusivamente à sua própria worktree.
3. **Mesma Interface Pública:** Todos os competidores devem implementar exatamente a mesma assinatura de função e contrato de I/O.

---

## ⚡ 3. Governança de Spawn & Invariante de Modelo

- **Herança Dinâmica de Modelo:** Em cada invocação `invoke_subagent`, utilize `Model: 'inherit'` para manter paridade com o modelo ativo da sessão (ou o tier rápido nativo do runtime, sem hardcode de versão ou tier).
- **Interdição de Swarm e Cron:** O torneio utiliza subagentes isolados ponto a ponto. Não use a ferramenta `swarm` nem cron via `schedule`.
- **Escalação Seletiva:** Caso uma hipótese envolva formulação matemática não-trivial, restrinja eventual alocação de capacidade superior a no máximo 1 candidato por lote, mantendo os demais em paridade padrão.

---

## ⏱️ 4. O Coliseu de Benchmark Determinístico

Com todas as implementações entregues, o Master executa a suíte de avaliação empírica:

1. **Métricas de Julgamento:**
    - **Tempo de CPU / Latência:** Execução média e latência de cauda (p99).
    - **Consumo de Memória:** Pico de RSS e alocações de heap.
    - **Qualidade da Solução:** Valor da função objetivo (menor custo de rota, menor erro geométrico).
    - **Estabilidade:** Ausência total de timeouts ou falhas numéricas.
2. **Promulgação do Vencedor:** A solução com a melhor pontuação global ponderada é selecionada.
3. **Limpeza Implacável (Teardown):** A branch vencedora é mesclada na branch de trabalho; todas as worktrees concorrentes são descartadas (`git worktree remove --force`) sem deixar resíduos.

---

## ⚖️ 5. Diretrizes Imperativas (DOs & DON'Ts)

| Prática   | Diretiva Operacional                                                                         |
| :-------- | :------------------------------------------------------------------------------------------- |
| **DO**    | Isole cada competidor em uma worktree Git própria (`git worktree add`).                      |
| **DO**    | Declare `Model: 'inherit'` (ou tier rápido nativo do runtime) em cada `invoke_subagent`.     |
| **DO**    | Exija rigorosa igualdade de assinaturas e formatos de entrada e saída.                       |
| **DO**    | Julgue os candidatos via baterias objetivas com dados reais e casos extremos.                |
| **DO**    | Descarte sumariamente branches derrotadas após a consagração do vencedor.                    |
| **DON'T** | Não faça hardcode de nomes, versões ou tiers específicos de modelo na chamada da tool.       |
| **DON'T** | Não use `swarm` nativo ou monitoramento periódico via `schedule`.                            |
| **DON'T** | Não permita que um concorrente consulte o código ou algoritmo de outro competidor.           |
| **DON'T** | Não escolha vencedores baseado em estilo narrativo; decida por dados empíricos de benchmark. |
| **DON'T** | Não mantenha worktrees órfãs no sistema após a conclusão do torneio.                         |

---

## 📋 6. Template de Invocação de Torneio Especulativo

```markdown
### CONTRATO DE TORNEIO ESPECULATIVO [TOURNAMENT-ID]

- **Problema Algorítmico:** [Descrição da função ou gargalo a ser superado]
- **Interface Requerida:** `include/solver_interface.h`
- **Candidato Alocado:** [Nome da Heurística / Abordagem atribuída ao Worker]
- **Alocação de Modelo:** inherit (herança dinâmica do modelo ativo da sessão ou tier rápido nativo)
- **Workspace Autorizado:** `.worktrees/cand-[ID]/`
- **Circuit Breaker:** Teto de 20 chamadas de ferramenta; interrompa em caso de falha de ambiente.
- **Métricas Alvo:** [Latência < 5ms, heap zero alocações dinâmicas]
```
