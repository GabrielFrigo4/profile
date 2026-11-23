# ☀️ illumos: Isolamento de Missão Crítica & Rede em Kernel

A linhagem illumos (mantida por distribuições como **SmartOS** e **OmniOS CE**) prioriza isolamento multitenant, observabilidade profunda com DTrace e virtualização nativa de rede e storage.

---

## 🛡️ Solaris / illumos Zones & SmartOS

1. **Zonas Nativas & `lx-brand`:** Espaços isolados sobre o kernel único com alocação estrita de recursos e tradução direta de syscalls Linux quando necessário.
2. **Hipervisor sem Disco (SmartOS):** Execução do sistema operacional em RAM via PXE/mídia somente leitura, mantendo 100% dos discos dedicados ao pool ZFS (`zones`).
3. **Manifestos Declarativos (`vmadm`) & Supervisão SMF:**
    ```sh
    vmadm create -f instance.json
    vmadm list
    ```

---

## 🌐 Virtualização de Rede com Crossbow

O subsistema **Crossbow** implementa virtualização de rede diretamente na camada de driver:

```sh
dladm create-vnic -l igb0 -m auto -p maxbw=1G vnic_app0
```

- **Etherstubs:** Switches virtuais em memória de kernel para isolamento e roteamento entre Zonas locais sem tráfego físico externo.
- **Hiperconvergência:** Combina Zones/Bhyve VMM com ZFS e Crossbow em arquitetura totalmente aberta e auditável.
