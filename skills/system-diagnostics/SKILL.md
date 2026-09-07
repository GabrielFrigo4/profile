---
name: system-diagnostics
description: Runbook cognitivo para diagnóstico de saúde de estações Linux e FreeBSD (Wayland, aceleração gráfica VA-API, PipeWire, logs e conectividade).
---

# 🩺 System Diagnostics Skill

Esta habilidade orienta o agente de inteligência artificial na investigação profunda de estações de trabalho, identificando gargalos de desempenho, incompatibilidades gráficas e anomalias de subsistemas.

---

## 🔍 Checklist Diagnóstico Passo a Passo

### 1. Sessão Gráfica & Protocolo de Janelas
Verificar se o ambiente desktop está operando em Wayland nativo:
```sh
echo "Sessão: ${XDG_SESSION_TYPE:-desconhecido}"
echo "Wayland Display: ${WAYLAND_DISPLAY:-nenhum}"
```
- Se `XDG_SESSION_TYPE` for `x11`, verificar se os drivers proprietários (ex: NVIDIA) ou o compositor suportam inicialização em Wayland.

### 2. Aceleração Gráfica por Hardware (VA-API & Vulkan)
Verificar se a GPU está decodificando vídeo via hardware:
```sh
if command -v vainfo >/dev/null 2>&1; then
    vainfo
elif [ -e "/dev/dri/renderD128" ]; then
    echo "Dispositivo de renderização /dev/dri/renderD128 presente."
fi
```
- Validar se os pacotes `intel-media-driver` / `libva-intel-driver` ou `mesa-va-drivers` estão instalados.

### 3. Subsistema de Áudio PipeWire
Validar se o servidor de som PipeWire e a camada PulseAudio de compatibilidade estão ativos:
```sh
if command -v pactl >/dev/null 2>&1; then
    pactl info | grep -E "Server Name|Server Version"
fi
```
- `Server Name` deve indicar `PulseAudio (on PipeWire 1.x.x)`.

### 4. Erros Críticos do Kernel & Systemd
Inspecionar falhas recentes de inicialização:
```sh
if command -v journalctl >/dev/null 2>&1; then
    journalctl -p 3 -xb --no-pager | tail -n 25
fi
```

### 5. Regras de Firewall Ativas
```sh
if command -v nft >/dev/null 2>&1; then
    sudo nft list ruleset 2>/dev/null || echo "Requer permissões de root para inspecionar nftables"
elif command -v pfctl >/dev/null 2>&1; then
    sudo pfctl -sr 2>/dev/null || echo "Requer permissões de root para inspecionar pf"
fi
```
