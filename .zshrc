# If not running interactively, don't do anything
[[ -o interactive ]] || return

# Launch fish in interactive session
if [[ -z "$SKIP_FISH" ]] && command -v fish >/dev/null 2>&1; then
  exec fish
fi
