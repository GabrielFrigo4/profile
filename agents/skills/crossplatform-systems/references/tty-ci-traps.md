# 🚦 Armadilhas de Kernel TTY & O Padrão PTY (`script -q /dev/null`) em CI Headless

> Análise de comportamento de drivers TTY em pipelines de automação e integração contínua sem terminal controlador.

---

## 1. Divergência de Kernels na Syscall `tcsetpgrp()`

Ao executar testes de inicialização interativa (`-i`) em runners headless (CI/CD, SSH sem PTY, VMs):

1. **Linux & macOS:** Retornam `ENOTTY`/`EPERM` na ausência de terminal controlador e prosseguem executando os arquivos RC com aviso não fatal.
2. **OpenBSD & NetBSD:** Retornam erro sem suspender o processo.
3. **FreeBSD (`kern/kern_tty.c`):** Envia `SIGTTIN` (sinal `21`) a processos em background sem PTY controlador que invoquem `tcsetpgrp()`, suspendendo o processo em estado `T` (`SIGSTOP`) e travando o pipeline.

---

## 2. Alocação de PTY Sob Demanda com `script(1)`

Em vez de suprimir `-i` (o que aciona a guarda interativa dos dotfiles e gera falsos positivos), aloque um pseudo-terminal (`/dev/pts`):

```sh
script -q /dev/null bash -i -c 'echo "Prompt OK: ${PS1}"'
ENV="${HOME}/.shrc" script -q /dev/null sh -i -c 'echo "Prompt OK: ${PS1}"'
```

---

## 3. Alternativa em GNU Bash (`+m`)

```sh
bash +m -i -c 'echo "Prompt OK: ${PS1}"'
```

A flag `+m` desativa o _monitor mode_ (job control), evitando chamadas a `tcsetpgrp()` enquanto mantém o carregamento completo do `.bashrc`.

---

## 4. Importância da Flag `-i` em Testes de Dotfiles

Arquivos RC iniciam com guarda interativa (`case "$-" in *i*) ;; *) return ;; esac`). O modo `-i` garante validação real de aliases, prompts, detecção de ambiente e temas de ponta a ponta.
