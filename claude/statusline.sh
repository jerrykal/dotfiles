#!/usr/bin/env bash
# Status line: <bold+colored tokens>(<dimmed percentage>)
# Color coding (Rosé Pine): foam < 50%, gold 50–80%, love > 80%

input=$(cat)

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
total_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
model=$(echo "$input" | jq -r '.model.display_name // ""')

# ANSI codes
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Rosé Pine palette (24-bit truecolor)
if (( $(echo "$used_pct >= 80" | bc -l) )); then
  COLOR='\033[38;2;235;111;146m'  # love #eb6f92
elif (( $(echo "$used_pct >= 50" | bc -l) )); then
  COLOR='\033[38;2;246;193;119m'  # gold #f6c177
else
  COLOR='\033[38;2;156;207;216m'  # foam #9ccfd8
fi

# Shorten token count: 142350 -> 142k, 1500000 -> 1.5M
if (( total_tokens >= 1000000 )); then
  tokens_fmt=$(printf "%.1fM" "$(echo "$total_tokens / 1000000" | bc -l)")
elif (( total_tokens >= 1000 )); then
  tokens_fmt="$(( total_tokens / 1000 ))k"
else
  tokens_fmt="$total_tokens"
fi

printf "${BOLD}${COLOR}%s${RESET} ${DIM}(%d%%)${RESET}" "$tokens_fmt" "$used_pct"
if [[ -n "$model" ]]; then
  printf " ${DIM}·${RESET} ${DIM}%s${RESET}" "$model"
fi
