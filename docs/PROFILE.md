# 🎨 O Repositório Profile (Identidade, Dotfiles & IA)

> Arquitetura detalhada, organização de dotfiles e camada cognitiva do repositório **Profile**.

---

## 🎯 Visão Geral

O repositório **[Profile](https://github.com/GabrielFrigo4/profile)** é o santuário de configurações do usuário. Ele é projetado para operar com **zero privilégios de sistema (`zero-sudo`)** e viver residente no `$HOME`.

### Camadas de Responsabilidade:

1. **[`software/`](../software/README.md):** Arquivos declarativos puros (`settings.json`, `.clang-format`, `.stylua.toml`, `config.nu`).
2. **[`skills/`](../skills/README.md):** Runbooks e habilidades portáteis de IA (`SKILL.md` com YAML Frontmatter) para assistentes autônomos.
3. **[`scripts/sync/`](../scripts/README.md):** Automações defensivas para criar links simbólicos atômicos (`ln -sf`).

---

## 🔄 Modo de Sincronização Dinâmica

Para manter seus editores e formatadores sempre atualizados:

```sh
# Clone no diretório de configuração do usuário
git clone "https://github.com/GabrielFrigo4/profile" "${HOME}/.config/profile"
cd "${HOME}/.config/profile"

# Execute a sincronização via symlinks
./scripts/sync/sync-dotfiles.sh
./scripts/sync/sync-skills.sh
```

Qualquer alteração futura no repositório através de `git pull` refletirá imediatamente em todos os seus aplicativos sem necessidade de reconfiguração manual.
