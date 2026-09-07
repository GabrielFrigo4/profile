# 🧠 A Filosofia do Ecossistema

A visão e o design arquitetural de longo prazo para este ambiente de desenvolvimento baseiam-se em três princípios imutáveis. Este documento é a "Bíblia" que guia a aprovação de qualquer novo script, configuração ou tecnologia no repositório.

## 1. "Clean Host" (Isolamento Extremo)

A regra de ouro do ambiente é: **O sistema operacional nativo (o _host_) deve ser tratado como um santuário.**

Em vez de instalar e jogar dezenas de linguagens, bancos de dados e frameworks (ex: Node, Python, Postgres) diretamente no host, utilizamos tecnologias de virtualização e conteinerização para manter o SO original o mais puro possível.

O _host_ é responsável única e exclusivamente por:

- Prover a interface gráfica nativa em Wayland:
    - **Fedora Workstation:** GNOME Shell puro com Adwaita dark.
    - **FreeBSD Desktop:** KDE Plasma 6 Wayland.
- Gerenciar drivers de hardware (áudio, vídeo, rede).
- Executar os editores de código (IDEs) e navegadores.
- Rodar o _hypervisor_ ou agente de virtualização e containers.

Todo projeto, script complexo ou serviço de desenvolvimento **rodará isolado** do host.

### Vantagens dessa Abordagem

- **Reprodutibilidade:** Se você precisar configurar um hardware novo, seu projeto subirá idêntico, provendo as próprias dependências.
- **Limpeza Fácil:** Deletar um projeto remove todas as sujeiras do sistema associadas a ele. Não ficam pacotes órfãos ou versões conflitantes de linguagens esquecidas no host.
- **Portabilidade:** Padronização do fluxo de trabalho independente do sistema hospedeiro.

## 2. ZFS: A Base da Segurança e Flexibilidade

Não é possível ter uma arquitetura verdadeiramente robusta e baseada em containers sem um sistema de arquivos à altura. O **ZFS** é adotado como cidadão de primeira classe (seja no FreeBSD nativo ou no Linux via OpenZFS).

O ZFS garante:

- **Snapshots Instantâneos:** Capacidade de criar pontos de restauração do sistema antes de qualquer teste arriscado, permitindo _rollbacks_ em milissegundos.
- **Criptografia Nativa:** Segurança de dados fundamental.
- **Integração com Containers/VMs:** É a fundação perfeita para armazenar as raízes dos containers (LXC, Jails) e discos virtuais de hypervisors (ZVOLs), permitindo clonagem quase instantânea de ambientes.

## 3. "Uma coisa, um lugar" (A Tríade de Modularidade)

Para evitar configurações espaguete, o ambiente de desenvolvimento foi desmembrado em três repositórios com fronteiras rígidas:

1. **Configuration (Este Repositório):** Focado no provisionamento da máquina e na configuração estática (dotfiles dos editores, formatação do sistema, receitas modulares). Ele funciona como um **Livro de Receitas (Cookbook)** do GitHub: você acessa diretamente pela web, copia o que precisa ou executa receitas atômicas. Não exige clone obrigatório.
2. **Shell (Repositório Dinâmico):** Focado no comportamento ativo. Ali ficam todos os aliases, funções e utilitários que comandam o terminal no dia a dia. É clonado e carregado continuamente a cada sessão.
3. **Vault (Repositório Privado):** Gerencia todos os segredos. O Configuration e o Shell nunca devem ter chaves SSH ou senhas "hardcoded". Eles apenas lêem do Vault.

Essa modularidade significa que você pode atualizar suas preferências de terminal (Shell) sem tocar na infraestrutura (Configuration), e gerenciar credenciais (Vault) sem arriscar vazar senhas ao compartilhar as configurações de sistema.
