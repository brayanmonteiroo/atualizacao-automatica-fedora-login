#!/usr/bin/env bash
set -euo pipefail

echo "[$(date)] Iniciando atualizacao do sistema..."
dnf upgrade --refresh -y
flatpak update -y
echo "[$(date)] Atualizacao concluida."
