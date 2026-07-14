# If not running interactively, don't do anything
[[ -o interactive ]] || return

# Ghostty quick terminal → global scratchpad (saves on focus lost)
if [[ -n "$GHOSTTY_QUICK_TERMINAL" ]] && command -v nvim >/dev/null 2>&1; then
  exec nvim \
    -c 'autocmd FocusLost * silent! update' \
    -c 'set laststatus=0 noruler' \
    ~/.scratchpad.md
fi

# Launch fish in interactive session
if [[ -z "$SKIP_FISH" ]] && command -v fish >/dev/null 2>&1; then
  exec fish
fi

# Initialize atuin
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi
