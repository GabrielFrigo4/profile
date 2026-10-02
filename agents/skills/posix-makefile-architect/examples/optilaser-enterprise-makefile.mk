.POSIX:
.SILENT:

MAKEFLAGS += --no-print-directory -s

APP             = optilaser
CMD             = ./cmd/optilaser
VERSION        != cat VERSION 2> "/dev/null" || echo 0.0.0-dev
FLAVOR         != cat FLAVOR 2> "/dev/null" || echo linux

CONTAINER_RT   ?= podman
IMAGE_NAME      = optilaser
PORT           ?= 8080
SUDO_DEFAULT   != if [ "$$(uname -s)" = "FreeBSD" ] && [ "$$(id -u)" != "0" ]; then if command -v sudo > "/dev/null" 2>&1; then echo "sudo"; elif command -v doas > "/dev/null" 2>&1; then echo "doas"; else echo ""; fi; else echo ""; fi
SUDO           ?= $(SUDO_DEFAULT)

.PHONY: all dev run stop restart build test logs status ps shell exec clean prune purge help

all: dev

# Atalhos Ergonômicos Principais:
dev:        container-dev
run:        container-run
stop:       container-stop
restart:    container-restart
build:      container-build
test:       container-test
logs:       container-logs
status:     container-status
ps:         container-ps
shell:      container-shell
exec:       container-exec
clean:      container-clean
prune:      container-prune
purge:      container-purge

help:
	cmd() { printf "    \x1b[36mmake %-42s\x1b[0m %s\n" "$$1" "$$2"; }; \
	sec() { printf "\n  \x1b[1;33m%s\x1b[0m\n" "$$1"; }; \
	sub() { printf "  \x1b[1;34m  ── %s ──\x1b[0m\n" "$$1"; }; \
	var() { printf "    \x1b[35m%-47s\x1b[0m %s\n" "$$1" "$$2"; }; \
	printf "\n  \x1b[1;37m$(APP) — Catálogo de Comandos Makefile\x1b[0m (v%s)\n" "$(VERSION)"; \
	printf "  ============================================================\n"; \
	sec "Fluxo Principal (Container-First via Podman OCI):"; \
	sub "Execução & Desenvolvimento"; \
	cmd "dev"                                     "Executar container interativo com logs ao vivo"; \
	cmd "run"                                     "Iniciar container em background (daemon)"; \
	cmd "stop"                                    "Parar container em execução"; \
	cmd "build"                                   "Construir imagem OCI do flavor ativo"; \
	cmd "test"                                    "Executar suíte de testes dentro do container"; \
	sub "Diagnóstico & Shell"; \
	cmd "status"                                  "Exibir diagnóstico completo (containers, volumes)"; \
	cmd "logs"                                    "Acompanhar logs do serviço em tempo real"; \
	cmd "shell"                                   "Abrir terminal interativo no container"; \
	sub "Limpeza & Manutenção"; \
	cmd "clean"                                   "Remover imagens finais compiladas (mantém cache)"; \
	cmd "prune"                                   "Faxina de containers mortos e imagens órfãs"; \
	cmd "purge"                                   "Limpeza profunda de containers, volumes e banco"; \
	sec "Variáveis Customizáveis:"; \
	var "PORT=8080"                               "Porta de escuta do serviço HTTP"; \
	var "CONTAINER_RT=podman"                     "Runtime OCI (podman ou docker)"; \
	echo ""
