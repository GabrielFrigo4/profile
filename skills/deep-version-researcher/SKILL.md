---
name: deep-version-researcher
description: Runbook cognitivo que instrui a IA a pesquisar ativamente na internet pelas versões mais recentes, notas de lançamento (release notes), manpages oficiais, novos recursos e especificações técnicas de softwares, sistemas e bibliotecas, combatendo conhecimento estático e desatualizado.
---

# 🔎 Deep Version Researcher Skill

Esta habilidade orienta o agente de IA a ser **proativo, investigativo e rigoroso** na pesquisa de versões atuais de softwares, ferramentas, bibliotecas e sistemas operacionais.

> [!IMPORTANT]
> **Combate ao Conhecimento Estático (Anti-Complacência):**
> Modelos de inteligência artificial operam com dados de treinamento congelados no tempo e frequentemente assumem práticas obsoletas, APIs descontinuadas ou versões ultrapassadas.
>
> Esta habilidade **PROÍBE a passividade**. Sempre que uma nova ferramenta, biblioteca, sistema operacional (como FreeBSD e Linux) ou padrão de linguagem for especificado ou integrado, o agente DEVE realizar pesquisas ativas na web para apurar o estado da arte real e atualizado.

---

## 🏛️ Hierarquia de Confiança de Fontes de Dados

Ao pesquisar informações técnicas e versões, consulte estritamente fontes primárias de alta reputação:

```
[Nível 1 - Máxima Autoridade]
Repositórios Oficiais / Manpages do Sistema (freebsd.org/cgi/man.cgi, man7.org)
Notas de Lançamento Oficiais (GitHub Releases, Changelog oficial dos mantenedores)
Sites de Padrões Oficiais (cppreference.com, standard POSIX, go.dev)
                    │
                    ▼
[Nível 2 - Repositórios de Pacotes Canônicos]
FreshPorts (FreeBSD), Fedora Packages, Arch Linux Package Repository, Debian Tracker
                    │
                    ▼
[Nível 3 - Documentações Oficiais de Projetos]
Docs oficiais dos mantenedores (ex: pocketbase.io, svelte.dev, neovim.io)
                    │
                    ▼
[Nível 4 - Fontes Proibidas para Tomada de Decisão]
Artigos de blogs de terceiros com mais de 2 anos, tutoriais desatualizados, fóruns sem curadoria
```

---

## 🔄 Protocolo de Investigação Ativa em 4 Etapas

Quando o agente for implementar código, sugerir dependências ou refatorar componentes:

### 1. Descoberta de Versão Estável e Funcionalidades Recentes

- Realize uma busca ativa utilizando a ferramenta de busca com termos precisos (ex: `"FreeBSD 14" release notes features`, `"PocketBase" latest release github`, `"Svelte 5" runes breaking changes`).
- Identifique:
    - Qual é a versão estável atual (_Current Stable_ / _GA_)?
    - Qual é a versão de desenvolvimento (_Current Dev_ / _Nightly_ / _CURRENT_)?
    - Quando foi lançada?

### 2. Análise de Mudanças Críticas (_Breaking Changes_ e Depreciações)

- Nunca utilize sintaxe antiga de uma ferramenta quando houver um substituto moderno e canônico aprovado pelos mantenedores.
- Exemplo 1: No Svelte 5, a reatividade mudou para _Runes_ (`$state`, `$derived`, `$props`). O agente não deve gerar sintaxe legada do Svelte 4 a menos que explicitamente solicitado.
- Exemplo 2: No FreeBSD 14+, o suporte a NVMe foi reformulado com o novo driver `nda` em vez de `nvd`, e o `/bin/sh` suporta novos recursos POSIX.

### 3. Verificação de Portabilidade e Suporte nos Sistemas Alvo

- A nova versão ou funcionalidade está disponível no FreeBSD (`pkg search`) e nas principais distribuições Linux (`dnf`, `apt`, `pacman`)?
- Caso seja um recurso muito novo disponível apenas em distribuições rolling-release, implemente um _fallback_ seguro ou configure uma verificação defensiva em tempo de execução via `command -v`.

### 4. Evidência e Justificativa no Código / Documentação

- Ao tomar uma decisão arquitetural baseada em uma versão recente, registre sucintamente nos metadados ou na documentação do componente o motivo técnico e a versão de referência.

---

## 📋 Checklist de Investigação para o Agente

Antes de propor ou escrever código com tecnologias de rápida evolução:

- [ ] Realizei pesquisa na web para checar a versão mais recente?
- [ ] Consultei as notas de lançamento (_Release Notes_) oficiais?
- [ ] Verifiquei se métodos ou comandos foram deprecados?
- [ ] Confirmei como o FreeBSD lida com este componente (pacote no `/usr/local`, serviço em `rc.d`)?
- [ ] A sintaxe utilizada representa o estado da arte moderno e limpo da ferramenta?
