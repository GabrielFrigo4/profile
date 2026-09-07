# 🟢 Vim / Neovim Minimal Configuration

> Configuração leve e pura (`lite.vim`) para Vim e Neovim sem dependências externas.

---

## 🎯 Finalidade

Este diretório provê uma configuração canônica e essencial para o **Vim** e **Neovim**, habilitando numeração de linhas, busca inteligente, indentação consistente de código e cores limpas sem plugins pesados.

---

## 📂 Catálogo de Arquivos

| Arquivo | Tipo | Descrição |
| :--- | :--- | :--- |
| [`lite.vim`](lite.vim) | Vimscript Declarativo | Configuração enxuta e portátil de comportamento do editor |

---

## 🚀 Como Usar / Sincronizar

### Linux & FreeBSD:
```sh
ln -sf "$(pwd)/lite.vim" "${HOME}/.vimrc"
mkdir -p "${HOME}/.config/nvim"
ln -sf "$(pwd)/lite.vim" "${HOME}/.config/nvim/init.vim"
```

### Windows:
```powershell
New-Item -ItemType SymbolicLink -Force -Path "$env:USERPROFILE\_vimrc" -Target "$((Get-Location).Path)\lite.vim"
```
