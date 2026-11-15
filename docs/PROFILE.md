# 🎨 O Repositório Profile (Identidade, Dotfiles & IA)

> Arquitetura detalhada, organização de dotfiles e camada cognitiva do repositório **Profile**.

---

## 🎯 Visão Geral

O repositório **[Profile](https://github.com/GabrielFrigo4/profile)** é o santuário de configurações do usuário. Ele é projetado para operar com **zero privilégios de sistema (`zero-sudo`)** e viver residente no `$HOME`.

### Camadas de Responsabilidade:

1. **[`desktop/`](../desktop/):** Templates adaptativos GTK 3/4 (light/dark por DE), CSS com preservação de cantos arredondados CSD e atalhos `.desktop` em [`desktop/applications/`](../desktop/applications/) sincronizados para `~/.local/share/applications/`.
2. **[`editors/`](../editors/README.md), [`terminals/`](../terminals/README.md), [`tools/`](../tools/README.md):** Arquivos declarativos puros (`settings.json`, `.clang-format`, `.stylua.toml`, `foot.ini`).
3. **[`agents/`](../agents/README.md):** Runbooks de IA (`skills/`) e regras transversais de governança (`rules/`) para assistentes autônomos.
4. **[`profile.sh`](../profile.sh):** Interface unificada de componente para sincronização atômica (`profile.sh sync`), testes e auditoria.

---

## 🔄 Modo de Sincronização Dinâmica

Para manter seus editores, atalhos XDG e formatadores sempre atualizados:

```sh
git clone "https://github.com/GabrielFrigo4/profile" "${HOME}/.local/share/profile"
cd "${HOME}/.local/share/profile"

sh profile.sh sync
```

Qualquer alteração futura no repositório através de `git pull` refletirá imediatamente em todos os seus aplicativos sem necessidade de reconfiguração manual.
