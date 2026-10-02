# 🏛️ FreeBSD Architecture & Ecosystem Deep Dive

> Referência técnica detalhada para a integração, ciclo de vida e particularidades do FreeBSD no ecossistema multiplataforma.

---

## 1. O Ciclo Oficial de Lançamentos do FreeBSD (freebsd.org)

Conforme a documentação oficial e o processo de Engenharia de Lançamento (_Release Engineering_) do The FreeBSD Project (<https://www.freebsd.org/> e <https://www.freebsd.org/releng/>):

| Ramo / Track | Descrição Técnica Oficial                                                               | Branch no Git                  | Versões em Atividade                 | Público-Alvo e Finalidade                                                                 |
| :----------- | :-------------------------------------------------------------------------------------- | :----------------------------- | :----------------------------------- | :---------------------------------------------------------------------------------------- |
| **CURRENT**  | _Bleeding-edge_ do desenvolvimento. Entrada de novas arquiteturas e mudanças no kernel. | `main`                         | **16.0-CURRENT**                     | Desenvolvedores do core e testadores. Não recomendado para produção sem validação prévia. |
| **STABLE**   | Ramo estabilizado de onde versões pontuais são cortadas (_Merged From CURRENT - MFC_).  | `stable/15`<br>`stable/14`     | **15.1-STABLE**                      | Engenharia e consolidação contínua de recursos para a próxima versão de produção.         |
| **RELEASE**  | Versões oficiais de produção (_Production Releases_), mantidas pelo _Security Officer_. | `releng/15.1`<br>`releng/14.5` | **15.1-RELEASE**<br>**14.5-RELEASE** | Ambientes corporativos, servidores de missão crítica, contêineres e estações de trabalho. |

---

## 2. Separação Canônica: Base System vs. `/usr/local`

- **Base System:** Reside estritamente em `/bin`, `/sbin`, `/usr/bin`, `/usr/sbin` e `/etc`.
- **Softwares de Terceiros (`pkg` / Ports):** Todos os pacotes instalados residem sob o prefixo `/usr/local` (`/usr/local/bin`, `/usr/local/etc`, `/usr/local/include`, `/usr/local/lib`).
- **Diretiva:** NUNCA force `#!/usr/bin/bash` ou `/usr/bin/python3`. Use invariavelmente `#!/usr/bin/env sh` ou `#!/usr/bin/env <interpretador>`.

---

## 3. Utilitário `flua` no Base System (`/usr/libexec/flua`)

Desde o FreeBSD 13+, o sistema base inclui `/usr/libexec/flua` (interpretador Lua nativo embutido). Inclui módulos C essenciais sem demandar interpretadores externos:

- **`libucl`:** Parser e emissor de UCL (_Universal Configuration Language_), processando JSON estrito/relaxado e YAML nativamente.
- **`libjail` (`jail(3lua)`):** API completa para gerenciar FreeBSD Jails diretamente em Lua.
- **`lfs` (LuaFileSystem):** Operações avançadas de atributos e travessia de arquivos.
- **`lposix`:** Chamadas de sistema POSIX fundamentais (`fork`, `exec`, `wait`, sinais, descritores).
- **`libfreebsd`:** Consulta de variáveis de ambiente do kernel via `freebsd.kenv(3lua)`.
- **`libhash`:** Cálculos de soma de verificação e hashing de integridade.

---

## 4. Containers OCI no Docker Hub (`hub.docker.com/u/freebsd`)

- Suporte pleno a Podman (`pkg install podman`) via **`runj`** como runtime OCI, mapeando contêineres para Jails com redes Netavark.
- **Imagens Oficiais:**
    - `freebsd/freebsd-runtime`: imagem base mínima para rodar aplicações.
    - `freebsd/freebsd-static`: imagem minimalista para binários estáticos.
    - `freebsd/freebsd-dynamic`: imagem base dinâmica com bibliotecas da base.
    - `freebsd/freebsd-toolchain`: ambiente de compilação com Clang, headers e ferramentas.
    - Invocação canônica: `podman run --rm -it freebsd/freebsd-runtime:15.1 uname -a`.

---

## 5. Orquestração e Infraestrutura: `Sylve` & Firewall `pf`

- **Sylve** (<https://sylve.io/> / `AlchemillaHQ/Sylve`): plataforma moderna open-source de infraestrutura para FreeBSD 15.0+ (`pkg install sylve`). Unifica gerenciamento de Bhyve VMs, Jails, ZFS Storage, redes virtuais e firewall PF em interface web reativa (SvelteKit + Go).
- **Packet Filter (`pf`):** Suporta sintaxe moderna OpenBSD com tradução inline (`nat-to`, `rdr-to` em regras de filtro) e tabelas dinâmicas (`table <spammers> persist`), operando multithread (SMP) no kernel.
