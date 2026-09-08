# 💻 Visual Studio Code Configuration

> Configuração estática de preferências de usuário, telemetria desativada e catálogo de extensões do VS Code.

---

## 🎯 Finalidade

Este diretório centraliza o arquivo canônico `settings.json` e o manifesto `extensions.txt` para o **Visual Studio Code**, garantindo formatação automática ao salvar, linters globais, fontes com ligaduras e telemetria estritamente bloqueada.

---

## 📂 Catálogo de Arquivos

| Arquivo                            | Tipo              | Descrição                                                        |
| :--------------------------------- | :---------------- | :--------------------------------------------------------------- |
| [`settings.json`](settings.json)   | Declaração JSON   | Preferências de interface, formatadores, LSP e renderização      |
| [`extensions.txt`](extensions.txt) | Lista Declarativa | Lista de extensões para reproduzir o ambiente de desenvolvimento |

---

## 🚀 Como Usar / Sincronizar

### Linux & FreeBSD:

```sh
mkdir -p "${HOME}/.config/Code/User"
ln -sf "$(pwd)/settings.json" "${HOME}/.config/Code/User/settings.json"
```

### Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force -Path "$env:APPDATA\Code\User"
New-Item -ItemType SymbolicLink -Force -Path "$env:APPDATA\Code\User\settings.json" -Target "$((Get-Location).Path)\settings.json"
```
