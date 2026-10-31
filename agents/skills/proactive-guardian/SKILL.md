---
name: proactive-guardian
description: >-
    Runbook cognitivo para custódia proativa de qualidade, conformidade contínua e Boy Scout Rule.
    Ativar ao identificar inconformidades sintáticas, links quebrados, ausência de documentação,
    permissões incorretas, desvios de padrões ou débitos técnicos adjacentes no ecossistema.
---

# 🛡️ Proactive Guardian — Custódia Proativa de Qualidade & Boy Scout Rule

> _"Always leave the campground cleaner than you found it."_<br>
> — Robert C. Martin, _Clean Code: A Handbook of Agile Software Craftsmanship_ (2008)

Esta skill estabelece as diretrizes de atuação proativa e custódia contínua de qualidade para todos os repositórios do ecossistema soberano. O agente nunca deve atuar de forma passiva diante de inconformidades observadas no código ou na documentação: ao interagir com qualquer componente, DEVE identificar e sanar proativamente pequenas irregularidades adjacentes, elevando a saúde geral do ecossistema sem perder o foco na tarefa principal.

---

## 🏛️ A Filosofia do Boy Scout no Ecossistema Soberano

A manutenção preventiva contínua impede o acúmulo de débito técnico. Quando o agente inspeciona ou edita qualquer módulo:

1. **Ação Corretiva Imediata:** Se encontrar um erro sintático, link quebrado, permissão incorreta ou ausência de documentação, deve corrigir no mesmo ciclo de entrega.
2. **Notificação Concisa:** Notifique o usuário de forma sucinta sobre os ajustes realizados, mantendo total transparência.
3. **Escopo Delimitado:** As correções proativas devem se concentrar em desvios objetivos e adjacentes ao trabalho em andamento, evitando refatorações disruptivas não solicitadas.

---

## ⚖️ Matriz de Auditoria Proativa Contínua

| Dimensão                   | Anti-padrão Passivo (Evite)                      | Custódia Proativa (Use)                                        |
| :------------------------- | :----------------------------------------------- | :------------------------------------------------------------- |
| **Formatação de Arquivos** | Ignorar arquivos desformatados na vizinhança     | **Formatar com a ferramenta canônica (`prettier`, `stylua`)**  |
| **Documentação de Pastas** | Criar diretório sem explicar sua função          | **Criar `README.md` tabular com índice e propósito**           |
| **Links em Documentos**    | Deixar links Markdown quebrados ou apontando 404 | **Validar e corrigir caminhos relativos e âncoras**            |
| **Permissões de Arquivos** | Deixar scripts sem permissão executável          | **Aplicar `chmod 0755` para scripts e `chmod 0644` para docs** |
| **Comentários de Código**  | Manter comentários óbvios que apenas narram      | **Remover comentários redundantes em favor de código limpo**   |
| **Segurança e Segredos**   | Ignorar dados sensíveis em commits ou configs    | **Expurgar chaves, tokens e variáveis confidenciais expostas** |

---

## 📋 Checklist de Verificação Antes da Entrega

Antes de finalizar qualquer modificação, realize a verificação de conformidade:

1. **Sintaxe & Formatação:**
    - Arquivos JSON, YAML, TOML, Markdown, C e Shell devem estar com sintaxe válida e formatados.
2. **Integridade de Documentação:**
    - Todo subdiretório criado ou navegado deve possuir um `README.md` atualizado.
    - Todos os links relativos entre documentos devem resolver com sucesso.
3. **Modos Octais POSIX:**
    - Permissões em 4 dígitos: `chmod 0755` para diretórios e scripts executáveis; `chmod 0644` para arquivos de texto e configurações.
4. **Higiene de Controle de Versão:**
    - Execute `git diff --check` para verificar ausência de espaços em branco residuais ou conflitos.
    - Valide contra os testes estáticos e linters do projeto (`make audit` ou scripts equivalentes).

---

## 🛡️ Diretrizes de Tom e Conduta

- **Regra:** Aplicar a regra do escoteiro em cada intervenção, sanando desvios evidentes.
- **Evite:** Adiar correções simples ou delegar pequenos reparos sintáticos para tarefas futuras.
- **Use:** Correção imediata, atômica e devidamente documentada no relatório final.
