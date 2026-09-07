# 🐂 GNU Emacs Minimal Configuration

> Configuração leve e rápida (`lite.el`) para GNU Emacs sem frameworks pesados.

---

## 🎯 Finalidade

Este diretório provê uma configuração minimalista, rápida e autocontida para o **GNU Emacs**, focada em inicialização instantânea, edição de texto eficiente e compatibilidade multiplataforma (Linux, FreeBSD, macOS e Windows).

---

## 📂 Catálogo de Arquivos

| Arquivo | Tipo | Descrição |
| :--- | :--- | :--- |
| [`lite.el`](lite.el) | Elisp Declarativo | Configuração enxuta de interface, modos básicos e navegação |

---

## 🚀 Como Usar / Sincronizar

### Linux & FreeBSD:
```sh
mkdir -p "${HOME}/.emacs.d"
ln -sf "$(pwd)/lite.el" "${HOME}/.emacs.d/init.el"
```

### Windows (PowerShell):
```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.emacs.d"
New-Item -ItemType SymbolicLink -Force -Path "$env:USERPROFILE\.emacs.d\init.el" -Target "$((Get-Location).Path)\lite.el"
```
