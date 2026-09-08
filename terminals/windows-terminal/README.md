# 🪟 Windows Terminal Configuration

> Configuração declarativa de perfis, esquemas de cores e atalhos para o Windows Terminal.

---

## 🎯 Finalidade

Este diretório mantém o arquivo `settings.json` do **Windows Terminal**, configurando esquemas de cores elegantes, transparência acrílica, suporte a fontes Nerd Font e perfis para PowerShell, CMD, WSL2 e MSYS2.

---

## 📂 Catálogo de Arquivos

| Arquivo                          | Tipo            | Descrição                                              |
| :------------------------------- | :-------------- | :----------------------------------------------------- |
| [`settings.json`](settings.json) | Declaração JSON | Preferências de interface e perfis do Windows Terminal |

---

## 🚀 Como Usar no Windows

### PowerShell:

```powershell
$wtPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
if (Test-Path $wtPath) {
    Copy-Item "settings.json" "$wtPath\settings.json" -Force
}
```
