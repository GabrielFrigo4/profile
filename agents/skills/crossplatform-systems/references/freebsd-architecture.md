# 🏛️ FreeBSD Architecture & Ecosystem Deep Dive

> Referência técnica detalhada para integração, ciclo de lançamentos e particularidades do FreeBSD em projetos multiplataforma.

---

## 1. O Ciclo Oficial de Lançamentos (`freebsd.org`)

Conforme o processo de Release Engineering do The FreeBSD Project (<https://www.freebsd.org/releng/>):

| Track       | Descrição Técnica Oficial                                                 | Branch Git | Finalidade                                                    |
| :---------- | :------------------------------------------------------------------------ | :--------- | :------------------------------------------------------------ |
| **CURRENT** | Linha ativa de desenvolvimento de novas arquiteturas e mudanças no kernel | `main`     | Testes de vanguarda; não indicada para produção sem validação |
| **STABLE**  | Ramo estabilizado alimentado por _Merged From CURRENT_ (`MFC`)            | `stable/*` | Consolidação contínua rumo ao próximo corte de produção       |
| **RELEASE** | Versões oficiais de produção mantidas pelo _Security Officer_             | `releng/*` | Servidores, containers, Jails e estações de trabalho          |

---

## 2. Separação Canônica: Base System vs. `/usr/local`

- **Base System:** Reside em `/bin`, `/sbin`, `/usr/bin`, `/usr/sbin` e `/etc`.
- **Pacotes de Terceiros (`pkg` / Ports):** Instalados sob `/usr/local` (`/usr/local/bin`, `/usr/local/etc`, `/usr/local/include`, `/usr/local/lib`).
- **Diretiva:** Nunca force `#!/usr/bin/bash` ou `/usr/bin/python3`; adote `#!/usr/bin/env sh` e `#!/usr/bin/env <interpretador>`.

---

## 3. Utilitário `flua` no Base System (`/usr/libexec/flua`)

O interpretador Lua embutido no sistema base fornece módulos C nativos sem dependências externas:

- **`libucl`:** Parser/emissor UCL compatível com JSON e YAML.
- **`libjail` (`jail(3lua)`):** Gerenciamento programático de FreeBSD Jails.
- **`lfs` / `lposix`:** Travessia de arquivos, `fork`, `exec`, `wait`, sinais e descritores.
- **`libfreebsd` / `libhash`:** Consulta via `freebsd.kenv(3lua)` e somas de verificação.

---

## 4. Containers OCI (`runj`) & Packet Filter (`pf`)

- **Podman + `runj`:** Mapeia contêineres OCI para Jails nativas com redes Netavark (`freebsd/freebsd-runtime`, `freebsd-static`, `freebsd-dynamic`, `freebsd-toolchain`):
    ```sh
    podman run --rm -it freebsd/freebsd-runtime:latest uname -a
    ```
- **Packet Filter (`pf`):** Tradução inline (`nat-to`, `rdr-to`), tabelas persistentes (`table <spammers> persist`) e processamento SMP no kernel.
