# 📊 Diagramação Visual com Mermaid

Markdown moderno no ecossistema deve priorizar diagramas Mermaid dinâmicos em cercaduras `mermaid` em vez de imagens rasterizadas (PNG/JPG), permitindo versionamento por texto e rastreamento claro em `git diff`.

---

## 🏛️ Arquitetura Hierárquica Híbrida (`flowchart TD` + Cards Horizontais)

Para evitar grafos excessivamente longos verticalmente ou largos horizontalmente, combine um fluxo macro top-down com subgrafos contendo elos invisíveis (`~~~`):

```mermaid
flowchart TD
    subgraph CAMADA1 ["🖥️ 1. Plataformas de Execução"]
        direction LR
        FBD["FreeBSD"]
        LNX["Linux"]
        WIN["Windows"]
        FBD ~~~ LNX ~~~ WIN
    end

    subgraph CAMADA2 ["⚙️ 2. Ambientes de Runtime"]
        direction LR
        CLI["CLI / Terminal"]
        GUI["Wayland / PGTK"]
        CLI ~~~ GUI
    end

    CAMADA1 ==> CAMADA2
```

---

## 🔄 Diagramas de Sequência (`sequenceDiagram`)

Para documentar ciclos de inicialização, sourcing de variáveis e handshakes de segurança:

```mermaid
sequenceDiagram
    autonumber
    actor Dev as Desenvolvedor
    participant Sh as Shell Interativo
    participant V as Vault (Segredos)

    Dev->>Sh: Executa login / novo terminal
    Sh->>V: Inspeciona cofre em ~/.vault
    V-->>Sh: Exporta chaves SSH silenciosamente
```

---

## 📐 Hierarquia Universal de 3 Camadas & Escolha Estrutural

1. **Diagrama Declarativo Primeiro:** O código que vira vetor (**Mermaid**) precede ilustrações vetoriais diretas (**SVG**), que por sua vez precedem arte em texto (**ASCII**).
2. **Clareza e Geometria, Nunca por Tema:** A decisão entre Mermaid, SVG ou ASCII é estritamente de estética, clareza, sintaxe e proporcionalidade espacial — nunca por divisões temáticas arbitrárias.
3. **Papel da ASCII Art:** Recurso alternativo especializado para matrizes densas de bitfields (`0b0010_1100`) ou quando o alinhamento monoespaçado for estritamente insubstituível.
4. **Proporção Harmônica (~16:9, ~4:3 ou ~2:1):** Evite cadeias horizontais longas (> 3–4 nós contínuos) ou verticais excessivas (> 4–5 nós). Prefira fluxo vertical macro (`flowchart TD`) com subgrupos horizontais (`direction LR` e elos invisíveis `~~~`).
5. **Prevenção de Colisão Aresta-Título:** Arestas externas nunca devem conectar diretamente ao nó de topo de um subgrafo. Conecte contêiner a contêiner (`SUBGRAPH1 ==> SUBGRAPH2`), ou modele estágios como nós independentes.

---

## ⚠️ Prevenção de Erros de Sintaxe no Mermaid

1. **Aspas em Rótulos:** Sempre coloque aspas em rótulos que contenham caracteres especiais como parênteses ou colchetes: `id["Nodo (Detalhe)"]`.
2. **Sem Tags HTML:** Evite tags HTML (`<br>`, `<b>`) dentro dos nós; utilize Markdown Strings nativas (`["`...`"]`) para quebras (`\n`) e formatação rica nos nós.
3. **Tipos Suportados:** Utilize `flowchart TD/LR`, `sequenceDiagram`, `stateDiagram-v2`, `classDiagram` ou tabelas Markdown nativas. Evite diagramas de Gantt ou tipos não-universais.
4. **Títulos de Subgrafos em Linha Única Sem Crases:** Títulos de `subgraph` DEVEM utilizar aspas convencionais em linha única (`subgraph ID["Título"]`), nunca Markdown Strings com crases (`["`...`"]`). O Mermaid limita clusters a 200px na renderização markdown, gerando quebras artificiais de linha com desalinhamento à esquerda no PDF.
5. **Contenção Geométrica de Títulos de Subgrafos:** O motor Dagre calcula a largura da caixa do subgrafo exclusivamente pelos nós filhos. O título nunca deve exceder visualmente a largura dos nós internos para não vazar a borda da caixa. Reduza o título ou alargue os nós filhos (em 2 linhas descritivas).
6. **Setas com Rótulos de Comprimento 3:** Sempre use `--->|"Rótulo"|`, `-..->`, `===>` ou `<--->` para arestas com texto, reservando espaço no rank para o badge branco protetor.
7. **Padronização de Cartões (Título em Negrito + Conteúdo em Bullets `•`):** Em nós com estrutura hierárquica (título/identificador acompanhado de descrição, atributos ou especificações técnicas), o título DEVE estar estritamente em negrito (`**Título**`) e cada linha subsequente DEVE iniciar obrigatoriamente com o marcador bullet (`• `). Nós conceituais simples/atômicos (sem lista descritiva) não devem utilizar bullets. Toda quebra e formatação deve utilizar Markdown Strings (`["`...`"]`).
8. **Taxonomia Semântica de Operadores de Arestas:** Use setas grossas (`===>` / `==>`) **ESTRITAMENTE E EXCLUSIVAMENTE** para conexões entre contêineres/subgrafos (`SUBGRAPH1 ===> SUBGRAPH2`). É categoricamente proibido utilizar setas grossas entre nós normais. Use setas sólidas padrão (`--->` / `-->`) para conexões sequenciais ordinárias entre nós. Use setas tracejadas (`-..->` / `-.->`) para dependências fracas, fluxos opcionais, canais assíncronos ou fallbacks.
9. **Prevenção do Bug de Listas Ordenadas (`htmlLabels: false` / Vetor Puro):** Quando o Mermaid renderiza em vetor nativo (`"htmlLabels": false`), linhas iniciadas por número seguido de ponto e espaço (`1. `, `2. `) são capturadas pelo parser Markdown como itens de lista e descartadas silenciosamente, gerando tags `<text>` vazias (`<text></text>`). Para evitar:
    - **Escapar o ponto (recomendado):** Use barra invertida: `["`1\. Input Assembler`"]`.
    - **Mudar delimitador numérico:** Use colchetes ou hífen: `["`[1] Input Assembler`"]` ou `["`1 - Input Assembler`"]`.
    - **Encapsular em negrito:** Envolva o marcador: `["`**1.** Input Assembler`"]`.

---

## 🎨 Diretrizes para Vetores SVG & Pós-Processamento

1. **Ilustrações Locais Embutidas:** Vetores geométricos devem residir como arquivos locais embutidos, garantindo portabilidade sem dependências remotas de rede.
2. **Zero Comentários em SVGs:** Arquivos vetoriais SVG e nós gráficos não devem conter comentários (`<!-- ... -->`).
3. **Pós-processamento Antifrágil de SVGs:**
    - **Atributos pelo Nome:** Extraia e manipule atributos XML pelo nome, nunca por posição ou índice ordinal.
    - **Falha Graciosa:** Se um atributo faltar ou a estrutura mudar, devolva o bloco original intacto ("sem ajuste fino", nunca "documento quebrado").
    - **Ajustes Finos Isolados e Nomeados:** Correções específicas devem ser funções atômicas e nomeadas (centralização ótica, snap de bordas, badges).
