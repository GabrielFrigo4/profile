#!/usr/bin/env sh
# ----------------------------------------------------------------
# Recipe: [Nome do Software / Funcionalidade]
# ----------------------------------------------------------------
set -eu

echo "📦 [Nome]: Iniciando configuração..."

ELEVATE="$( [ "$(id -u)" -ne 0 ] && { command -v doas > "/dev/null" 2>&1 && echo "doas" || { command -v sudo > "/dev/null" 2>&1 && echo "sudo"; }; } )"

echo "✅ [Nome]: Configurado com sucesso!"
