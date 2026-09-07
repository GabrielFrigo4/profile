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

## 🚀 Integração com o Host Wayland

- **Aceleração Gráfica:** No Fedora (GNOME) e FreeBSD (KDE), garanta que o Firefox execute nativamente sobre Wayland (`MOZ_ENABLE_WAYLAND=1`), dispensando qualquer camada XWayland intermediária.
