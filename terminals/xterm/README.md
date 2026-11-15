# 🖥️ XTerm X11 Configuration

> Configuração visual declarativa (`Xresources`) para o emulador XTerm em sessões X11 e fallback gráfico.

---

## 🎯 Finalidade

Este diretório provê a definição declarativa de fontes, paleta escura de alto contraste e geometria de cursor do **XTerm**, sincronizada em `~/.Xresources` e `~/.Xdefaults`.

---

## 📂 Catálogo de Arquivos

| Arquivo                    | Tipo                     | Descrição                                                     |
| :------------------------- | :----------------------- | :------------------------------------------------------------ |
| [`Xresources`](Xresources) | Configuração Declarativa | Paleta cromática, `JetBrainsMono Nerd Font` e cursor piscante |

> O atalho XDG [`xterm.desktop`](../../desktop/applications/xterm.desktop) reside centralizado em [`../../desktop/applications/`](../../desktop/applications/) e é sincronizado para `~/.local/share/applications/` via `sh profile.sh sync`.

---

## 🚀 Como Usar / Sincronizar

```sh
sh profile.sh sync
```
