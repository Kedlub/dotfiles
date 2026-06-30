#!/usr/bin/env bash
# Stop hook: reinforce the attention ping. The sound/banner itself comes from the
# model calling PushNotification (PreToolUse -> notify.sh attention), which keeps
# the message personalized and lets the model — the only party that knows whether
# other background tasks are still running — decide if a real handoff happened.
# A plain Stop sound can't make that call (it fires on every turn-end, incl.
# background-resumes), so instead of sounding we nudge the model once if it ended
# a long working turn without pinging. A per-turn marker caps it at one nudge,
# and the nudge is non-error feedback (additionalContext), not a blocking error.
set -eu

# Only nudge once a working turn has run this long — a rough "you likely stepped
# away" proxy, so quick interactive turns don't get a forced extra round-trip.
THRESHOLD_SECONDS=90

input="$(cat)"

# Already nudged once this handoff, or an abnormal stop: let it stop.
[ "$(jq -r '.stop_hook_active // false' <<<"$input" 2>/dev/null || echo false)" = "true" ] && exit 0
[ "$(jq -r '.stop_reason // "end_turn"' <<<"$input" 2>/dev/null || echo end_turn)" = "end_turn" ] || exit 0

tpath="$(jq -r '.transcript_path // empty' <<<"$input" 2>/dev/null || true)"
[ -n "$tpath" ] && [ -f "$tpath" ] || exit 0   # can't inspect -> don't interfere
sid="$(jq -r '.session_id // "nosession"' <<<"$input" 2>/dev/null || echo nosession)"

# Scope to the current turn (entries after the last genuine user prompt — a
# user message with string content; tool_result messages are role:user too but
# carry an array of tool_result blocks). Classify the turn: already pinged, no
# real work, too short to matter, or a long working turn that forgot to ping.
# Tail-bounded so huge transcripts stay cheap.
result="$(tail -n 600 "$tpath" 2>/dev/null | jq -rs --argjson t "$THRESHOLD_SECONDS" '
  def is_prompt:
    .type == "user"
    and ( (.message.content | type) == "string"
          or ((.message.content | type) == "array"
              and ((.message.content | map(.type) | index("tool_result")) | not)) );
  (map(is_prompt)) as $f
  | ([range(0; ($f | length)) | select($f[.])] | last) as $u
  | (if $u == null then 0 else $u + 1 end) as $start
  | (if $u == null then null else .[$u].timestamp end) as $uts
  | [ .[$start:][]
      | select(.type == "assistant")
      | .message.content[]
      | select(.type == "tool_use") ] as $tools
  | (if $uts == null then 0
     else now - ($uts | sub("\\.[0-9]+Z$"; "Z") | fromdateiso8601) end) as $dur
  | (if ($tools | any(.name == "PushNotification")) then "pinged"
     elif ($tools | length) == 0 then "idle"
     elif $dur < $t then "short"
     else "worked" end) as $v
  | "\($v) \($uts // "none")"
' 2>/dev/null || echo "error none")"

read -r verdict turnkey <<<"$result"

# Only nudge a long working turn that forgot to ping. Anything else -> stop.
[ "$verdict" = "worked" ] || exit 0

# Nudge at most once per user turn. additionalContext (below) continues the
# conversation, so without a guard the continuation could re-trigger this. Key a
# marker on session + the turn's starting prompt timestamp; prune stale ones.
mdir="${TMPDIR:-/tmp}/claude-stop-nudge"
mkdir -p "$mdir" 2>/dev/null || true
marker="$mdir/$(printf '%s' "${sid}-${turnkey}" | tr -c 'A-Za-z0-9._-' '_')"
[ -e "$marker" ] && exit 0
: > "$marker"
find "$mdir" -type f -mtime +1 -delete 2>/dev/null || true

# Non-error feedback (not decision:block) so it doesn't render as an error; it
# still continues the conversation so the ping can happen on a real handoff.
jq -n '{
  hookSpecificOutput: {
    hookEventName: "Stop",
    additionalContext: ("You ended a working turn without calling PushNotification. "
      + "If you are genuinely handing control back and I may have stepped away, "
      + "call PushNotification now with a short, specific message. If background "
      + "tasks are still running, or I am clearly still here, just stop. Do not "
      + "narrate this — either call the tool or stop.")
  }
}'
