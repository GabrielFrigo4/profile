# 📜 Princípios de Engenharia & Filosofia do Repositório (Profile)

> _"Rule of Representation: Fold knowledge into data so program logic can be stupid and robust."_<br>
> — Eric S. Raymond, _The Art of UNIX Programming_ (2003)

O repositório **Universal Profile Environment** é o pilar de identidade declarativa, dotfiles e inteligência artificial do **Quarteto de Produtividade** (`Setup`, `Profile`, `Shell`, `Vault`). Ele centraliza as preferências estáticas dos editores de código, perfis de emuladores de terminal, formatadores universais e runbooks cognitivos de IA para execução no espaço do usuário (`$HOME`).

Para garantir elegância, reprodutibilidade e portabilidade sem fricção, toda contribuição neste repositório deve obedecer aos **18 Princípios de Engenharia** (17 Princípios UNIX + Regra da Soberania do Usuário) e às normas de **Clean Code** adaptadas a dotfiles e engenharia de contexto para IA.

---

## 🏛️ Os 18 Princípios de Design (17 Princípios UNIX + Soberania do Usuário)

### 1. Regra da Modularidade (_Rule of Modularity_)

> _Escreva partes simples conectadas por interfaces limpas._

- A pasta `editors/` contém configurações autocontidas por editor (Antigravity, VS Code, VSCodium, Zed, Emacs, Vim). Ajustar um editor nunca afeta os demais.
- Cada skill de IA em `skills/` é autocontida e independente.

### 2. Regra da Clareza (_Rule of Clarity_)

> _Clareza é melhor que esperteza._

- Arquivos de configuração priorizam formatos padronizados pela indústria (JSON, TOML, YAML) sem truques obscuros.
- Scripts de sincronização em `scripts/sync/` são curtos, transparentes e defensivos.

### 3. Regra da Composição (_Rule of Composition_)

> _Projete programas para serem conectados a outros programas._

- Linters globais (`.clang-format`, `.prettierrc`, `.stylua.toml`) compõem diretamente com os formatadores de IDEs e pipelines de CI/CD.

### 4. Regra da Separação (_Rule of Separation_)

> _Separe a política do mecanismo; separe o motor da interface._

- **Mecanismo (`Setup`):** Scripts que instalam pacotes no sistema operacional (`dnf`, `pkg`, `winget`).
- **Política (`Profile`):** Arquivos declarativos puros (`settings.json`, `config.nu`, `.clang-format`) que definem _o que_ deve ser configurado no espaço do usuário.

### 5. Regra da Simplicidade (_Rule of Simplicity_)

> _Projete para a simplicidade; adicione complexidade apenas onde estritamente necessário._

- Sem gerenciadores de dotfiles pesados ou dependências de terceiros; sincronização direta via links simbólicos (`ln -sf`) nativos do sistema operacional.

### 6. Regra da Parcimônia (_Rule of Parsimony_)

> _Escreva um programa grande apenas quando estiver claro por demonstração que nada mais resolverá._

- Cada dotfile contém apenas os ajustes que realmente alteram o comportamento padrão para melhorar a ergonomia. Evite duplicar configurações padrão redundantes.

### 7. Regra da Transparência (_Rule of Transparency_)

> _Projete para a visibilidade para tornar inspeção e depuração fáceis._

- Todos os arquivos usam formatos de texto legíveis por humanos. A inspeção de qualquer configuração é imediata.

### 8. Regra da Robustez (_Rule of Robustness_)

> _A robustez é filha da transparência e da simplicidade._

- Scripts de sincronização verificam a existência dos diretórios de destino antes de criar links (`mkdir -p`), evitando falhas silenciosas.

### 9. Regra da Representação (_Rule of Representation_)

> _Dobre o conhecimento em dados para que a lógica do programa possa ser estúpida e robusta._

- Configurações são puramente declarativas. O comportamento do editor é determinado por dados estruturados, e não por lógica procedural complexa.

### 10. Regra do Menor Espanto (_Rule of Least Surprise_)

> _No design de interfaces, sempre faça a coisa menos surpreendente._

- Seguir estritamente o padrão **XDG Base Directory** (`~/.config/`, `~/.local/share/`).
- Nada de poluir a raiz de `$HOME` com diretórios fora do padrão da indústria.

### 11. Regra do Silêncio (_Rule of Silence_)

> _Quando um programa não tem nada surpreendente a dizer, ele não deve dizer nada._

- Scripts de sincronização devem rodar de forma limpa, emitindo mensagens objetivas apenas sobre o que foi linkado.

### 12. Regra do Reparo (_Rule of Repair_)

> _Quando você precisar falhar, falhe ruidosamente e o mais rápido possível._

- Se um formato JSON ou YAML contiver erro de sintaxe, o pre-commit hook aborta imediatamente com a linha do erro.

### 13. Regra da Economia (_Rule of Economy_)

> _O tempo do programador é caro; economize-o em preferência ao tempo da máquina._

- Com um único comando (`./scripts/sync/sync-dotfiles.sh`), todos os seus editores, fontes e formatadores são configurados de uma só vez.

### 14. Regra da Geração (_Rule of Generation_)

> _Evite codificação manual; escreva programas para escrever programas quando puder._

- Listas declarativas de extensões (`extensions.txt`) consumidas por automações para reconstruir ambientes em segundos.

### 15. Regra da Otimização (_Rule of Optimization_)

> _Prototipe antes de polir. Faça funcionar antes de otimizar._

- Garanta que as configurações funcionem com estabilidade antes de tentar agrupar formatos.

### 16. Regra da Diversidade (_Rule of Diversity_)

> _Desconfie de todas as afirmações de "uma única maneira verdadeira"._

- Suporte a múltiplos editores modernos com a mesma identidade visual e rigor:
    - Antigravity / VS Code / VSCodium
    - Zed
    - GNU Emacs
    - Vim / Neovim

### 17. Regra da Extensibilidade (_Rule of Extensibility_)

> _Projete para o futuro, porque ele chegará antes do que você imagina._

- A adição de um novo editor em `editors/` ou de uma nova skill em `skills/` é 100% plugável sem alterar os demais componentes.

### 18. Regra da Soberania do Usuário (_Rule of User Sovereignty_)

> _Honre a escolha explícita e deliberada do usuário antes de impor padrões genéricos._

- **Não-Destrutividade:** Scripts de sincronização preservam arquivos de configuração existentes criando backups quando necessário, em vez de sobrescrever silenciosamente preferências do desenvolvedor.
- **Liberdade de Escolha de Ferramenta:** Cada desenvolvedor pode escolher trabalhar com Helix, Zed, Emacs ou VS Code; o ecossistema provê equivalência de formatação e linters em todos eles.

---

## 🧼 Clean Code & Padrões para Dotfiles e IA

### 1. Formatos Declarativos Puros

- `.json` e `.jsonc` com 2 espaços de indentação.
- `.yaml` e `.yml` limpos e padronizados.
- `.toml` estruturado por seções.
- Comentários narrativos triviais são proibidos.

### 2. Permissões Canônicas em 4 Dígitos Octais

- `chmod 0755` para diretórios e scripts executáveis (`scripts/sync/*.sh`).
- `chmod 0644` para arquivos de configuração, dotfiles e arquivos Markdown.

### 3. Progressive Disclosure para Skills de IA

- Cada skill em `skills/` deve conter:
    - Cabeçalho `YAML Frontmatter` conciso (`name` e `description` clara em terceira pessoa para ativação sob demanda).
    - `SKILL.md` direto e objetivo, sem desperdício de tokens de contexto.

### 4. Isolamento Absoluto de Segredos (Zero Secrets in Public Git)

- O repositório `Profile` é 100% público. NUNCA comite tokens, senhas, chaves privadas ou dados pessoais. Todos os segredos pertencem exclusivamente ao `Vault`.

### 5. Orçamento de Linhas (Regra 8 - 128)

- Scripts de sincronização e automação não devem possuir menos de 8 linhas nem ultrapassar 128 linhas úteis (evitar monólitos e manter coesão temática).
