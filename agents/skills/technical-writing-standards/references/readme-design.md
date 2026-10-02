# 🎨 Design & Arquitetura de READMEs Institucionais

O `README.md` raiz de um repositório é seu cartão de visitas e sua especificação executiva. Ele deve sintetizar propósito, status operacional, arquitetura e instruções em menos de 10 segundos de leitura.

---

## 💎 Engenharia de Badges (Shields.io + Simple Icons)

Badges comunicam metadados instantaneamente (CI, plataformas, linters, licença). O padrão canônico utiliza **logos vetoriais em SVG puro** via API do Shields.io:

```markdown
![Nome](https://img.shields.io/badge/LABEL-MESSAGE-COLOR?logo=SLUG&logoColor=white)
```

### Exemplos do Ecossistema:

```markdown
![FreeBSD](https://img.shields.io/badge/FreeBSD-Supported-red?logo=freebsd&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-Supported-blue?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-Supported-black?logo=apple&logoColor=white)
![Windows](<https://img.shields.io/badge/Windows_(MSYS2)-Supported-purple?logo=gitforwindows&logoColor=white>)
![OpenBSD](https://img.shields.io/badge/OpenBSD-Supported-yellow?logo=openbsd&logoColor=white)
```

---

## 🧩 Slugs Canônicos & Associações Inteligentes

Quando uma tecnologia não possuir slug direto no Simple Icons, aplique associações simétricas:

| Tecnologia / Alvo      | Slug Simple Icons | Justificativa Arquitetural                                     |
| :--------------------- | :---------------: | :------------------------------------------------------------- |
| **Windows / MSYS2**    |  `gitforwindows`  | Logotipo do Git for Windows sobre a plataforma Windows         |
| **illumos / Solaris**  |     `openzfs`     | OpenZFS é a espinha dorsal nativa da linhagem illumos          |
| **FreeBSD `/bin/sh`**  |     `freebsd`     | Identifica que o alvo `sh` é o interpretador nativo do FreeBSD |
| **OpenBSD `/bin/ksh`** |     `openbsd`     | Identifica que o alvo `ksh` é o interpretador do OpenBSD       |
| **Fish Shell**         |    `fishshell`    | Peixe estilizado oficial do interpretador                      |

---

## 🏛️ Estrutura Canônica de Hero Section

```markdown
# 🏛️ Nome do Projeto

> Descrição de alto nível concisa em uma ou duas frases definindo a proposta de valor.

[![CI](https://github.com/org/repo/actions/workflows/ci.yml/badge.svg)](https://github.com/org/repo/actions)
[![Roadmap](https://img.shields.io/badge/🗺️_Roadmap-TODO.md-teal)](TODO.md)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
```
