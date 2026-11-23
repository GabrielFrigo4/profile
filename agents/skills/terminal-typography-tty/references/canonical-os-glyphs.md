# 🗺️ Matriz Canônica de Glifos de Sistemas & Terminal

Esta referência estabelece a tabela oficial de correspondência entre sistemas operacionais, distribuições, elementos de controle de versão (VCS) e seus glifos vetoriais canônicos no ecossistema soberano.

---

## 🏛️ Sistemas Operacionais & Núcleos

| Sistema / Família   | Glifo | Nome Nerd Fonts           | Codepoint | Família Primária | Fallback ASCII  |
| :------------------ | :---: | :------------------------ | :-------- | :--------------- | :-------------- |
| **Linux (Tux)**     | ` `  | `nf-linux-tux`            | `U+F31A`  | Font Logos       | `[LINUX]`       |
| **FreeBSD**         | ` `  | `nf-linux-freebsd`        | `U+F30C`  | Font Logos       | `[BSD]`         |
| **GhostBSD**        | ` `  | `nf-linux-freebsd`        | `U+F30C`  | Font Logos       | `[GHOSTBSD]`    |
| **NomadBSD**        | ` `  | `nf-linux-freebsd`        | `U+F30C`  | Font Logos       | `[NOMADBSD]`    |
| **OpenBSD**         | ` `  | `nf-linux-openbsd`        | `U+F328`  | Font Logos       | `[BSD]`         |
| **NetBSD**          | `󰈺 `  | `nf-md-flag`              | `U+F023A` | Material Design  | `[BSD]`         |
| **DragonFly BSD**   | ` `  | `nf-custom-dragonfly_bsd` | `U+EEF8`  | Custom PUA       | `[BSD]`         |
| **illumos**         | ` `  | `nf-linux-illumos`        | `U+F326`  | Font Logos       | `[ILLUMOS]`     |
| **OmniOS**          | ` `  | `nf-linux-illumos`        | `U+F326`  | Font Logos       | `[OMNIOS]`      |
| **SmartOS**         | ` `  | `nf-linux-illumos`        | `U+F326`  | Font Logos       | `[SMARTOS]`     |
| **OpenIndiana**     | ` `  | `nf-linux-illumos`        | `U+F326`  | Font Logos       | `[OPENINDIANA]` |
| **Solaris/SunOS**   | `󰖨 `  | `nf-md-weather_sunny`     | `U+F05A8` | Material Design  | `[SOLARIS]`     |
| **macOS / Darwin**  | ` `  | `nf-linux-apple`          | `U+F302`  | Font Logos       | `[MAC]`         |
| **Windows / MSYS2** | ` `  | `nf-custom-windows`       | `U+E62A`  | Custom PUA       | `[WIN]`         |
| **UNIX Genérico**   | ` `  | `nf-md-server_network`    | `U+E8CC`  | Material Design  | `[UNIX]`        |

---

## 🐧 Distribuições Linux

| Distribuição       | Glifo | Nome Nerd Fonts         | Codepoint | Família Primária | Fallback ASCII |
| :----------------- | :---: | :---------------------- | :-------- | :--------------- | :------------- |
| **Alpine Linux**   | ` `  | `nf-linux-alpine`       | `U+F300`  | Font Logos       | `[ALPINE]`     |
| **Arch Linux**     | ` `  | `nf-linux-arch`         | `U+F303`  | Font Logos       | `[ARCH]`       |
| **Debian**         | ` `  | `nf-linux-debian`       | `U+F306`  | Font Logos       | `[DEBIAN]`     |
| **Fedora**         | ` `  | `nf-linux-fedora`       | `U+F30A`  | Font Logos       | `[FEDORA]`     |
| **Gentoo**         | ` `  | `nf-linux-gentoo`       | `U+F30D`  | Font Logos       | `[GENTOO]`     |
| **NixOS**          | ` `  | `nf-linux-nixos`        | `U+F313`  | Font Logos       | `[NIXOS]`      |
| **openSUSE**       | ` `  | `nf-linux-opensuse`     | `U+F314`  | Font Logos       | `[SUSE]`       |
| **Raspbian**       | ` `  | `nf-linux-raspberry_pi` | `U+F315`  | Font Logos       | `[RPI]`        |
| **Red Hat (RHEL)** | ` `  | `nf-linux-redhat`       | `U+F316`  | Font Logos       | `[RHEL]`       |
| **Ubuntu**         | ` `  | `nf-linux-ubuntu`       | `U+F31B`  | Font Logos       | `[UBUNTU]`     |
| **Void Linux**     | ` `  | `nf-linux-void`         | `U+F32E`  | Font Logos       | `[VOID]`       |

---

## 🌿 VCS & Estado do Shell

| Elemento Semântico    | Glifo | Nome Nerd Fonts     | Codepoint | Finalidade                           |
| :-------------------- | :---: | :------------------ | :-------- | :----------------------------------- |
| **Branch Git / Got**  | ` `  | `nf-oct-git_branch` | `U+F418`  | Identificação de branch ativa        |
| **Working Tree Suja** |  `*`  | ASCII Asterisco     | `U+002A`  | Indicador de alterações pendentes    |
| **Sucesso / Retorno** |  `✔`  | Heavy Check Mark    | `U+2714`  | Retorno com status zero (`$? = 0`)   |
| **Falha / Erro**      |  `✘`  | Heavy Ballot X      | `U+2718`  | Retorno com erro (`$? != 0`)         |
| **Privilégio Root**   | `⚡`  | High Voltage Sign   | `U+26A1`  | Execução como superusuário (`UID 0`) |
| **Shell Interativo**  | ` `  | `nf-oct-terminal`   | `U+F489`  | Indicador de shell ativo no prompt   |
