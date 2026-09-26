#!/usr/bin/env bash
# Status line: <bold+colored tokens>(<dimmed percentage>)
# Color coding (Rosé Pine): foam < 50%, gold 50–80%, love > 80%

input=$(cat)

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
total_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
model=$(echo "$input" | jq -r '.model.display_name // ""')
effort=$(echo "$input" | jq -r '.effort.level // ""')

# ANSI codes
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[38;2;110;106;134m'  # muted #6e6a86

# Rosé Pine palette (24-bit truecolor)
pct_int=${used_pct%.*}
if (( pct_int >= 80 )); then
  COLOR='\033[38;2;235;111;146m'  # love #eb6f92
elif (( pct_int >= 50 )); then
  COLOR='\033[38;2;246;193;119m'  # gold #f6c177
else
  COLOR='\033[38;2;156;207;216m'  # foam #9ccfd8
fi

# Shorten token count: 142350 -> 142k, 1500000 -> 1.5M
if (( total_tokens >= 1000000 )); then
  tokens_fmt="$(( total_tokens / 1000000 )).$(( total_tokens % 1000000 / 100000 ))M"
elif (( total_tokens >= 1000 )); then
  tokens_fmt="$(( total_tokens / 1000 ))k"
else
  tokens_fmt="$total_tokens"
fi

# Git: <branch> +staged ~modified ?untracked ↑ahead ↓behind
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
if [[ -n "$cwd" ]] && git_out=$(git -C "$cwd" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null); then
  branch="" ahead=0 behind=0 staged=0 modified=0 untracked=0
  while IFS= read -r line; do
    case "$line" in
      "# branch.head "*) branch=${line#\# branch.head } ;;
      "# branch.oid "*) oid=${line#\# branch.oid } ;;
      "# branch.ab "*)
        read -r _ _ a b <<<"$line"
        ahead=${a#+} behind=${b#-}
        ;;
      "? "*) untracked=$(( untracked + 1 )) ;;
      "u "*) staged=$(( staged + 1 )); modified=$(( modified + 1 )) ;;
      [12]" "*)
        xy=${line:2:2}
        [[ ${xy:0:1} != "." ]] && staged=$(( staged + 1 ))
        [[ ${xy:1:1} != "." ]] && modified=$(( modified + 1 ))
        ;;
    esac
  done <<<"$git_out"
  [[ "$branch" == "(detached)" ]] && branch=${oid:0:7}

  IRIS='\033[38;2;196;167;231m'  # iris #c4a7e7
  FOAM='\033[38;2;156;207;216m'  # foam #9ccfd8
  GOLD='\033[38;2;246;193;119m'  # gold #f6c177
  LOVE='\033[38;2;235;111;146m'  # love #eb6f92

  printf "${IRIS}%s${RESET}" "$branch"
  (( staged > 0 )) && printf " ${FOAM}+%d${RESET}" "$staged"
  (( modified > 0 )) && printf " ${GOLD}~%d${RESET}" "$modified"
  (( untracked > 0 )) && printf " ${LOVE}?%d${RESET}" "$untracked"
  (( ahead > 0 )) && printf " ${DIM}↑%d${RESET}" "$ahead"
  (( behind > 0 )) && printf " ${DIM}↓%d${RESET}" "$behind"
  printf " ${DIM}·${RESET} "
fi

if [[ -n "$model" ]]; then
  printf "${DIM}%s ·${RESET} " "$model${effort:+ ($effort)}"
fi
printf "${BOLD}${COLOR}%s${RESET} ${DIM}(%d%%)${RESET}" "$tokens_fmt" "$pct_int"
exit 0
