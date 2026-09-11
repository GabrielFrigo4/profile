# 📜 Princípios de Engenharia & Filosofia do Universal Profile

> _"Rule of Separation: Separate policy from mechanism; separate engine from interface."_<br>
> — Eric S. Raymond, _The Art of UNIX Programming_ (2003)

O **Profile** é o repositório de estado declarativo de usuário e catálogo central de habilidades de IA do **Quarteto de Produtividade** (`Setup`, `Shell`, `Vault`, `Profile`), orquestrado pelo ecossistema **[Environment](https://github.com/GabrielFrigo4/environment)**. Ele é responsável por definir _o que_ deve existir configurado no espaço do usuário (`$HOME`), mantendo dotfiles estáticos de editores, navegadores, terminais, formatadores e runbooks cognitivos para agentes autônomos.

> [!IMPORTANT]
> **A Regra de Ouro do Agente de IA:** Ao entrar em qualquer diretório de repositório, o agente DEVE SEMPRE ler os arquivos `AGENTS.md`, `PRINCIPLES.md` e `.agents/` daquele repositório antes de realizar qualquer alteração.

---

## 🏛️ Os 18 Princípios de Design (17 Princípios UNIX + Soberania do Usuário)

### 1. Regra da Modularidade (_Rule of Modularity_)

> _Escreva partes simples conectadas por interfaces limpas._

- As configurações são particionadas por domínios funcionais limpos:
    - `editors/`: Configurações de VS Code, Zed e editores gráficos.
    - `terminals/`: Configurações de emuladores de terminal (Ghostty, Alacritty, Kitty, WezTerm).
    - `browsers/`: Preferências de navegadores (Brave, Firefox, Chrome).
    - `tools/`: Formatadores e linters globais (`.clang-format`, `.stylua.toml`, `prettier`).
    - `skills/`: Habilidades e runbooks cognitivos portáteis para agentes de IA.

### 2. Regra da Clareza (_Rule of Clarity_)

> _Clareza é melhor que esperteza._

- Arquivos de configuração são mantidos em seus formatos nativos declarativos (`.json`, `.toml`, `.yaml`, `.el`, `.vim`), evitando linguagens de template dinâmicas ou camadas obscuras de interpolação.

### 3. Regra da Composição (_Rule of Composition_)

> _Projete programas para serem conectados a outros programas._

- Scripts de sincronização (`sync-dotfiles.sh`, `sync-skills.sh`) operam via links simbólicos idempotentes (`ln -sf`), permitindo que as ferramentas leiam seus arquivos de configuração originais em tempo real.

### 4. Regra da Separação (_Rule of Separation_)

> _Separe a política do mecanismo; separe o motor da interface._

- **Política Pura:** O Profile define _o que_ deve ser configurado (arquivos estáticos e dotfiles). Ele nunca instala binários ou mexe no sistema operacional (responsabilidade do **Setup**).

### 5. Regra da Simplicidade (_Rule of Simplicity_)

> _Projete para a simplicidade; adicione complexidade apenas onde estritamente necessário._

- **Zero Sudo / Zero Root:** O Profile opera exclusivamente no espaço do usuário comum (`$HOME`). Nenhuma operação neste repositório requer privilégios de administrador.

### 6. Regra da Parcimônia (_Rule of Parsimony_)

> _Escreva um programa grande apenas quando estiver claro por demonstração que nada mais resolverá._

- Mantemos apenas as configurações que realmente alteram a experiência padrão para melhor, descartando opções redundantes com os padrões das aplicações.

### 7. Regra da Transparência (_Rule of Transparency_)

> _Projete para a visibilidade para tornar inspeção e depuração fáceis._

- Estrutura espelhada do `$HOME` e da pasta de configuração padrão (`~/.config/`).

### 8. Regra da Robustez (_Rule of Robustness_)

> _A robustez é filha da transparência e da simplicidade._

- Scripts de sincronização criam diretórios pais automaticamente e realizam backups defensivos antes de sobrescrever arquivos preexistentes.

### 9. Regra da Representação (_Rule of Representation_)

> _Dobre o conhecimento em dados para que a lógica do programa possa ser estúpida e robusta._

- Tabelas declarativas de extensões e configurações substituem rotinas procedurais imperativas.

### 10. Regra do Menor Espanto (_Rule of Least Surprise_)

> _No design de interfaces, sempre faça a coisa menos surpreendente._

- Respeito estrito às especificações XDG Base Directory (`~/.config`, `~/.local/share`).

### 11. Regra do Silêncio (_Rule of Silence_)

> _Quando um programa não tem nada surpreendente a dizer, ele não deve dizer nada._

- Scripts de auditoria e sincronização informam de forma concisa apenas o progresso real e falhas.

### 12. Regra do Reparo (_Rule of Repair_)

> _Quando você precisar falhar, falhe ruidosamente e o mais rápido possível._

- Erros de sintaxe em JSON/TOML ou links simbólicos quebrados são detectados na auditoria (`make audit`) antes do commit.

### 13. Regra da Economia (_Rule of Economy_)

> _O tempo do programador é caro; economize-o em preferência ao tempo da máquina._

- Replicar um ambiente de desenvolvimento completo em uma máquina recém-instalada exige apenas `make sync`.

### 14. Regra da Geração (_Rule of Generation_)

> _Evite codificação manual; escreva programas para escrever programas quando puder._

- Scripts de exportação automática de listas de extensões instaladas.

### 15. Regra da Otimização (_Rule of Optimization_)

> _Prototipe antes de polir. Faça funcionar antes de otimizar._

- Manter temas e fontes leves para evitar latência em editores e terminais.

### 16. Regra da Diversidade (_Rule of Diversity_)

> _Desconfie de todas as afirmações de "uma única maneira verdadeira"._

- Suporte a múltiplos editores (Helix, NeoVim, Vim, Emacs, VS Code, Zed) e plataformas (FreeBSD, Linux, macOS, Windows).

### 17. Regra da Extensibilidade (_Rule of Extensibility_)

> _Projete para o futuro, porque ele chegará antes do que você imagina._

- A pasta `skills/` permite plugar novos runbooks e procedimentos cognitivos para qualquer IA do ecossistema.

### 18. Regra da Soberania do Usuário (_Rule of User Sovereignty_)

> _Honre a escolha explícita e deliberada do usuário antes de impor padrões genéricos._

- Dotfiles locais não-versionados (`*.local`) sempre têm precedência sobre os defaults do repositório.

---

## 🧼 Princípios de Clean Code para o Profile

1. **Shebang Universal:** `#!/usr/bin/env sh` para scripts em `scripts/`.
2. **Quoting Defensivo & Variáveis:** Sempre `"${VAR}"` e redirecionamentos `> "/dev/null"`.
3. **Taxonomia de Emissão:** `echo` para mensagens, `printf` para relatórios, `echo -n $'\e...'` para ANSI.
4. **Permissões Canônicas:** `chmod 0755` para scripts de sincronização, `chmod 0644` para dotfiles estáticos.
5. **Arquitetura de Comentários (A Tríade Sem Vazamento):**
    - Header Banner: 64 hífens (`# ----------------------------------------------------------------`).
    - Delimitadores Estruturais: 32 caracteres (`### ================================` e `### --------------------------------`). Título $\le$ 32 caracteres.
    - Zero comentários explicativos no código.
