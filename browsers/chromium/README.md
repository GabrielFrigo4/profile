# 🌐 Chrome / Chromium — Configurações e Otimizações do Host

O Chromium é o navegador secundário de desenvolvimento executado diretamente no Host. Este documento centraliza configurações de aceleração gráfica e WebGPU via `chrome://flags`.

---

## 🎮 Aceleração Gráfica com WebGPU (`chrome://flags`)

Por padrão, a API **WebGPU** pode estar desabilitada ou limitada no Chromium, especialmente em sistemas Linux e FreeBSD onde a blocklist de hardware impede a aceleração via GPU. A ativação manual via flags internas é necessária para destravar a pipeline gráfica Vulkan e expor a API WebGPU completa ao JavaScript.

### Como Habilitar

1. Abra o Chrome/Chromium normalmente.
2. Na barra de endereços, acesse: `chrome://flags`
3. Procure e ative (**Enabled**) as 3 seguintes opções:

| Flag                                 | ID em `chrome://flags`  |  Valor  | O que faz                                                      |
| :----------------------------------- | :---------------------- | :-----: | :------------------------------------------------------------- |
| **Override software rendering list** | `#ignore-gpu-blocklist` | Enabled | Faz o Chromium ignorar o bloqueio de hardware do FreeBSD/Linux |
| **Unsafe WebGPU**                    | `#enable-unsafe-webgpu` | Enabled | Habilita a API WebGPU                                          |
| **Vulkan**                           | `#enable-vulkan`        | Enabled | Ativa o backend Vulkan                                         |

4. Clique em **Relaunch** para reiniciar o navegador com as flags ativas.

### O que isso destrava

Expõe a interface gráfica e computacional de baixo nível diretamente para o motor do navegador:

- **WebGPU API completa:** `navigator.gpu` disponível para JavaScript, WGSL shaders e compute pipelines.
- **Aceleração Vulkan nativa:** Renderização direta via GPU sem fallback para software rasterization.
- **Compatibilidade FreeBSD/Linux:** Ignora a blocklist que impede aceleração de hardware em drivers Mesa.
- **Inferência de IA Local:** Modelos de linguagem e visão executados integralmente na GPU do cliente via WebLLM, ONNX e Transformers.js.

### Verificação

Após reiniciar com as flags ativas, acesse `chrome://gpu` e verifique:

- **Graphics Feature Status:** WebGPU deve mostrar `Hardware accelerated`.
- **Driver Information:** Deve exibir o driver Vulkan da sua GPU (Mesa, NVIDIA, etc.).

---

## 🚀 Integração com o Host Wayland

- **Fedora (GNOME):** Lance com `chromium --ozone-platform=wayland` para renderização Wayland nativa.
- **FreeBSD (KDE):** Use `--ozone-platform-hint=auto` para detecção automática do display server.
- **Variável de ambiente:** `CHROMIUM_FLAGS="--ozone-platform=wayland"` pode ser exportada no perfil do shell para persistência.
