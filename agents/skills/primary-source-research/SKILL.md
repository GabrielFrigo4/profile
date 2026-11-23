---
name: primary-source-research
description: >-
    Protocolo para investigação de causa raiz e verificação ativa em fontes primárias
    (código-fonte upstream, especificações formais, manpages e release notes). Ativar
    ao diagnosticar falhas, validar schemas ou selecionar versões atuais de ferramentas.
---

# 🔍 Primary Source Research — Causa Raiz & Fontes Primárias

Esta skill estabelece o protocolo investigativo contra suposições estáticas e soluções paliativas ao diagnosticar falhas de compilação, schemas, APIs de sistemas operacionais ou seleção de versões estáveis.

---

## 🏛️ 1. Hierarquia de Autoridade das Fontes

Consulte sempre do maior para o menor grau de autoridade técnica:

1. **Nível 1 — Código-Fonte Upstream & Especificações Formais:** Padrões ISO/IEC, POSIX.1, schemas JSON/YAML oficiais e árvores de código upstream (compiladores, kernels, ferramentas).
2. **Nível 2 — Manpages & Documentação Canônica da Plataforma:** Manuais oficiais do sistema (`man.freebsd.org`, `kernel.org/doc/man-pages`, `man.openbsd.org`, `cppreference.com`) e documentação mantida pelos autores originais.
3. **Nível 3 — Release Notes & Changelogs Oficiais:** Notas de lançamento oficiais (`releases`, changelogs no repositório, repositórios de pacotes como FreshPorts, Fedora, Debian Tracker, Arch).
4. **Nível 4 (Não Autoritativo):** Posts de blog antigos, tutoriais de terceiros sem curadoria e suposições baseadas em memória estática de treinamento.

---

## ⚖️ 2. Postura Investigativa vs. Especulação

| Dimensão               | Evite (Anti-padrão)                       | Use (Investigação Primária)                               |
| :--------------------- | :---------------------------------------- | :-------------------------------------------------------- |
| **Versões & APIs**     | Assumir APIs antigas por memória estática | Consultar release notes atuais e flags não-deprecadas     |
| **Schemas de Config**  | Supor chaves por analogia                 | Validar diretamente contra o schema oficial da ferramenta |
| **Erro de Compilação** | Testar flags aleatoriamente               | Inspecionar diagnóstico, padrão da linguagem e manpage    |
| **Temporização/Rede**  | Inserir `sleep` arbitrários               | Inspecionar retornos de syscalls, sockets e handshakes    |
| **Contorno de Falha**  | Mascarar erros com redirects ou shims     | Corrigir a causa raiz na definição canônica               |

---

## 📋 3. Protocolo Operacional em 4 Etapas

1. **Isolar & Reproduzir:** Capture a linha exata, código de retorno, sinal ou chave rejeitada com reprodução mínima determinística.
2. **Apurar Versão & Ground Truth:** Verifique via busca ativa ou CLI (`gh release view`, manpage local) a versão estável corrente, breaking changes, depreciações e suporte nos sistemas alvo (usando `command -v` quando houver diferença entre plataformas).
3. **Diagnosticar a Causa Raiz:** Explique estruturalmente por que a falha ocorre antes de editar arquivos.
4. **Corrigir na Origem:** Aplique alteração limpa e atômica sem shims residuais e valide com linters e suíte de testes.

---

## ✅ 4. Checklist Pré-Implementação

- [ ] A versão estável e sintaxe atual foram verificadas em fonte oficial ou release notes recentes?
- [ ] Métodos ou chaves marcados como obsoletos no changelog foram substituídos pela alternativa moderna?
- [ ] A portabilidade entre os sistemas operacionais alvo (Linux, FreeBSD, OpenBSD, macOS, MSYS2) foi conferida?
- [ ] A correção ataca a causa raiz em vez de silenciar o sintoma?
