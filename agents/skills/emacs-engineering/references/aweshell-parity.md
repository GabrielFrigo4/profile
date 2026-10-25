# 🐚 Governança de Paridade: Universal Shell & Aweshell

Este documento estabelece as diretrizes canônicas para manter a simetria funcional, estética e ergonômica entre o **Universal Shell** (`Shell/`) e o módulo **Aweshell** (`Editor/Emacs/usr/local/aweshell/`).

---

## 🧭 O Papel do Aweshell no Ecossistema

O **Aweshell** não é um emulador de terminal desacoplado. Ele é o embaixador e runtime do Universal Shell operando dentro do runtime Emacs Lisp (Eshell). A experiência de uso dentro de um buffer do Aweshell deve ser transparente para quem utiliza o terminal nativo nos shells `zsh`, `bash` ou `ksh`.

---

## 🏛️ Invariantes de Simetria

1. **Paridade de Temas de Prompt:**
    - O Aweshell implementa nativamente os mesmos 3 layouts canônicos do shell:
        - `aweshell/theme-multi`: Layout Powerline multi-linha com metadados de OS, usuário, diretório e branch Git.
        - `aweshell/theme-pill`: Layout moderno em cápsula, com fallback automático para caracteres ASCII puros quando sob Raw TTY.
        - `aweshell/theme-micro`: Linha única compacta.
    - Qualquer refinamento tipográfico ou cromático realizado em `Shell/theme/` deve ser refletido em `Editor/Emacs/usr/local/aweshell/aweshell-theme.el`.

2. **Paridade de Aliases & Workflows:**
    - Todo alias universal introduzido em `Shell/docs/ALIASES.md` pertencente às categorias de **Sincronização** (`upall`, `upsh`, `uprc`, `uped`, `upvt`, `upmodes`, `resh`, `bsh`) e **Ferramentas de IA** (`agyc`, `agya`, `agyca`, etc.) DEVE estar presente no `aweshell/setup-aliases` do `aweshell.el`.

3. **Ergonomia Híbrida Lisp/Buffers:**
    - Comandos que interagem com arquivos e navegação devem respeitar os paradigmas do Emacs:
        - `e <arquivo>`: Abre o arquivo no buffer corrente (`find-file`).
        - `ee <arquivo>`: Abre o arquivo dividindo a janela (`find-file-other-window`).
        - `d` / `dired`: Abre o Dired para navegação de diretórios.
        - `g` / `magit`: Dispara o `magit-status`.

4. **Splicing Seguro em Aliases do Eshell:**
    - Aliases definidos no Eshell devem utilizar `$@*` (splicing) em vez de `$*` para argumentos múltiplos, evitando que listas de argumentos sejam empacotadas como argumento único.
