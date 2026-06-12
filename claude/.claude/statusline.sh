#!/usr/bin/env bash
# Claude Code statusline script
# Input: JSON payload via stdin

input=$(cat)

# --- Model ID (left) ---
model_id=$(printf '%s' "$input" | jq -r '.model.id // empty')

# --- Context window % ---
ctx_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')

# --- Rate-limit % (5-hour window, omit if absent) ---
lim_pct=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')

# --- ANSI helpers (256-color) ---
gray='\033[38;5;240m'     # dark gray for labels
green='\033[38;5;71m'     # muted green  <=60%
yellow='\033[38;5;178m'   # amber        61-85%
red='\033[38;5;167m'      # muted red    >=86%
reset='\033[0m'

color_for_pct() {
  local pct
  pct=$(printf '%.0f' "$1" 2>/dev/null) || pct=0
  if   [ "$pct" -ge 86 ]; then printf '%s' "$red"
  elif [ "$pct" -ge 61 ]; then printf '%s' "$yellow"
  else                          printf '%s' "$green"
  fi
}

# --- Build right segment ---
right=""

if [ -n "$ctx_pct" ]; then
  ctx_int=$(printf '%.0f' "$ctx_pct")
  ctx_color=$(color_for_pct "$ctx_pct")
  right="${gray}ctx:${reset}${ctx_color}${ctx_int}%${reset}"
fi

if [ -n "$lim_pct" ]; then
  lim_int=$(printf '%.0f' "$lim_pct")
  lim_color=$(color_for_pct "$lim_pct")
  lim_seg="${gray}lim:${reset}${lim_color}${lim_int}%${reset}"
  if [ -n "$right" ]; then
    right="${right}  ${lim_seg}"
  else
    right="${lim_seg}"
  fi
fi

# --- Assemble line ---
# Use %b so backslash escapes (\033) are expanded but literal % (in
# percentages) and data are left untouched — never put data in the format.
if [ -n "$right" ]; then
  printf '%b\n' "${model_id}  ${right}"
else
  printf '%b\n' "${model_id}"
fi
