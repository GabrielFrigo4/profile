# 🦀 NuShell Configuration

> Configurações declarativas para o shell moderno baseado em pipelines estruturados NuShell.

---

## 🎯 Finalidade

Este diretório contém os arquivos de configuração do **NuShell**, definindo variáveis de ambiente, aliases, temas e integração com o Vault (`vault.nu`).

---

## 📂 Catálogo de Arquivos

| Arquivo | Tipo | Descrição |
| :--- | :--- | :--- |
| [`config.nu`](config.nu) | NuScript Declarativo | Configuração de atalhos, tabelas e temas do NuShell |
| [`env.nu`](env.nu) | NuScript Declarativo | Variáveis de ambiente e carregamento do ecossistema |
| [`nushell.nu`](nushell.nu) | NuScript | Utilitários complementares de pipeline |

---

## 🚀 Como Usar / Sincronizar

### Linux, FreeBSD & macOS:
```sh
mkdir -p "${HOME}/.config/nushell"
ln -sf "$(pwd)/config.nu" "${HOME}/.config/nushell/config.nu"
ln -sf "$(pwd)/env.nu" "${HOME}/.config/nushell/env.nu"
```

### Windows (PowerShell):
```powershell
New-Item -ItemType Directory -Force -Path "$env:APPDATA\nushell"
New-Item -ItemType SymbolicLink -Force -Path "$env:APPDATA\nushell\config.nu" -Target "$((Get-Location).Path)\config.nu"
New-Item -ItemType SymbolicLink -Force -Path "$env:APPDATA\nushell\env.nu" -Target "$((Get-Location).Path)\env.nu"
```
