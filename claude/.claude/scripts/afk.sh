#!/usr/bin/env bash
# AFK system — single source of truth for state paths, log/brief format, and
# hook-side enforcement. See skills/.agents/skills/afk/SYSTEM.md.
#
# Skill-facing (session id from $CLAUDE_CODE_SESSION_ID):
#   afk.sh on | off | log <decision|done|deferred|blocker> | brief
# Hook-facing (reads hook JSON on stdin, session id from JSON):
#   afk.sh hook
set -euo pipefail

AFK_DIR="$HOME/.claude/afk"
SELF="$HOME/.claude/scripts/afk.sh"

flag_f()  { echo "$AFK_DIR/$1"; }
log_f()   { echo "$AFK_DIR/$1.log.md"; }
brief_f() { echo "$AFK_DIR/$1.brief.md"; }

need_sid() {
  SID="${CLAUDE_CODE_SESSION_ID:-}"
  [ -n "$SID" ] || { echo "afk: CLAUDE_CODE_SESSION_ID not set" >&2; exit 1; }
}

cmd_on() {
  need_sid
  mkdir -p "$AFK_DIR"
  if [ -e "$(flag_f "$SID")" ]; then
    echo "Already AFK — no change."
    return
  fi
  touch "$(flag_f "$SID")"
  echo "AFK on. Unattended until /back. Log: $(log_f "$SID")"
}

cmd_off() {
  need_sid
  if [ ! -e "$(flag_f "$SID")" ]; then
    echo "Not AFK — nothing to report."
    return
  fi
  rm -f "$(flag_f "$SID")"
  make_brief "$SID" | tee "$(brief_f "$SID")"
}

cmd_log() {
  need_sid
  local type="${1:-}"
  case "$type" in
    decision|done|deferred|blocker) ;;
    *) echo "afk: usage: afk.sh log decision|done|deferred|blocker  (body on stdin)" >&2; exit 1 ;;
  esac
  mkdir -p "$AFK_DIR"
  { printf '\n## %s [%s]\n\n' "$(date '+%Y-%m-%d %H:%M')" "$type"; cat; } >> "$(log_f "$SID")"
  echo "logged: $type"
}

cmd_brief() {
  need_sid
  make_brief "$SID"
}

make_brief() {
  local sid="$1" lf
  lf="$(log_f "$sid")"
  if [ ! -s "$lf" ]; then
    printf '# AFK brief\n\nNo decisions were logged this AFK period.\n'
    return
  fi
  awk -v sid="$sid" '
    /^## [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] [0-9][0-9]:[0-9][0-9] \[(decision|done|deferred|blocker)\]$/ {
      ts = $2 " " $3
      cur = $4; gsub(/[\[\]]/, "", cur)
      buf[cur] = buf[cur] "\n### " ts "\n"
      next
    }
    cur != "" {
      buf[cur] = buf[cur] $0 "\n"
      if (cur == "decision" && $0 ~ /^\*\*Reversal:\*\*/) {
        line = $0; sub(/^\*\*Reversal:\*\*[ ]*/, "", line)
        if (line != "" && tolower(line) !~ /^none/) rev = rev "- " ts " — " line "\n"
      }
    }
    END {
      printf "# AFK brief — session %s\n", sid
      emit("done", "Accomplished")
      emit("decision", "Decisions")
      emit("deferred", "Deferred — run these yourself")
      emit("blocker", "Blockers")
      if (rev != "") printf "\n## Reversals\n%s", rev
    }
    function emit(key, title) {
      if (buf[key] != "") printf "\n## %s%s", title, buf[key]
    }
  ' "$lf"
}

# Irreversible-command blocklist (guardrail, not policy — edit to taste).
blocked() {
  local c="$1" p
  local patterns=(
    'git push[^|;&]* (-f|--force|--force-with-lease|--delete|--prune|--mirror)'
    'git (rebase|filter-branch|filter-repo)'
    'git reflog expire|git gc [^|;&]*--prune'
    'git commit[^|;&]* --amend'
    'git reset[^|;&]* --hard'
    'git clean[^|;&]* -[A-Za-z]*f'
    'git branch[^|;&]* -[A-Za-z]*D'
    'git tag[^|;&]* (-d|--delete)'
    'git checkout[^|;&]* -- \.'
    '(^|[^[:alnum:]_-])rm +(-[A-Za-z]+ +)*-[A-Za-z]*r'
    '(^|[^[:alnum:]_-])rm +[^|;&]*--recursive'
    'find [^|;&]* -delete'
    '(npm|pnpm|yarn) publish|cargo publish|gem push|twine upload'
    'gh (pr merge|release create|repo delete)'
    'terraform (apply|destroy)'
    '(vercel|netlify|fly|wrangler)[^|;&]* (deploy|--prod)'
    'kubectl (delete|drain)'
    '(DROP|drop|TRUNCATE|truncate) +(TABLE|table|DATABASE|database)'
    '(prisma migrate reset|rails db:(drop|reset))'
  )
  for p in "${patterns[@]}"; do
    grep -qE "$p" <<<"$c" && return 0
  done
  return 1
}

cmd_hook() {
  local input sid event
  input=$(cat)
  sid=$(jq -r '.session_id // empty' <<<"$input")
  event=$(jq -r '.hook_event_name // empty' <<<"$input")
  [ -n "$sid" ] || return 0

  case "$event" in
    SessionStart)
      case "$(jq -r '.source // empty' <<<"$input")" in
        compact)
          if [ -e "$(flag_f "$sid")" ]; then
            jq -n --arg ctx "AFK mode active — session unattended until /back.
Decision log (disk only): append via $SELF log <decision|done|deferred|blocker>, body on stdin.
No questions; log nontrivial decisions; irreversible steps are log-and-defer." \
              '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$ctx}}'
          fi
          ;;
        resume|clear)
          # Back at the keyboard — AFK never survives resume/clear.
          rm -f "$(flag_f "$sid")"
          local tp osid
          tp=$(jq -r '.transcript_path // empty' <<<"$input")
          if [ -n "$tp" ]; then
            osid=$(basename "$tp" .jsonl)
            [ "$osid" != "$sid" ] && rm -f "$(flag_f "$osid")"
          fi
          ;;
        startup)
          # Backstop for sessions killed without SessionEnd: flags after 2
          # days, logs/briefs after 30.
          [ -d "$AFK_DIR" ] || return 0
          find "$AFK_DIR" -maxdepth 1 -type f ! -name '*.md' -mtime +2 -delete 2>/dev/null || true
          find "$AFK_DIR" -maxdepth 1 -type f -name '*.md' -mtime +30 -delete 2>/dev/null || true
          ;;
      esac
      ;;
    SessionEnd)
      if [ -e "$(flag_f "$sid")" ]; then
        make_brief "$sid" > "$(brief_f "$sid")"
        rm -f "$(flag_f "$sid")"
      fi
      ;;
    PreToolUse)
      [ -e "$(flag_f "$sid")" ] || return 0
      local cmdline
      cmdline=$(jq -r '.tool_input.command // empty' <<<"$input")
      [ -n "$cmdline" ] || return 0
      if blocked "$cmdline"; then
        jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",
          permissionDecisionReason:"AFK: irreversible — log a deferred entry with the exact command, take a reversible equivalent, continue."}}'
      fi
      ;;
    Stop)
      [ -e "$(flag_f "$sid")" ] || return 0
      [ "$(jq -r '.stop_hook_active // false' <<<"$input")" = "true" ] && return 0
      jq -n --arg r "AFK: append any unlogged decisions ($SELF log …). If the task is complete, run: $SELF brief > $(brief_f "$sid") and mention that path; otherwise continue working." \
        '{decision:"block",reason:$r}'
      ;;
  esac
}

case "${1:-}" in
  on)    cmd_on ;;
  off)   cmd_off ;;
  log)   shift; cmd_log "$@" ;;
  brief) cmd_brief ;;
  hook)  cmd_hook ;;
  *) echo "usage: afk.sh on|off|log <type>|brief|hook" >&2; exit 1 ;;
esac
