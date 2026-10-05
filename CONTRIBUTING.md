# 🤝 Guia de Contribuição — Universal Profile

> Diretrizes de desenvolvimento, setup inicial da bancada, sincronização de dotfiles e quality gates para o **Universal Profile**.

---

## 🚀 Setup Inicial da Bancada (Primeiros Passos)

Para clonar e configurar o repositório localmente com ganchos e quality gates ativados:

```sh
# 1. Clonar o repositório
git clone "https://github.com/GabrielFrigo4/profile.git" "${HOME}/Documents/Profile"
cd "${HOME}/Documents/Profile"

# 2. Configurar ganchos Git e permissões canônicas
make hooks

# 3. Validar a sintaxe POSIX dos scripts utilitários
make test

# 4. Executar a suíte de auditoria estática (JSON/YAML/TOML/links)
make audit
```

> [!IMPORTANT]
> O comando `make hooks` configura `core.hooksPath -> .githooks` e aplica permissões canônicas `0755` aos ganchos de pre-commit e commit-msg. Execute-o sempre após um novo clone.

---

## 🛡️ Invariantes de Engenharia no Profile

1. **Separação Rigorosa Política vs. Mecanismo:**
    - O Profile armazena exclusivamente **política declarativa** (configurações puras de editores, perfis de terminal, linters e skills).
    - O mecanismo de aplicação (`profile.sh`) opera com idempotência estrita sem privilégios administrativos (`$HOME`).

2. **Invariante de Clonagem "Out-of-the-Box" (Zero-Tweaks Invariant):**
    - Scripts executáveis (`profile.sh`, `install.sh`, `.scripts/audit/*.py`) e ganchos Git devem ter modo canônico `100755` no Git Index.
    - Dotfiles, templates, arquivos de configuração (`.json`, `.toml`, `.yaml`) e skills devem ter modo `100644`.
    - Se cometer um erro de modo no Git Index, corrija com:
        ```sh
        git update-index --chmod=+x caminho/script.sh
        git update-index --chmod=-x caminho/config.json
        ```

3. **Governança XDG Base Directory:**
    - Resolução de caminhos respeita as especificações XDG (`$XDG_CONFIG_HOME`, `$XDG_DATA_HOME`).
    - Todos os symlinks e cópias garantem diretórios-pai defensivamente via `mkdir -p`.

4. **Portabilidade Multiplataforma:**
    - Paridade ergonômica entre Linux, FreeBSD, macOS e Windows (PowerShell, NuShell, CMD/Clink).

---

## 🪝 Quality Gates & Validação Local

O repositório possui uma bateria completa de testes e auditorias:

```sh
make test     # Valida sintaxe POSIX (sh -n)
make audit    # Executa a suíte Python de formatos, banners e integridade
make sync     # Sincroniza dotfiles com o sistema hospedeiro
make ci       # Executa bateria completa de CI local
```

Ganchos Git em `.githooks/`:

- **`pre-commit`:** Verifica whitespace, modos octais no Git Index (0755 vs 0644), sintaxe de shell, auditoria de formatos e Prettier.
- **`commit-msg`:** Valida formato semântico da mensagem de commit.

---

## 📝 Convenção de Commits Semânticos

As mensagens de commit devem seguir o formato:

```text
<tipo>(<escopo>): <descrição objetiva>
```

Tipos permitidos: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `ci`, `chore`.

---

## 📖 Referências Canônicas

- [README.md](README.md) — Visão geral e catálogo de configurações
- [PRINCIPLES.md](PRINCIPLES.md) — Princípios de Engenharia e Clean Code
- [AGENTS.md](AGENTS.md) — Briefing para agentes autônomos de IA
- [TODO.md](TODO.md) — Roadmap operacional do Profile
