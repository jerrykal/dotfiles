#!/usr/bin/env bash
# Status line: <bold+colored tokens>(<dimmed percentage>)
# Color coding (Claude theme): green < 50%, yellow 50–80%, red > 80%

input=$(cat)

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
total_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')

# ANSI codes
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Claude theme palette (24-bit truecolor)
if (( $(echo "$used_pct >= 80" | bc -l) )); then
  COLOR='\033[38;2;191;77;67m'    # red    #BF4D43
elif (( $(echo "$used_pct >= 50" | bc -l) )); then
  COLOR='\033[38;2;214;165;74m'   # yellow #D6A54A
else
  COLOR='\033[38;2;111;176;127m'  # green  #6FB07F
fi

# Shorten token count: 142350 -> 142k, 1500000 -> 1.5M
if (( total_tokens >= 1000000 )); then
  tokens_fmt=$(printf "%.1fM" "$(echo "$total_tokens / 1000000" | bc -l)")
elif (( total_tokens >= 1000 )); then
  tokens_fmt="$(( total_tokens / 1000 ))k"
else
  tokens_fmt="$total_tokens"
fi

printf "${BOLD}${COLOR}%s${RESET} ${DIM}(%.1f%%)${RESET}" "$tokens_fmt" "$used_pct"
