# ⚔️ Verificação Adversarial Red-Team / Blue-Team

> Protocolo de validação assimétrica com isolamento de visibilidade entre construtores e atacantes automatizados.

---

## 1. Topologia da Célula Assimétrica

Divida o pool limitado de workers efêmeros (`Model: 'inherit'`) em três papéis com escopos de disco disjuntos:

1. **Blue Team (Builders — `src/`):** Implementa a funcionalidade conforme especificação e cabeçalhos públicos. Não lê nem edita `tests/adversarial/`.
2. **Red Team (Breakers — `tests/adversarial/`):** Lê apenas contratos públicos e schemas para gerar baterias hostis (`0`, `-1`, `INT_MAX`, strings nulas, payloads malformados, truncamentos e seqüências incompletas). Não lê `src/`.
3. **Inquisitor (QA Verifier — `Makefile` / Runner):** Compila o código do Blue Team contra os testes do Red Team com sanitizers (`-fsanitize=address,undefined` ou `-race`) e coleta logs brutos.

---

## 2. Ciclo de Combate & Retorno

1. **Geração Paralela:** Blue Team e Red Team operam simultaneamente em diretórios isolados.
2. **Execução Hermética:** O Inquisitor executa a suíte adversarial completa.
3. **Diagnóstico de Fratura:** Diante de falha, crash ou alerta de sanitizer, o Master extrai o contraexemplo mínimo e aciona no máximo `2` ciclos de reparo no Blue Team.
4. **Consolidação:** Testes adversariais aprovados permanecem na suíte de regressão permanente; os subagentes são encerrados imediatamente.

---

## 3. Template da Célula Adversarial

```markdown
### PROTOCOLO DE COMBATE ADVERSARIAL [CRUCIBLE-ID]

- **Alvo:** [Módulo / Função sob verificação]
- **Alocação de Modelo:** inherit
- **Blue Team:** `src/modulo/`
- **Red Team:** `tests/adversarial/test_modulo`
- **Inquisitor:** `make test-adversarial SANITIZE=1`
- **Condição de Aceite:** Zero vazamentos, zero alertas de sanitizer e código de saída 0.
```
