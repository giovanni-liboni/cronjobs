#!/usr/bin/env bash
set -euo pipefail

log() {
  # Prepend timestamps to log messages for easier debugging under cron.
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

error() {
  log "ERROR: $*"
  exit 1
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Command '$1' not found on PATH. Install it before running this script."
  fi
}

require_command "cc-switch"
CLAUDE_CMD="${CLAUDE_CMD:-claude}"
require_command "$CLAUDE_CMD"

MESSAGE="${CLAUDE_MESSAGE:-Hello from the Claude daily cron job.}"
ACCOUNT_SPEC="${CLAUDE_ACCOUNTS:-}"

if [[ -z "$ACCOUNT_SPEC" ]]; then
  error "Set CLAUDE_ACCOUNTS to a comma-separated list of cc-switch configuration names."
fi

IFS=',' read -r -a ACCOUNT_NAMES <<< "$ACCOUNT_SPEC"

# Parse any extra Claude CLI arguments supplied via CLAUDE_ARGS.
CLAUDE_ARGS_STRING="${CLAUDE_ARGS:-}"
CLAUDE_ARGS=()
if [[ -n "$CLAUDE_ARGS_STRING" ]]; then
  # shellcheck disable=SC2206  # Intentional to allow simple word-splitting on spaces.
  CLAUDE_ARGS=($CLAUDE_ARGS_STRING)
fi

log "Starting daily Claude notification."

for raw_account in "${ACCOUNT_NAMES[@]}"; do
  account="$(printf '%s' "$raw_account" | xargs)"  # trim whitespace
  if [[ -z "$account" ]]; then
    continue
  fi

  safe_account="$(printf '%s' "$account" | tr -c '[:alnum:]-_' '_')"
  cc_switch_log="/tmp/cc-switch-${safe_account}-$$.log"
  claude_log="/tmp/claude-${safe_account}-$$.log"

  log "Switching to Claude account '$account'."
  if ! cc-switch use "$account" >"$cc_switch_log" 2>&1; then
    log "Failed to switch to account '$account'. See $cc_switch_log for details."
    continue
  fi

  log "Sending message with '$CLAUDE_CMD' for account '$account'."
  if ! printf '%s\n' "$MESSAGE" | "$CLAUDE_CMD" "${CLAUDE_ARGS[@]}" >"$claude_log" 2>&1; then
    log "Claude command failed for account '$account'. See $claude_log for details."
    continue
  fi

  log "Message sent successfully for account '$account'."
done

log "Claude notification run complete."
