# ⚡ Foot Wayland Terminal Profile

> Configuração declarativa, hiperperformática e de alta fidelidade visual para o terminal Foot Wayland.

---

## 🎯 Finalidade

Este diretório provê a configuração declarativa do **Foot**, emulador de terminal nativo para Wayland com foco em latência mínima e eficiência de recursos. Configura tipografia nítida com **JetBrainsMono Nerd Font**, suporte completo a glifos vetoriais, dimensionamento DPI automático (_dpi-aware_), preenchimento interno (_padding_ de 16px) e paleta escura de alto contraste harmônica com o ecossistema e ambientes modernos (GNOME/KDE).

---

## 📂 Catálogo de Arquivos

| Arquivo                | Tipo                     | Descrição                                                                      |
| :--------------------- | :----------------------- | :----------------------------------------------------------------------------- |
| [`foot.ini`](foot.ini) | Configuração Declarativa | Definição de fontes, preenchimento, cores, atalhos de teclado e cursor do Foot |

---

## 🚀 Como Usar / Sincronizar

### Instalação via Universal Profile:

```sh
sh profile.sh sync
```

O dotfile é sincronizado automaticamente em:

```sh
~/.config/foot/foot.ini
```
