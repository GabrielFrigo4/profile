# [Emoji] [Nome do Projeto] — [Subtítulo Conciso]

> [Declaração de missão institucional e invariantes do repositório em uma ou duas frases].

---

## 🏛️ Arquitetura & Escopo

| Componente   | Papel Central                            | Escopo & Privilégios                    |
| :----------- | :--------------------------------------- | :-------------------------------------- |
| **Core**     | Lógica de negócio e núcleo executável    | Agnóstico de interface e determinístico |
| **CLI / UI** | Interface de comando ou apresentação     | Emissão limpa em `stdout` e `stderr`    |
| **Config**   | Arquivos declarativos de configuração    | XDG Base Directory (`~/.config/<app>/`) |
| **Tests**    | Suítes unitárias, integração e auditoria | Execução hermética offline              |

---

## 📂 Catálogo de Diretórios

| Diretório | Descrição                                       |
| :-------- | :---------------------------------------------- |
| `pasta/`  | Descrição do propósito dos arquivos nesta pasta |

---

## 🚀 Como Usar

[Instruções concisas de clone, build ou execução].

---

## 🧪 Auditoria & Quality Gates

```sh
make test
make ci
```
