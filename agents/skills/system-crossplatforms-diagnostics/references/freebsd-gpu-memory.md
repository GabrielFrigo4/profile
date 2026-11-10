# 🎮 FreeBSD GPU, DRM & Memory Architecture Guide

> Diagnóstico aprofundado de subsistemas gráficos DRM (`drm-kmod`), LinuxKPI, gestão de memória sob ZFS ARC, Bhyve e estabilidade de hardware no FreeBSD.

---

## 1. Regressão Gráfica no FreeBSD 15.1 (`drm-612-kmod`)

No FreeBSD 15.1-RELEASE, a transição do `drm-66-kmod` (Linux 6.6 LTS) para o `drm-612-kmod` (Linux 6.12 LTS) introduziu instabilidades severas em GPUs integradas Intel (Alder Lake/Iris Xe e gerações correlatas):

1. **GTT v5 e Perda de Posse de Páginas `shmem`:**
    - O driver `i915` elevou `i915_gem_mmap_gtt_version` de 3 para 5, ativando `I915_GEM_MMAP_OFFSET` (mapeamentos `I915_MMAP_OFFSET_WB`).
    - A função `lkpi_vmf_insert_pfn_prot_locked()` (`sys/compat/linuxkpi/common/src/linux_page.c`) desvincula a página física (`vm_page_t`) de seu objeto `shmem` original (`vm_page_remove(page)`), transferindo-a para o `cdev_pager` do FreeBSD.
    - Sob pressão de memória (RAM ou swap) e desalocação pelo shrinker da GPU (`DROP_UNBOUND`), o `device_pager` revoga as PTEs sem devolver a posse da página ao objeto `shmem` original, resultando em corrupção de dados (`RESULT=DATA_LOSS`).
    - Mapeamentos concorrentes disparam falha `page rename failed: page is mapped`, travando em loop infinito de `VM_FAULT_NOPAGE`.
    - O motor de renderização `rcs0` perde acesso a páginas de comandos e texturas, disparando `GPU HANG: ecode 12:1:85dffffb`, preemption timeouts e colapso irreversível de compositores (`kwin_wayland`).

2. **Retorno Invertido em `linux_cancel_delayed_work_sync()`:**
    - No `LinuxKPI` do FreeBSD 15.1, `linux_cancel_delayed_work_sync()` retornava `false` ao cancelar trabalho pendente antes da execução (Linux retorna `true`).
    - O escalonador GuC do `i915` realizava unpin antecipado de contextos, provocando corrupção de estado de microcódigo: `GT0: GUC: Bad context sched_state 0x6`.

---

## 2. Matriz de Versões & Repositórios (15.0 vs 15.1 vs 15.2 vs 16-CURRENT)

| Versão / Canal       | Driver DRM                    | Status & Comportamento                                                                                      |
| :------------------- | :---------------------------- | :---------------------------------------------------------------------------------------------------------- |
| **15.0-RELEASE**     | `drm-66-kmod`                 | Estável: GTT v3, sem perda de páginas `shmem`.                                                              |
| **15.1 (quarterly)** | `drm-612-kmod-6.12.85_2`      | Crítico: Instável, falhas de Vulkan, GPU hangs em Alder Lake sob pressão de RAM.                            |
| **15.1 (latest)**    | `drm-612-kmod-6.12.110_3`     | Muito Melhorado: Corrige Vulkan (commit `3e1c3ad47598`), reduz hangs, mas bug de `shmem` persiste sob swap. |
| **15.2-RELEASE**     | `drm-612-kmod-6.12.110_3`     | LinuxKPI corrigido: PR #2268 (GuC `0x6`), D58194 e D58195. Aguarda merge de D59481/D59883 (`shmem`).        |
| **16.0-CURRENT**     | `drm-612-kmod` / `drm_v6.13+` | Não recomendado: Refatoração de `struct page` (`PAGE_IS_LKPI_PAGE`, D58320/D58498) gera novos panics.       |

---

## 3. Resolução Prática: Downgrade Seletivo para `drm-66-kmod`

A estratégia de maior estabilidade no FreeBSD 15.1 consiste em manter o sistema operacional no 15.1 e realizar o downgrade do driver DRM para a série 6.6 LTS com trava de pacote:

```sh
bectl create pre-drm66-fix
pkg delete -f drm-kmod drm-612-kmod
pkg install drm-66-kmod gpu-firmware-intel-kmod-alderlake
pkg lock -y drm-66-kmod
```

---

## 4. Fórmula de Orçamento de Memória em 16 Partes

Em estações de trabalho de 16 GB rodando ZFS, DRM e máquinas virtuais Bhyve, adota-se a partição estrita de 16 avos:

- **1/16 (1 GB):** Alocado para Bhyve VM (guest de orquestração Linux via NFSv3).
- **4/16 (4 GB):** Teto do ZFS ARC (`vfs.zfs.arc.max="4294967296"`, piso de 1 GB).
- **11/16 (~11 GB):** Reservado para Host OS, aplicativos, buffers gráficos GEM da GPU integrada e IPC SHM.

---

## 5. Tunables Canônicos (`/boot/loader.conf`)

Configurações mandatárias para gráficos Intel Alder Lake (12ª geração) e mitigação de regressões de energia e memória:

```ini
compat.linuxkpi.i915_enable_guc="2"
compat.linuxkpi.i915_enable_psr="0"
compat.linuxkpi.i915_enable_psr2_sel_fetch="0"
compat.linuxkpi.i915_enable_fbc="0"
compat.linuxkpi.i915_enable_dc="0"
compat.linuxkpi.i915_disable_power_well="0"
kern.ipc.shmseg="1024"
kern.ipc.shmmni="1024"
kern.maxproc="100000"
vfs.zfs.arc.max="4294967296"
vfs.zfs.arc.min="1073741824"
vfs.zfs.txg.timeout="10"
```

O módulo gráfico deve ser carregado tardiamente em `/etc/rc.conf`:

```sh
sysrc kld_list+="i915kms"
```
