# 🚦 Armadilhas de Kernel TTY & O Padrão PTY (`script -q /dev/null`) em CI Headless

> Análise aprofundada de comportamento de drivers TTY em pipelines de automação e integração contínua (CI/CD).

---

## 1. A Divergência de Kernels na Syscall `tcsetpgrp()`

Ao executar testes que envolvem inicialização de shells interativos (`-i`) em pipelines headless de CI/CD (GitHub Actions, SSH sem PTY, VMs QEMU):

1. **Linux & macOS:** Detectam ausência de terminal controlador. A syscall falha retornando `ENOTTY` ou `EPERM`, o shell emite aviso inofensivo no stderr (`no job control in background`) e prossegue com a execução lendo os arquivos RC.
2. **OpenBSD & NetBSD:** Tratam a ausência de terminal com retorno de erro sem disparo de sinal suspensivo.
3. **FreeBSD (`kern/kern_tty.c`):** O kernel do FreeBSD segue estritamente a especificação clássica BSD: qualquer processo em background que tente invocar `tcsetpgrp()` sem PTY controlador recebe **imediatamente o sinal `SIGTTIN` (sinal 21)**.
    - Como a ação padrão de `SIGTTIN` é suspender a execução (`SIGSTOP`), o processo entra no estado `T` (stopped) e a VM congela em loop infinito.

---

## 2. O Padrão Canônico: Alocação de PTY com `script(1)`

Em vez de desativar o modo interativo (o que ignoraria o `~/.bashrc` e travaria na _Interactive Guard_), aloque um pseudo-terminal (PTY) sob demanda com o utilitário nativo `script`:

```sh
# FreeBSD: Aloca PTY real (/dev/pts), satisfaz o kernel e evita SIGTTIN
script -q /dev/null bash -i -c 'echo "Prompt OK: ${PS1}"'
ENV="${HOME}/.shrc" script -q /dev/null sh -i -c 'echo "Prompt OK: ${PS1}"'
```

- O `script` do FreeBSD base aloca `/dev/pts`, torna o processo líder de terminal e garante que `tcsetpgrp()` conclua com sucesso.

---

## 3. Alternativa em GNU Bash (`+m`)

```sh
bash +m -i -c 'echo "Prompt OK: ${PS1}"'
```

A flag `+m` desativa o _monitor mode_ (job control), impedindo o Bash de invocar `tcsetpgrp()`, enquanto `-i` preserva o modo interativo e executa o `.bashrc`.

---

## 4. Por que a flag `-i` é insubstituível em testes reais de dotfiles

Arquivos RC canônicos protegem-se com uma _Interactive Guard_ no cabeçalho (`case "$-" in *i*) ;; *) return ;; esac`). Sem a flag `-i`, o arquivo RC é interrompido de imediato, gerando falsos positivos nos testes. O modo `-i` é o único que valida aliases, prompts, temas e detecção de contexto de ponta a ponta.
