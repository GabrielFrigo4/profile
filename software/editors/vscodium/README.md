# 🛡️ VSCodium Configuration

> Configuração para o binário livre de telemetria VSCodium.

---

## 🎯 Finalidade

Este diretório mantém os parâmetros de configuração e extensões compatíveis com o **VSCodium** (versão 100% open-source do VS Code compilada sem rastreadores proprietários da Microsoft).

---

## 📂 Catálogo de Arquivos

| Arquivo | Tipo | Descrição |
| :--- | :--- | :--- |
| [`settings.json`](settings.json) | Declaração JSON | Preferências de interface e linters para VSCodium |
| [`extensions.txt`](extensions.txt) | Lista Declarativa | Catálogo de extensões compatíveis com o Open VSX Registry |

---

## 🚀 Como Usar / Sincronizar

### Linux & FreeBSD:
```sh
mkdir -p "${HOME}/.config/VSCodium/User"
ln -sf "$(pwd)/settings.json" "${HOME}/.config/VSCodium/User/settings.json"
```

### Windows (PowerShell):
```powershell
New-Item -ItemType Directory -Force -Path "$env:APPDATA\VSCodium\User"
New-Item -ItemType SymbolicLink -Force -Path "$env:APPDATA\VSCodium\User\settings.json" -Target "$((Get-Location).Path)\settings.json"
```
