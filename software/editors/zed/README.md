# ⚡ Zed Editor Configuration

> Configuração de alto desempenho para o editor Rust de última geração Zed.

---

## 🎯 Finalidade

Este diretório mantém os parâmetros de configuração declarativos do **Zed**, editor de texto acelerado por GPU escrito em Rust, configurado com temas escuros consistentes, servidores LSP nativos e formatação automática.

---

## 📂 Catálogo de Arquivos

| Arquivo                          | Tipo            | Descrição                                                 |
| :------------------------------- | :-------------- | :-------------------------------------------------------- |
| [`settings.json`](settings.json) | Declaração JSON | Preferências de interface, LSP, fonte e telemetria do Zed |

---

## 🚀 Como Usar / Sincronizar

### Linux, FreeBSD & macOS:

```sh
mkdir -p "${HOME}/.config/zed"
ln -sf "$(pwd)/settings.json" "${HOME}/.config/zed/settings.json"
```
