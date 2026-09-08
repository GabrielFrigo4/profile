# 🖥️ KDE Konsole Terminal Profiles

> Perfis de terminal para o Konsole no KDE Plasma (FreeBSD e Linux).

---

## 🎯 Finalidade

Este diretório provê perfis declarativos para o **Konsole** do KDE Plasma, configurando fontes monospace com Nerd Fonts, esquema de cores suave e comandos padrão para Bash, Zsh e FreeBSD `/bin/sh`.

---

## 📂 Catálogo de Arquivos

| Arquivo                          | Tipo       | Descrição                                              |
| :------------------------------- | :--------- | :----------------------------------------------------- |
| [`Bash.profile`](Bash.profile)   | Perfil KDE | Configuração de sessão inicializando o Bash            |
| [`Zsh.profile`](Zsh.profile)     | Perfil KDE | Configuração de sessão inicializando o Zsh             |
| [`Shell.profile`](Shell.profile) | Perfil KDE | Configuração de sessão inicializando o Universal Shell |

---

## 🚀 Como Usar / Sincronizar

### FreeBSD & Linux:

```sh
mkdir -p "${HOME}/.local/share/konsole"
ln -sf "$(pwd)/"*.profile "${HOME}/.local/share/konsole/"
```
