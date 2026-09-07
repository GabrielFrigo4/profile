# ✨ Google Antigravity Configuration

> Configurações de interface, modelos de inteligência artificial, regras de agentes e extensões para a IDE Google Antigravity.

---

## 🎯 Finalidade

Este diretório contém a configuração declarativa do **Google Antigravity IDE**, centralizando os parâmetros de inteligência artificial, atalhos, telemetria restrita e catálogo de extensões essenciais para produtividade máxima.

---

## 📂 Catálogo de Arquivos

| Arquivo | Tipo | Descrição |
| :--- | :--- | :--- |
| [`settings.json`](settings.json) | Declaração JSON | Configuração do editor, fontes, telemetria e agentes de IA |
| [`extensions.txt`](extensions.txt) | Lista Declarativa | Catálogo de extensões recomendadas para instalação |

---

## 🚀 Como Usar / Sincronizar

### Linux & FreeBSD:
```sh
mkdir -p "${HOME}/.config/Antigravity/User"
ln -sf "$(pwd)/settings.json" "${HOME}/.config/Antigravity/User/settings.json"
```

### Windows (PowerShell):
```powershell
New-Item -ItemType Directory -Force -Path "$env:APPDATA\Antigravity\User"
New-Item -ItemType SymbolicLink -Force -Path "$env:APPDATA\Antigravity\User\settings.json" -Target "$((Get-Location).Path)\settings.json"
```
