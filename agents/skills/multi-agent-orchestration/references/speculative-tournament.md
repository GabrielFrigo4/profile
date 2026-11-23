# 🏆 Torneio Especulativo N-Versões em Worktrees

> Exploração paralela de alternativas algorítmicas divergentes com seleção estritamente baseada em benchmarks determinísticos.

---

## 1. Arquitetura em Worktrees Isoladas

Para problemas com alta incerteza heurística (otimização de solvers, latência de renderização, layouts de grafos), isole cada hipótese em uma worktree Git independente:

```sh
git worktree add -b "exp/cand-1" ".worktrees/cand-1"
git worktree add -b "exp/cand-2" ".worktrees/cand-2"
```

- Cada Worker (`Model: 'inherit'`) escreve exclusivamente em sua própria worktree e implementa rigorosamente a mesma assinatura pública de entrada e saída.
- Competidores não consultam o código uns dos outros durante a execução.

---

## 2. Julgamento Empírico & Teardown

Avalie todas as entregas sob carga determinística idêntica:

- **Latência e CPU:** Tempo médio e cauda (`p99`).
- **Memória:** Pico de RSS e alocações em hot path.
- **Qualidade da Solução:** Valor da função objetivo e estabilidade em casos extremos.

Integre apenas a branch vencedora e remova todas as worktrees e branches descartadas sem deixar resíduos:

```sh
git worktree remove --force ".worktrees/cand-1"
git branch -D "exp/cand-1"
```

---

## 3. Template de Torneio Especulativo

```markdown
### CONTRATO DE TORNEIO ESPECULATIVO [TOURNAMENT-ID]

- **Problema:** [Função ou gargalo alvo]
- **Interface Pública:** `include/solver_interface.h`
- **Candidato Alocado:** [Heurística ou algoritmo atribuído]
- **Alocação de Modelo:** inherit
- **Workspace Autorizado:** `.worktrees/cand-[ID]/`
- **Métricas Alvo:** [Latência máxima, limite de memória e critério de corretude]
```
