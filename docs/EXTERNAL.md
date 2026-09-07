# 📥 Ferramentas Externas

Este documento cataloga softwares, utilitários e aplicativos vitais para o ecossistema que **não** são gerenciados pelos scripts automatizados de `bootstrap/` (seja por não estarem em repositórios oficiais, requererem licenças manuais, ou serem exclusividades de lojas de aplicativos).

## 📦 Downloads Manuais (Instaladores)

Ferramentas que exigem o download direto do binário/instalador pelo navegador:

- **[VMWare Workstation/Fusion](https://www.vmware.com/products/desktop-hypervisor/workstation-and-fusion)**: Hypervisor Type-2 (alternativa ao Hyper-V/bhyve para casos de uso específicos).
- **[Intel Quartus Prime](https://www.intel.com.br/content/www/br/pt/collections/products/fpga/software/downloads.html?s=Newest)**: IDE para desenvolvimento e síntese de FPGA Intel.
- **[TeX Live](https://www.tug.org/texlive/windows.html)**: Distribuição abrangente do sistema de tipografia TeX (geralmente instalada via script web nativo deles).
- **[Npcap](https://npcap.com/#download)**: Arquitetura de captura de pacotes para Windows (necessária para ferramentas de rede).
- **[CUDA-Z](https://cuda-z.sourceforge.net/)**: Utilitário leve de diagnóstico para placas de vídeo NVIDIA e CUDA.
- **[GLView](https://www.realtech-vr.com/home/)**: Ferramenta de diagnóstico e teste para extensões e capacidades OpenGL/Vulkan.
- **[Win32DiskImager](https://sourceforge.net/projects/win32diskimager/)**: Gravador de imagens RAW/IMG em pendrives (essencial para criar mídias de instalação de ISOs do Linux/BSD).
- **[Macrorit Partition Expert](https://macrorit.com/partition-magic-manager/partition-expert-download.html)**: Gerenciador de partições avançado. Não disponível no Winget; usar a versão portátil oficial baixada do site.

## 🛍️ Microsoft Store (Windows)

Aplicações nativas recomendadas para o host Windows, instaladas via loja oficial:

- **Microsoft PC Manager**: Otimização nativa de sistema provida pela Microsoft.
- **MSIX Packaging Tool**: Empacotamento de aplicações desktop para o formato moderno MSIX.
- **Pixel Art Studio Free**: Editor simples para pixel art e mockups rápidos.
- **Aquile Reader**: Leitor moderno de e-books (EPUB) e PDFs.
- **File Downloader**: Gerenciador de downloads simples integrado ao ecossistema Windows.

## 📱 Integração Dispositivos (Android ↔ PC)

Soluções específicas para transformar dispositivos móveis em periféricos temporários:

- **[Simple Protocol Player](https://github.com/kaytat/simpleprotocolplayer)**: Player de áudio via rede local. Fundamental para receber áudio do PC no celular quando o host não possui caixas de som ou saídas adequadas.
- **[IP Webcam (Google Play)](https://play.google.com/store/apps/details?id=com.pas.webcam&hl=pt_BR&pli=1)**: Transforma a câmera do smartphone em uma webcam de rede (via IP/RTSP) para uso pontual no host.
