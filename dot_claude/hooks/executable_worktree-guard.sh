#!/usr/bin/env bash
# PreToolUse/Bash guard for git worktree sessions (portable, dotfile-safe).
#
# In a Claude worktree (cwd under .claude/worktrees/), deny any Bash command
# matching a project's block patterns. This file carries NO project knowledge:
# patterns and the deny reason come from local drop-ins under worktree-guard.d/,
# so machine-specific rules stay out of the dotfiles repo. With no drop-ins it
# no-ops. Drop-ins are sourced and may append to BLOCK_PATTERNS and set REASON.
set -euo pipefail

input=$(cat)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')

# Only guard inside Claude-created worktrees; elsewhere defer to normal flow.
case "$cwd" in
  */.claude/worktrees/*) ;;
  *) exit 0 ;;
esac

BLOCK_PATTERNS=()
REASON='Blocked by worktree guard: this command is disallowed in worktree sessions.'

dropin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/worktree-guard.d"
if [[ -d "$dropin_dir" ]]; then
  for f in "$dropin_dir"/*.sh; do
    [[ -e "$f" ]] || continue   # no-glob-match guard
    # shellcheck source=/dev/null
    source "$f"
  done
fi

[[ ${#BLOCK_PATTERNS[@]} -eq 0 ]] && exit 0

for re in "${BLOCK_PATTERNS[@]}"; do
  if printf '%s' "$cmd" | grep -Eq "$re"; then
    jq -n --arg r "$REASON" \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
    exit 0
  fi
done
exit 0
