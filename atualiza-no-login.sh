#!/usr/bin/env bash
set -euo pipefail

notify_send() {
  local title="$1"
  local body="$2"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$title" "$body"
  fi
}

notify_send "Atualizacao automatica" "Atualizacao iniciada apos 30 segundos da sessao."

if sudo /usr/bin/systemctl start --wait atualiza-sistema.service; then
  notify_send "Atualizacao automatica" "Atualizacao concluida com sucesso."
else
  notify_send "Atualizacao automatica" "Atualizacao falhou. Verifique os logs."
  exit 1
fi
