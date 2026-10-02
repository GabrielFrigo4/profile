# 🎯 Tom de Voz, Sobriedade & Economia de Contexto

A excelência em documentação técnica fundamenta-se na precisão, na serenidade e na parcimônia. Toda redação no ecossistema elimina ruído retórico, teatralidade e token-bloat, operando sob uma dicotomia funcional estrita.

---

## 🏛️ A Dicotomia Funcional de Estilo

### 1. Documentação de Sistema & Agentes de IA (`AGENTS.md`, `.agents/rules/`, `skills/`)

- **Princípio da Máxima Densidade de Sinal (Signal-to-Noise Ratio):** Cada token consumido na janela de contexto deve carregar valor instrutivo puro.
- **Gramática Declarativa Contrastiva (RFC 2119 Sóbrio):**
  Instruções devem seguir o formato direto:
    ```markdown
    - **<Tópico>:** <Diretriz imperativa clara>.
        - Evite: <Anti-padrão técnico conciso>.
        - Use: <Padrão canônico recomendado>.
    ```
- **Banimento de Melodrama & Hiperadjetivação:**
    - Não use expressões dramáticas ou jurídicas (_"terminantemente proibido"_, _"proibição absoluta"_, _"erro fatal"_, _"cláusulas pétreas"_, _"sob pena de nulidade/falha"_). Modelos de IA não aderem mais por superlativos; respondem à clareza contrastiva.
    - Elimine advérbios intensificadores vazios (_"rigorosamente"_, _"estritamente"_, _"expressamente"_).
    - Elimine maiúsculas emotivas (_"NUNCA"_, _"JAMAIS"_, _"NADA"_).
- **Matriz de Shells e Escapes:**
    - Shells suportados: `zsh`, `bash`, FreeBSD `/bin/sh`, OpenBSD `/bin/ksh`. Não adapte para Debian `dash` ou NetBSD `sh`.
    - Escapes ANSI: utilize sempre `$'\e'` (em Makefiles: `_e=$$'\e';`) ou `\x1b`. Octal (`\033`) é exclusivo para permissões POSIX (`chmod 0755`).

### 2. Documentação Humana (`README.md`, `PRINCIPLES.md`, Manuais Técnicos)

- **Tom "Quiet Engineering Competence":** Redação confiante, técnica, serena e reader-first.
- **Foco Arquitetural:** Explique o problema, o mecanismo e a solução com clareza conceitual e diagramas limpos.
- **Sem Paranoia ou Ameaças:** Substitua avisos alarmistas por notas técnicas objetivas (`> [!NOTE]` ou `> [!IMPORTANT]`).

---

## 📊 Matriz de Transformação: Do Dramático ao Técnico

| Antes (Ruído Retórico / Token-Bloat)                                                 | Depois (Técnico / Alta Densidade)                                       |
| :----------------------------------------------------------------------------------- | :---------------------------------------------------------------------- |
| _"É terminantemente proibido utilizar octal para escapes sob pena de quebra fatal."_ | _"Escapes ANSI: use `$'\e'` ou `\x1b`. Não use octal (`\033`)."_        |
| _"Proibição absoluta e irrestrita de comentários narrativos no código-fonte."_       | _"Comentários narrativos: proibidos. Código deve ser autoexplicativo."_ |
| _"Erro Fatal (Monólito): arquivos acima de 256 linhas são inaceitáveis."_            | _"Teto máximo: 256 linhas. Modularize componentes acima desse limite."_ |
| _"Cláusulas pétreas inegociáveis de engenharia."_                                    | _"Regras canônicas de engenharia."_                                     |
| _"Absolutamente NADA deve ser alterado sem autorização expressa."_                   | _"Alterações exigem validação prévia."_                                 |
