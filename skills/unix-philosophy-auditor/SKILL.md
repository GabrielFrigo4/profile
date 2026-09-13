---
name: unix-philosophy-auditor
description: Runbook cognitivo para auditoria estática e comportamental de código conforme os 17 Princípios UNIX (Eric S. Raymond) + 18ª Regra da Soberania do Usuário + 19ª Regra da Autonomia Reentrante.
---

# 📜 Unix Philosophy Auditor Skill

Esta habilidade orienta o agente de IA na auditoria crítica de arquitetura, ferramentas de linha de comando, scripts e sistemas, avaliando sua aderência estrita aos **19 Princípios de Engenharia** consolidados no ecossistema de **Gabriel Frigo**.

---

## 🏛️ O Cânone dos 19 Princípios de Design

A fonte primária de autoridade é o tratado _The Art of UNIX Programming_ (Eric S. Raymond, 2003), acrescido das Regras de Soberania do Usuário e Autonomia Reentrante desenvolvidas no ecossistema:

|   #    | Princípio                | Nome Original                | Diretriz de Auditoria                                                                                           |
| :----: | :----------------------- | :--------------------------- | :-------------------------------------------------------------------------------------------------------------- |
| **1**  | **Modularidade**         | _Rule of Modularity_         | Partes simples conectadas por interfaces limpas. O código tem responsabilidade única (SRP)?                     |
| **2**  | **Clareza**              | _Rule of Clarity_            | Clareza > esperteza. O código é legível sem "truques" arcanos ou expressões regulares impenetráveis?            |
| **3**  | **Composição**           | _Rule of Composition_        | Conexão a outros programas. O software lê de `stdin` e escreve em `stdout`? Suporta pipes Unix?                 |
| **4**  | **Separação**            | _Rule of Separation_         | Separar mecanismo de política; separar motor de interface. O núcleo computacional é agnóstico a UI?             |
| **5**  | **Simplicidade**         | _Rule of Simplicity_         | Projetar para a simplicidade. Complexidade só onde for estritamente demonstrada como necessária.                |
| **6**  | **Parcimônia**           | _Rule of Parsimony_          | Escreva um programa grande apenas quando comprovado que nada menor resolverá o problema.                        |
| **7**  | **Transparência**        | _Rule of Transparency_       | Projetar para a visibilidade para tornar inspeção e depuração fáceis. O estado do sistema é claro?              |
| **8**  | **Robustez**             | _Rule of Robustness_         | A robustez é filha da transparência e da simplicidade. Falhas de ambiente são tratadas defensivamente?          |
| **9**  | **Representação**        | _Rule of Representation_     | Dobrar conhecimento em dados para que a lógica possa ser estúpida e robusta. Listas sobre if/else.              |
| **10** | **Menor Espanto**        | _Rule of Least Surprise_     | Sempre faça a coisa menos surpreendente. Segue as convenções Unix (códigos de saída, `/etc/`, flags)?           |
| **11** | **Silêncio**             | _Rule of Silence_            | Quando não há nada surpreendente a dizer, NÃO diga nada. Sucesso é silêncio. Sem banners inúteis.               |
| **12** | **Reparo**               | _Rule of Repair_             | Quando precisar falhar, falhe ruidosamente e o mais rápido possível (_fail-fast_ com `set -eu`).                |
| **13** | **Economia**             | _Rule of Economy_            | O tempo do programador é caro; economize-o em preferência ao tempo da máquina.                                  |
| **14** | **Geração**              | _Rule of Generation_         | Escreva programas para escrever programas quando puder. Evite codificação manual repetitiva.                    |
| **15** | **Otimização**           | _Rule of Optimization_       | Prototipe antes de polir. Faça funcionar antes de otimizar assintótica ou mecanicamente.                        |
| **16** | **Diversidade**          | _Rule of Diversity_          | Desconfie de "uma única maneira verdadeira". O software tolera sistemas e ambientes heterogêneos?               |
| **17** | **Extensibilidade**      | _Rule of Extensibility_      | Projete para o futuro, porque ele chegará antes do que você imagina. Interfaces abertas a extensões.            |
| **18** | **Soberania do Usuário** | _Rule of User Sovereignty_   | Honre a escolha do usuário (`doas > sudo`) e a precedência Local > Global (CLI > $VAR > Projeto > $HOME > Sys). |
| **19** | **Autonomia Reentrante** | _Rule of Reentrant Autonomy_ | O módulo opera 100% autônomo isolado; ativa sinergias em silêncio quando integrado a outros repositórios.       |

---

## 🔍 Checklist de Auditoria para Agentes de IA

Ao analisar um arquivo, PR ou repositório:

1. **Checagem de Ruído (Regra do Silêncio):**
    - O comando imprime mensagens prolixas desnecessárias quando tudo deu certo?
    - Se for um script de build ou loader, ele imprime linhas de boas-vindas sem que o usuário tenha pedido? Se sim, marque violação da **Regra do Silêncio**.
2. **Checagem de Formato de Saída (Regra da Composição):**
    - A saída para pipe (`! [ -t 1 ]`) contém códigos ANSI de cor ou escapes gráficos que quebram `grep`, `awk` ou `sed`?
3. **Checagem de Falha Precoce (Regra do Reparo):**
    - Falhas em comandos intermediários são mascaradas ou ignoradas? O script continua rodando após um erro grave? Se sim, exija `set -eu` ou verificação explícita de código de retorno.
4. **Checagem de Soberania do Usuário e Precedência Local (Local > Global):**
    - O script ou loader respeita a precedência de resolução local (`$VAR` > `$HOME` > `/usr/local/share`)?
    - O script tenta forçar `sudo` cegamente sem respeitar a presença ou preferência do usuário por `doas`?
    - O script sobrescreve arquivos de configuração preexistentes sem criar backups (`.bak`) ou pedir confirmação?
5. **Checagem de Dados vs Código (Regra da Representação):**
    - Existe uma cascata gigantesca de `if [ "$1" = "a" ] ... elif [ "$1" = "b" ]` que poderia ser expressa como uma tabela ou array declarativo simples?
6. **Checagem de Autonomia Reentrante:**
    - O módulo opera de forma autônoma sem emitir erros ou avisos caso outros módulos do ecossistema não estejam presentes?

---

## 📝 Formato do Relatório de Auditoria Unix

Ao emitir o diagnóstico para o desenvolvedor:

```markdown
### 🏛️ Relatório de Auditoria Unix — <Nome do Arquivo / Módulo>

- **Pontuação de Aderência:** X / 18 princípios satisfeitos.
- **Violações Detectadas:**
    - ⚠️ **Regra do Silêncio (Regra 11):** Script emite 15 linhas de progresso sem flag `-v`.
    - ⚠️ **Regra da Composição (Regra 3):** Códigos ANSI emitidos mesmo quando `stdout` é redirecionado para pipe.
    - ⚠️ **Regra da Soberania do Usuário (Regra 18):** Invocação direta de `sudo` sem checagem de `doas`.
- **Ações Corretivas Propostas:**
    1. Envolver saídas visuais sob verificação `[ -t 1 ]`.
    2. Implementar variável `${ELEVATE}` para abstração de privilégios.
```

---

## 📚 Literatura de Referência & Leitura Altamente Recomendada

Recomenda-se enfaticamente ao agente de IA e aos operadores o estudo aprofundado das obras canônicas que fundamentam esta habilidade:

- **Obra Canônica Principal:** _The Art of UNIX Programming_ (Eric S. Raymond, 2003, Addison-Wesley Professional).
    - Portal da obra: <http://www.catb.org/~esr/writings/taoup/> | Texto integral aberto: <http://www.catb.org/~esr/writings/taoup/html/>
    - Trata da filosofia de design, modularidade, transparência, silêncio e separação entre mecanismos e políticas.
- **The Open Group (Padrão POSIX IEEE 1003.1):**
    - Portal oficial: <https://www.opengroup.org/> | Especificações e manuais oficiais: <https://pubs.opengroup.org/onlinepubs/9699919799/>
