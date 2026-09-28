# 🔤 Tipografia, Semântica e Acessibilidade em Markdown

Documentos técnicos devem ser visualmente limpos, confortáveis para longas leituras e livres de ambiguidades para parsers e leitores de tela.

---

## 💻 Identificadores Canônicos de Blocos de Código

- **Padrão Universal `sh`:** Todo bloco de comandos de terminal, clonagem git, chamadas de build (`make`) e comandos de pacotes (`pkg`, `apt`) deve usar `sh`:
    ````markdown
    ```sh
    git clone "https://github.com/GabrielFrigo4/environment.git"
    make install
    ```
    ````
- **Proibições:** Nunca use `shell`, `console`, `terminal` ou `prompt`.
- **Identificadores Específicos:** Use `zsh`, `bash`, `fish`, `pwsh`, `nu`, `lua`, `elisp`, `toml`, `json`, `yaml`, `make` exclusivamente quando o código exigir a sintaxe ou interpretador daquela linguagem específica.

---

## 📊 Alinhamento de Tabelas Markdown

- `:---` (Alinhamento à esquerda): Descrições, textos explicativos, nomes de ferramentas e caminhos de arquivo.
- `:---:` (Alinhamento central): Status, emojis, flags booleanas, versões curtas e ícones.
- `---:` (Alinhamento à direita): Números, latências de benchmarks e tamanhos em bytes.

```markdown
| Ferramenta | Status | Latência |
| :--------- | :----: | -------: |
| Prompt     |   ✅   |     12ms |
| Sync       |   ✅   |     45ms |
```

---

## 🚨 Admonitions Semânticas do GitHub Flavored Markdown (GFM)

Use as caixas de alerta padrão do GitHub:

- `> [!NOTE]` — Contexto de fundo, detalhes de implementação ou notas conceituais.
- `> [!TIP]` — Dicas de produtividade, otimizações de performance ou atalhos.
- `> [!IMPORTANT]` — Requisitos obrigatórios e invariantes que não podem ser violadas.
- `> [!WARNING]` — Advertências de quebra de compatibilidade ou requisitos essenciais.
- `> [!CAUTION]` — Ações de alto risco, perigo de perda de dados ou impacto em segredos.

Evite colocar múltiplos alertas de forma consecutiva sem parágrafos intermediários.

---

## 🛡️ Proteção de Links e Acessibilidade

1. **URLs com Parênteses:** Sempre envolva a URL em colchetes angulares `<...>` caso o link possua parênteses:
    ```markdown
    [MSYS2](<https://img.shields.io/badge/Windows_(MSYS2)-Supported-purple>)
    ```
2. **Textos Alternativos:** Sempre preencha o `alt` em imagens (`![Diagrama de Arquitetura](https://example.com/diagram.png)`) para leitores de tela.
