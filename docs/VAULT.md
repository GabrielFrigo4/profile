# 🔒 The Vault

O **[Vault](https://github.com/GabrielFrigo4/Vault)** é o repositório privado da **Tríade de Produtividade**, responsável pelo gerenciamento de credenciais confidenciais, chaves SSH/PuTTY, tokens de autenticação, mapeamento de servidores e credenciais de rede.

Sempre que um script de setup, configuração de Git ou ferramenta de terminal precisar de segredos, os dados serão lidos a partir do Vault local (`~/.vault`).

---

## 📂 Localização e Permissões de Instalação

O Vault deve ser clonado e posicionado no seguinte caminho seguro:

```sh
# UNIX (Linux, FreeBSD, macOS, WSL2)
git clone "https://github.com/GabrielFrigo4/Vault" "${HOME}/.vault"
chmod 0700 "${HOME}/.vault"

# Windows Nativo (Prompt de Comando ou PowerShell)
git clone "https://github.com/GabrielFrigo4/Vault" "%USERPROFILE%\.vault"
```

> [!IMPORTANT]
> **Permissões Estritas em 4 Dígitos:** Conforme os princípios do Vault ([PRINCIPLES.md](../PRINCIPLES.md)), os diretórios e scripts devem ter permissão `0700`, e os arquivos `.env` e chaves privadas devem ter permissão `0600`. O utilitário `vault-perms` aplica e audita essas restrições automaticamente.

---

## 🗂️ Estrutura de Domínios do Vault

O Vault organiza os dados sensíveis em domínios claros:

- **`config/*.env`** — Configurações de perfil e chaves de API (`git.env`, perfis gerais).
- **`keys/*`** — Chaves criptográficas SSH (`.key`, `.pub`) e PuTTY (`.ppk`).
- **`network/*.env`** — Credenciais e senhas de redes Wi-Fi (`wifi.env`).
- **`servers/*.env`** — Mapeamentos de IPs, portas e aliases de servidores remotos (`hosts.env`).
- **`tokens/*`** — Tokens de autenticação de serviços (`authinfo`).

---

## ⚡ Mecanismos de Carregamento (Loaders)

O Vault provê carregadores nativos para todos os ambientes do ecossistema:

| Arquivo                  | Interpretador / Ambiente                  |
| :----------------------- | :---------------------------------------- |
| **`vault.sh`**           | POSIX `/bin/sh`, Bash, Zsh                |
| **`vault.ps1`**          | PowerShell Core e Windows PowerShell      |
| **`vault.cmd`**          | Prompt de Comando (CMD Batch)             |
| **`vault.nu`**           | NuShell                                   |
| **`script/regedit.ps1`** | Injeção permanente no Registro do Windows |

---

## 🔗 Integração com o Universal Shell

O **Universal Shell** detecta o diretório `~/.vault` automaticamente a cada nova sessão via `core/vault.sh`. Não é necessário fazer `source` manual em cada script — o ambiente carrega as variáveis de forma silenciosa e instantânea.

Em máquinas limpas recém-provisionadas ou ambientes anônimos onde o Vault não estiver clonado, o ecossistema opera normalmente em modo anônimo (degradação graciosa).
