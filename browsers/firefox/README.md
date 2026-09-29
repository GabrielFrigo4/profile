# 🦊 Mozilla Firefox — Configurações e Otimizações do Host

O Mozilla Firefox é o navegador gráfico principal executado diretamente no Host (Wayland nativo). Este documento centraliza configurações de alta prioridade (`about:config`) e ajustes manuais recomendados.

---

## 📋 Clipboard Assíncrono (`dom.events.testing.asyncClipboard`)

Por padrão, o Firefox bloqueia o acesso assíncrono à área de transferência (clipboard) por questões de segurança em determinados contextos de navegabilidade. Aplicações web modernas (editores online, consoles de cloud, dashboards de CI/CD e interfaces interativas) que dependem das APIs modernas de clipboard podem falhar silenciosamente ao copiar ou colar código sem esta chave ativa.

### Como Habilitar

1. Abra uma nova aba e digite: `about:config`
2. Clique no aviso: **"Aceitar o risco e continuar"**
3. Na barra de pesquisa, busque por:
    ```text
    dom.events.testing.asyncClipboard
    ```
4. Clique duas vezes ou no botão de alternância (⇄) para mudar o valor para **`true`**.

### O que isso destrava

Permite que a Clipboard API opere de ponta a ponta:

- `navigator.clipboard.writeText(texto)` — escrita direta de texto/código.
- `navigator.clipboard.readText()` — leitura de blocos de texto.
- `navigator.clipboard.write(data)` / `read()` — manipulação de blobs arbitrários.

---

## 🎮 Aceleração Gráfica com WebGPU (`dom.webgpu.enabled`)

Por padrão, a API **WebGPU** permanece desabilitada ou restrita a canais de desenvolvimento no Firefox, aguardando a consolidação da implementação do backend nativo (`wgpu`) e compatibilidade estrita de drivers no ecossistema Linux/Wayland. Trata-se da evolução direta do WebGL, projetada para reduzir drasticamente o overhead da CPU e expor os recursos modernos das GPUs contemporâneas via Vulkan.

Ferramentas modernas de inteligência artificial no cliente (execução de modelos locais via ONNX/Transformers.js), engines de jogos compiladas para WebAssembly e aplicações complexas de CAD/3D dependem do WebGPU para renderização e computação de alta fidelidade sem gargalos de pipeline.

### Como Habilitar

1. Abra uma nova aba e digite: `about:config`
2. Clique no aviso: **"Aceitar o risco e continuar"**
3. Na barra de pesquisa, busque por:
    ```text
    dom.webgpu.enabled
    ```
4. Clique duas vezes ou no botão de alternância (⇄) para mudar o valor para **`true`**.

> **Nota para Linux / Wayland:** Caso a stack gráfica não inicialize de imediato (verificável em `about:support` na seção _WebGPU_), pode ser necessário alternar também a chave `gfx.webgpu.ignore-status` para **`true`** para ignorar bloqueios preventivos de driver sobre a stack Mesa/Vulkan.

### O que isso destrava

Expõe a interface gráfica e computacional de baixo nível diretamente para o motor do navegador:

- **Compute Shaders (WGSL):** Execução de processamento paralelo arbitrário (GPGPU) no browser sem a necessidade de simular operações via shaders de fragmento do WebGL.
- **Inferência de IA Local Acelerada:** Execução eficiente de modelos locais (LLMs compactos, transcrição de áudio via Whisper e visão computacional) com aceleração direta de hardware.
- **Overhead Reduzido de CPU:** Menor consumo de ciclos de processador em chamadas de desenho (_draw calls_), viabilizando taxas de quadros (FPS) mais estáveis em engines modernas (Three.js, Babylon.js e stacks em Rust/Wasm).

---

## 🚀 Integração com o Host Wayland

- **Aceleração Gráfica:** No Fedora (GNOME) e FreeBSD (KDE), garanta que o Firefox execute nativamente sobre Wayland (`MOZ_ENABLE_WAYLAND=1`), dispensando qualquer camada XWayland intermediária.
